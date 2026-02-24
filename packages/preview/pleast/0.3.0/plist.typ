#import "utils.typ": *

#let valid-types = (
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

#let default-parsers = (
  date: parse-rfc3339,
  integer: int,
  real: float,
  data: it => it
)

/// Parse a bytes of Property List (plist) file into a dictionary.
///
/// Default `date` parser *ONLY* support RFC 3339 format datetime, *NOT* ISO 8601!
///
/// - xml-raw (bytes): xml format bytes
/// - parsers (dictionary): custom parsers for plist types,
///   *ONLY* accept `date`, `integer`, `real`, and `data` types
/// -> dictionary
#let plist(xml-raw, parsers: (:)) = {
  // Parameter validation
  assert.eq(type(xml-raw), bytes, message: "`xml-raw` must be bytes")
  assert.eq(type(parsers), dictionary, message: "`parsers` must be a dictionary")

  // Parser merge
  parsers = default-parsers + parsers
  assert.eq(parsers.keys().sorted(), default-parsers.keys().sorted(), message: "invalid parsers")

  // Validate xml
  let data = xml(xml-raw).at(0)
  assert.eq(data.tag, "plist", message: "failed to parse plist (not a plist)")

  let get-children(node) = {
    assert.eq(type(node), dictionary, message: "node must be a dictionary")
    node.children.filter(x => {
      type(x) != str or x.trim() != ""
    })
  }

  let get-parser(t) = {
    assert(default-parsers.keys().contains(t), message: "invalid type: " + t)
    parsers.at(t)
  }

  let parse(node) = {
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
      return get-parser("date")(children.at(0))
    } else if type == "string" {
      let children = get-children(node)
      if children.len() == 0 { return "" }
      return children.at(0)
    } else if type == "integer" {
      let children = get-children(node)
      return get-parser("integer")(children.at(0))
    } else if type == "real" {
      let children = get-children(node)
      return get-parser("real")(children.at(0))
    } else if type == "true" {
      return true
    } else if type == "false" {
      return false
    } else if type == "data" {
      let children = get-children(node)
      let data = children.at(0).trim()
      return get-parser("data")(data)
    }
  }

  parse(get-children(data).at(0))
}
