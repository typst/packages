// elem: author XML trees with Typst syntax.
//
// Tag functions created by `make-tag` return their node wrapped in
// `metadata(...)` content. Because content joins cleanly with content and
// strings, all three call styles work and can be mixed:
//
//   #let (foo, bar) = make-tags("foo", "bar")
//   #foo(bar(baz: "zz"), "text")            // positional
//   #foo({ bar(baz: "zz"); "text" })        // code block (content joins)
//   #foo[#bar(baz: "zz") text $x^2$]        // markup block
//
// The node model is the same one Typst's `xml()` reader uses: an element is a
// dictionary with `tag`, `attrs`, and `children`; a text node is a string.

/// Built-in handlers that map Typst content elements to XML nodes.
///
/// Keys are content-function names (as produced by `repr(c.func())`), plus the
/// special `"math"` slot used to serialize equation bodies. Each handler is
/// called as `handler(element, ctx)` where `ctx` is a dictionary with:
///
/// - `convert`: function converting any child value to an array of nodes
/// - `handlers`: the merged handler table (built-ins + user overrides)
///
/// and must return an array of nodes (element dictionaries and/or strings).
/// Override or extend any of these by passing `handlers: (...)` to `make-tag`
/// or `make-tags`.
#let default-handlers = (
  "sequence": (c, ctx) => c.children.map(ch => (ctx.convert)(ch)).flatten(),
  "text": (c, ctx) => (c.text,),
  "space": (c, ctx) => (" ",),
  "linebreak": (c, ctx) => ("\n",),
  "parbreak": (c, ctx) => ("\n\n",),
  "smartquote": (c, ctx) => {
    let double = c.fields().at("double", default: true)
    (if double { "\"" } else { "'" },)
  },
  // A show/set rule inside a body wraps the rest in `styled`; recurse into the
  // wrapped child (the style information itself has no XML representation).
  "styled": (c, ctx) => (ctx.convert)(c.fields().child),
  // Nodes authored by xmlit tag functions travel through markup as metadata.
  "metadata": (c, ctx) => {
    let v = c.value
    if type(v) == dictionary and "tag" in v {
      (v,)
    } else {
      panic("xmlit: metadata content does not carry an XML node: " + repr(v))
    }
  },
  // Default markup mappings (in the spirit of Typst's HTML export). Override
  // via `handlers:` to emit different tags.
  "strong": (c, ctx) => ((tag: "b", attrs: (:), children: (ctx.convert)(c.body)),),
  "emph": (c, ctx) => ((tag: "em", attrs: (:), children: (ctx.convert)(c.body)),),
  "raw": (c, ctx) => {
    let f = c.fields()
    // A plain code value (e.g. a bare dictionary) interpolated into markup
    // displays as inline raw with lang "typc" -- almost certainly a mistake.
    if f.at("lang", default: none) == "typc" {
      panic(
        "xmlit: a plain code value was interpolated into markup: `" + f.text
          + "`. Tag functions already return content; did you interpolate a "
          + "bare dictionary?",
      )
    }
    let tag = if f.at("block", default: false) { "pre" } else { "c" }
    ((tag: tag, attrs: (:), children: (f.text,)),)
  },
  // $...$ -> <m>, $ ... $ -> <md>. The body is serialized by the "math" slot.
  "equation": (c, ctx) => {
    let f = c.fields()
    let tag = if f.block { "md" } else { "m" }
    let math-handler = ctx.handlers.at("math")
    ((tag: tag, attrs: (:), children: math-handler(f.body, ctx)),)
  },
  // Special slot (not a content-function name): serializes the *body* of an
  // equation into child nodes. The default is an opaque, best-effort
  // placeholder (`repr` of the math AST) and is NOT a stable format; replace
  // it via `handlers: ("math": (body, ctx) => (...))`.
  "math": (body, ctx) => (repr(body),),
)

/// Convert any child value into an array of XML nodes.
///
/// Accepts: strings (text nodes), element dictionaries, arrays of either,
/// numbers/booleans (stringified), `none` (dropped), and content (walked
/// using the handler table -- see `default-handlers`).
#let convert(value, handlers: auto) = {
  if type(value) == str { return (value,) }
  if value == none { return () }
  if type(value) == int or type(value) == float {
    return (str(value),)
  }
  if type(value) == bool {
    return (repr(value),)
  }
  if type(value) == array {
    return value.map(v => convert(v, handlers: handlers)).flatten()
  }
  if type(value) == dictionary {
    if "tag" in value { return (value,) }
    panic("xmlit: expected an element dictionary with a `tag` key, found: " + repr(value))
  }
  if type(value) == content {
    let merged = if handlers == auto {
      default-handlers
    } else {
      default-handlers + handlers
    }
    let name = repr(value.func())
    let handler = merged.at(name, default: none)
    if handler == none {
      panic(
        "xmlit: no handler for content element `" + name + "`. "
          + "Pass `handlers: (\"" + name + "\": (elem, ctx) => ..)` to make-tag "
          + "to map it to XML.",
      )
    }
    let ctx = (convert: v => convert(v, handlers: handlers), handlers: merged)
    return handler(value, ctx)
  }
  panic("xmlit: cannot convert value of type " + repr(type(value)) + " to XML: " + repr(value))
}

/// Convert a content block to an array of XML nodes (exported alias of
/// `convert` for content input).
#let content-to-children(c, handlers: auto) = convert(c, handlers: handlers)

/// True for text nodes that consist entirely of whitespace.
#let is-whitespace(v) = type(v) == str and v.trim() == ""

/// Drop whitespace-only text nodes from the edges of a children array.
/// Applied to content-block bodies so that `#foo[ text ]` == `#foo("text")`.
#let trim-ws(children) = {
  let out = children
  while out.len() > 0 and is-whitespace(out.first()) { out = out.slice(1) }
  while out.len() > 0 and is-whitespace(out.last()) { out = out.slice(0, out.len() - 1) }
  out
}

/// Create a function that produces an XML element with the given tag name.
/// Named arguments become XML attributes; positional arguments become
/// children (strings, other tag calls, arrays, or arbitrary content --
/// including trailing `[...]` bodies).
///
/// The returned function yields the node wrapped in `metadata(...)` content,
/// so tag calls can be freely embedded in markup and joined in code blocks.
///
/// `handlers` extends/overrides `default-handlers` for content conversion.
///
/// Example:
///   #let foo = make-tag("foo")
///   #let bar = make-tag("bar")
///   #foo[#bar(baz: "zz") some text]
///   // => <foo><bar baz="zz" />some text</foo>
#let make-tag(tag, handlers: auto) = (..args) => {
  let children = args.pos().map(a => {
    let nodes = convert(a, handlers: handlers)
    // Trim insignificant edge whitespace of `[...]` bodies, but keep
    // explicitly passed strings verbatim.
    if type(a) == content { trim-ws(nodes) } else { nodes }
  }).flatten()
  metadata((tag: tag, attrs: args.named(), children: children))
}

/// Generic one-off element constructor (compare `html.elem`):
///   #elem("foo", elem("bar", baz: "zz"))
#let elem(tag, ..args) = make-tag(tag)(..args)

/// Create several tag functions at once (destructurable):
///   #let (foo, bar) = make-tags("foo", "bar")
/// A `handlers:` named argument is forwarded to every created tag.
#let make-tags(..names) = {
  let handlers = names.named().at("handlers", default: auto)
  names.pos().map(n => make-tag(n, handlers: handlers))
}
