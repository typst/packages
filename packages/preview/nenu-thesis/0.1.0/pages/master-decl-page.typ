// TODO [@Dian Ling](https://github.com/virgiling) 重写这部分内容

#import "../utils/style.typ": font_family, font_size
#import "../utils/justify-text.typ": justify-text
#import "../utils/datetime-display.typ": datetime-display


/// 硕博委员会页
/// -> content
#let master-decl-page(
  info: (:),
  /// 自定义字体
  /// 在 @@font_size 中我们加入了一些默认值，这里用于添加自定义的字体
  /// 但注意需要满足 @@font_size 的格式:
  ///
  /// `fonts = ( 宋体: ("Times New Romans"), 黑体: ( "Arial"), 楷体: ("KaiTi"), 仿宋: ("FangSong"), 等宽: ("Courier New")`
  /// -> dictionary
  fonts: (:),
  /// 盲审模式
  ///
  /// 隐藏学校/作者/导师等一切信息，满足盲审要求
  /// -> bool
  anonymous: false,
  /// 双面模式
  ///
  /// 会在每一个部分后加入空白页，便于打印
  /// -> bool
  twoside: false,
  // * 其他参数
  /// 标题的字号
  /// -> font_size
  title-font-size: font_size.三号,
  /// 内容的字号
  /// -> font_size
  content-font-size: font_size.小四,
  /// 整个页面的大边框的内边距
  /// -> relative | dictionary
  box-inset: 0.5em,
  /// 整个页面的大边框的边框样式
  /// -> none | length | color | gradient | stroke | tiling | dictionary
  box-stroke: 0.5pt + black,
  /// 签名/日期 框的高度
  /// -> length
  small-box-height: 1.5em,
  /// 签名/日期 框的宽度
  /// -> length
  small-box-width: 9.5em,
  /// 签名/日期 框的边框样式
  /// -> none | length | color | gradient | stroke | tiling | dictionary
  small-box-stroke: 0.5pt + black,
  /// 段落首行缩进
  /// -> length | dictionary
  par_indent: 2em,
  /// 段落行距
  /// -> length
  par_leading: 1.5em,
  /// 段落间距
  /// -> length
  par-spacing: 2em,
  /// 网格（签名key、签名value、日期key、日期value）的x方向外边距
  /// -> ralative
  pad-x: 1em,
  /// 粗体的样式
  /// -> str|int
  weight-style: "bold",
  /// 网格（签名key、签名value、日期key、日期value）y方向内边距
  /// -> auto | relative | dictionary
  info-value-cell-inset: (bottom: 5pt),
  /// 网格（签名key、签名value、日期key、日期value）的列宽数组
  /// -> array
  grid-columns: (0.7fr, 1fr, 0.4fr, 1.2fr),
  /// 网格（签名key、签名value、日期key、日期value）的内边距
  /// -> relative | array | dictionary | function
  grid-inset: 0pt,
  /// 网格（签名key、签名value、日期key、日期value）的行间距
  /// -> auto|int|relative|fraction|array
  grid-row-gutter: 0em,
  /// 网格（签名key、签名value、日期key、日期value）的列间距
  /// -> auto|int|relative|fraction|array
  grid-column-gutter: (0em, 1.5em, 0em),
  datetime-display: datetime-display,
) = {
  info = (
    (
      submit-date: datetime.today(),
    )
      + info
  )

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
          columns: grid-columns,
          row-gutter: grid-row-gutter,
          column-gutter: grid-column-gutter,
          grid.cell(justify-text("论文作者签名")),
          info-value-cell(box()),
          grid.cell(justify-text("日期")),
          info-value-cell(box(datetime-display(info.submit-date)))
          ,
        ),
      )
    ]

    #v(10em)

    #title-text[学位论文使用授权书]

    #text()[
      本学位论文作者完全了解东北师范大学有关保留、使用学位论文的规定，即：东北师范大学有权保留并向国家有关部门或机构送交学位论文的复印件和电子版，允许论文被查阅和借阅。本人授权东北师范大学可以将学位论文的全部或部分内容编入有关数据库进行检索，可以采用影印、缩印或其它复制手段保存、汇编本学位论文。

      （保密的学位论文在解密后适用本授权书）

      #pad(
        grid(
          columns: (.7fr, 1fr, .7fr, 1fr),
          column-gutter: (0em, 1em, 0em),
          grid.cell(justify-text("论文作者签名")),
          info-value-cell(box()),
          grid.cell(justify-text("指导教师签名")),
          info-value-cell(box()),
        ),
      )

      #pad(
        grid(
          columns: (.7fr, 1fr, .7fr, 1fr),
          column-gutter: (0em, 1em, 0em),
          grid.cell(justify-text("日期")),
          info-value-cell(box(datetime-display(info.submit-date))),
          grid.cell(justify-text("日期")),
          info-value-cell(box(datetime-display(info.submit-date))),
        ),
      )
    ]
  ]
}

