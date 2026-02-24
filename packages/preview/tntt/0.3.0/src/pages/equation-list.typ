#let equation-list(
  // from entry
  twoside: false,
  // options
  title: [公式清单],
  outlined: false,
) = {
  pagebreak(weak: true, to: if twoside { "odd" })

  heading(
    level: 1,
    numbering: none,
    outlined: outlined,
    title,
  )

  outline(
    title: none,
    target: math.equation.where(block: true),
  )
}
