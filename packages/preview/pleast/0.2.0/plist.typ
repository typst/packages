#import "utils.typ": *

/// Parse a plist xml file
///
/// Default datetime parser *ONLY* support RFC 3339 format datetime, *NOT* ISO 8601!
///
/// - xml-raw (bytes): xml format bytes
/// - datetime-parser (function): parser of datetime
/// -> dictionary
#let plist(xml-raw, datetime-parser: parse-rfc3339) = {
  assert.eq(type(xml-raw), bytes, message: "`xml-raw` must be bytes")
  let data = xml(xml-raw).at(0)
  assert.eq(data.tag, "plist", message: "failed to parse plist (not a plist)")

  let get-children(node) = {
    assert.eq(type(node), dictionary, message: "node must be a dictionary")
    node.children.filter(x => {
      type(x) != str or x.trim() != ""
    })
  }

  let parse(node) = {
    let valid-types = (
      "dict",
      "array",
      "date",
      "string",
      "integer",
      "real",
      "true",
      "false",
      "data",
    )
    let type = node.tag
    assert(valid-types.contains(type), message: "invalid type: " + type)

    if type == "dict" {
      let children = get-children(node)
      let dict = (:)
      let index = 0
      while index < children.len() {
        assert.eq(children.at(index).tag, "key", message: "failed to parse plist (dict has mismatched key-value pair)")
        let key = get-children(children.at(index)).at(0)
        let value = parse(children.at(index + 1))
        dict.insert(key, value)
        index = index + 2
      }
      return dict
    } else if type == "array" {
      let children = get-children(node)
      return children.map(parse)
    } else if type == "date" {
      let children = get-children(node)
      return parse-rfc3339(children.at(0))
    } else if type == "string" {
      let children = get-children(node)
      if children.len() == 0 { return "" }
      return children.at(0)
    } else if type == "integer" {
      let children = get-children(node)
      return int(children.at(0))
    } else if type == "real" {
      let children = get-children(node)
      return float(children.at(0))
    } else if type == "true" {
      return true
    } else if type == "false" {
      return false
    } else if type == "data" {
      let children = get-children(node)
      let data = children.at(0).trim()
      return data
    }
  }

  parse(get-children(data).at(0))
}
