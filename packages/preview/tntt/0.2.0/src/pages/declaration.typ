#import "../utils/font.typ": font-size, use-size

// 本科生声明页
#let declaration(
  // from entry
  anonymous: false,
  twoside: false,
  fonts: (:),
  // options
  title-size: "小三",
) = {
  if anonymous { return }

  pagebreak(weak: true, to: if twoside { "odd" })

  align(
    center,
    text(
      font: fonts.HeiTi,
      size: use-size(title-size),
      "声　　明",
    ),
  )

  v(1em)

  set text(font: fonts.SongTi, size: font-size.小四)

  block[
    #set par(justify: true, first-line-indent: (amount: 2em, all: true))

    本人郑重声明：所呈交的学位论文，是本人在导师指导下，独立进行研究工作所取得的成果。尽我所知，除文中已经注明引用的内容外，本学位论文的研究成果不包含任何他人享有著作权的内容。对本论文所涉及的研究工作做出贡献的其他个人和集体，均已在文中以明确方式标明。
  ]

  v(2em)

  grid(
    columns: (1fr, 150pt),
    [],
    align(left)[
      签　名：

      日　期：
    ],
  )
}
