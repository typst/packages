#import "@preview/codly:1.3.0": codly-init, no-codly, codly

// The project function defines how your document looks.
// It takes your content and some metadata and formats it.
// Go ahead and customize it to your liking!
#let project(
  title: "",
  subtitle: "",
  abstract: [],
  authors: (),
  url: none,
  date: none,
  version: none,
  body,
) = {
  // Set the document's basic properties.
  set document(author: authors, title: title)
  set page(numbering: "1", number-align: center)

  show heading.where(level: 1): it => block(smallcaps(it), below: 1em)
  // set heading(numbering: (..args) => if args.pos().len() == 1 { numbering("I", ..args) })
  //set heading(numbering: "1.a.i")
  show list: pad.with(x: 5%)
  show heading.where(level: 3): set text(1.2em)

  // show link: set text(fill: purple.darken(30%))
  show link: it => {
    let dest = str(it.dest)
    if "." in dest and not "/" in dest { return underline(it, stroke: luma(60%), offset: 1pt) }
    set text(fill: rgb("#1e8f6f"))
    underline(it)
  }

  v(4em)

  // Title row.
  align(center)[
    #block(text(weight: 700, 1.75em, title))
    #block(text(1.0em, subtitle))
    #v(4em, weak: true)
    v#version #h(1.2cm) #date
    #block(link(url))
    #v(1.5em, weak: true)
  ]

  // Author information.
  pad(
    top: 0.5em,
    x: 2em,
    grid(
      columns: (1fr,) * calc.min(3, authors.len()),
      gutter: 1em,
      ..authors.map(author => align(center, strong(author))),
    ),
  )

  v(3cm, weak: true)

  // Abstract.
  pad(
    x: 3.8em,
    top: 1em,
    bottom: 1.1em,
    align(center)[
      #heading(
        outlined: false,
        numbering: none,
        text(0.85em, smallcaps[Abstract]),
      )
      #abstract
    ],
  )

  // Main body.
  set par(justify: true)
  v(7em)

  pad(x: 10%, outline(depth: 2, indent: 2em))
  pagebreak()

  show: codly-init.with(
  )
  codly(
    fill: white
  )
  // codly(
  //   languages: (:
  //     // typ: (name: "typ", icon: none, color: rgb("#239DAE")),
  //   ),
  // )
  show raw.where(block: true): set text(size: .95em)
  show raw.where(block: true): it => pad(x: 4%, it)
  show raw.where(block: false, lang: "typ").or(raw.where(lang: "notnone")): it => box(inset: (x: 3pt), outset: (y: 3pt), radius: 40%, fill: luma(235), it)
  set raw(lang: "notnone")
  body
}

#let ref-fn(name) = link(label("tidy-" + name), raw(name))

#let file-code(filename, code) = pad(x: 4%, block(
  width: 100%,
  fill: rgb("#239DAE").lighten(80%),
  inset: 1pt,
  stroke: rgb("#239DAE") + 1pt,
  radius: 3pt,
  {
    block(align(right, text(raw(filename, lang: "cmd"))), width: 100%, inset: 5pt)
    v(1pt, weak: true)
    move(dx: -1pt, line(length: 100% + 2pt, stroke: 1pt + rgb("#239DAE")))
        v(1pt, weak: true)
    pad(x: -4.3%, code)
  }
))


#let tidy-output-figure(
  output,
  breakable: false,
  fill: none
) = no-codly({
  set heading(numbering: none)
  set text(size: .8em)
  show figure: set block(breakable: breakable)
  figure(align(left, block(
    width: 80%,
    fill: fill,
    stroke: 0.5pt + luma(200),
    inset: 20pt,
    radius: 10pt,
    block(
      breakable: breakable,
      output
    )
  )))
})


#let gqe-snippet(the_file) = {
  heading(level: 3, "Example :")
  raw(read(the_file), lang:"typst")

  heading(level: 3, "Result :")
  {
    include(the_file)
  }
}
