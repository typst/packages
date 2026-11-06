// 成果页
#let achv(
  anonymous: false,
  twoside: false,
  // 其他参数
  title: "在学期间参加课题的研究成果",
  outlined: true,
  body,
) = {
  if not anonymous {
    pagebreak(weak: true, to: if twoside { "odd" })

    [#heading(level: 1, numbering: none, outlined: outlined, title) <no-auto-pagebreak>]

    body
  }
}
