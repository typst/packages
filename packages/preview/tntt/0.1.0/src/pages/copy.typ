#import "../font.typ": font-size, font-family

#import "../imports.typ": show-cn-fakebold

// 本科生授权页
#let copy(
  anonymous: false,
  twoside: false,
  fonts: (:),
) = {
  if anonymous { return }

  fonts = font-family + fonts

  pagebreak(weak: true, to: if twoside { "odd" })

  show: show-cn-fakebold

  align(
    center,
    text(
      font: fonts.HeiTi,
      size: font-size.二号,
      "关于学位论文使用授权的说明",
    ),
  )

  v(1em)

  set text(font: fonts.SongTi, size: font-size.小四)

  block[
    #set par(justify: true, first-line-indent: (amount: 2em, all: true))

    本人完全了解清华大学有关保留、使用学位论文的规定，即：学校有权保留学位论文的复印件，允许该论文被查阅和借阅；学校可以公布该论文的全部或部分内容，可以采用影印、缩印或其他复制手段保存该论文。

    *（涉密的学位论文在解密后应遵守此规定）*
  ]

  v(2em)

  grid(
    columns: (1fr, 150pt),
    [],
    align(left)[
      签　　名：

      导师签名：

      日　　期：
    ],
  )
}
