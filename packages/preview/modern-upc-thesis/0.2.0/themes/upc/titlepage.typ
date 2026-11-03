// ============================================================
// themes/upc/titlepage.typ: UPC 封面布局
// ============================================================

#import "../../lib/fonts.typ"
#import "../../lib/utils.typ"
#import "colors.typ" as colors

#let titlepage(
  title: "",
  subtitle: "",
  author: "",
  student-id: "",
  college: "",
  major: "",
  advisor: "",
  university: "中国石油大学（华东）",
  date: "",
) = {
  // 封面无页眉页脚
  set page(header: none, footer: none)

  align(center, [
    // 校徽：左上角
    #v(0.2cm)
    #align(left, image("logo.pdf", height: 1.8cm))

    #v(2.2cm)

    // 大标题：伪粗体
    #utils.fakebold(text(size: utils.xiaochu, font: fonts.get-cjk-sans())[#h(0.26em)本#h(0.5em)科#h(0.5em)毕#h(0.5em)业#h(0.5em)设#h(0.5em)计（论文）])

    #v(2.3cm)

    // 题目（表格对齐：换行后与标题首字对齐）
    #align(left, grid(
      columns: (100pt, 1fr),
      column-gutter: 0em,
      align(right + top, text(size: utils.xiaoer, font: fonts.get-cjk-sans(), [题#h(1em)目：#h(0.15em)])),
      align(left + top, text(size: utils.xiaoer, font: fonts.get-cjk-sans(), title)),
    ))
    #if subtitle != "" {
      align(right, text(size: utils.xiaoer, font: fonts.get-cjk-sans(), [——#h(0.3em)] + subtitle))
    }

    #v(2.3cm)

    // 信息表格
    #let info-row(label, value) = grid(
      columns: (100pt, 240pt),
      column-gutter: 1em,
      align(right + horizon, utils.fakebold(text(size: utils.sanhao, font: fonts.get-cjk-fang(), label + h(0.15em)))),
      align(left + horizon, box(
        width: 100%,
        stroke: (bottom: 0.5pt),
        outset: (bottom: 0.8em),
        align(center + horizon, text(size: utils.sanhao, font: fonts.get-cjk-fang(), value)),
      )),
    )

    #info-row([姓#h(2em)名：], author)
    #v(0.33em)
    #info-row([学#h(2em)号：], student-id)
    #v(0.33em)
    #info-row([学#h(2em)院：], college)
    #v(0.33em)
    #info-row([专#h(2em)业：], major)
    #v(0.33em)
    #info-row("指导教师：", advisor)

    #v(2.7cm)

    // 日期
    #text(size: utils.xiaoer, font: fonts.get-cjk-sans(),
      if date == "" { "\u{2003} 年 \u{2003} 月 \u{2003} 日" } else { date })
  ])

  pagebreak()
}
