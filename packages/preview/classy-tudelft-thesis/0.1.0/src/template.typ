#import "@preview/equate:0.3.1": equate
#import "@preview/wrap-it:0.1.1": wrap-content as wrap_content_original

#let small = 10pt
#let normal = 11pt
#let large = 13pt
#let Large = 15pt
#let LARGE = 18pt
#let huge = 25pt

#let in-appendix-part = state("in-appendix-part", false)

#let base(
  title: none,
  name: none,
  rightheader: none,
  main-font: "Stix Two Text",
  math-font: "Stix Two Math",
  ref-color: blue,
  cite-color: olive,
  language: "en",
  region: "GB",
  body,
) = {
  /* General document & Page setup */

  set document(
    title: title,
    author: name,
  )

  set page(
    paper: "a4",
    margin: (x: 25mm, y: 25mm, top: 25mm + 5pt),
    numbering: "i",
    header: context {
      let currpage = here().page()
      let chapterpages = query(heading.where(level: 1)).map(chapter => {
        chapter.location().page()
      })
      let headings = query(heading.where(level: 1).before(here())).map(it => {
        if it.numbering != none {
          let num = numbering(it.numbering, ..counter(heading).at(it.location()))
          smallcaps[#it.supplement #num: #it.body]
        } else {
          smallcaps[#it.body]
        }
      })


      if currpage not in chapterpages and currpage > 2 [
        #headings.at(-1, default: "") #h(1fr) #rightheader
        #v(-3pt)
        #line(stroke: 1pt, length: 100%)
        #v(-5pt)
      ]
    },
  )

  /* Some main-text typography */

  set text(size: normal, lang: language, region: region, font: main-font)

  set par(
    justify: true,
    first-line-indent: 1.8em,
    spacing: 0.7em,
    leading: .77em,
  )

  /* Equation formatting */

  show math.equation: set text(font: math-font, size: normal)

  show: equate.with(breakable: false, sub-numbering: false)
  set math.equation(supplement: "Eq.")

  /* Numbering by section of equations & Figures */

  set math.equation(numbering: (..num) => numbering("(1.1)", counter(heading).get().first(), num.pos().first()))

  set figure(numbering: (..num) => numbering("1.1", counter(heading).get().first(), num.pos().first()))

  /* Heading formatting */

  set heading(numbering: "1.1.1")

  // 1em spacing between number and heading title
  show heading: it => {
    if (it.depth >= 2) {
      block(counter(heading).display(it.numbering) + h(1em) + it.body)
    } else {
      it
    }
  }

  // Make level 2 and 3 headings larger, with more space around them and with proper supplement name
  show heading.where(level: 2): set text(size: Large)
  show heading.where(level: 3): set text(size: large)
  show heading.where(level: 2): set block(above: 1.5em, below: .5em + 5pt)
  show heading.where(level: 3): set block(above: 1.5em, below: .5em + 5pt)
  show heading.where(level: 2): set heading(supplement: [Section])
  show heading.where(level: 3): set heading(supplement: [Subsection])

  // Level 1 headings: supplement chapter or appendix, depending on whether we are in appendix part.
  show heading.where(level: 1): set heading(supplement: it => context {
    if in-appendix-part.at(it.location()) {
      return "Appendix"
    } else {
      return "Chapter"
    }
  })

  // Fancy chapter title
  show heading.where(level: 1): it => {
    let chapternum = counter(heading).get().first()

    pagebreak()
    v(-30pt)
    set par(justify: false)
    box(
      text(size: huge)[
        #it.body
      ],
      width: 80%,
    )
    h(1fr)

    if it.numbering != none {
      text(size: 70pt, fill: rgb(80, 80, 80), weight: "semibold", font: "Lora")[
        #numbering(it.numbering, chapternum)
      ]
    }
    v(-6pt)
    line(length: 100%)
    v(10pt)
  }

  // For some reason, this needs to be after we have function for our fancy heading. Very weird.
  // (Lines are neccesary for numbering-by-section)

  show heading.where(level: 1): it => {
    counter(figure.where(kind: raw)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(math.equation).update(0)
    it
  }

  /* Citations and reference formatting */


  show cite: it => {
    // Only color the number, not the brackets.
    show regex("\d+"): set text(fill: cite-color)
    // or regex("[\p{L}\d+]+") when using the alpha-numerical style
    it
  }

  show ref: it => {
    if it.element == none {
      // This is a citation, which is handled above.
      return it
    }

    let el = it.element
    show regex("([0-9]+\.[0-9]+\.[0-9]+)|([0-9]+\.[0-9]+)|([0-9]+)|[A-Z]\.[0-9]+"): set text(fill: ref-color)

    // First check if it.element has "kind", which is not the case for footnotes.
    // Add parentheses to equations
    if (el.has("kind")) and el.kind == math.equation {
      show regex("^(\d+)(\.(\d+))*(\/(\d+))*-(\d+)$"): x => "(" + x + ")"
      it
    } // Change heading ref so that number (or letter) is colored by ref-color
    else if el.func() == heading {
      return link(
        it.target,
        [#el.supplement~#text(fill: ref-color, numbering(el.numbering, ..counter(heading).at(it.target)))],
      )
    } // Change figures so that supplement supplie during citation call is appended to output colored according to ref-color
    else if (el.func() == figure) and (el.kind != math.equation) {
      let the-numbering = if in-appendix-part.at(it.target) { "A.1" } else { "1.1" }
      let the-numbers = (counter(heading).at(it.target).at(0), ..el.counter.at(it.target))
      link(it.target, [#el.supplement~#text(fill: ref-color)[#numbering(the-numbering, ..the-numbers)#{
            if it.supplement != auto { it.supplement }
          }]])
    } else {
      it
    }
  }

  /* Figure styling */
  // Basic formatting of a caption, make first part bold, and use smaller font size

  show figure.caption: c => {
    text(size: small)[
      #context {
        text(weight: "bold")[
          #c.supplement #c.counter.display(c.numbering)#c.separator
        ]
      }
      #c.body
    ]
  }

  // if caption size is longer than page, justify left

  show figure.caption: c => context {
    let pagewidth = if page.flipped { page.height } else { page.width }
    if measure(c).width > (pagewidth - page.margin.left - page.margin.right) {
      set align(left)
      c
    } else {
      c
    }
  }

  // Tables with caption on top
  show figure.where(kind: table): set figure.caption(position: top)

  let figure_spacing = 0.75em // Additional spacing between figures and the text, https://stackoverflow.com/questions/78622060/add-spacing-around-figure-in-typst
  show figure: it => {
    if it.placement == none {
      block(it, inset: (y: figure_spacing))
    } else if it.placement == top {
      place(
        it.placement,
        float: true,
        block(width: 100%, inset: (bottom: figure_spacing), align(center, it)),
      )
    } else if it.placement == bottom {
      place(
        it.placement,
        float: true,
        block(width: 100%, inset: (top: figure_spacing), align(center, it)),
      )
    }
  }

  /* Outline styling */

  show outline.entry: it => {
    link(it.element.location())[
      #it.indented(it.prefix(), it.inner(), gap: 1.4em)]
  }

  show outline.entry.where(level: 1): it => {
    show repeat: none
    v(11pt)
    strong(it)
  }

  set outline.entry(fill: repeat([#h(2pt).#h(2pt)]))

  /* Miscellaneous styling*/

  show regex(" - "): [ #sym.dash ]

  set list(
    indent: 6pt,
    marker: (
      [
        #v(2.5pt) #circle(radius: 2pt, fill: white, stroke: 0.5pt + black)],
      [‣],
      [#sym.dash],
    ),
  )

  body
}

#let appendix(body) = {
  in-appendix-part.update(true)
  set heading(numbering: "A")

  counter(heading).update(0)

  set math.equation(numbering: (..num) => numbering("(A.1)", counter(heading).get().first(), num.pos().first()))

  set figure(numbering: (..num) => numbering("A.1", counter(heading).get().first(), num.pos().first()))


  body
}

#let wrap-content(
  fixed,
  to-wrap,
  alignment: top + left,
  size: auto,
  ..grid-kwargs,
) = {
  // Modifying the wrap-content function from the wrap-it package for extra styling.
  // Wrap caption to figure width and text align left

  show figure: it => {
    let w = measure(it.body).width

    show figure.caption: cap => box(width: w, [
      #set par(justify: true)
      #set align(left)
      #cap
    ])
    it
  }

  wrap_content_original(fixed, to-wrap, align: alignment, size: size, ..grid-kwargs)
}

#let chem(body) = {
  show regex("[\d]+"): sub
  body
}

#let doubleline = table.hline.with(stroke: stroke(thickness: 4pt, paint: tiling(
  size: (30pt, 5pt),
  [#rect(width: auto, height: 3pt, stroke: (y: 1pt + black))],
)))


#let makecoverpage(
  img: image("../template/img/cover-image.jpg"),
  title: none,
  subtitle: none,
  name: none,
  main-titlebox-fill: color.hsv(
    0deg,
    0%,
    0%,
    50%,
  ),
) = context {
  let pw = page.width
  let ph = page.height
  set image(width: pw, height: ph, fit: "cover")
  set page(background: img, margin: 0pt)
  set par(first-line-indent: 0pt, justify: false, leading: 1.5em)

  place(left + horizon, dx: 12pt, rotate(-90deg, origin: center, reflow: true)[
    #text(fill: white, font: "Roboto Slab")[Delft University of Technology]])


  place(dy: 2cm, rect(width: 100%, inset: 30pt, fill: main-titlebox-fill)[
    #text(fill: white, size: 45pt, font: "Roboto Slab", weight: "extralight", [#title])
    #linebreak()
    #linebreak()

    #if (subtitle != none) {
      text(fill: white, size: 20pt, font: "Roboto Slab", weight: "light", subtitle)
      linebreak()
      v(-5pt)
      linebreak()
    } else {
      v(-10pt)
    }

    #text(fill: white, size: 30pt, font: "Roboto Slab", weight: "extralight", name)
  ])


  set image(width: 6cm)
  place(
    bottom,
    dx: 1cm,

    image(
      "../template/img/TUDelft_logo_white.svg",
      width: 6cm,
      height: auto,
      fit: "contain",
    ),
  )
}

#let maketitlepage(
  title: none,
  subtitle: none,
  name: none,
  defense-date: datetime.today().display("[weekday] [month repr:long] [day], [year]") + " at 10:00",
  student-number: none,
  project-duration: none,
  daily-supervisor: none,
  thesis-committee: none,
  cover-description: none,
  publicity-statement: [An electronic version of this thesis is available at #link(" http://repository.tudelft.nl").],
) = {
  show par: set align(center)
  set par(spacing: 1.1em, justify: false) //, leading: 0.65em)
  set page(margin: (bottom: 0pt))

  text(size: 40pt, font: "Roboto Slab", weight: "extralight")[#title]
  if (subtitle != none) {
    v(-15pt)
    text(size: 20pt, font: "Roboto Slab", weight: "light")[#subtitle]
  }
  parbreak()
  // v(10pt)
  [by]
  parbreak()
  // v(10pt)
  text(size: 25pt, font: "Roboto Slab", weight: "extralight")[#name]
  parbreak()
  [to obtain the degree of Master of Science]
  //ter verkrijging van de graad van Master of Science
  parbreak()
  [at the Delft University of Technology,]
  //aan de Technische Universiteit Delft,
  parbreak()
  [to be defended publicly on #defense-date]
  //in het openbaar de verdedigen op maandag 1 januari om 10:00 uur.
  v(40pt)

  align(center)[#table(
    columns: (auto, auto, auto),
    stroke: none,
    align: (right, left, left),
    [Student number:], table.cell(colspan: 2)[#student-number],
    [Project duration:], table.cell(colspan: 2)[#project-duration],
    [Daily supervisor:], table.cell(colspan: 2)[#daily-supervisor],
    [Thesis committee:],
    table.cell(rowspan: 3, colspan: 2)[#table(columns: (
        auto,
        auto,
      ), stroke: none, align: (
        left,
        left,
      ), inset: 0pt, row-gutter: 10pt, column-gutter: 10pt, ..thesis-committee)],
  )]

  v(20pt)

  [Cover: #cover-description]

  v(1fr)
  [#publicity-statement]

  align(center)[#image("../template/img/TUDelft_logo_black.svg", width: 4.5cm)]
}

#let switch-page-numbering(body) = {
  set page(numbering: "1")
  counter(page).update(1)
  body
}
