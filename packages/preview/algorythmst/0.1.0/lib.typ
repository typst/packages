// algorythmst — algorithm/pseudocode blocks for Typst (built on lovelace).
// Import: #import "@preview/algorythmst:0.1.0": *

#import "@preview/lovelace:0.3.0": *

// Right-aligned, gray text comment; use at the end of a line.
#let comment(body) = h(1fr) + text(fill: gray.darken(30%), body)

// Algorithm-style pseudocode (booktabs rules, "1:" line numbers, indent guides).
// Comments: append `#comment[text]` to any line, e.g. `$i <- 0$ #comment[init]`.
// Pass `title` to get a numbered "Algorithm N: title" figure, `caption` for a caption below.
// #pseudo(title: [Binary Search], caption: [Describes binary search.], {
//   import lovelace: *
//   [*procedure* #smallcaps[Binary-Search]($A, n, v$)]
//   indent[$l <- 1$ \ $r <- n$]
//   [*end*]
// })
#let pseudo(body, title: none, caption: none, ..args) = {
  show math.equation.where(block: true): eq => block(width: 100%, align(center, eq))
  let rule = line(length: 100%, stroke: 0.8pt + black)
  let list = pseudocode-list(
    line-numbering: "1:",
    line-gap: 0.75em,
    ..args,
    body,
  )
  let framed(head) = {
    rule
    v(-0.65em)
    if head != none {
      head
      v(-0.35em)
      rule
    }
    v(-0.55em)
    list
    v(-0.3em)
    rule
  }
  if title == none and caption == none { block(width: 100%, framed(none)) } else {
    show figure: set block(breakable: true, width: 100%)
    show figure.where(kind: "algorithm"): set align(left)
    show figure.caption: it => align(left, it.body) 
    block(width: 100%, figure(
      kind: "algorithm",
      supplement: [Algorithm],
      caption: caption,
      framed[#strong[Algorithm #context counter(figure.where(kind: "algorithm")).display():] #smallcaps(title)],
    ))
  }
}
