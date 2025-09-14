// TODO [@Dian Ling](https://github.com/virgiling) 重写这部分内容

#import "../utils/style.typ": font_family, font_size
#import "../utils/justify-text.typ": justify-text

#let master-decl-page(
  info: (
    author-sign: [],
    originality-datetime: [],
    supervisor-sign: [],
    author-originality-datetime: [],
    supervisor-originality-datetime: [],
  ),
  fonts: (:),
  anonymous: false,
  twoside: false,
  title-font-size: font_size.三号,
  content-font-size: font_size.小四,
  box-inset: 0.5em,
  box-stroke: 0.5pt + black,
  small-box-height: 1.5em,
  small-box-width: 7em,
  small-box-stroke: 0.5pt + black,
  par_indent: 2em,
  par_leading: 1.5em,
  par-spacing: 2em,
  pad-x: 2em,
  weight-style: "bold",
  info-value-cell-inset: (bottom: 5pt),
  grid-columns: (0.7fr, 1fr) * 2,
  grid-inset: 0pt,
  grid-row-gutter: 0em,
  grid-column-gutter: (0em, 3em, 0em),
) = {
  if anonymous {
    return
  }
  pagebreak(weak: true, to: if twoside { "odd" })

  fonts = font_family + fonts
  let title-font = fonts.宋体
  let content-font = fonts.宋体
  let justify-text = justify-text.with(with-tail: true, tail: "：")
  let title-text(body) = {
    set text(font: title-font, size: title-font-size, weight: weight-style)
    v(3em)
    set par(spacing: par-spacing)
    set align(center)
    body
  }
  let info-value-cell = grid.cell.with(inset: info-value-cell-inset)

  set pad(x: pad-x)
  set grid(
    align: center + horizon,
    inset: grid-inset,
    columns: grid-columns,
    row-gutter: grid-row-gutter,
    column-gutter: grid-column-gutter,
  )
  set text(
    font: content-font,
    size: content-font-size,
  )
  set par(first-line-indent: par_indent, leading: par_leading)

  box(
    stroke: box-stroke,
    height: 100%,
    width: 100%,
    inset: box-inset,
  )[
    #set box(height: small-box-height, width: small-box-width, stroke: (bottom: small-box-stroke))

    #title-text[独　创　性　声　明]

    #text()[
      本人郑重声明：所提交的学位论文是本人在导师指导下独立进行研究工作所取得的成果。据我所知，除了特别加以标注和致谢的地方外，论文中不包含其他人已经发表或撰写过的研究成果。对本人的研究做出重要贡献的个人和集体，均已在文中作了明确的说明。本声明的法律结果由本人承担。

      #pad(
        grid(
          grid.cell()[#justify-text("论文作者签名")],
          info-value-cell()[#box()[#info.author-sign]],
          grid.cell()[#justify-text("日期")],
          info-value-cell()[#box()[#info.originality-datetime]
          ],
        ),
      )
    ]

    #v(10em)

    #title-text[学位论文使用授权书]

    #text()[
      本学位论文作者完全了解东北师范大学有关保留、使用学位论文的规定，即：东北师范大学有权保留并向国家有关部门或机构送交学位论文的复印件和电子版，允许论文被查阅和借阅。本人授权东北师范大学可以将学位论文的全部或部分内容编入有关数据库进行检索，可以采用影印、缩印或其它复制手段保存、汇编本学位论文。

      （保密的学位论文在解密后适用本授权书）

      #pad()[
        #grid(
          grid.cell()[#justify-text("论文作者签名")],
          info-value-cell()[#box()[#info.author-sign]],
          grid.cell()[#justify-text("指导教师签名")],
          info-value-cell()[#box()[#info.supervisor-sign]],

          grid.cell()[#justify-text("日期")],
          info-value-cell()[#box()[#info.author-originality-datetime]],
          grid.cell()[#justify-text("日期")],
          info-value-cell()[#box()[#info.supervisor-originality-datetime]],
        )
      ]
    ]
  ]
}

#master-decl-page(
  info: (
    author-sign: [],
    originality-datetime: [],
    supervisor-sign: [],
    author-originality-datetime: [],
    supervisor-originality-datetime: [],
  ),
)
