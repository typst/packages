#import "constants.typ" as constants
#import "units.typ" as units


#let widgets(
  space: units.space(), 
  font: units.font(),
  weight: units.weight(), 
) = {
  
  let card(
    title: none,
    width: 100%,
    highlight: constants.palette.red,
    body
    ) = {
    block(
      width: width,
      fill: highlight.desaturate(32%).lighten(86%),
      breakable: false,
      inset: (
        left: space.sm + weight.xl,
        right: space.md, 
        y: space.md
      ),
      stroke: (left: weight.xl + highlight),
      radius: weight.lg, 
    )[
      #if title != none {
        v(-space.xs)
        text(
          weight: "bold", 
          title
        )
      }
  
      #body
    ]
  }

  let statement(
    byline: none,
    width: 100%,
    highlight: constants.palette.red,
    body
    ) = {
    block(
      width: width,
    )[
      #heading(level: 2, numbering: none, outlined: false, body)
    
      #line(
        length: constants.span.p3, 
        stroke: weight.xl + highlight
      )

      #if byline != none {
        text(
          size: font.base,
          weight: "light", 
          tracking: font.base * .01,
          fill: constants.palette.grey.medium,
          byline
        )
        v(-space.md)
      }
    ]
  }

  // ---- bar-plot
  let bar(share, color) = box(
    width: 100%,
    height: font.base, 
    fill: constants.palette.grey.light, 
    radius: weight.xl, 
    align(
      left,
      box(
        width: share * 100%, 
        height: 100%, 
        fill: color, 
        radius: weight.xl
      ),
    )
  )

  let bar-chart(..rows) = grid(
    columns: (auto, 1fr, auto),
    row-gutter: space.sm,
    column-gutter: space.md,
    align: horizon,
    ..rows
    .pos()
    .map(row => {
      let (label, share, color, value) = row
      (
        text(size: font.sm, label), 
        bar(share, color),  
        text(
          size: font.sm, 
          weight: "semibold",
          value
        )
      )
    })
    .flatten()
  )

  (card: card, statement: statement, bar: bar, bar-chart: bar-chart)
}
