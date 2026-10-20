#import "font_config.typ": *
#let auth-use-page() = {
  set page(margin: (top: 2.54cm, bottom: 2.54cm, left: 3.17cm, right: 3.17cm))
  set text(font: 宋体)
  set align(center)
  set par(leading: 1.3em)
  set text(size: 二号)
  [毕业论文（设计）使用授权声明]
  set align(left)
  set text(size: 四号)
  set par(first-line-indent: (amount: 2em), justify: true, linebreaks: "simple")
  [本人授权汕头大学保存本毕业论文（设计）的电子和纸质文档，允许毕业论文（设计）被查阅和借阅；学校可将本毕业论文（设计）的全部或部分内容编入有关数据库进行检索，可以采用影印、缩印或其它复制手段保存和汇编本毕业论文（设计）。]
  v(四号 * 2.6)
  let info-key(body) = {
    rect(
      // 矩形容器
      width: 100%, // 占满父容器宽度
      inset: (x: 0pt, bottom: 22pt), // 内边距引用全局变量
      stroke: none, // 无边框线
      text(
        // 文本内容
        size: 四号,
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
        size: 四号,
        bottom-edge: "descender", // 文本基线对齐（避免字符下沉导致的间距不均）
        body,
      ),
    )
  }
  grid(
    columns: (1fr, 2 * 四号, 1fr),
    block(width: 100%, grid(
      columns: (4.5 * 四号, 1fr),
      //调整列宽1fr为自适应宽度,72pt为固定宽度
      column-gutter: 6pt,
      //调整列间距
      row-gutter: 11.5pt,
      info-key("本人签名："), info-value(" "),
    )),
    "",
    block(width: 100%, grid(
      columns: (4.5 * 四号, 1fr),
      //调整列宽1fr为自适应宽度,72pt为固定宽度
      column-gutter: 6pt,
      //调整列间距
      row-gutter: 11.5pt,
      info-key("作者签名："), info-value(" "),
    )),

    block(width: 100%, grid(
      columns: (2.5 * 四号, 1.7fr, 四号, 1fr, 四号, 1fr, 四号),
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
    )),
    "",
    block(width: 100%, grid(
      columns: (2.5 * 四号, 1.7fr, 四号, 1fr, 四号, 1fr, 四号),
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
    )),
  )
}
