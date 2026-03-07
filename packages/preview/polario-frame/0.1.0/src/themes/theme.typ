#import "base.typ": extend-bottom, extend-right

// theme1
#let theme1(size: (), img: image, ext-info: (:)) = {
  let logo = ext-info.at("logo", default: [])
  let title = ext-info.at("title", default: [])
  let date = ext-info.at("date", default: [])
  let address = ext-info.at("address", default: [])
  let background = ext-info.at("background", default: none)

  let extend = grid(
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
  extend-bottom(size: size, img: img, bottom: extend, ratio: 10fr, background: background)
}

// theme2
#let theme2(size: (), img: image, ext-info: (:)) = {
  let logo = ext-info.at("logo", default: [])
  let title = ext-info.at("title", default: [])
  let date = ext-info.at("date", default: [])
  let address = ext-info.at("address", default: [])
  let background = ext-info.at("background", default: none)

  let extend = grid(
    rows: (10fr, 2fr, 60fr, 2fr, 20fr),
    inset: 2pt,
    gutter: 0pt,
    align: center + horizon,
    logo,
    line(stroke: 2pt + gray, length: size.at(0) * 0.08, angle: 0deg),
    title,
    line(stroke: 2pt + gray, length: size.at(0) * 0.08, angle: 0deg),
    [#address\ #date],
  )
  extend-right(size: size, img: img, right: extend, ratio: 10fr, background: background)
}

// theme3
#let theme3(size: (), img: image, ext-info: (:)) = {
  let device-model = ext-info.at("model", default: none)
  let logo = ext-info.at("logo", default: none)
  let exif = ext-info.at("exif", default: none)
  let background = ext-info.at("background", default: none)

  let bottom = grid(
    columns: (35fr, 30fr, 35fr),
    inset: 2pt,
    gutter: 0pt,
    align: center + horizon,
    device-model,
    logo,
    exif,
  )
  extend-bottom(size: size, img: img, bottom: bottom, ratio: 10fr, background: background)
}
