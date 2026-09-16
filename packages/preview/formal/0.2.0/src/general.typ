#import "utils.typ": arrowhead, detail-stack, dotted-line, draft-pattern, inline-heading, star
#import "defs.typ": *

// Function to render a ghost text
#let ghost(body, italic: false) = {
  let txt = text(fill: ghost-color, body)
  if italic { return emph(txt) }
  return txt
}

// Function to render an accent text
#let accent(body) = {
  set text(fill: accent-color)
  body
}

#let style-headings(font-size: font-size, body) = {
  show heading: set text(fill: accent-color, size: font-size, weight: "bold")

  show heading.where(level: 1): it => {
    set text(size: large-font-size)
    set block(below: 2em)
    smallcaps(it)
  }

  show heading.where(level: 2): it => {
    set text(size: font-size)
    {
      set block(above: 1.5em)
      it
      v(-0.8em)
    }
    line(length: 100%, stroke: 0.25pt + accent-color.transparentize(70%))
    v(0.3em)
  }

  show heading.where(level: 3): it => {
    inline-heading(it.body)
  }

  body
}

#let style-math(equation-numbering: "(1)", body) = {
  set math.equation(numbering: equation-numbering)
  show ref: it => {
    let eq = math.equation
    let element = it.element

    if element != none and element.func() == eq {
      link(element.location(), numbering(
        element.numbering,
        ..counter(eq).at(element.location()),
      ))
    } else {
      it
    }
  }

  show math.equation.where(block: true): set block(spacing: 0.65em)
  show math.equation: set text(font: font-family)
  set math.cancel(stroke: black.transparentize(50%))

  body
}

// General style for formal documents
#let formal-general(font-size: font-size, frame-thickness: 5mm, frame-outset: 0cm, body) = {
  set par(justify: true)
  set text(
    size: font-size,
    font: font-family,
    hyphenate: true,
  )

  show: style-headings.with(font-size: font-size)
  show: style-math

  show raw: it => text(size: smaller-font-size, it)

  show link: it => {
    if type(it.dest) == str and it.body.func() == text and it.body.text == it.dest {
      link(it.dest, raw(it.dest))
    } else {
      it
    }
  }

  set list(
    marker: (
      arrowhead(),
    ),
    tight: true,
    body-indent: 0.3em,
  )

  // Page frame
  let frame = rect(
    width: 100% - frame-thickness,
    height: 100% - frame-thickness,
    stroke: accent-color + frame-thickness,
    outset: -frame-outset,
  )

  set page(margin: 1.2cm, background: frame)
  body
}
