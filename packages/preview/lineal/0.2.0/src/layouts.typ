#import "@preview/touying:0.5.3": components

#import "../src/brand.typ": colour, brand

/// Compose arbitrary content in equally sized or explicitly weighted columns.
#let columns(..bodies, widths: auto, gutter: 1em, align: top) = {
  assert(bodies.named().len() == 0, message: "columns: unexpected named option")
  let bodies = bodies.pos()
  assert(bodies.len() > 0, message: "columns: provide at least one body")
  let widths = if widths == auto { (1fr,) * bodies.len() } else { widths }
  assert(type(widths) == array and widths.len() == bodies.len(),
    message: "columns: widths must contain one track per body")
  grid(columns: widths, gutter: gutter, align: align, ..bodies)
}

/// A surface for content, with an automatic height by default.
#let panel(body, fill: colour.neutral-light, ink: colour.neutral-dark,
  stroke: none, inset: 1em, radius: .35em, width: 100%, height: auto,
  breakable: false,
) = block(width: width, height: height, fill: fill, stroke: stroke,
  inset: inset, radius: radius, breakable: breakable, text(fill: ink, body))

/// A fixed frame that reports vertical overflow instead of clipping content.
#let frame(body, width: 100%, height: 200pt, inset: 0pt,
  fill: none, stroke: none, radius: 0pt,
) = layout(size => context {
  assert(type(width) in (length, ratio, relative),
    message: "frame: width must be a length or relative width")
  let width = if type(width) == length { width } else if type(width) == ratio {
    width * size.width
  } else { width.length + width.ratio * size.width }
  assert(width > 0pt, message: "frame: width must be positive")
  assert(type(height) == length and height > 0pt,
    message: "frame: height must be a positive length")
  let used = measure(block(width: width, inset: inset, breakable: false, body)).height
  assert(used <= height, message: "frame: content exceeds the available height")
  block(width: width, height: height, inset: inset, fill: fill,
    stroke: stroke, radius: radius, breakable: false, body)
})

#let page-center(content) = {
  block(width: 100%)[
    #set align(horizon + center)
    #components.cell(width: auto)[
      #set align(left)
      #content
    ]
  ]
}

#let two-boxes(content1, content2) = {
  grid(
    columns: 2,
    column-gutter: 1em,
    align: horizon + center,
    
    block(
      height: 100%,
      width: 100%,
      fill: gradient.linear(colour.primary, colour.primary-light, angle: -30deg),
      inset: .5em,
      radius: .5em,
    )[
      #set text(fill: white)
      #content1
    ],
    
    block(
      height: 100%,
      width: 100%,
      fill: colour.neutral-light,
      stroke: colour.primary,
      inset: .5em,
      radius: .5em,
    )[
      #set text(fill: colour.primary)
      #content2
    ]
  )
}

#let contained(content, sidebar) = {
  block(
    inset: .5em,
    radius: .5em,
    width: 100%,
    height: 100%,
    fill: colour.neutral-light,

    grid(
      columns: 2,
      column-gutter: 1em,
      
      content,

      block(
        height: 100%,
        width: 100%,
        fill: colour.primary,
        inset: .5em,
        radius: .25em,

        align(horizon + center)[
          #set text(fill: white)
          #sidebar
        ]
      )
    )
  )
}

#let four-columns(..contents) = {
  let grid-item(fill, body) = {
    block(
      width: 100%,
      height: 100%,
      inset: .5em,
      radius: 4pt,
      fill: fill,
      body
    )
  }

  grid(
    columns: (1fr,) * 4,
    column-gutter: 1em,
    align: top + left,
    
    ..contents.pos().enumerate().map(((index, content)) => {
      let lightness = 20% * index
      grid-item(colour.primary.lighten(lightness))[
        #set text(fill: if lightness > 30% { black } else { white })
        #content
      ]
    })
  )
}

#let matrix(items) = {
  let matrix-item(body, fill: colour.primary) = {
    block(
      width: 100%,
      height: 50% - .5em,
      inset: .5em,
      radius: .5em,
      fill: fill,
      body
    )
  }

  grid(
    columns: (1fr,) * 3,
    rows: 2,
    gutter: 1em,
    align: horizon + center,
    ..items.map(item => matrix-item[#text(fill: white, item)])
  )
}
