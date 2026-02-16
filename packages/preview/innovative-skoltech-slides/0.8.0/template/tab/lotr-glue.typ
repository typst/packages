#let roberta-base = [#smallcaps[RoBERTa]#sub("base")]
#let roberta-large = [#smallcaps[RoBERTa]#sub("large")]

#let vtext(body) = context {
  let shape = measure(body)
  let content = rotate(-90deg, body)
  box(inset: (x: (shape.height - shape.width) / 2,
              y: (shape.width - shape.height) / 2),
      content)
}
#let la = it => align(left, smallcaps[#it])
#let header = ([Model], [Method], [Param \ 10#super("3")], [Rank], [CoLA], [MNLI], [MRPC], [QNLI], $Sigma$)
#let rows = (
  table.hline(stroke: 2pt),
  ..header.map(it => table.cell(align: center + horizon, strong(it))),
  table.hline(),
  table.cell(rowspan: 7, roberta-base),
      la[FT],        [125M],[---], [61(1)],     [*87.6*],    [*89.3*(9)], [92.6(1)], [*86.4*],
      la[BitFit],    [113], [---], [*62*(1)],   [84.8(1)],   [*92.0*(4)], [91.3(2)], [84.6],
      la[LoRA],      [295], [8  ], [61.1(6)],   [*87.3*(2)], [88(1)],     [91.3(2)], [81.5(8)],
      table.cell(rowspan: 4, la[LoTR]),
                     [74 ], [32 ], [60.5(?)],   [85.2(6)],   [85.9(4)], [90.0(1)],   [77.2(9)],
                     [100], [40 ], [58(2)],     [85.2(2)],   [88(1)],   [92.5(3)],   [78.2(5)],
                     [276], [80 ], [61(2)],     [84.6(1)],   [89.0(0)], [92.1(5)],   [79.1(8)],
                     [321], [88 ], [61.3(6)],   [84.7(0)],   [88.0(9)], [92.0(4)],   [79(2)],
  table.hline(),
  table.cell(rowspan: 3, roberta-large),
      la[FT],    [355M],[---], [*68*],    [90.2],      [*91*],      [94.7],      [*88.9*],
  la[LoRA],      [786], [8],   [42(37)],  [*90.6*(2)], [75(12)],    [*94.8*(3)], [69(8)],
  la[LoTR],      [328], [64],  [61.3(9)], [*90.3*(0)], [*89.0*(5)], [*94.8*(1)], [83(9)],
  table.hline(stroke: 2pt),
)

#table(
  columns: 9,
  column-gutter: 1%,
  stroke: none,
  align: center,
  ..rows)
