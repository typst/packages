#import "counters.typ": equation-counter

#let equation-rules(body) = {
  set math.equation(numbering: "(1.1)")

  show math.equation.where(block: true): it => {
    locate(loc => {
      // Get heading numbers at current location
      let heading-numbers = counter(heading).at(loc)

      // Increment equation number
      equation-counter.step(level: 3)

      counter(math.equation).update(equation-counter.at(loc))
    })

    // Equation content
    it
  }

  // The rest of the document
  body
}
