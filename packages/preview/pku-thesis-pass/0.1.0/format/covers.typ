// ============================================================
// covers.typ — 学位论文封面页
// 提供两个封面变体：
//   - cover-page-blind：匿名评阅用（隐去作者信息，显示论文编号）
//   - cover-page-normal：正常提交用（显示校徽、作者、导师等信息）
// ============================================================

#import "@preview/cuti:0.4.0": show-cn-fakebold
#import "const.typ": font, size
#import "utils.typ": split-text-by-width, build-field-grid, degree-type-checkbox, chinesenumber, chineseyear

/// 盲审版封面。
/// 显示校名（header-text）、中英文题目、学科信息、论文编号和学位类型。
/// 隐去作者姓名、学号、导师等可识别信息。
#let cover-page-blind(
  font: font,
  header-text: none,
  title-zh: none,
  title-en: none,
  first-major: none,
  major-zh: none,
  blind-id: none,
  year: none,
  month: none,
  degree-type: "academic",
) = {
  set align(center + top)
  text(size: size.小初, font: font.黑体)[
    #show: show-cn-fakebold
    #strong(header-text)
  ]
  linebreak()
  set text(size: size.三号, font: font.仿宋)
  set par(justify: true, leading: 1em)
  [（匿名评阅论文封面）]
  v(1fr)
  [
    #set align(left)
    #set par(spacing: 1.5em)
    中文题目：#title-zh.split("\n").join()

    英文题目：#title-en.split("\n").join()

    #linebreak()

    一级学科：#first-major

    二级学科：#major-zh

    论文编号：#blind-id
  ]
  v(1fr)
  degree-type-checkbox(degree-type)
  v(3fr)
  [#chineseyear(year) 年 #chinesenumber(month) 月]
}

/// 正常版封面。
/// 显示北京大学校徽（logo + wordmark）、论文类型、题目、作者信息及学位类型。
/// 利用 build-field-grid 实现字段名与值的对齐排版。
#let cover-page-normal(
  font: font,
  thesis-name: none,
  title-zh: none,
  author-zh: none,
  student-id: none,
  school: none,
  major-zh: none,
  direction: none,
  supervisor-zh: none,
  degree-type: "academic",
  year: none,
  month: none,
) = {
  set align(center + horizon)
  set text(size: size.一号)
  box(
    grid(
      columns: (auto, auto),
      gutter: 0.4em,
      image("../assets/logo.svg", height: 2.4em, fit: "contain"),
      image("../assets/wordmark.svg", height: 1.6em, fit: "contain"),
    ),
  )
  linebreak()
  text(size: size.小初)[#strong(thesis-name)]
  v(1fr)
  context {
    set text(weight: "bold")
    show: show-cn-fakebold
    let title-zh-parts = split-text-by-width(title-zh, 10.16cm)
    let grid-contents = (
      [
        #set align(center)
        #text(size: size.二号, weight: "regular")[题目：]
      ],
    )
    for (i, part) in title-zh-parts.enumerate() {
      grid-contents.push(strong(part))
      if i < title-zh-parts.len() - 1 {
        grid-contents.push([])
      }
    }

    grid(
      columns: (2.75cm, 10.16cm),
      rows: 1.48cm,
      align: center,
      stroke: (x, y) => if x == 1 { (bottom: 1pt) } else { none },
      ..grid-contents,
    )
  }
  v(5fr)
  set text(size: size.三号)
  build-field-grid(
    (
      (text("姓") + h(2em) + text("名："), author-zh),
      (text("学") + h(2em) + text("号："), student-id),
      (text("院") + h(2em) + text("系："), school),
      (text("专") + h(2em) + text("业："), major-zh),
      ("研究方向：", direction),
      ("导师姓名：", supervisor-zh),
    ),
    3.19cm,
    7.63cm,
    1.5em,
    font: font,
  )
  v(2fr)
  text(font: font.仿宋)[#degree-type-checkbox(degree-type)]
  v(1fr)
  text(font: font.宋体)[
    #chineseyear(year) *年* #chinesenumber(month) *月*
  ]
}
