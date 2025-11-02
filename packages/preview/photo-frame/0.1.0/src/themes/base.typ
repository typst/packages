#let extend-bottom(size:(0, 0), img: image, bottom: [], ratio: fraction) = {
  rect(width: size.at(0), height: size.at(1), inset: 0mm, outset: 0mm)[
    #grid(
      rows: (90fr, ratio),
      fill: rgb("#ffffff"),
      inset: 0mm,
      img,
      bottom,
    )
  ]
}

#let extend-right(size:(0, 0), img: image, right: [], ratio: fraction) = {
  rect(width: size.at(0), height: size.at(1), inset: 0mm, outset: 0mm)[
    #grid(
      columns: (90fr, ratio),
      fill: rgb("#ffffff"),
      inset: 0mm,
      img,
      right,
    )
  ]
}