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

// Math constructs whose AST cannot be reconstructed node-by-node, matched
// wholesale by comparing against the parsed form of their source. `dif`, for
// example, expands to `sequence(h(..), class(.., styled(..)))`, none of which
// can be re-created by evaluating serialized output -- but the whole node
// compares equal to `$dif$.body`, so it serializes back to "dif".
#let _special-math-forms = (
  ("dif", repr($dif$.body)),
)

/// Serialize equation (body) content to a Typst math source string:
/// $x^2$ -> "x^2", $1/2$ -> "1/2", $sqrt(x+1)$ -> "sqrt(x+1)". Symbols
/// appear as their Unicode characters (e.g. "∫" for `integral`).
///
/// For supported constructs the output round-trips: evaluating it as math
/// (e.g. `eval("$" + s + "$")`) reproduces exactly the original expression
/// (the property is enforced by the unit tests). Constructs without a
/// faithful serialization (matrices, cases, alignment points, ...) fall back
/// to their `repr`, which is visible in the output but is NOT valid math
/// source -- override the `"math"` handler to serialize those yourself.
#let math-to-string(c) = {
  if type(c) == str { return c }
  if type(c) != content { return repr(c) }
  for (source, form) in _special-math-forms {
    if repr(c) == form { return source }
  }
  let join-all(parts) = {
    let s = parts.join("")
    if s == none { "" } else { s }
  }
  // Parenthesize a sub-expression unless it is atomic: a single grapheme
  // (letters and symbols), a number (single tokens in Typst math), a quoted
  // string, or already parenthesized.
  let group(s) = {
    if s.clusters().len() <= 1 { return s }
    if s.match(regex("^[0-9]+(\\.[0-9]+)?$")) != none { return s }
    if s.starts-with("\"") and s.ends-with("\"") { return s }
    if s.starts-with("(") and s.ends-with(")") { return s }
    "(" + s + ")"
  }
  let name = repr(c.func())
  // Letters and symbols (x, π, ∫) are `symbol` elements: single characters
  // that re-evaluate to themselves.
  if name == "symbol" {
    c.text
  } else if name == "text" {
    // Digit runs / decimals and single characters (operators like "+", ",")
    // re-evaluate to the same `text` node; longer runs would re-parse as
    // per-letter symbols, so they are emitted as quoted strings.
    let t = c.text
    if t.clusters().len() <= 1 or t.match(regex("^[0-9]+(\\.[0-9]+)?$")) != none {
      t
    } else {
      "\"" + t.replace("\\", "\\\\").replace("\"", "\\\"") + "\""
    }
  } else if name == "space" {
    " "
  } else if name == "sequence" {
    join-all(c.children.map(math-to-string))
  } else if name == "equation" {
    math-to-string(c.fields().body)
  } else if name == "lr" {
    // Parentheses re-create the lr group when re-parsed; other delimiter
    // pairs (|x|, [x], ...) need the explicit lr(...) form.
    let inner = math-to-string(c.fields().body)
    if inner.starts-with("(") and inner.ends-with(")") {
      inner
    } else {
      "lr(" + inner + ")"
    }
  } else if name == "op" {
    // Named operators (lim, sin, max, ...) re-parse to the identical op node.
    c.fields().text.text
  } else if name == "primes" {
    join-all(range(c.fields().count).map(_ => "'"))
  } else if name == "frac" {
    let f = c.fields()
    group(math-to-string(f.num)) + "/" + group(math-to-string(f.denom))
  } else if name == "root" {
    let f = c.fields()
    let index = f.at("index", default: none)
    if index == none {
      "sqrt(" + math-to-string(f.radicand) + ")"
    } else {
      "root(" + math-to-string(index) + ", " + math-to-string(f.radicand) + ")"
    }
  } else if name == "attach" {
    let f = c.fields()
    let s = math-to-string(f.base)
    // Primes attach top-right without an operator: $x'$ -> "x'".
    let tr = f.at("tr", default: none)
    if tr != none { s += math-to-string(tr) }
    let b = f.at("b", default: none)
    if b != none { s += "_" + group(math-to-string(b)) }
    let t = f.at("t", default: none)
    if t != none { s += "^" + group(math-to-string(t)) }
    s
  } else {
    // No faithful serialization known: degrade to repr (visible, but not
    // valid math source). Override the "math" handler for full control.
    repr(c)
  }
}

/// Built-in handlers that map Typst content elements to XML nodes.
///
/// Keys are content-function names (as produced by `repr(c.func())`), plus the
/// special `"math"` slot used to serialize equation bodies. Each handler is
/// called as `handler(element, convert, ctx)` where:
///
/// - `convert`: function converting any child value to an array of nodes
///   (using the same merged handler table); use it to process bodies:
///     "strong": (c, convert, ctx) => ((tag: "b", attrs: (:), children: convert(c.body)),)
/// - `ctx`: a dictionary for handlers that delegate to another slot, with:
///   - `handlers`: the merged handler table (built-ins + user overrides);
///     see the built-in `equation` handler, which dispatches to `"math"`
///
/// and must return either an array of nodes (element dictionaries and/or
/// strings) or a single such node (a bare element dictionary or string), which
/// is normalized to a one-element array. Override or extend any of these by
/// passing `handlers: (...)` to `make-tag` or `make-tags`.
#let default-handlers = (
  "sequence": (c, convert, ctx) => c.children.map(convert).flatten(),
  "text": (c, convert, ctx) => (c.text,),
  "space": (c, convert, ctx) => (" ",),
  "linebreak": (c, convert, ctx) => ("\n",),
  "parbreak": (c, convert, ctx) => ("\n\n",),
  "smartquote": (c, convert, ctx) => {
    let double = c.fields().at("double", default: true)
    (if double { "\"" } else { "'" },)
  },
  // A show/set rule inside a body wraps the rest in `styled`; recurse into the
  // wrapped child (the style information itself has no XML representation).
  "styled": (c, convert, ctx) => convert(c.fields().child),
  // Nodes authored by xmlit tag functions travel through markup as metadata.
  "metadata": (c, convert, ctx) => {
    let v = c.value
    if type(v) == dictionary and "tag" in v {
      (v,)
    } else {
      panic("xmlit: metadata content does not carry an XML node: " + repr(v))
    }
  },
  // Default markup mappings (in the spirit of Typst's HTML export). Override
  // via `handlers:` to emit different tags.
  "strong": (c, convert, ctx) => ((tag: "b", attrs: (:), children: convert(c.body)),),
  "emph": (c, convert, ctx) => ((tag: "em", attrs: (:), children: convert(c.body)),),
  "raw": (c, convert, ctx) => {
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
  // $...$ -> <m>, $ ... $ -> <md>. The children (string form) are produced
  // by the "math" slot; the node additionally keeps the actual equation
  // content under the reserved `math` key, so `xml-to-string(...,
  // extract-math: true)` can hand it back for rendering/measuring.
  "equation": (c, convert, ctx) => {
    let f = c.fields()
    let tag = if f.block { "md" } else { "m" }
    let math-handler = ctx.handlers.at("math")
    ((tag: tag, attrs: (:), children: math-handler(f.body, convert, ctx), math: c),)
  },
  // Special slot (not a content-function name): serializes the *body* of an
  // equation into child nodes. Unlike the others, it receives the equation's
  // BODY content, not the equation element. The default emits a best-effort
  // Typst-flavored linear string (see `math-to-string`); replace it via
  // `handlers: ("math": (body, convert, ctx) => (...))`.
  "math": (body, convert, ctx) => (math-to-string(body),),
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
          + "Pass `handlers: (\"" + name + "\": (elem, convert, ctx) => ..)` to "
          + "make-tag to map it to XML.",
      )
    }
    let convert-child = v => convert(v, handlers: handlers)
    let ctx = (handlers: merged)
    let result = handler(value, convert-child, ctx)
    // A handler may return a single node (a bare element dictionary or a
    // string) instead of a one-element array; normalize any non-array return
    // back through `convert` (arrays take the fast path unchanged).
    return if type(result) == array { result } else { convert(result, handlers: handlers) }
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
