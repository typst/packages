#import "../utils/font.typ": font-size, use-size

// 本科生授权页
#let copyright(
  // from entry
  anonymous: false,
  twoside: false,
  fonts: (:),
  // options
  title: "关于学位论文使用授权的说明",
  title-size: "二号",
) = {
  if anonymous { return }

  pagebreak(weak: true, to: if twoside { "odd" })

  align(
    center,
    text(
      font: fonts.HeiTi,
      size: use-size(title-size),
      title,
    ),
  )

  v(1em)

  set text(font: fonts.SongTi, size: font-size.小四)

  block[
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
