#import "constants.typ":*

#let icon_and_contact(icon, content) = {
  if icon != none and content != none {
    grid(
      columns: 2,
      align: center+horizon,
      gutter: COMPANY_ICON_SPACING,

      box(
        height: HEADER_ICON_HEIGHT,
        width: auto,
        icon
      ),
      content
    )
  }
}

#let make-icon-header(icon-tuples) = {
  // what we put between elements
  let icon-joiner = box(baseline: -0.15em, [#h(0.5em)#sym.divides#h(0.5em)])

  // map them into formatted content, and join
  icon-tuples.map(((icon, content)) => {
    box(
      icon_and_contact(icon, content)
    )
  }).join(icon-joiner)
}

#let hrule(stroke: 1pt + black) = {
  block(
    above: HRULE_HEIGHT,
    below: 0em,
    breakable: false,
    line(length: 100%, stroke: stroke)
  )
}
