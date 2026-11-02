# ling-handout

A Typst template for linguistics handouts. Examples are numbered (1), (2), ... continuously across the whole document. Sub-lists inside an example are numbered (i), (ii), ... And references to examples render as (n) with a link back to the example.

## Quick start

Start a new project from the template:

```
typst init @preview/ling-handout:0.1.0
```

Or import it into an existing document:

```typst
#import "@preview/ling-handout:0.1.0": ling-handout, ex

#show: ling-handout.with(
  handout-title: [Your Title],
  handout-author: "Your Name",
  handout-date: datetime.today(),
  group: "Your Group",
  location: "Your Institution",
)

= Introduction

#ex[
  + If Oswald didn't shoot Kennedy, someone else did.
  + If Oswald hadn't shot Kennedy, someone else would have.
] <ex-conditionals>

Referencing examples from anywhere in the document, like @ex-conditionals, is easy. 
```

## Examples: the `ex` function

`ex` creates a numbered example. Numbering runs continuously through the whole document, independent of headings, as is customary in linguistics.

`ex` only displays correctly inside a document wrapped with `#show: ling-handout.with(..)`, which supplies the layout and reference styling.

### Single examples

```typst
#ex[Every linguist who knows about donkey sentences loves them.]
```

renders as

```
(1)  Every linguist who knows about donkey sentences loves them.
```

### Examples with sub-items

Use a numbered list (`+`) inside the example. Sub-items are numbered (i), (ii), ...

```typst
#ex[
  + John left.
  + \*Left John.
]
```

renders as

```
(2)  (i)  John left.
     (ii) *Left John.
```

Note that `*` starts bold text in Typst, so write `\*` for an ungrammaticality star. The same goes for `#`, `_`, and `@`.

### Referring to examples

Put a label directly after the closing bracket of `ex`, then reference it with `@` and the label name:

```typst
#ex[The present King of France is bald.] <ex-russell>

As @ex-russell shows, *the* requires a unique referent that exists (or at some point existed) in the evaluation world.
```

The reference renders as `(3)` (whatever the example's number is) and links to the example. The label's angle brackets are only used where it's defined, not in the reference.

### Current limitations

- Only whole examples can be referenced. Individual sub-items like (3.i) can't be labeled yet, so write the suffix manually in plain text.
- Sub-items always use (i), (ii), ... numbering.

### The example counter

Examples are figures of kind `"example"`, so their counter can be accessed directly. For instance, to restart numbering at (1), e.g. for an appendix:

```typst
#counter(figure.where(kind: "example")).update(0)
```

## Parameters

| Parameter | Default | Notes |
|---|---|---|
| `handout-title` | `none` | string or content; also sets `document.title`; omit with `none`  |
| `handout-author` | `none` | string or content; also sets `document.author`; omit with `none`  |
| `handout-date` | `none` | string, content, or datetime; shown in the header only, does not set `document.date`; omit with `none`  |
| `group` | `none` | string or content; left side of the header; omit with `none`  |
| `location` | `none` | string or content; shown after `group`; omit with `none` |
| `paper` | `"us-letter"` | passed to `page.paper` |
| `margin` | `1in` | passed to `page.margin` |
| `font` | `"New Computer Modern"` | passed to `text.font` |
| `font-size` | `12pt` | passed to `text.size` |
| `leading` | `0.52em` | passed to `par.leading` |
| `spacing` | `0.9em` | passed to `par.spacing` |

## Planned features

- Optional bibliography with the Unified Style Sheet for Linguistics
- IPA, Leipzig glossing, syntax trees, and phonological rules
- Referencing sub-items, e.g. (3.i)
- Configurable example and sub-item numbering
- Customizable header layout

## License

MIT-0. See `LICENSE`.
