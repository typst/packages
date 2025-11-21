// 个人信息
#let backmatter(
  // documentclass 传入参数
  anonymous: false,
  twoside: false,
  // 其他参数
  title: [作者简历及攻读学位期间发表的学术论文与其他相关学术成果],
  outlined: true,
  body,
) = {
  if (not anonymous) {
    pagebreak(weak: true, to: if twoside { "odd" })
    [
      #heading(
        level: 1,
        numbering: none,
        outlined: outlined,
        title,
      ) <no-auto-pagebreak>
      #set par(first-line-indent: 0em)

      #body
    ]
  }
}
