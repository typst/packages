// A calm placeholder for front-matter sections the student has not filled in.
//
// 0.1.0 rendered these as 3em purple capitals followed by `lorem(200)` in red,
// with no paragraph break between them, so the lorem text started on the same
// line as the placeholder and ran into it. It was the loudest thing in the
// document.
//
// This is deliberately quiet but still obviously unfinished, and it says what
// to do about it.
/// -> content
#let placeholder(message) = block(
  width: 100%,
  inset: 1em,
  radius: 2pt,
  stroke: 0.5pt + luma(60%),
  {
    set par(first-line-indent: 0pt, justify: false)
    text(fill: luma(35%), style: "italic", message)
  },
)
