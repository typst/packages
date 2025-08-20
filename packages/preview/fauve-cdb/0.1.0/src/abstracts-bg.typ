#import "@preview/cetz:0.2.2": canvas, draw

#let abstracts-bg(school-color) = canvas({
  let page-w = 21
  let page-h = 29.7
  // TikZ very thick = 0.42mm

  // top-left lines
  for i in range(1, 35) {
    draw.line(
      (0, 4.428+i*4.128/35), (7, 6.4+i*4.128/35),
      stroke: school-color.transparentize(75%) + 0.42mm
    )
  }

  // top-left mask
  draw.line(
    (0, 8.556), (7.05, 6.4), (7.05, 10.8), (0, 10.8),
    close: true, fill: white, stroke: 0pt
  )

  // bottom-right lines
  let x = 14
  let y = -24
  for i in range(1, 35) {
    draw.line(
      (x+0.02, y+6.4+i*4.128/35), (x+7.02, y+4.428+i*4.128/35),
      stroke: school-color.transparentize(85%) + 0.42mm
    )
  }

  // bottom-right mask
  draw.line(
    (x -.03, y+6.4), (x+7.02, y+8.556), (x+7.02, y+10.8), (x -.03, y+10.8),
    close: true, fill: white, stroke: 0pt
  )

  // top lines
  let x = 7
  let y = 4
  for i in range(1, 35) {
    draw.line(
      (x, y+4.428+i*4.128/35), (x+7, y+6.4+i*4.128/35),
      stroke: school-color.transparentize(75%) + 0.42mm
    )
  }

  // top lines edge mask
  draw.rect(
    (x -.05, y+3), (x+.01, y+10),
    fill: white, stroke: 0pt
  )

  // top fading mask
  draw.rect(
    (x, y+4.428), (x+7.05, y+10.8), stroke: 0pt,
    fill: gradient.linear(dir: ttb, white, white, white, white.transparentize(100%))
  )
})