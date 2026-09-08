#let header(header-path, body) = {
  set page(
    paper: "a4",
    margin: (
      top: 2cm + 0.98cm, // 图片 0.98cm
      bottom: 2cm,
      left: 1.5cm + 0.5cm, // 装订线 0.5cm
      right: 1.5cm,
    ),
    header: align(center, block(
      width: 100%,
      stroke: (bottom: 1pt + black),
      inset: (bottom: 4pt),
      image(header-path, height: 0.98cm, width: 4.13cm),
    )),
    header-ascent: 1.2em,
  )

  body
}
