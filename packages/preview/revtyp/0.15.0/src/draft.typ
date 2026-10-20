
#let as-draft(
  show-line-numbers: false,
  content,
) = {
  set par.line(..if show-line-numbers {
    (numbering: it => text(fill: gray, size: 0.8em)[#it])
  })

  content
}

