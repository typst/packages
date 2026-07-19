#let extend-bottom(size:(0, 0), img: image, bottom: [], ratio: ratio, background: none) = {
  rect(width: size.at(0), height: size.at(1), inset: 0mm, outset: 0mm)[
    #grid(
      rows: (100% - ratio, ratio),
      fill: background,
      inset: 0mm,
      img,
      bottom,
    )
  ]
}

#let extend-top(size:(0, 0), img: image, bottom: [], ratio: ratio, background: none) = {
  rect(width: size.at(0), height: size.at(1), inset: 0mm, outset: 0mm)[
    #grid(
      rows: (ratio, 100% - ratio),
      fill: background,
      inset: 0mm,
      bottom,
      img,
    )
  ]
}

#let extend-right(size:(0, 0), img: image, right: [], ratio: fraction, background: none) = {
  rect(width: size.at(0), height: size.at(1), inset: 0mm, outset: 0mm)[
    #grid(
      columns: (100% - ratio, ratio),
      fill: background,
      inset: 0mm,
      img,
      right,
    )
  ]
}