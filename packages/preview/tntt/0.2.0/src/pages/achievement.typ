// 成果页
#let achievement(
  // from entry
  anonymous: false,
  twoside: false,
  // options
  title: "在学期间参加课题的研究成果",
  outlined: true,
  // self
  it,
) = {
  if anonymous { return }

  pagebreak(weak: true, to: if twoside { "odd" })

  [#heading(level: 1, numbering: none, outlined: outlined, title) <no-auto-pagebreak>]

  it
}
