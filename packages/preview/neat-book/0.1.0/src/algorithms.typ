#import "@preview/algorithmic:1.0.7" as algorithmic
#import "theme.typ": figure-number

/// A numbered, referenceable algorithm with algorithmic's control-flow DSL.
/// Pass statements in a code block: #algorithm(title: "Euclid", { ... }).
#let algorithm(title: none, input: none, output: none, line-numbers: true, ..statements) = {
  figure(
    kind: "algorithm",
    supplement: it => context if text.lang.starts-with("zh") { [算法] } else { [Algorithm] },
    caption: if title == none { [] } else { [#title] },
    numbering: figure-number,
    context {
      let is-zh = text.lang.starts-with("zh")
      set par(first-line-indent: 0pt, justify: false)
      if input != none { block(above: 3pt, below: 3pt)[*#if is-zh { [输入] } else { [Input] }：* #input] }
      if output != none { block(above: 3pt, below: 5pt)[*#if is-zh { [输出] } else { [Output] }：* #output] }
      algorithmic.algorithm(
        indent: 1em, inset: .23em,
        vstroke: .5pt + luma(210),
        line-numbers: line-numbers,
        line-numbers-format: n => text(fill: luma(140), size: .85em, [#n]),
        ..statements.pos(),
      )
    },
  )
}
#let show-algorithms(body, accent: black) = {
  show: algorithmic.style-algorithm.with(
    breakable: true,
    hlines: (
      grid.hline(stroke: .9pt + accent),
      grid.hline(stroke: .4pt + accent.lighten(50%)),
      grid.hline(stroke: .9pt + accent),
    ),
  )
  body
}
