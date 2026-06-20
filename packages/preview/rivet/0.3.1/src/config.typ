#let config(
  default-font-family: "Ubuntu Mono",
  default-font-size: 15pt,
  italic-font-family: "Ubuntu Mono",
  italic-font-size: 12pt,
  background: white,
  text-color: black,
  link-color: black,
  bit-i-color: black,
  border-color: black,
  bit-width: 30,
  bit-height: 30,
  description-margin: 10,
  dash-length: 6,
  dash-space: 4,
  arrow-size: 10,
  margins: (20, 20, 20, 20),
  arrow-margin: 4,
  values-gap: 5,
  arrow-label-distance: 5,
  force-descs-on-side: false,
  left-labels: false,
  width: 1200,
  height: 800,
  full-page: false,
  all-bit-i: true,
  ltr-bits: false,
) = {
  return (
    default-font-family: default-font-family,
    default-font-size: default-font-size,
    italic-font-family: italic-font-family,
    italic-font-size: italic-font-size,
    background: background,
    text-color: text-color,
    link-color: link-color,
    bit-i-color: bit-i-color,
    border-color: border-color,
    bit-width: bit-width,
    bit-height: bit-height,
    description-margin: description-margin,
    dash-length: dash-length,
    dash-space: dash-space,
    arrow-size: arrow-size,
    margins: margins,
    arrow-margin: arrow-margin,
    values-gap: values-gap,
    arrow-label-distance: arrow-label-distance,
    force-descs-on-side: force-descs-on-side,
    left-labels: left-labels,
    width: width,
    height: height,
    full-page: full-page,
    all-bit-i: all-bit-i,
    ltr-bits: ltr-bits,
  )
}

#let dark = config.with(
  background: rgb(24, 24, 24),
  text-color: rgb(216, 216, 216),
  link-color: rgb(150, 150, 150),
  bit-i-color: rgb(180, 180, 180),
  border-color: rgb(180, 180, 180)
)

#let blueprint = config.with(
  background: rgb(53, 77, 158),
  text-color: rgb(231, 236, 249),
  link-color: rgb(169, 193, 228),
  bit-i-color: rgb(214, 223, 244),
  border-color: rgb(214, 223, 244)
)

#let transparent = config.with(
  background: rgb(0, 0, 0, 0),
  text-color: rgb(128, 128, 128),
  link-color: rgb(128, 128, 128),
  bit-i-color: rgb(128, 128, 128),
  border-color: rgb(128, 128, 128)
)

