// xml-to-string: serialize XML node trees to an XML string -- both trees
// authored with xmlit tag functions and the output of Typst's built-in
// `xml()` reader (faithfully reversed).

#import "../elem/elem.typ": convert

/// Escape a string for use as XML text content (`&`, `<`, `>`).
/// `&` must be replaced first so already-escaped entities are not double-escaped.
#let esc-text(s) = {
  s.replace("&", "&amp;")
   .replace("<", "&lt;")
   .replace(">", "&gt;")
}

/// Escape a string for use inside a double-quoted attribute value
/// (`&`, `<`, `"`).
#let esc-attr(s) = {
  s.replace("&", "&amp;")
   .replace("<", "&lt;")
   .replace("\"", "&quot;")
}

/// Faithfully serialize the output of Typst's built-in `xml()` reader back to
/// an XML string.
///
/// `xml()` yields text nodes as plain strings (with entities already decoded)
/// and element nodes as dictionaries with `namespace`, `tag`, `attrs`, and
/// `children` keys. This function reverses that:
///
/// - Text nodes are re-escaped for text context.
/// - Attribute values are re-escaped for attribute context; attribute order is
///   preserved.
/// - Namespaces are emitted as default `xmlns="..."` declarations, but only
///   when an element's resolved namespace URI differs from the one it inherits
///   from its parent (mirroring how `xml()` repeats the URI on every
///   descendant). Original prefixes and attribute namespaces are not
///   recoverable from `xml()` output and are not reconstructed.
/// - Elements with no children are written self-closing (`<tag ... />`).
/// - Comment and processing-instruction nodes (which `xml()` collapses to an
///   empty-tag sentinel with `tag == ""` and no recoverable content) are
///   skipped.
///
/// Accepts a single node, an array of nodes (as returned directly by
/// `xml("file.xml")`), or content -- e.g. the direct return value of an xmlit
/// tag function, or a markup block, normalized via `convert` (`handlers:` is
/// forwarded to it).
///
/// Example:
///   #xml-to-string(xml("doc.xml"))
///   #xml-to-string(foo(bar(baz: "zz")))
#let xml-to-string(node, inherited-ns: none, handlers: auto) = {
  // Authored content (metadata-wrapped nodes, markup, ...): normalize first.
  if type(node) == content {
    node = convert(node, handlers: handlers)
  }

  // Top-level array (e.g. the direct return of `xml(...)`).
  if type(node) == array {
    let s = node.map(n => xml-to-string(n, inherited-ns: inherited-ns, handlers: handlers)).join("")
    return if s == none { "" } else { s }
  }

  if type(node) == str {
    return esc-text(node)
  }

  let tag = node.at("tag", default: "")
  // Comment / processing-instruction sentinel: content is lost, so skip it.
  if tag == "" {
    return ""
  }

  let ns = node.at("namespace", default: none)
  let attrs = node.at("attrs", default: (:))
  let children = node.at("children", default: ())

  let attrs-str = attrs.pairs().map(((k, v)) => {
    let vs = if type(v) == str { v } else if type(v) == bool { repr(v) } else { str(v) }
    " " + k + "=\"" + esc-attr(vs) + "\""
  }).join("")

  // Declare a default namespace only when it changes relative to the parent.
  let ns-str = if ns != inherited-ns {
    " xmlns=\"" + esc-attr(if ns == none { "" } else { ns }) + "\""
  } else {
    ""
  }

  let open = "<" + tag + ns-str + attrs-str

  if children.len() == 0 {
    open + " />"
  } else {
    let inner = children.map(c => {
      xml-to-string(c, inherited-ns: ns, handlers: handlers)
    }).join("")
    open + ">" + inner + "</" + tag + ">"
  }
}
