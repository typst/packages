#import "@preview/hydra:0.6.2": hydra

#import "src/frontmatter.typ": *
#import "src/backmatter.typ": *
#import "src/utils.typ": *


/*--------[Accent Color]--------*/

#let accent-color = rgb(165, 28, 48)

#let thesis(
  title: "",
  author: "",
  date: datetime.today(),
  frontmatter: none,
  appendix: none,
  backmatter: none,
  body,
) = {


  /*--------[Parameters]--------*/

  let body-font = "IBM Plex Sans"
  let heading-font = "IBM Plex Serif"
  let caption-font = "IBM Plex Serif"
  let math-font = "STIX Two Math"
  let body-size = 11pt
  let h1-size = 22pt
  let h2-size = 14pt
  let h3-size = body-size
  let h4-size = body-size
  let caption-size = 10pt


  /*-----[General Settings]-----*/

  set document(title: title, author: author, date: date)

  show title: it => text(font: "IBM Plex Serif", 17pt, weight: "regular", tracking: 1pt, upper(it))

  let in-body = state("in-body", false)

  // Use measures to define text layout
  set text(font: body-font, size: body-size)
  show math.equation: set text(font: math-font, fallback: false)


  /*----[Fancy Hydra-Header]----*/

  let custom-header(title, dir, it) = {
    set text(style: "oblique")
    stack(
      dir: dir,
      [
        *#title #numbering(it.numbering, ..counter(heading).at(it.location()))*
        #h(7pt)
        #it.body
      ],
      [#h(7pt)|#h(7pt)],
      counter(page).display()
    )
    v(5pt)
  }

  set page(
    paper: "a4",
    margin: (
      bottom: 3cm,
      top: 4cm,
      inside: 4cm,
      outside: 3cm,
    ),
    header: context {
      // Check if header should be removed (page is empty)
      if not state("content.switch", false).get() or not in-body.get() {
        return
      }

      // select header type based on page number
      if calc.even(here().page()) {
        align(left, emph(hydra(1, display: (_, it) => {
          custom-header("Chapter", rtl, it)   // Chapter title on the left of even pages
        })))
      } else {
        align(right, emph(hydra(2, display: (_, it) => {
            custom-header("Section", ltr, it)   // Section title on the right of odd pages
          },
          skip-starting: false))
        )
      }
    },
    footer: []
  )

  set par(
    spacing: 1.5em,
    justify: true,
  )


  /*---------[Headings]---------*/

  show heading: it => {
    v(2.5em, weak: true)
    it
    v(1.5em, weak: true)
  }

  show heading.where(level: 1): it => [
    #set text(size: h1-size, weight: "medium", font: heading-font)
    #set align(right)

    #if in-body.get() {
      v(30pt)
      let heading-number = text(
          counter(heading).display(),
          size: 26pt,
        )
      box[
        #set align(horizon)
        #stack(
          dir: ltr,
          line(length: 30pt, angle: 90deg, stroke: (thickness: 0.75pt)),
          h(0.75em),
          heading-number,
        )
      ]
    }

    #it.body
    #v(30pt)
  ]

  show heading.where(level: 2): it => {text(size: h2-size, it)}
  show heading.where(level: 3): it => {text(size: h3-size, it)}
  show heading.where(level: 4): it => {text(size: h4-size, weight: "semibold", it.body) + h(1em)}
  show heading.where(level: 5): it => {text(size: h4-size, weight: "semibold", it.body)}


  /*----------[Figures]---------*/

  set figure(numbering: (..n) => {
      counter(figure.where(kind: "subfigure")).update(0)
      numbering("1.1", ..n)
    },
    placement: auto
  )

  show figure.where(kind: "code"): set figure(supplement: [Algorithm])
  show figure.where(kind: "subfigure"): set figure(supplement: [], numbering: "(a)", outlined: false, placement: none)

  show figure.caption: it => {
    set text(font: (caption-font), size: caption-size)

    layout(size => context {
      // Get length of caption text
      let caption-length = measure(
        ..size,
        it.supplement + it.separator + it.body,
      )

      // Center caption if less than one line
      if caption-length.width < size.width {
        set align(center)
      }

      // Make figure title bold and caption italic
      context {
        set align(left)
        if it.kind == "subfigure" {
          // don't display separator if it's a subfigure
          strong[#it.supplement #it.counter.display(it.numbering) ]
        } else {
          strong[#it.supplement #numbering(it.numbering,
            ..counter(heading.where(level: 1)).at(here()),
            ..counter(figure.where(kind: it.kind)).at(here())
          )#it.separator]
        }
        emph(it.body)

        // add spacing between mainfigure caption and subfigure
        if it.kind == "subfigure" {v(0.75em)}
      }
    })
  }


  /*---------[Equations]--------*/

  // Setup custom numbering of math functions: (chapter.number)
  set math.equation(number-align: bottom + end, supplement: none, numbering: num => {
      let count = counter(heading.where(level: 1)).get().first()
      numbering("(1.1)", count, num)
  })


  /*--------[References]--------*/

  // color name and date in citations
  show cite: it => {
    show regex("[\d\p{L}\s.]+"): set text(accent-color)
    it
  }

  // Give different types of references a custom style
  show ref: it => {
    let e = it.element

    if e == none {
      it
    // reference figures as "Fig. {chapter}.{figure}[subfigure]"
    } else if e.func() == figure {
      if e.kind == "subfigure" {
        let q = query(figure.where(outlined: true).before(it.target)).last()
        // display mainfigure and subfigure counter after each other if subfigure is referenced
        [Figure~] + link(
          e.location(),
          numbering(q.numbering,
            ..counter(heading.where(level: 1)).at(e.location()),
            ..counter(figure.where(kind: q.kind)).at(q.location())
          ) +
          numbering("a", ..counter(figure.where(kind: "subfigure")).at(e.location()))
        )
      } else {
        if e.kind == "code" [Algorithm~] else if e.kind == table [Table~] else [Figure~] + link(e.location(),
          numbering(e.numbering,
            ..counter(heading.where(level: 1)).at(e.location()),
            ..counter(figure.where(kind: e.kind)).at(e.location())
          )
        )
      }
    // color equation numbering, but not parentheses
    } else if e.func() == math.equation {
      show regex("[^()]+"): set text(accent-color)
      it
    // reference l1 headers has "Chapter" and all others as "Section"
    } else if e.func() == heading {
      if e.level == 1 [Chapter~] else [Section~]
      link(e.location(), numbering(e.numbering, ..counter(heading).at(e.location())))
    } else {
      it
    }
  }


  /*-------[Chapter Start]------*/

  show heading.where(level: 1): it => {
    // Reset figure and equation numbering on every chapter start
    for kind in (image, table, raw, "code") {
      counter(figure.where(kind: kind)).update(0)
    }

    counter(figure).update(0)
    counter(math.equation).update(0)

    // Start chapter headings on a new page
    state("content.switch").update(false)
    pagebreak(weak: true, to:"odd")
    state("content.switch").update(true)

    it
  }


   //===========================//
  //------ Front Matter -------//
 //===========================//

  in-body.update(false)

  set page(numbering: "i")

  frontmatter


   //===========================//
  //----------- Body ----------//
 //===========================//

  in-body.update(true)

  set page(numbering: "1")
  set heading(numbering: "1.1")

  counter(page).update(1)
  counter(heading).update(0)

  // Give links the accent color
  show link: set text(accent-color)

  body


   //===========================//
  //--------- Appendix --------//
 //===========================//

  set heading(numbering: "A.1")

  counter(heading).update(0)

  appendix


   //===========================//
  //------- Back Matter -------//
 //===========================//

  in-body.update(false)

  set page(header: [])

  backmatter
}
