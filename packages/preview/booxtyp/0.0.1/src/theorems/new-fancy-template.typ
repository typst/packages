#import "../colors.typ": color-schema
#import "../counters.typ": exercise-counter

#let exercise(content) = {
  locate(loc => {
    // Increament the exercise counter
    exercise-counter.step(level: 3)

    // Get the current exercise number
    let number = numbering("1.1", ..exercise-counter.at(loc))

    // Emoji for the exercise
    emoji.hand.write

    // Render the exercise title
    text(fill: color-schema.green.dark)[
      *Exercise #number*
    ]

    // Add some space
    h(0.5em)

    // Exercise content
    content
  })
}