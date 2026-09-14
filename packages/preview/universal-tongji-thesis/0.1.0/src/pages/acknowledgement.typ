// 致谢页
#import "../utils/zh-aio.typ":*
#import "../utils/style.typ":字体, 字号

#let acknowledgement(
  // documentclass 传入参数
  anonymous: false,
  twoside: false,
  // 其他参数
  title: "致谢",
  outlined: true,
  body,
) = {
  set text(font: 字体.宋体, size: zh(-4))
  let ls = 8pt
  set par(leading: ls, spacing: ls)

  pagebreak(weak: true, to: if twoside { "odd" })
  [
    #heading(level: 1, numbering: none, outlined: outlined, title)
    #vh1l()
    #v(2pt)
    #if (not anonymous) [
      #body

      #h(1fr)#datetime.today().display("[year]年[month padding:none]月")#h(2.5em)
    ]
  ]
}