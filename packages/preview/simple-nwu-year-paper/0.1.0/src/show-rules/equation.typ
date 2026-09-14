
/// 公式编号生成器
#let equation-numbering(n) = context {
  let levels = counter(heading).at(here())
  if levels.len() == 0 {
    numbering("(1.1)", 1, n)
  } else {
    let chapter = levels.at(0)
    numbering("(1.1)", chapter, n)
  }
}

#let show-equation = it => {
  // 禁止公式断行
  show math.equation.where(block: false): box
  it
}
