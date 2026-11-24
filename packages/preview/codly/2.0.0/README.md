# 🐟 Codly

<p align="center">
  <a href="https://codly.dherse.dev">
    <img alt="Codly documentation site status" src="https://img.shields.io/website?down_message=offline&label=manual&up_color=007aff&up_message=online&url=https%3A%2F%2Fcodly.dherse.dev" />
  </a>
  <a href="https://github.com/Dherse/codly/blob/main/LICENSE">
    <img alt="Codly MIT license" src="https://img.shields.io/badge/license-MIT-brightgreen">
  </a>
  <img alt="Codly test workflow status" src="https://github.com/Dherse/codly/actions/workflows/test.yml/badge.svg" />
</p>

Code blocks for Typst with line numbers, references, annotations, themes, custom
gutters, and syntax-aware diffs.

Requires **Typst 0.15.0 or newer**.

## Quickstart

One show rule converts ordinary fenced blocks. Inline code stays untouched.

````typ
#import "@preview/codly:2.0.0" as codly
#show raw.where(block: true): codly.new

```rs
pub fn greeting(name: &str) -> String {
    format!("Hello, {name}!")
}
```
````

[![Rust greeting function with line numbers and a filename badge; inline code below uses native formatting.](https://raw.githubusercontent.com/Dherse/codly/v2.0.0/examples/quickstart.png)](https://github.com/Dherse/codly/blob/v2.0.0/examples/quickstart.typ)

[Rendered example source](https://github.com/Dherse/codly/blob/v2.0.0/examples/quickstart.typ). The screenshot also applies
the `github-light` theme and a filename badge.

Use [codly-languages](https://typst.app/universe/package/codly-languages/) for
language names and icons:

```typ
#import "@preview/codly:2.0.0" as codly
#import "@preview/codly-languages:0.1.8": codly-languages
#show: codly.lang-set_(languages: codly-languages)
#show raw.where(block: true): codly.new
#raw("print(42)", lang: "py", block: true)
```

## Explicit blocks and scoped defaults

Use `codly.new` for per-block settings, literal source strings, or caller-resolved
file paths; explicit blocks need no initialization rule.

```typ
#import "@preview/codly:2.0.0" as codly
#codly.new(raw("return value", lang: "py", block: true), file: "result.py")
#codly.new("print(42)", lang: "py", file: "answer.py")
// For a real source file: #codly.new(path("src/main.rs"))
```

Defaults use scoped show rules. Put the conversion rule in a content block to
limit it to that scope:

````typ
#import "@preview/codly:2.0.0" as codly
#[
  #show: codly.theme("dark")
  #show: codly.set_(padding: 4pt, radius: 5pt)
  #show: codly.number-set_(numbering: "1.")
  #show raw.where(block: true): codly.new
  ```py
  print("styled")
  ```
]
// Outside that scope, code blocks retain native Typst formatting.
````

To leave selected blocks unstyled, replace the conversion rule with a conditional one:

```typ
#import "@preview/codly:2.0.0" as codly
#show raw.where(block: true): it => if it.lang == "plain" { it } else { codly.new(it) }
#raw("native formatting", lang: "plain", block: true)
#raw("print(42)", lang: "py", block: true)
```

## Listing figures

Put a code block in a `figure` to get a native listing caption, counter, and
references. Codly discovers the enclosing figure's label automatically.
Use `figure.where(kind: raw)` to style listing captions or build a list of
listings:

````typ
#import "@preview/codly:2.0.0" as codly
#show figure.where(kind: raw): set figure.caption(position: top)

#figure(caption: [Normalize a name])[
  #codly.new(
    ```py
    def normalize(name):
        return name.strip()
    ```,
    file: "normalize.py",
  )
]<normalizer>

See @normalizer for the listing and @normalizer:2 for the return statement.

#outline(target: figure.where(kind: raw), title: [List of listings])
````

## Themes

Choose `thesis` (the default), `dark`, `clean`, `github-light`,
`solarized-light`, or `one-light`. Each preset includes a five-color highlight
palette; later component rules override theme settings.

```typ
#import "@preview/codly:2.0.0" as codly
#show: codly.theme("github-light", accent: rgb("8250df"))
#codly.new(raw("return value * 2", lang: "py", block: true))
```

[![Python function with a highlighted return expression, shown in all six built-in Codly themes.](https://raw.githubusercontent.com/Dherse/codly/v2.0.0/examples/themes.png)](https://github.com/Dherse/codly/blob/v2.0.0/examples/themes.typ)

[Theme example](https://github.com/Dherse/codly/blob/v2.0.0/examples/themes.typ) · [Theme definitions](src/themes.typ)

## Highlights, annotations, and references

Span highlights can carry tags and labels; braces annotate line ranges; callouts
can follow source indentation or point to a character. References are native
Typst references: use `@block:5` for a line and `@highlight` for a labeled span.
Put labeled highlights inside a figure.

Highlight character positions are **one-based and inclusive**, counting leading
indentation. On `            return operation()`, `operation()` is positions
20–30. Omitted bounds select the corresponding line edge; whitespace runs stay
whole when a boundary falls inside them.

[![Python retry loop with success and failure highlights, a brace annotation, two callouts, and a listing reference.](https://raw.githubusercontent.com/Dherse/codly/v2.0.0/examples/annotations.png)](https://github.com/Dherse/codly/blob/v2.0.0/examples/annotations.typ)

[Annotation and reference example](https://github.com/Dherse/codly/blob/v2.0.0/examples/annotations.typ)

## Syntax-aware diffs

Set the raw block language to `diff-py` or `diff,py`, with any language after
the prefix. Codly highlights old and new source separately, strips the patch
markers, and adds old/new number and change-marker gutters. Unified hunks and
simple `-`/`+` fragments are supported; colors and gutters are configurable,
and themes supply matching defaults.

```typ
#import "@preview/codly:2.0.0" as codly
#codly.new(raw("-return 1\n+return 2", lang: "diff-py", block: true))
```

Fenced blocks accept the `diff-py` tag in Typst 0.15; on versions without comma
support in language tags, use `raw(..., lang: "diff,py")`.

[![Python HTTP client patch with added and removed lines, old and new line numbers, and bounded retries.](https://raw.githubusercontent.com/Dherse/codly/v2.0.0/examples/diff.png)](https://github.com/Dherse/codly/blob/v2.0.0/examples/diff.typ)

[Diff example](https://github.com/Dherse/codly/blob/v2.0.0/examples/diff.typ)

## Custom gutters

Add columns with arrays or row callbacks, independent fills, widths, alignment,
and typography. Array entries refer to original source lines, even in excerpts.
Include `auto` in `gutters` to retain the ordinary number column; `gutters: ()`
hides all gutters.

[![Python validation function with coverage marks, line numbers, review labels, and a highlighted age check.](https://raw.githubusercontent.com/Dherse/codly/v2.0.0/examples/gutters.png)](https://github.com/Dherse/codly/blob/v2.0.0/examples/gutters.typ)

[Gutter example](https://github.com/Dherse/codly/blob/v2.0.0/examples/gutters.typ)

## Fills and layout

`codly.line-set_(fill: ...)` accepts a paint, a cycling array of paints, or a
function receiving a row dictionary with `index`, `kind`, `source-line`, and
`number`. The last two can be `none`; guard them in callbacks. Header and footer
fills are independent. `padding` controls block-edge space separately from row
insets and leading.

[![JavaScript blocks with cycling row colors, a gradient row fill, and separate header and footer backgrounds.](https://raw.githubusercontent.com/Dherse/codly/v2.0.0/examples/presentation.png)](https://github.com/Dherse/codly/blob/v2.0.0/examples/presentation.typ)

[Fill and layout example](https://github.com/Dherse/codly/blob/v2.0.0/examples/presentation.typ)

## Wrapping and indentation

Smart indentation is enabled by default. Indentation guides, rainbow delimiters,
and continuation markers are opt-in through `indent-guides`, `rainbow`, and
`wrap-marker`. Wrapped rows retain their original source number.

[![Wrapped Rust code with indentation guides, colored delimiters, and arrows marking continuation lines.](https://raw.githubusercontent.com/Dherse/codly/v2.0.0/examples/wrapping.png)](https://github.com/Dherse/codly/blob/v2.0.0/examples/wrapping.typ)

[Wrapping example](https://github.com/Dherse/codly/blob/v2.0.0/examples/wrapping.typ)

## Excerpts and numbering

`range` selects one interval; `ranges` selects multiple intervals. `offset`
accepts a number, `auto` to start the excerpt at one, or a block/figure label to
continue its last displayed number. Disjoint excerpts preserve their gaps.
`codly.info(label)` exposes `lines` and `last-number` in context.

[![Three Python blocks showing omitted source lines, an excerpt renumbered from one, and continued numbering in the final block.](https://raw.githubusercontent.com/Dherse/codly/v2.0.0/examples/excerpts.png)](https://github.com/Dherse/codly/blob/v2.0.0/examples/excerpts.typ)

[Excerpt example](https://github.com/Dherse/codly/blob/v2.0.0/examples/excerpts.typ)

## Migrating from v1

The [manual](https://codly.dherse.dev/v2.0.0/) contains the full API and a
[1.3.0 / 1.3.1 migration guide](https://codly.dherse.dev/v2.0.0/migration-1.3.html)
with before/after examples.
