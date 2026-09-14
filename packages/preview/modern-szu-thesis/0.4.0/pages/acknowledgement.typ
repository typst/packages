// 致谢页
#import "../utils/custom-cuti.typ":*
#let acknowledgement(
  // documentclass 传入参数
  anonymous: false,
  twoside: false,
  // 其他参数
  title: "致谢",
  outlined: true,
  body,
) = {
  if (not anonymous) {
    pagebreak(weak: true, to: if twoside { "odd" })
    [
      #fakebold(heading(level: 1, numbering: none, outlined: outlined, title, )) <no-auto-pagebreak>
      #text()[#body]
    ]

  }
}