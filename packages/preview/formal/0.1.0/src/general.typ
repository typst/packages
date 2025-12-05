#let font-size = 10pt
#let font-family = "New Computer Modern"
#let accent-color = rgb("004d80")
#let ghost-color = rgb(0, 0, 0, 50%)

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

// General style for formal documents
#let formal-general(frame-thickness: 5mm, frame-outset: 0cm, body) = {
  set par(justify: true)
  set text(
    size: font-size,
    font: font-family,
    hyphenate: true,
  )

  show heading: it => {
    set text(fill: accent-color, size: font-size, weight: 900)
    block(strong(smallcaps(it.body)))
  }

  show math.equation: set text(font: font-family)
  show raw: set text(size: 0.95em, font: "Menlo")
  show link: set text(font: "Menlo", size: 0.8em)

  set list(
    marker: (
      text(font: "Menlo", size: 1.3em, baseline: -0.17em, "✴"),
      text(size: 0.5em, baseline: +0.35em, "➤"),
    ),
    spacing: 0.65em,
    tight: true,
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

// Function to apply custom syntax
#let formal-syntax(body) = {
  // Custom syntax
  show ">": "•"
  show "|": h(1fr)
  show "+-": "±"
  show "etc": emph("etc")

  show "LaTeX": {
    set text(font: "New Computer Modern")
    box(
      width: 2.55em,
      {
        [L]
        place(top, dx: 0.3em, text(size: 0.7em)[A])
        place(top, dx: 0.7em)[T]
        place(top, dx: 1.26em, dy: 0.22em)[E]
        place(top, dx: 1.8em)[X]
      },
    )
  }

  body
}

