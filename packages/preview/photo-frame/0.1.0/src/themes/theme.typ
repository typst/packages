#import "base.typ": extend-bottom, extend-right

// theme1
#let theme1(size: (), img: image, ext-info: (:)) = {
  let logo = ext-info.at("logo", default: [])
  let title = ext-info.at("title", default: [])
  let date = ext-info.at("date", default: [])
  let address = ext-info.at("address", default: [])

  let bottom = grid(
    columns: (20fr, 2fr, 60fr, 2fr, 20fr),
    inset: 2pt,
    gutter: 0pt,
    logo,
    align: center + horizon,
    line(stroke: 2pt + gray, length: size.at(1) * 0.08, angle: 90deg),
    title,
    line(stroke: 2pt + gray, length: size.at(1) * 0.08, angle: 90deg),
    [#address #date],
  )
  extend-bottom(size: size, img: img, bottom: bottom, ratio: 10fr)
}

// theme2
#let theme2(size: (), img: image, ext-info: (:)) = {
  let logo = ext-info.at("logo", default: [])
  let title = ext-info.at("title", default: [])
  let date = ext-info.at("date", default: [])
  let address = ext-info.at("address", default: [])

  let bottom = grid(
    rows: (10fr, 2fr, 60fr, 2fr, 20fr),
    inset: 2pt,
    gutter: 0pt,
    logo,
    align: center + horizon,
    line(stroke: 2pt + gray, length: size.at(0) * 0.08, angle: 0deg),
    title,
    line(stroke: 2pt + gray, length: size.at(0) * 0.08, angle: 0deg),
    [#address\ #date],
  )
  extend-right(size: size, img: img, right: bottom, ratio: 10fr)
}

