#import "../colors.typ": color-schema
#import "../counters.typ": exercise-counter

#let new-plain-template(
  identifier,
  title-color: color-schema.green.dark,
  title-prefix: none,
  body-text-style: "normal",
  template-counter: none,
) = (body) => {
  locate(loc => {
    // Get the current template number
    let number = if template-counter != none {
      // Increament the template counter
      template-counter.step(level: 3)

      numbering("1.1", ..template-counter.at(loc))
    } else {
      none
    }

    figure(block()[
      // Something to add before the title
      #title-prefix
      // Render the template title
      #if number != none {
        text(fill: title-color)[*#identifier #number*]
      } else {
        text(fill: title-color)[*#identifier*]
      }
      // Add some space
      #h(0.0em)
      // Main content
      #text(style: body-text-style)[#body]
    ], kind: identifier, supplement: identifier)
  })
}