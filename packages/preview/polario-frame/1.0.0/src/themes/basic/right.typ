#import "base.typ": extend-right

#let two-rows(size: (), img: [], extend-content: (), half-ratio: 50%, extend-ratio: ratio, background: none) = {
  let right = grid(
    rows: (half-ratio, 100% - half-ratio),
    inset: 0pt,
    gutter: 0pt,
    align: center + horizon,
    ..extend-content,
  )
  extend-right(size: size, img: img, right: right, ratio: extend-ratio, background: background)
}


#let three-rows(
  size: (),
  img: [],
  extend-content: (),
  middle-ratio: 20%,
  extend-ratio: ratio,
  background: none,
) = {
  let right = grid(
    rows: (50% - middle-ratio / 2, middle-ratio, 50% - middle-ratio / 2),
    inset: 0pt,
    gutter: 0pt,
    align: center + horizon,
    ..extend-content,
  )
  extend-right(size: size, img: img, right: right, ratio: extend-ratio, background: background)
}
