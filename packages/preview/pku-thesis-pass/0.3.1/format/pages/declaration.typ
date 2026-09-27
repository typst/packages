// ============================================================
// declaration.typ — 原创性声明和授权说明页
// 包含两份法律文书：
//   1. 学位论文原创性声明
//   2. 学位论文使用授权说明
// ============================================================

#import "../layouts/headings.typ": back-heading
#import "../utils/bold.typ": bold
/// 原创性声明与授权说明页
/// clean-declaration: 为 true 时清除该页的页眉和页码（通过 back-heading 的 show-page-marks 元数据）
#let declaration-page(clean-declaration: false, style: none) = {
  set par(first-line-indent: style.正文.first-line-indent)
  back-heading(
    "北京大学学位论文原创性声明和使用授权说明",
    pagebreak: true,
    show-page-marks: not clean-declaration,
  )

  align(center)[#bold(
    [原创性声明],
    style.声明.fakebold,
    size: style.声明.size,
  )]
  v(1fr)
  [
    #set par(leading: style.声明.leading, spacing: style.声明.spacing)
    本人郑重声明：所呈交的学位论文，是本人在导师的指导下，独立进行研究工作所取得的成果。除文中已经注明引用的内容外，本论文不含任何其他个人或集体已经发表或撰写过的作品或成果。对本文的研究做出重要贡献的个人和集体，均已在文中以明确方式标明。本声明的法律结果由本人承担。

    #v(1fr)

    #align(right)[
      论文作者签名：
      #h(5em)
      日期：
      #h(2em)
      年
      #h(2em)
      月
      #h(2em)
      日
    ]

    #v(1fr)
    #align(center)[#bold(
      [学位论文使用授权说明],
      style.声明.fakebold,
      size: style.声明.size,
    )]
    #align(center)[#text(size: style.声明.size)[（必须装订在提交学校图书馆的印刷本）]]
    #v(1fr)

    #set par(leading: style.声明.leading, spacing: style.声明.spacing)
    本人完全了解北京大学关于收集、保存、使用学位论文的规定，即：
    #[
      #set list(
        marker: [#grid(
          columns: (auto, 1em),
          circle(radius: 0.3em, fill: black, stroke: none), [],
        )],
        indent: 1.5em,
      )
      - 按照学校要求提交学位论文的印刷本和电子版本；
      - 学校有权保存学位论文的印刷本和电子版，并提供目录检索与阅览服务，在校园网上提供服务；
      - 学校可以采用影印、缩印、数字化或其它复制手段保存论文；
      - 因某种特殊原因需要延迟发布学位论文电子版，授权学校#box(width: 12pt, align(center, square(size: 9pt)))一年/#box(width: 12pt, align(center, square(size: 9pt)))两年/#box(width: 12pt, align(center, square(size: 9pt)))三年以后，在校园网上全文发布。
    ]
    #v(1fr)
    #align(center)[（保密论文在解密后遵守此规定）]
    #v(2fr)
    #align(center)[
      论文作者签名：
      #h(5em)
      导师签名：
      #h(5em)
      #v(1em)
      日期：
      #h(2em)
      年
      #h(2em)
      月
      #h(2em)
      日
    ]
  ]
}
