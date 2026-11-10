#import "../utils/style.typ": zihao, ziti

#let doc(
  info: (:),
  doctype: "bachelor",
  twoside: false,
  print: false,
  fallback: false,
  fonts: (:),
  it,
) = {
  set page(
    paper: "a4",
    margin: (top: 25mm, bottom: 20mm, left: 25mm, right: 20mm),
  )

  set text(
    font: ziti.songti,
    size: zihao.xiaosi,
    lang: "zh",
    region: "cn",
  )
  set par(
    leading: 20pt,
    first-line-indent: 2em,
    justify: true,
  )

  show figure: set align(center)
  show table: set align(center)
  
  // 三线表格式：只保留顶部、底部和表头下方的横线
  set table(
    stroke: (x, y) => (
      top: if y == 0 { 1.5pt } else { 0pt },
      bottom: if y == 1 { 1pt } else if y > 1 { 0pt } else { 1.5pt },
      left: 0pt,
      right: 0pt,
    ),
    inset: (x: 8pt, y: 6pt),
  )
  
  show figure.caption: set text(font: ziti.songti, size: zihao.wuhao)
  show figure.caption: set par(justify: false, leading: 1em)
  
  show figure.where(kind: image): set figure.caption(position: bottom)
  
  show figure.where(kind: table): set figure.caption(position: top)

  set document(
    title: info.title,
    author: info.name,
  )

  it
}
