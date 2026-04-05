#import "@preview/tidy:0.2.0"
#import "/doc/example.typ": example
#import "/doc/style.typ" as doc-style
#import "/src/lib.typ" as cetz-venn

// Usage:
//   ```example
//   /* canvas drawing code */
//   ```
#show raw.where(lang: "example"): example
#show raw.where(lang: "example-vertical"): example.with(vertical: true)

#set terms(indent: 1em)
#set par(justify: true)
#set heading(numbering: (..num) => if num.pos().len() < 4 {
  numbering("1.1", ..num)
})
#show link: set text(blue)

#rect(width: 100%, fill: blue.darken(30%),
  table(columns: (1fr, 1fr), align: (left, right), stroke: none,
    text(white)[*CeTZ Venn*], text(white)[#cetz-venn.version]))

// Outline
#{
  show heading: none
  columns(2, outline(indent: true, depth: 3))
  pagebreak(weak: true)
}

#set page(numbering: "1/1", header: align(right)[CeTZ Venn])

= Introduction

CeTZ Venn is a tiny package for drawing two- and three-set Venn diagrams
using Typst and CeTZ.

*CeTZ version $>=$ 0.3.1 is required!*

= Examples

A simple two set Venn diagram:

```example
cetz.canvas({
  cetz-venn.venn2(
    name: "venn",
    a-fill: gray,
    ab-fill: gray,
  )

  import cetz.draw: *
  content("venn.ab", [AB])
})
```

A three set diagram with arrows:

```example
cetz.canvas({
  cetz-venn.venn3(
    name: "venn",
    a-fill: gray,
    b-fill: gray,
    abc-fill: gray,
  )

  import cetz.draw: *
  content("venn.c", [C])

  line("venn.abc", (rel: (2.2,-2.5)), mark: (start: "o", fill: black), name: "arrow")
  content("arrow.end", [Here], anchor: "north", padding: .1)
})
```

= Styling

All diagrams use the style root `venn` and accept the following style keys:
#doc-style.show-parameter-block("fill", "fill", default: "white", [The default fill for all elements])
#doc-style.show-parameter-block("stroke", "stroke", default: auto, [The default stroke for all elements])
#doc-style.show-parameter-block("padding", ("number", "dictionary"), default: 2em, [
  Padding of the outer (rect) element. Per side padding can be specified by passing a dicitonary with one or more
  of the following keys: `top`, `bottom`, `left`, `right` and `rest`, where `rest` acts as a fallback for unset values.])

= Functions

#doc-style.parse-show-module("/src/venn.typ")
