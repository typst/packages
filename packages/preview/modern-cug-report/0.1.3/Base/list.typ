#let order-list(i, fill: rgb(0, 0, 255)) = {
  let nums = ("①", "②", "③", "④", "⑤", "⑥", "⑦", "⑧", "⑨", "⑩")
  // type(i)
  let it = if type(i) == int { nums.at(i - 1) } else { i }
  // it
  text(fill: fill)[*#it*]
}

#let order-list-black(i) = {
  order-list(i, fill: rgb(0, 0, 0))
}

#let blue-num(it) = {
  text(fill: rgb(0, 0, 255))[*#it*]
}

// 用于展示研究基础中的参考文献。
#let ref-list(..it, size:11.5pt) = {
  
  // unable to overwrite
  show table.cell: it => {
    // set table.cell.where(y: 0): strong
    set text(size: size)
    set par(spacing: 1.4em, leading: 0.9em)
    it
  }
  
  // show table.cell.where(y: 0): it => text(it)
  // show table.cell: it => text(it, weight: "regular")
  v(-0.6em)
  
  table(
    columns: (0.68cm, 1fr), // (2.0cm, 1.9cm, 1.55cm),
    rows: auto,
    align: (top + left, top),
    stroke: 0pt,
    inset: (x:0pt, y:6.5pt),
    ..it
  )
  v(-0.6em)
}
