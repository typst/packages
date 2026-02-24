#import "base.typ": extend-bottom

#let two-columns(size: (), img: [], extend-content: (), half-ratio: 50%, extend-ratio: ratio, background: none) = {
  let bottom = grid(
    columns: (half-ratio, 100% - half-ratio),
    inset: 0pt,
    gutter: 0pt,
    align: center + horizon,
    ..extend-content.map(b => block(b, height: 100%)),
  )
  extend-bottom(size: size, img: img, bottom: bottom, ratio: extend-ratio, background: background)
}


#let three-columns(
  size: (),
  img: [],
  extend-content: (),
  middle-ratio: 20%,
  extend-ratio: ratio,
  background: none,
) = {
  let bottom = grid(
    columns: (50% - middle-ratio / 2, middle-ratio, 50% - middle-ratio / 2),
    inset: 1pt,
    gutter: 0pt,
    align: center + horizon,
    ..extend-content.map(b => block(b, height: 100%)),
  )
  extend-bottom(size: size, img: img, bottom: bottom, ratio: extend-ratio, background: background)
}
