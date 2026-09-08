#import "th_color.typ": th-color

#let infocard(
  heading,
  description,
  color-dark: th-color.paleblue,
  color-light: th-color.lightblue2
) = {
  figure(
    {
      set block(
        width: 100%,
        inset: 10pt,
        stroke: 1pt + color-dark
      )
      show block: (it) => align(left, it)
      block(
        text(strong(heading), fill: color-light),
        fill: color-dark,
        radius: (top: 5pt),
        below: 0pt,
      )
      block(
        text(description),
        fill: color-light,
        radius: (bottom: 5pt),
        above: 0pt
      )
    },
    kind: "infocard",
    supplement: none
  )
}
