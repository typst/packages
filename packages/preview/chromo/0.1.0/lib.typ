#let cyan = cmyk(100%, 0%, 0%, 0%)
#let magenta = cmyk(0%, 100%, 0%, 0%)
#let yellow = cmyk(0%, 0%, 100%, 0%)
#let transparent = rgb(100%, 100%, 100%, 0)

#let cyan-gradient = gradient.linear(cyan, transparent, angle: 0deg)
#let magenta-gradient = gradient.linear(magenta, transparent, angle: 0deg)
#let yellow-gradient = gradient.linear(yellow, transparent, angle: 0deg)
#let black-gradient = gradient.linear(black, transparent, angle: 0deg)

#let cyan-mid-opacity = rgb(cyan.to-hex() + "88")
#let magenta-mid-opacity = rgb(magenta.to-hex() + "88")
#let yellow-mid-opacity = rgb(yellow.to-hex() + "88")

#let square-printer-test(dir: ltr, size: 15pt) = [
  #stack(
    dir: dir,
    spacing: 5pt,
    square(width: size, height: size, fill: cyan),
    square(width: size, height: size, fill: magenta),
    square(width: size, height: size, fill: yellow),
    square(width: size, height: size, fill: black)
  )
]

#let gradient-printer-test(dir: ttb, width: 100pt, height: 15pt) = [
  #stack(
    dir: dir,
    spacing: 5pt,
    rect(width: width, height: height, fill: cyan-gradient),
    rect(width: width, height: height, fill: magenta-gradient),
    rect(width: width, height: height, fill: yellow-gradient),
    rect(width: width, height: height, fill: black-gradient)
  )
]

#let circular-printer-test(size: 100pt) = [
  #let adjusted-size = size/3.5

  #rect(width: size, height: size*0.93, fill: transparent)

  #place(
    dx: 0pt,
    dy: -size - 6pt,
    circle(radius: adjusted-size, fill: cyan-mid-opacity)
  )
  #place(
    dx: adjusted-size*0.75,
    dy: -size - 6pt + adjusted-size*1.25,
    circle(radius: adjusted-size, fill: magenta-mid-opacity)
  )
  #place(
    dx: adjusted-size*1.5,
    dy: -size - 6pt,
    circle(radius: adjusted-size, fill: yellow-mid-opacity)
  )
]

#let crosshair(size: 20pt, stroke: black) = [
  #place(
    line(start: (0pt, size/2), end: (size, size/2), stroke: stroke)
  )
  #place(
    line(start: (size/2, 0pt), end: (size/2, size), stroke: stroke)
  )
  #place(
    dx: size*0.1,
    dy: size*0.1,
    circle(radius: size*0.4, stroke: stroke)
  )
  #place(
    dx: size*0.15,
    dy: size*0.15,
    circle(radius: size*0.35, stroke: stroke)
  )
  #place(
    dx: size*0.2,
    dy: size*0.2,
    circle(radius: size*0.3, stroke: stroke)
  )
  #place(
    dx: size*0.25,
    dy: size*0.25,
    circle(radius: size*0.25, stroke: stroke)
  )
  #place(
    dx: size*0.3,
    dy: size*0.3,
    circle(radius: size*0.2, stroke: stroke)
  )
  #place(
    dx: size*0.35,
    dy: size*0.35,
    circle(radius: size*0.15, stroke: stroke)
  )

  #square(size: size, fill: transparent)
]

#let crosshair-printer-test(dir: ltr, size: 40pt) = [
  #stack(
    dir: dir,
    spacing: 5pt,
    crosshair(size: size, stroke: cyan),
    crosshair(size: size, stroke: magenta),
    crosshair(size: size, stroke: yellow),
    crosshair(size: size, stroke: black)
  )
]