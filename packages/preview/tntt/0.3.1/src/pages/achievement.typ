/// Achievement Page
#let achievement(
  // from entry
  anonymous: false,
  twoside: false,
  // options
  title: [在学期间参加课题的研究成果],
  outlined: true,
  // self
  it,
) = {
  if anonymous { return }

  pagebreak(weak: true, to: if twoside { "odd" })

  heading(level: 1, numbering: none, outlined: outlined, title)

  // reset indent
  set par(first-line-indent: 0pt)

  set list(
    indent: 0pt,
    body-indent: 1.2em,
  )

  set enum(
    indent: 0pt,
    numbering: "[1]",
    body-indent: 1.2em,
  )

  it
}
