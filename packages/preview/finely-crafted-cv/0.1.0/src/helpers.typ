#import "constants.typ":*

#let icon_and_contact(icon, content) = {
  grid(
    columns: 2,
    align: center+horizon,
    gutter: COMPANY_ICON_SPACING,

    box(
      height: HEADER_ICON_HEIGHT,
      width: auto,
      image(icon)
    ),
    content
  )
}

#let hrule(stroke: 1pt + black) = {
  block(
    above: HRULE_HEIGHT,
    below: 0em,
    breakable: false,
    line(length: 100%, stroke: stroke)
  )
}
