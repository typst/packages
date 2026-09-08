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
   .replace("\"", "&quot;")
   .replace("<", "&lt;")
}

// One level of pretty-print indentation.
#let _indent-unit = "  "

// Core serializer. Returns `(text: str, math: dict, ranges: array)`. When
// `extract` is true, a node carrying the reserved `math` key (an equation
// element, as produced by the built-in `equation` handler) is emitted with a
// text sentinel in place of its serialized children, and the equation content
// is collected into `math` under a sequential document-order id.
//
// When `pretty` is true, an element whose children are all elements (no text
// nodes) has each child placed on its own line, indented by `depth` levels.
// Elements with any text child (mixed content) stay inline, so significant
// whitespace is never introduced.
//
// When `record` is true, `ranges` collects one `(path, start, end)` entry per
// element node, where `path` is the sequence of child indices from the root
// and `start`/`end` are byte offsets of the element's serialized text within
// the returned `text` (byte offsets so they line up with the plugin's error
// positions and Typst's byte-indexed `str.len`/`str.slice`). Otherwise
// `ranges` is empty and the bookkeeping is skipped.
#let _serialize(node, inherited-ns, handlers, extract, pretty, depth, math, path, record) = {
  // Authored content (metadata-wrapped nodes, markup, ...): normalize first.
  if type(node) == content {
    node = convert(node, handlers: handlers)
  }

  // Array of nodes (e.g. the direct return of `xml(...)`).
  if type(node) == array {
    let text = ""
    let ranges = ()
    let off = 0
    let i = 0
    for n in node {
      let r = _serialize(n, inherited-ns, handlers, extract, pretty, depth, math, path + (i,), record)
      if record {
        for rg in r.ranges { ranges.push((path: rg.path, start: rg.start + off, end: rg.end + off)) }
      }
      text += r.text
      off += r.text.len()
      math = r.math
      i += 1
    }
    return (text: text, math: math, ranges: ranges)
  }

  if type(node) == str {
    return (text: esc-text(node), math: math, ranges: ())
  }

  let tag = node.at("tag", default: "")
  // Comment / processing-instruction sentinel: content is lost, so skip it.
  if tag == "" {
    return (text: "", math: math, ranges: ())
  }

  let ns = node.at("namespace", default: none)
  let attrs = node.at("attrs", default: (:))
  let children = node.at("children", default: ())

  let attrs-str = attrs.pairs().map(((k, v)) => {
    let vs = if type(v) == str { v } else if type(v) == bool { repr(v) } else { str(v) }
    " " + k + "=\"" + esc-attr(vs) + "\""
  }).join("")
  if attrs-str == none { attrs-str = "" }

  // Declare a default namespace only when it changes relative to the parent.
  let ns-str = if ns != inherited-ns {
    " xmlns=\"" + esc-attr(if ns == none { "" } else { ns }) + "\""
  } else {
    ""
  }

  let open = "<" + tag + ns-str + attrs-str

  // Range covering this element's whole serialized text (added once the text
  // length is known); descendants' ranges are shifted into this frame.
  let self-range(text, ranges) = if record {
    (((path: path, start: 0, end: text.len()),) + ranges)
  } else { () }

  // Math extraction: replace the (string-serialized) children with a
  // sentinel and collect the actual equation content under a fresh id.
  if extract and "math" in node {
    let id = "math-" + str(math.len())
    math.insert(id, node.math)
    let text = open + ">⟦" + id + "⟧</" + tag + ">"
    return (text: text, math: math, ranges: self-range(text, ()))
  }

  if children.len() == 0 {
    let text = open + " />"
    return (text: text, math: math, ranges: self-range(text, ()))
  }

  // Pretty-print only when every child is an element node: reformatting
  // mixed content (any text child) would inject significant whitespace.
  let element-only = pretty and children.all(c =>
    type(c) == dictionary and c.at("tag", default: "") != "")

  let opengt = open + ">"
  let inner = ""
  let ranges = ()
  let off = opengt.len()
  let i = 0
  if element-only {
    let child-indent = _indent-unit * (depth + 1)
    for c in children {
      let r = _serialize(c, ns, handlers, extract, pretty, depth + 1, math, path + (i,), record)
      let prefix = "\n" + child-indent
      off += prefix.len()
      if record {
        for rg in r.ranges { ranges.push((path: rg.path, start: rg.start + off, end: rg.end + off)) }
      }
      inner += prefix + r.text
      off += r.text.len()
      math = r.math
      i += 1
    }
    let text = opengt + inner + "\n" + _indent-unit * depth + "</" + tag + ">"
    (text: text, math: math, ranges: self-range(text, ranges))
  } else {
    for c in children {
      let r = _serialize(c, ns, handlers, extract, pretty, depth, math, path + (i,), record)
      if record {
        for rg in r.ranges { ranges.push((path: rg.path, start: rg.start + off, end: rg.end + off)) }
      }
      inner += r.text
      off += r.text.len()
      math = r.math
      i += 1
    }
    let text = opengt + inner + "</" + tag + ">"
    (text: text, math: math, ranges: self-range(text, ranges))
  }
}

/// Serialize XML nodes to an XML string; also faithfully reverses the output
/// of Typst's built-in `xml()` reader.
///
/// For `xml()` reader output:
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
/// With `extract-math: true`, returns a dictionary `(xml: str, math-items:
/// dictionary)` instead of a plain string: `xml` is the XML string with each
/// equation's content replaced by a text sentinel `⟦math-N⟧`, and
/// `math-items` maps each id ("math-0", "math-1", ... in document order) to
/// the actual Typst equation content -- ready to be rendered or `measure()`d.
/// Equation nodes are recognized by the reserved `math` key that the built-in
/// `equation` handler stores on them.
///
/// With `pretty-print: true`, elements whose children are all elements (no
/// text nodes) are indented with each child on its own line. Elements with
/// any text child (mixed content) stay inline, so no significant whitespace
/// is introduced. Note that pretty-printed output is not byte-faithful to
/// `xml()` reader input -- it is for human reading, not round-tripping.
///
/// Example:
///   #xml-to-string(xml("doc.xml"))
///   #xml-to-string(foo(bar(baz: "zz")))
///   #xml-to-string(foo(bar(baz: "zz")), pretty-print: true)
///   #let (xml, math-items) = xml-to-string(doc, extract-math: true)
///   #context math-items.pairs().map(((id, eq)) => (id, measure(eq)))
#let xml-to-string(
  node,
  inherited-ns: none,
  handlers: auto,
  extract-math: false,
  pretty-print: false,
) = {
  let r = _serialize(node, inherited-ns, handlers, extract-math, pretty-print, 0, (:), (), false)
  if extract-math {
    (xml: r.text, math-items: r.math)
  } else {
    r.text
  }
}

/// Like `xml-to-string`, but also returns per-element source ranges. Returns
/// `(xml: str, ranges: array)` where each `ranges` entry is
/// `(path: (int,), start: int, end: int)`: `path` is the element's sequence of
/// child indices from the root and `start`/`end` are byte offsets of its
/// serialized text within `xml`.
///
/// Used to map a validator's byte-offset error position back to the specific
/// element that produced it (see `create-from-relaxng`'s
/// `render-and-show-validation-errors`). Serialize compact (the default) to
/// locate against a validator's positions; serialize with `pretty-print: true`
/// to find the same element's line in a human-readable rendering (the `path`
/// is stable across both).
#let xml-to-string-with-ranges(
  node,
  inherited-ns: none,
  handlers: auto,
  pretty-print: false,
) = {
  let r = _serialize(node, inherited-ns, handlers, false, pretty-print, 0, (:), (), true)
  (xml: r.text, ranges: r.ranges)
}
