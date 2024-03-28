#import "../colors.typ": color-schema
#import "../counters.typ": theorem-counter

/// Create a new theorem-like template.
#let new-theorem-template(
  identifier,
  theorem-counter: theorem-counter,
  fill: color-schema.blue.light,
  stroke: color-schema.blue.primary,
) = (body, title: none) => {
  // * I wrap the theorem block in `figure` to allow for a label
  // * This is a hack!!!
  figure(
    block(
      fill: fill,
      stroke: stroke,
      radius: 12pt,
      inset: 12pt,
      width: 100%,
      above: 1.5em,
    )[
      // Theorem title
      #let theorem-title = locate(loc => {
        // Get heading numbers at current location
        let heading-numbers = counter(heading).at(loc)

        // Increment theorem counter
        theorem-counter.step(level: 3)

        // Set the theorem title
        [
          #identifier
          #numbering("1.1", ..theorem-counter.at(loc))
          #if title != none [
            #h(1pt)
            (#title)
          ]
        ]
      })

      // Display theorem title
      #text(fill: stroke)[*#theorem-title*]

      // Set paragraph
      #set par(first-line-indent: 0pt)

      // Theorem content
      #body
    ],
    kind: identifier,
    outlined: false,
    supplement: identifier,
  )
}

