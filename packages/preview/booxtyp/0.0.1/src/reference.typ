#import "counters.typ": theorem-counter, definition-counter, example-counter, exercise-counter, equation-counter

#let reference(body) = {
  show ref: it => {
    // let eq = math.equation
    let numbering-style = "1.1"
    let element = it.element

    if element == none {
      return it
    }

    if element.func() == math.equation {
      // Override equation references
      return numbering(element.numbering, ..equation-counter.at(element.location()))
    }

    if element.func() == figure and element.kind == "Theorem" {
      // Override theorem references
      return [
        #element.supplement
        #numbering(numbering-style, ..theorem-counter.at(element.location()))
      ]
    }

    if element.func() == figure and element.kind == "Proposition" {
      // Override proposition references
      return [
        #element.supplement
        #numbering(numbering-style, ..theorem-counter.at(element.location()))
      ]
    }

    if element.func() == figure and element.kind == "Lemma" {
      // Override lemma references
      return [
        #element.supplement
        #numbering(numbering-style, ..theorem-counter.at(element.location()))
      ]
    }

    if element.func() == figure and element.kind == "Corollary" {
      // Override corollary references
      return [
        #element.supplement
        #numbering(numbering-style, ..theorem-counter.at(element.location()))
      ]
    }

    if element.func() == figure and element.kind == "Definition" {
      // Override definition references
      return [
        #element.supplement
        #numbering(numbering-style, ..definition-counter.at(element.location()))
      ]
    }

    if element.func() == figure and element.kind == "Example" {
      // Override example references
      return [
        #element.supplement
        #numbering(numbering-style, ..example-counter.at(element.location()))
      ]
    }

    if element.func() == figure and element.kind == "Exercise" {
      // Override exercise references
      return [
        #element.supplement
        #numbering(numbering-style, ..exercise-counter.at(element.location()))
      ]
    }

    it
  }

  // The rest of the document
  body
}