#import "base.typ": extend_bottom, extend_right

// theme1
#let theme1(size: (), img: image, ext_info: (:)) = {
  let logo = ext_info.at("logo", default: [])
  let title = ext_info.at("title", default: [])
  let date = ext_info.at("date", default: [])
  let address = ext_info.at("address", default: [])

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
  extend_bottom(size: size, img: img, bottom: bottom, ratio: 10fr)
}

// theme2
#let theme2(size: (), img: image, ext_info: (:)) = {
  let logo = ext_info.at("logo", default: [])
  let title = ext_info.at("title", default: [])
  let date = ext_info.at("date", default: [])
  let address = ext_info.at("address", default: [])

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
  extend_right(size: size, img: img, right: bottom, ratio: 10fr)
}

