#import "@preview/pointless-size:0.1.2": zh

#import "/src/fonts.typ"


// 记录当前是否在绘制续表中的 header
#let _continued-header-state = state("continued-header")

/// 提供为跨页表显示表序、表题的能力
///
/// 如果需要绘制可跨页的表格，请用此函数创建 header。
/// 同时还需将 @toprule.continued 赋值为 `true`。
///
/// -> content
#let continued-header(
  /// 表格的列数
  /// -> int
  columns: none,
  /// 同 `table.header` 的同名参数 -> int
  level: 1,
  ..children,
) = {
  let continued-cell = table.cell(
    colspan: columns,
    inset: (bottom: 9pt, top: 0pt),
    {
      pdf.artifact(
        context if _continued-header-state.get() {
          align(center)[
            #set text(font: fonts.sans, size: zh(5))
            表#context counter(figure.where(kind: table)).display()#h(0.4em, weak: true)（续）
          ]
        } else {
          v(-9pt)
          _continued-header-state.update(true)
        },
      )
    })

  table.header(
    repeat: true,
    continued-cell,
    ..children,
  )
}

/// 三线表的顶线
/// -> content
#let toprule(
  /// 如果这个表格是可跨页的表，设置此参数为 `true` -> bool
  continued: false,
  /// 同 `table.hline` 的同名参数
  stroke: 0.08em,
) = table.hline(y: if continued { 1 } else { auto }, stroke: stroke)

/// 三线表的底线
/// -> content
#let bottomrule(
  /// 同 `table.hline` 的同名参数
  stroke: 0.08em,
) = toprule(stroke: stroke)

/// 三线表的栏目线
/// -> content
#let midrule(
  /// 同 `table.hline` 的同名参数
  stroke: 0.05em,
) = table.hline(stroke: stroke)

/// 三线表的部分栏目线
/// -> content
#let cmidrule(
  /// 线放置的行（零索引）
  /// -> auto | int
  y: auto,
  /// 线开始的列（零索引，包含）
  /// -> int
  start: 0,
  /// 线结束的列（零索引，不包含）
  /// -> none | int
  end: none,
  /// 同 `table.hline` 的同名参数
  stroke: 0.03em,
) = table.hline(y: y, stroke: stroke, start: start, end: end)

#let table-style(body) = {
  show figure.where(kind: table): it => {
    set figure.caption(position: top)
    show figure.caption: set block(sticky: true)
    it
  }
  set table(inset: (y: 0.5em), stroke: none)
  show table: it => _continued-header-state.update(false) + it
  body
}
