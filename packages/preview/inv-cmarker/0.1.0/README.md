# inv-cmarker

Convert [Typst](https://typst.app) content to [CommonMark](https://commonmark.org/) strings.

Written entirely in Typst script — no external tooling required.

## Usage

```typst
#import "@preview/inv-cmarker:0.1.0": to-commonmark

#let doc = [
= Introduction

This is a _Typst_ document with *bold*, `code`, and lists:

- First
- Second
- Third

#quote(block: true)[A block quote with multiple paragraphs is easy.]
]

#let commonmark = to-commonmark(doc)
```

The result is a plain CommonMark string:

```markdown
# Introduction

This is a *Typst* document with **bold**, `code`, and lists:

- First
- Second
- Third

> A block quote with multiple paragraphs is easy.
```

## Supported Elements

| Typst Element | CommonMark Output |
|---|---|
| Headings (`=`, `==`, …) | `# H1` through `###### H6` (clamped at 6) |
| Paragraphs | Separated by blank lines |
| Unordered lists (`- item`) | `- item` with 2-space indentation |
| Ordered lists (`+ item`) | `1. item` (code mode `enum`) |
| Block quotes (`#quote(block: true)`) | `> text` |
| Code blocks (fenced) | `` `` `` ``` with language info string |
| Inline code | `` `code` `` |
| Strong (`#strong`) | `**text**` |
| Emphasis (`#emph`) | `*text*` |
| Nested emphasis | Outer `*`, inner `_` |
| Links (`#link`) | `[text](url)` or `<url>` (autolink) |
| Images (`#image`) | `![alt](src)` |
| Line breaks | `  \n` (trailing two spaces) |

### Dropped Elements

Elements not in the table above emit an HTML comment:

```markdown
<!-- dropped: equation -->
<!-- dropped: table -->
```

Labels are silently dropped. Cross-references (`@label`) are
emitted as literal text (`@label`).

## API

```text
to-commonmark(content: content) -> str
```

Takes arbitrary Typst content and returns a CommonMark string.

The function accepts content produced by Typst markup, code-mode
constructors (`list()`, `enum()`, `heading()`, etc.), or any
combination thereof.

## How It Works

A single-pass recursive walk over the Typst content tree:

1. **Dispatch on element type** via `elem.func()`
2. **Context-threaded mode** — `"block"` or `"inline"` — determines
   how sequences of children are joined (`\n\n` vs `""`)
3. **Inline emphasis nesting** — `emph-depth` tracks nesting so the
   innermost emphasis uses `_`/`__` to avoid ambiguity
4. **Sequence grouping** — consecutive inline elements are merged
   into paragraphs; consecutive `item` elements (from markup-mode
   lists) are grouped into bullet lists

## Known Limitations

- Ordered lists in markup mode (`+ item`) are rendered as unordered
  (`- item`). Use code-mode `enum()` for ordered lists.
- Image dimensions are silently dropped.
- Tables, math, figures, strikethrough, and footnotes emit drop
  comments rather than CommonMark equivalents.
- HTML pass-through (e.g. images with dimensions, table markup) is
  not supported.

## Compatibility

Tested with **Typst 0.14.x**.
