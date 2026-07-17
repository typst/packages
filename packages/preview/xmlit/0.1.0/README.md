# typst-xmlit

Tools for generating, validating, and outputting XML using Typst syntax.

## Authoring XML

Create functions which return XML elements with `make-tag`/`make-tags`.
Use the resulting functions using standard typst syntax.

```typst
#import "@preview/xmlit:0.1.0": make-tags, xml-to-string

#{
  let (foo, bar) = make-tags("foo", "bar")
  
}

// Positional
#xml-to-string(foo(bar(baz: "zz"), "text"))

// Code block
#xml-to-string(foo({
  bar(baz: "zz")
  "text"
}))

// Markup body
#xml-to-string(foo[#bar(baz: "zz")text])

// All three => <foo><bar baz="zz" />text</foo>
```

Named arguments become attributes; positional arguments (strings, other tag
calls, arrays, numbers, or content) become children. `elem("foo", ...)` is a
generic one-off constructor in the spirit of `html.elem`.

### Markup in bodies

Inside a `[...]` body, ordinary Typst markup is mapped to XML by a built-in
handler table (in the spirit of Typst's HTML export): `*bold*` → `<b>`,
`_emph_` → `<em>`, `` `code` `` → `<c>`/`<pre>`, smart quotes → plain quote
characters. Inline math `$x^2$` becomes `<m>…</m>` and display math
`$ ... $` becomes `<md>…</md>`.

Every mapping is configurable per tag factory:

```typst
#let p = make-tag("p", handlers: (
  // strong -> <alert> instead of <b>
  "strong": (c, ctx) => ((tag: "alert", attrs: (:), children: (ctx.convert)(c.body)),),
  // serialize equation bodies yourself (the default payload is an
  // unstable placeholder)
  "math": (body, ctx) => ("...",),
))
#p[A *very important* point about $x^2$.]
```

Unmapped markup (e.g. headings) raises an error naming the element and the
`handlers:` entry that would map it.

## Typechecked authoring from a RELAX NG grammar

`create-from-relaxng` derives tag functions from a RELAX NG grammar (compact
syntax, `.rnc`) and validates the composed document — via a bundled WASM
plugin (see [plugin/](https://github.com/siefkenj/typst-xmlit/blob/0.1.0/plugin/README.md)):

```typst
#import "@preview/xmlit:0.1.0": create-from-relaxng

#let (root, foo, bar) = create-from-relaxng(
  "start = element foo { element bar { attribute baz { text } }* }",
)

#show: root

#foo[#bar(baz: "xx")]
```

The returned dictionary has one tag function per element defined in the
grammar, plus:

- `root` — a template (`#show: root`) that serializes its body, validates it
  against the grammar, and renders the XML source. Invalid documents fail
  compilation with a readable panic, e.g.:

  ```
  XML failed RELAX NG validation:
  - element <qux> is not allowed here. Expected element(s): bar. (line 1, column 7)
  Document was: <foo><qux /></foo>
  ```

- `validate` — validate content or an XML string without panicking; returns
  `(valid: bool, errors: (..))`.
- `roots` / `elements` — the allowed document-root names and all element names.

These reserved keys win over grammar elements with the same names. A
`handlers:` argument is forwarded to every generated tag (see above).

## Serializing

`xml-to-string` accepts authored trees (the return value of a tag function or
any markup content), plain node dictionaries/strings/arrays, and — faithfully —
the output of Typst's built-in `xml()` reader:

```typst
#xml-to-string(xml("doc.xml"))
```

Attribute order is preserved, text/attribute contexts are escaped correctly,
empty elements self-close, and default-namespace declarations are re-emitted
only where the namespace actually changes.

## Testing

Tests run with [tytanic](https://github.com/typst-community/tytanic):

```sh
tt run
```


