#let sjtu-red = rgb("#c9151e")

#let header(fill) = align(center, image(
  bytes(
    read("vi/sjtu-logo.svg").replace(
      sjtu-red.to-hex(),
      fill.to-hex(),
    ),
  ),
  width: 75%,
))

#let footer(fill) = align(center)[
  #set text(
    top-edge: "baseline",
    bottom-edge: "baseline",
    style: "normal",
    fill: fill,
    size: 11pt,
  )
  地址：闵行东川路800号
]

#let template(
  doc,
  header: header,
  footer: footer,
  header-ascent: 1.3cm,
  footer-descent: 0.45cm,
  fill: red,
) = [
  #let lh1 = 0.85cm
  #let lh2 = 0.36cm
  #let margin-top = 4.75cm
  #let margin-bottom = 1.52cm
  #let margin-x = 1.85cm

  #let background = box(width: 100%, height: 100%, inset: (x: margin-x))[
    #place(top, dy: margin-top, line(length: 100%, stroke: 0.8mm + fill))
    #place(bottom, dy: -margin-bottom, line(length: 100%, stroke: 0.8mm + fill))
    #for i in range(16) {
      place(top, dy: margin-top + (lh1 + lh2) * i + lh1, line(length: 100%, stroke: fill))
      place(top, dy: margin-top + (lh1 + lh2) * (i + 1), line(length: 100%, stroke: fill))
    }
  ]

  #set page(
    width: 19.3cm,
    height: 26.5cm,
    margin: (x: margin-x, top: margin-top + lh1, bottom: margin-bottom),
    background: background,
    header: header(fill),
    header-ascent: header-ascent,
    footer: footer(fill),
    footer-descent: footer-descent,
  )
  #set text(
    top-edge: "baseline",
    bottom-edge: "baseline",
    size: 20pt,
    costs: (orphan: 0%, widow: 0%),
  )
  #set par(leading: lh1 + lh2, spacing: lh1 + lh2)

  #doc
]
