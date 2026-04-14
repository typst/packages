#import "config.typ": 字体, 字号

#let bachelor-decl-page(
  info: (:
    //title:
  ), //传入参数
) = {
  //函数
  let info-key(body) = {
    rect(
      // 矩形容器
      width: 100%, // 占满父容器宽度
      inset: (x: 0pt, bottom: 22pt), // 内边距引用全局变量
      stroke: none, // 无边框线
      text(
        // 文本内容
        font: 字体.楷体, // 楷体
        size: 字号.小三,
        body, // 接收的文本内容
      ),
    )
  }

  let info-value(body) = {
    rect(
      width: 100%,
      inset: (x: 0pt, bottom: 1pt), // 左右无内边距，底部内边距为0pt
      stroke: (bottom: 0.5pt + black), // 底部边框：0.5pt黑色实线（常用于分隔线）
      text(
        font: 字体.楷体, // 楷体
        size: 字号.小三,
        bottom-edge: "descender", // 文本基线对齐（避免字符下沉导致的间距不均）
        body,
      ),
    )
  }

  // 渲染
  align(
    center,
    text(
      font: 字体.黑体,
      size: 字号.小二,
      "汕头大学本科生毕业论文（设计）诚信承诺书",
    ),
  )

  v(字号.小四)

  block[
    #set text(font: 字体.楷体, size: 字号.小三)
    // #set par(justify: true, first-line-indent: (amount: 2em, all: true), leading: 2.42em)
    //设置首行缩进两个字符，行距为双倍行距,对齐方式为双端对齐
    #set par(
      justify: true,
      first-line-indent: (amount: 2em, all: true),
      leading: 1.5em,
    )

    本人承诺呈交的毕业论文（设计） 《#info.title》是在指导教师的指导下，独立开展研究取得的成果，文中引用他人的观点和材料，均在文后按顺序列出其参考文献，论文（设计）使用的数据真实可靠。
  ]

  v(76pt)

  set align(right)
  block(width: 222pt, grid(
    columns: (80pt, 132pt),
    //调整列宽1fr为自适应宽度,72pt为固定宽度
    column-gutter: 6pt,
    //调整列间距
    row-gutter: 11.5pt,
    info-key("本人签名："), info-value(" "),
  ))

  set align(right)
  block(width: 210pt, grid(
    columns: (40pt, 40pt, 14pt, 30pt, 14pt, 30pt, 14pt),
    //调整列宽1fr为自适应宽度,72pt为固定宽度
    column-gutter: 6pt,
    //调整列间距
    row-gutter: 11.5pt,
    info-key("日期："),
    info-value(" "),
    info-key("年"),
    info-value(" "),
    info-key("月"),
    info-value(" "),
    info-key("日"),
  ))

  // 结束，下一页
  pagebreak()
}
