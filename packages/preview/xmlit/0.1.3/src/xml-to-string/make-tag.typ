// to-xml: serialize plain node dictionaries (no namespace handling). The
// element-authoring API (`make-tag`, `elem`, ...) lives in ../elem/elem.typ.

/// Escape special XML characters in a string value.
#let xml-escape(s) = {
  s.replace("&", "&amp;")
   .replace("<", "&lt;")
   .replace(">", "&gt;")
   .replace("\"", "&quot;")
   .replace("'", "&apos;")
}

/// Serialize a single XML node (dictionary with `tag`, `attrs`, `children`)
/// or a plain string to an XML string.
#let to-xml(node) = {
  if type(node) == str {
    return xml-escape(node)
  }

  let tag = node.tag
  let attrs = node.at("attrs", default: (:))
  let children = node.at("children", default: ())

  // Build attribute string
  let attrs-str = attrs.pairs().map(((k, v)) => {
    let vs = if type(v) == str { v } else if type(v) == bool { repr(v) } else { str(v) }
    " " + k + "=\"" + xml-escape(vs) + "\""
  }).join("")

  // Serialize children
  let inner = children.map(to-xml).join("")

  if inner == "" {
    "<" + tag + attrs-str + " />"
  } else {
    "<" + tag + attrs-str + ">" + inner + "</" + tag + ">"
  }
}
