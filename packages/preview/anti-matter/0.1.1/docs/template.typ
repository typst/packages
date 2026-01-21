// Modified version of https://github.com/Mc-Zen/tidy/blob/abedd7abbb7f072e67ef95867e3b89c0db987441/docs/template.typ

// The project function defines how your document looks.
// It takes your content and some metadata and formats it.
// Go ahead and customize it to your liking!
#let project(
  package: (:),
  subtitle: "",
  abstract: [],
  date: none,
  body,
) = {
  // Set the document's basic properties.
  set document(author: package.authors, title: package.name)
  set text(font: "Linux Libertine", lang: "en")
 
  show heading.where(level: 1): it => block(smallcaps(it), below: 1em)
  set heading(numbering: (..args) => if args.pos().len() == 1 { numbering("I", ..args) })

  // show link: set text(fill: purple.darken(30%))
  show link: set text(fill: rgb("#1e8f6f"))
  
  v(4em)

  // Title row.
  align(center)[
    #block(text(weight: 700, 1.75em, package.name))
    #block(text(1.0em, subtitle))
    #v(4em, weak: true)
    v#package.version #h(1.2cm) #date
    #block(link(package.repository))
    #v(1.5em, weak: true)
  ]

  // Author information.
  pad(
    top: 0.5em,
    x: 2em,
    grid(
      columns: (1fr,) * calc.min(3, package.authors.len()),
      gutter: 1em,
      ..package.authors.map(author => align(center, strong(author))),
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

  set page(numbering: "1", number-align: center)
  counter(page).update(1)

  // Main body.
  set par(justify: true)
  v(10em)

  body
}
