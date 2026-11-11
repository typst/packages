// Functions that encode and decode XML.

#import "util.typ" as _util

#let _name-re = regex("^[\p{L}_:][\p{L}\p{N}_:.\-\x{B7}]*$")
#let _invalid-re = regex("[\x00-\x08\x0B\x0C\x0E-\x1F\x{FFFE}\x{FFFF}]")
#let _element-keys = ("tag", "attrs", "children", "namespace")

#let _check-chars(s, what) = {
  if s.contains(_invalid-re) {
    panic(what + " contains a character that is not allowed in XML: " + repr(s))
  }
  s
}

#let _check-name(name, what) = {
  if type(name) != str or name.match(_name-re) == none {
    panic(what + " is not a valid XML name: " + repr(name))
  }
  name
}

/// Escapes text for XML character data. The function changes `&`, `<` and
/// `>` to entity references.
///
/// ```examplec
/// xml.escape("Fish & <Chips>")
/// ```
///
/// -> str
#let escape(
  /// The text. -> str | content
  text,
) = {
  _check-chars(_util.to-text(text, field: "text"), "text")
    .replace("&", "&amp;")
    .replace("<", "&lt;")
    .replace(">", "&gt;")
}

#let _escape-attr(s) = {
  escape(s)
    .replace("\"", "&quot;")
    .replace("\t", "&#9;")
    .replace("\n", "&#10;")
    .replace("\r", "&#13;")
}

/// Makes an element node. The result is the same as the dictionary
/// `(tag: tag, attrs: attrs, children: children)`.
///
/// ```examplec
/// xml.element("a", attrs: (href: "/"), "Home")
/// ```
///
/// -> dictionary
#let element(
  /// The element name. It can have a namespace prefix, for example `"atom:link"`. -> str
  tag,
  /// The attributes. The function does not write attributes that are `none`. -> dictionary
  attrs: (:),
  /// The child nodes. -> str | content | dictionary | array | none
  ..children,
) = {
  if children.named().len() > 0 {
    panic(
      "unexpected named arguments "
        + repr(children.named().keys())
        + "; put attributes into `attrs`",
    )
  }
  (tag: tag, attrs: attrs, children: children.pos())
}

/// Makes a comment node. `xml.encode` writes it as `<!--body-->`.
///
/// ```examplec
/// xml.encode(
///   (tag: "p", children: (xml.comment(" draft "),)),
///   declaration: false,
/// )
/// ```
///
/// -> dictionary
#let comment(
  /// The comment text. It must not contain `--`, and it must not end with `-`. -> str
  body,
) = (comment: body)

/// Makes a CDATA section. `xml.encode` writes it as `<![CDATA[body]]>`. If the
/// text contains `]]>`, the function divides the text into two sections. Thus,
/// all text is safe.
///
/// ```examplec
/// xml.encode(
///   (tag: "script", children: (xml.cdata("if (a < b) go()"),)),
///   declaration: false,
/// )
/// ```
///
/// -> dictionary
#let cdata(
  /// The text. -> str
  body,
) = (cdata: body)

/// Makes a processing instruction. `xml.encode` writes it as `<?target data?>`.
///
/// ```examplec
/// xml.encode(
///   (xml.pi("xml-stylesheet", "href=\"style.xsl\""), (tag: "doc")),
///   declaration: false,
/// )
/// ```
///
/// -> dictionary
#let pi(
  /// The target, for example `"xml-stylesheet"`. -> str
  target,
  /// The data of the instruction. It must not contain `?>`. -> str | none
  data,
) = (pi: target, data: data)

/// Makes a node from markup that is already serialized. `xml.encode` writes
/// the markup without changes. Make sure that the markup is well-formed.
///
/// ```examplec
/// xml.encode(
///   (tag: "p", children: (xml.raw("<b>bold</b> &amp; raw"),)),
///   declaration: false,
/// )
/// ```
///
/// -> dictionary
#let raw(
  /// The markup. -> str
  body,
) = (raw: body)

// Returns the kind of a node: "text", "element", "comment", "cdata", "pi" or "raw".
#let _kind(node) = {
  let t = type(node)
  if t in (str, content, int, float, decimal, symbol) {
    return "text"
  }
  if t != dictionary {
    panic("not an XML node: " + repr(node) + " (expected a string or a dictionary)")
  }
  if "tag" in node {
    if node.tag == "" {
      panic(
        "element with an empty tag; Typst's `xml()` reader produces these for comments and "
          + "processing instructions, read files with `xml.decode` instead, which removes them",
      )
    }
    for key in node.keys() {
      if key not in _element-keys {
        panic(
          "unknown key `"
            + key
            + "` in element `"
            + str(node.tag)
            + "`; allowed are "
            + _element-keys.map(k => "`" + k + "`").join(", "),
        )
      }
    }
    return "element"
  }
  for kind in ("comment", "cdata", "pi", "raw") {
    if kind in node { return kind }
  }
  panic("not an XML node: " + repr(node) + " (dictionaries need a `tag` key)")
}

#let _render-leaf(node, kind) = {
  if kind == "text" {
    return escape(_util.to-text(node, field: "text node"))
  }
  if kind == "raw" {
    return _check-chars(_util.to-text(node.raw, field: "raw"), "raw markup")
  }
  if kind == "cdata" {
    let body = _check-chars(_util.to-text(node.cdata, field: "cdata"), "CDATA section")
    return "<![CDATA[" + body.replace("]]>", "]]]]><![CDATA[>") + "]]>"
  }
  if kind == "comment" {
    let body = _check-chars(_util.to-text(node.comment, field: "comment"), "comment")
    if body.contains("--") or body.ends-with("-") {
      panic("XML comments must not contain `--` or end with `-`: " + repr(body))
    }
    return "<!--" + body + "-->"
  }
  // Processing instruction
  let target = _check-name(node.pi, "processing instruction target")
  if lower(target) == "xml" {
    panic("use the `declaration` parameter of `xml.encode` for the XML declaration")
  }
  let data = _util.opt-text(node.at("data", default: none), field: "processing instruction")
  let data = if data == none { "" } else { _check-chars(data, "processing instruction") }
  if data.contains("?>") {
    panic("processing instructions must not contain `?>`: " + repr(data))
  }
  "<?" + target + (if data == "" { "" } else { " " + data }) + "?>"
}

// Returns the start tag without the `>` or `/>` at the end. Also returns the
// default namespace for the children of the element.
#let _start-tag(node, tag, default-ns) = {
  let attrs = node.at("attrs", default: (:))
  if type(attrs) != dictionary {
    panic("`attrs` of element `" + tag + "` must be a dictionary, found " + str(type(attrs)))
  }
  // A decoded element contains its namespace URI. Declare the URI as the
  // default namespace where it changes. Then the encoded document keeps the
  // namespaces of the decoded document.
  let ns = default-ns
  let parts = ()
  if "xmlns" in attrs {
    ns = attrs.xmlns
  } else if "namespace" in node and not tag.contains(":") and node.namespace != default-ns {
    ns = node.namespace
    parts.push(" xmlns=\"" + _escape-attr(if ns == none { "" } else { ns }) + "\"")
  }
  for (name, value) in attrs {
    if value == none { continue }
    let value = if type(value) == bool {
      if value { "true" } else { "false" }
    } else {
      _util.to-text(value, field: "attribute `" + name + "`")
    }
    parts.push(" " + _check-name(name, "attribute name") + "=\"" + _escape-attr(value) + "\"")
  }
  ("<" + tag + _util.concat(parts), ns)
}

// Serializes a node. The function uses a stack, not recursion. Thus, deep
// trees do not go above the call depth limit of Typst. The stack contains
// output strings and tasks `(node, depth, default-ns, pretty)`.
#let _render(root, pretty, pad) = {
  let out = ()
  let stack = ((root, 0, none, pretty),)
  // Typst stops a `while` loop after 10 000 iterations. Thus, do the work in batches.
  while stack.len() > 0 {
    for _ in range(4096) {
      if stack.len() == 0 { break }
      let task = stack.pop()
      if type(task) == str {
        out.push(task)
        continue
      }
      let (node, depth, default-ns, pretty) = task
      let kind = _kind(node)
      if kind != "element" {
        out.push(_render-leaf(node, kind))
        continue
      }
      let tag = _check-name(node.tag, "tag")
      let (open, ns) = _start-tag(node, tag, default-ns)
      let children = _util.flatten(node.at("children", default: ()))
      if children.len() == 0 {
        out.push(open + "/>")
        continue
      }
      out.push(open + ">")
      // Indent only elements that contain only elements. Whitespace adjacent to text changes the text.
      let mixed = children.any(c => _kind(c) in ("text", "cdata", "raw"))
      let tasks = ()
      if pretty and not mixed {
        let indent = "\n" + pad * (depth + 1)
        for child in children {
          tasks.push(indent)
          tasks.push((child, depth + 1, ns, true))
        }
        tasks.push("\n" + pad * depth + "</" + tag + ">")
      } else {
        for child in children {
          tasks.push((child, depth + 1, ns, false))
        }
        tasks.push("</" + tag + ">")
      }
      stack += tasks.rev()
    }
  }
  _util.concat(out)
}

/// Serializes a tree of nodes to an XML document.
///
/// An element is a dictionary `(tag: .., attrs: .., children: ..)`. You can
/// leave out `attrs` and `children`. Text is a string, a number or simple
/// content. The function escapes text automatically. It ignores children that
/// are `none` and flattens nested arrays. Thus, you can use `if` and
/// `.map(..)` in the list of children.
///
/// ```examplec
/// xml.encode(
///   (
///     tag: "book",
///     attrs: (id: "bk101", lang: none),
///     children: (
///       (tag: "title", children: ("XML & Typst",)),
///       (tag: "price", children: (44.95,)),
///     ),
///   ),
///   pretty: true,
/// )
/// ```
///
/// -> str
#let encode(
  /// The root element, or an array of top-level nodes. The array must contain
  /// one element. It can also contain comments and processing instructions.
  /// -> dictionary | array
  root,
  /// If `true`, the function indents elements that contain only elements. It
  /// does not change text. -> bool
  pretty: false,
  /// The indentation for each level if `pretty` is `true`. Use a number of
  /// spaces or a string, for example `"\t"`. -> int | str
  indent: 2,
  /// The XML declaration. Use `true` for `<?xml version="1.0" encoding="UTF-8"?>`,
  /// `false` for no declaration, or a string for a different declaration.
  /// -> bool | str
  declaration: true,
) = {
  // The reader returns whitespace between top-level nodes. This whitespace is not important.
  let nodes = _util.flatten(root).filter(n => not (type(n) == str and n.trim() == ""))
  let kinds = nodes.map(_kind)
  let elements = kinds.filter(k => k == "element").len()
  if elements != 1 {
    panic("an XML document needs exactly one root element, found " + str(elements))
  }
  if kinds.any(k => k not in ("element", "comment", "pi")) {
    panic("only comments and processing instructions may appear next to the root element")
  }
  let pad = if type(indent) == int { " " * indent } else { indent }
  let parts = ()
  if declaration == true {
    parts.push("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
  } else if type(declaration) == str {
    parts.push(declaration)
  }
  for node in nodes {
    parts.push(_render(node, pretty, pad))
  }
  if pretty { parts.join("\n") + "\n" } else { parts.join() }
}

// Makes the output of the reader again, without the placeholders that have
// an empty tag. The reader makes these placeholders for comments and
// processing instructions. The function uses a stack, as `_render` does. Each
// frame contains three items:
// - the element that the function makes again (`none` at the top level)
// - the children that are complete
// - the children that the function did not examine yet, in reverse order
#let _strip-placeholders(nodes) = {
  let stack = ((node: none, done: (), todo: nodes.rev()),)
  while true {
    for _ in range(4096) {
      if stack.at(-1).todo.len() == 0 {
        let frame = stack.pop()
        let finished = if frame.node == none { frame.done } else {
          frame.node + (children: frame.done)
        }
        if stack.len() == 0 { return finished }
        stack.at(-1).done.push(finished)
        continue
      }
      let child = stack.at(-1).todo.pop()
      if type(child) == dictionary and child.at("tag", default: none) == "" { continue }
      if type(child) == dictionary and "children" in child {
        stack.push((node: child, done: (), todo: child.children.rev()))
      } else {
        stack.at(-1).done.push(child)
      }
    }
  }
}

/// Parses XML into the node structure of `xml.encode`. The function uses the
/// XML reader of Typst.
///
/// The function returns each element as
/// `(namespace: .., tag: .., attrs: .., children: ..)`. The `namespace` is the
/// namespace URI of the element. `xml.encode` changes it back to `xmlns`
/// declarations. The reader removes comments, processing instructions and
/// namespace prefixes.
///
/// ```examplec
/// xml.decode("<p>Hello <b>world</b></p>")
/// ```
///
/// -> array
#let decode(
  /// The XML as a string or bytes, or a `path(..)` to a file. For a file, use
  /// `path`, not only the file name. Then Typst finds the file relative to your
  /// document, not relative to this package. -> str | bytes | path
  source,
) = {
  let data = if type(source) == str { bytes(source) } else { source }
  _strip-placeholders(std.xml(data))
}
