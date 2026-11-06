#import "../utils/font.typ": use-size
#import "../imports.typ": cuti

#import cuti: fakebold

/// = Examples
///
/// ```typ
/// #summary-block(
///   notion: [
///     - 流变学的概念、分支和研究体系
///     - 聚合物流变学的研究对象、基本概念和研究方法
///     - 流变学在聚合物加工中的应用
///   ],
///   equation: table(
///     table.header([涵义], [公式], [索引]),
///     [1], [2], [3],
///     [4], [5], [6],
///   ),
///   reference: [
///     - 《高分子物理》
///   ],
/// )
/// ```
#let summary-block(
  // content
  notion: none,
  equation: none,
  reference: none,
) = {
  let block1(ctx) = block(
    width: 100%,
    fill: black,
    text(
      ctx,
      white,
      size: use-size("四号"),
      font: "SimHei",
    ),
    inset: (left: 8pt, y: 4pt),
    below: 16pt,
  )

  let block2(ctx) = block(
    text(
      ctx,
      size: use-size("小四"),
      font: "SimHei",
    ),
    inset: (left: 24pt),
  )

  set list(
    marker: text(fakebold("☐"), font: "KaiTi"),
    indent: 24pt,
    body-indent: 1.5em,
  )

  set table(
    columns: (1fr, 1fr, auto),
    stroke: none,
    fill: (x, y) => if calc.even(y) { luma(220) },
    align: center + horizon,
  )

  [
    #block1[本章要点]

    #if (notion != none) {
      block2[概念]

      notion
    }

    #if (equation != none) {
      block2[公式]

      equation
    }

    #if (reference != none) {
      block2[延伸阅读]

      reference
    }
  ]
}
