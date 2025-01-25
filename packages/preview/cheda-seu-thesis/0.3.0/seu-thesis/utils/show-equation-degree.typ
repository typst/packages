// 研究生院要求：公式首行的起始位置空四格。
// #show math.equation: show-math-equation-degree
#let show-math-equation-degree(eq) = {
  if eq.block and eq.numbering != none {
    set align(left)
    grid(
      columns: (4em, 100% - 4em),
      h(4em),
      eq
    )
  } else {
    eq
  }
}