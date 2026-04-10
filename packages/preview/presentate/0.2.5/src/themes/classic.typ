#import "../presentate.typ" as p
#import "../components/styling.typ" as sty

#let slide-title = sty.element(
  "title",
  it => {
    if it == none { return none }
    set text(weight: "bold", size: 1.2em)
    block(
      stack(
        dir: ltr,
        if it.has("numbering") and it.numbering != none {
          numbering("1.1", ..counter(heading).at(it.location()))
          h(0.5em)
        },
        it.body,
      ),
      inset: (bottom: 1.2em),
    )
  },
)

#let slide(title: auto, body, ..styles, debug: false, align: left) = {
  let block = block.with(stroke: if debug { 1pt + red })
  p.slide(
    ..styles,
    stack(
      dir: ttb,
      block(width: 100%, context slide-title(sty.resolve-title(title))),
      block(width: 100%, height: 1fr, std.align(align, body)),
    ),
  )
}

#let empty-slide(..args, align: center + horizon) = {
  set page(margin: 0pt, header: none, footer: none)
  set std.align(align)
  p.slide(..args)
}

#let template(
  aspect-ratio: "16-9",
  body,
) = {
  set page(
    paper: "presentation-" + aspect-ratio,
    numbering: (n, m) => text(numbering("1 / 1", n, m), fill: gray, size: 0.8em),
    number-align: right,
  )
  show heading.where(level: 1): set text(size: 1.2em) 
  show heading.where(level: 1): empty-slide
  show heading.where(level: 2): none
  set text(font: "TeX Gyre Termes", size: 22pt)
  show math.equation: set text(font: "TeX Gyre Termes Math")
  show sty.select("title"): set text(size: 1.2em)

  body
}

// Usage 
// #show: template
// #set heading(numbering: "1.1")
// = First Topic

// == Energy Balance

// #slide[
//   What gives this talk so special?
//   $ a^2 + b^2 = c^2 $
//   #block(fill: red, height: 1fr, width: 100%)
// ]

// #slide[
//   What gives this talk so special? Huh
//   $ a^2 + b^2 = c^2 $
//   #block(fill: red, height: 1fr, width: 100%)
// ]
