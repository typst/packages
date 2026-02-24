#import "../styling.typ" as styling

#let bar-thickness = 3pt

// Credits to https://github.com/s15n/typst-thmbox
#let thmbox(title, tags, body, supplement, number, accent-color) = {
  let text-color = accent-color.saturate(60%).darken(20%)

  let bar = stroke(paint: accent-color, thickness: bar-thickness)

  show: styling.dividers-as({
    line(
      length: 100% + 1em,
      start: (-1em, 0pt),
      stroke: accent-color + bar-thickness * 0.8,
    )
    v(-0.2em)
  })

  block(
    stroke: (
      left: bar,
    ),
    inset: (
      left: 1em,
      top: 0.6em,
      bottom: 0.6em,
    ),
    spacing: 1.2em,
  )[
    #set align(left)
    // Title bar
    #if title != none {
      block(
        above: 0em,
        below: 1.2em,
      )[
        #set text(text-color, weight: "bold")
        #if title != [] {
          title
          h(3fr)
          for tag in tags {
            text(tag, weight: "regular")
            h(1fr)
          }
          h(2fr)
        }
        #supplement #number
      ]
    }
    // Body
    #if body != [] {
      block(
        inset: (
          right: 1em,
        ),
        spacing: 0em,
        width: 100%,
        body,
      )
    }
  ]
}

