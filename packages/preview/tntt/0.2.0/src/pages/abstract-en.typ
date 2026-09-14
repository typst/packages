#import "../utils/font.typ": font-size

// 本科生英文摘要页
#let abstract-en(
  // documentclass 传入的参数
  anonymous: false,
  twoside: false,
  fonts: (:),
  // 其他参数
  keywords: (),
  outline-title: "ABSTRACT",
  outlined: false,
  anonymous-info-keys: ("author-en", "supervisor-en", "supervisor-ii-en"),
  leading: 1.28em,
  spacing: 1.38em,
  body,
) = {
  pagebreak(weak: true, to: if twoside { "odd" })

  set text(font: fonts.SongTi, size: font-size.小四)
  set par(leading: leading, justify: true)

  align(
    center,
    text(
      size: font-size.小三,
      font: fonts.HeiTi,
      "ABSTRACT",
    ),
  )

  set par(first-line-indent: (amount: 2em, all: true))

  v(2pt)

  body

  v(1em)

  [*Keywords: *]
  (("",) + keywords.intersperse("; ")).sum()
}
