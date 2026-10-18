#import "@preview/pointless-size:0.1.2": zh

#let _spread(width, s) = box(width: width, {
  set text(
    weight: "bold",
  )
  let chars = s.clusters()
  stack(dir: ltr, spacing: 1fr, ..chars)
})

#let _header_text = text(size: zh(3), fill: rgb("#e80808"))[#_spread(22em, "华中科技大学课程实验报告")]

#let _header_line = line(length: 100%, stroke: rgb(24, 116, 205))

#let header_colorful = {
  align(center, _header_text)
  v(-0.5em)
  _header_line
  v(-1em)
  _header_line
}
