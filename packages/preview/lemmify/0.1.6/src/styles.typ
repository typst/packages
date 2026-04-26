#import "util.typ": *

// Numbering function which combines
// heading number and theorem number
// with a dot: 1.1 and 2 -> 1.1.2
#let thm-numbering-heading(fig, max-heading-level: none) = {
  if fig.numbering != none {
    let heading-counter = display-heading-counter-at(fig.location(), max-heading-level)
    if type(heading-counter) == str and heading-counter.ends-with(".") {
      heading-counter
    } else {
      heading-counter
      "."
    }
    numbering(fig.numbering, ..fig.counter.at(fig.location()))
  }
}

// Numbering function which only
// returns the theorem number.
#let thm-numbering-linear(fig) = {
  if fig.numbering != none {
    numbering(fig.numbering, ..fig.counter.at(fig.location()))
  }
}

// Numbering function which takes
// the theorem number of the last
// theorem, but does not return it.
#let thm-numbering-proof(fig) = {
  if fig.numbering != none {
    fig.counter.update(n => n - 1)
  }
}

// Simple theorem style:
// thm-type n (name) body
#let thm-style-simple(
  thm-type,
  name,
  number,
  body
) = block(width: 100%, breakable: true)[#{
  strong(thm-type) + " "
  if number != none {
    strong(number) + " "
  }

  if name != none {
    emph[(#name)] + " "
  }
  " " + body
}]

// Reversed theorem style:
// n thm-type (name) body
#let thm-style-reversed(
  thm-type,
  name,
  number,
  body
) = block(width: 100%, breakable: true)[#{
  if number != none {
    strong(number) + " "
  }
  strong(thm-type) + " "

  if name != none {
    emph[(#name)] + " "
  }
  " " + body
}]

// Simple proof style:
// thm-type n (name) body □
#let thm-style-proof(
  thm-type,
  name,
  number,
  body
) = block(width: 100%, breakable: true)[#{
  strong(thm-type) + " "
  if number != none {
    strong(number) + " "
  }

  if name != none {
    emph[(#name)] + " "
  }
  " " + body + h(1fr) + $square$
}]

// Basic theorem reference style:
// @thm -> thm-type n
// @thm[X] -> X n
// @thm[] -> n
// where n is the numbering specified
// by the numbering function
#let thm-ref-style-simple(
  thm-type,
  thm-numbering,
  ref
) = link(ref.target, box[#{
  assert(
    ref.element.numbering != none,
    message: "cannot reference theorem without numbering"
  )

  let supplement = if ref.citation.supplement != none {
    ref.citation.supplement
  } else {
    thm-type
  }

  supplement

  if supplement != [] {
    " "
  }
  
  thm-numbering(ref.element)
}])
