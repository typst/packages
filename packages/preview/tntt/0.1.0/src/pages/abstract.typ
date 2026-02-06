#import "../font.typ": font-size, font-family

#import "../imports.typ": show-cn-fakebold

// 本科生中文摘要页
#let abstract(
  // documentclass 传入的参数
  anonymous: false,
  twoside: false,
  fonts: (:),
  // 其他参数
  keywords: (),
  outline-title: "中文摘要",
  outlined: false,
  anonymous-info-keys: ("author", "supervisor", "supervisor-ii"),
  leading: 1.28em,
  spacing: 1.28em,
  body,
) = {
  fonts = font-family + fonts

  show: show-cn-fakebold

  pagebreak(weak: true, to: if twoside { "odd" })
  set text(font: fonts.SongTi, size: font-size.小四)
  set par(leading: leading, justify: true, spacing: spacing, first-line-indent: (amount: 2em, all: true))

  align(
    center,
    text(
      size: font-size.小三,
      font: fonts.HeiTi,
      "中文摘要",
    ),
  )

  body

  v(1em)

  [*关键词：*]
  (("",) + keywords.intersperse("；")).sum()
}
