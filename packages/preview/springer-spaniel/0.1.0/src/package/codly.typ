#import "@preview/codly:0.2.0": *

#let codly = codly.with(
  // display-icon: false, display-name: false,
  zebra-color: luma(95%),
  radius: 2pt,
  stroke-width: 0.25pt,
  stroke-color: black,
  language-block: (x) => (name, icon, default-color, loc) => {
    let radius = __codly-radius.at(loc)
    let padding = __codly-padding.at(loc)
    let stroke-width = __codly-stroke-width.at(loc)
    let color = if default-color == none { __codly-default-color.at(loc) } else { default-color }
    box(
      radius: radius,
      fill: color.lighten(60%),
      inset: padding,
      stroke: none,
      outset: 0pt,
      icon + name,
    )
  }
)