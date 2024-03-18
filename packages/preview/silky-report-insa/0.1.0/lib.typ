// FULL DOCUMENT :

#let insa-full(
  cover-top-left: [],
  cover-middle-left: [],
  cover-bottom-right: [],
  page-header: [],
  doc
) = {
  set text(lang: "fr")
  set page("a4")

  // IMAGE
  place(dx: -2.5cm, dy: -2.5cm, image("cover.jpeg", width: 20.9cm, height: 29.6cm))

  // TOP-LEFT
  place(
    dy: 4cm,
    block(
      width: 9.5cm,
      par(
        justify: false,
        text(size: 18pt, cover-top-left)
      )
    )
  )

  // middle-left
  place(
    dx: -1.35cm,
    dy: 11.2cm,
    block(
      width: 7.5cm,
      height: 7cm,
      inset: 1cm,
      align(horizon, par(
        justify: false,
        text(size: 16pt, cover-middle-left)
      ))
    )
  )

  // BOTTOM-RIGHT
  place(
    dx: 7cm,
    dy: 23cm,
    box(
      width: 8.5cm,
      par(
        justify: false,
        text(size: 24pt, weight: "bold", cover-bottom-right)
      )
    )
  )
  
  counter(page).update(0)
  set page(
    "a4",
    header-ascent: 25%,
    footer: [
      #place(
        right,
        dy: -0.6cm,
        dx: 1.9cm,
        image("footer.png")
      )
      #place(
        right,
        dx: 1.55cm,
        dy: 0.58cm,
        text(fill: white, weight: "bold", counter(page).display())
      )
    ],
    header: {
      page-header
      line(length: 100%)
    }
  )
  set par(justify: true)
  set figure(numbering: "1")
  show figure.where(kind: image): set figure(supplement: "Figure") // par défaut, Typst affiche "Fig."
  show figure.caption: it => [
    #text(weight: "bold")[
      #it.supplement
      #context it.counter.display(it.numbering) :
    ]
    #it.body
   ]
  
  doc
}


// FULL REPORT DOCUMENT :

#let insa-report(
  id: 1,
  pre-title: none,
  title : none,
  authors: [],
  date: none,
  doc,
) = {
  insa-full(
    cover-middle-left: authors,
    cover-top-left: [
      #set text(size: 28pt, weight: "bold")
      #if pre-title != none [
        #pre-title #sym.hyph
      ]
      TP #id\
      #set text(size: 22pt, weight: "medium")
      #smallcaps(title)
    ],
    page-header: [
      TP #id #sym.hyph #smallcaps(title)
      #h(1fr)
      #if type(date) == datetime [
        #date.display("[day]/[month]/[year]")
      ] else [
        #date
      ]
    ],
    {
      set math.equation(numbering: "(1)")
      set text(hyphenate: false)
      set heading(numbering: "I.1.")
      show heading.where(level: 1): it => [
        #set text(18pt)
        #smallcaps(it)
      ]
      show raw.where(block: true): it => block(stroke: 0.5pt + black, inset: 5pt, width: 100%, it)
      doc
    }
  )
}
