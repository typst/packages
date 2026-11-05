#import "@preview/hydra:0.6.3": hydra

#import "src/utils.typ": *


/*--------[Accent Color]--------*/

#let accent-color = rgb(165, 28, 48)


/*---------[Math Font]----------*/

// Libertinus, with script letters and integrals from New Computer Modern, which also serves as a fallback
#let math-font = (
  (
    name: "New Computer Modern Math",
    covers: regex("[\u{1D49C}-\u{1D503}\u{212C}\u{2130}\u{2131}\u{210B}\u{2110}\u{2112}\u{2133}\u{211B}\u{212F}\u{210A}\u{2134}\u{222B}-\u{2233}]"),
  ),
  "Libertinus Math",
  "New Computer Modern Math",
)

#let thesis(
  title: "",
  author: "",
  date: datetime.today(),
  lang: "en",
  body-font: "IBM Plex Sans",
  heading-font: "IBM Plex Serif",
  caption-font: auto,
  math-font: math-font,
  code-font: "IBM Plex Mono",
  body-size: 11pt,
  accent-color: accent-color,
  print: false,
  frontmatter: none,
  appendix: none,
  backmatter: none,
  body,
) = {
  /*--------[Parameters]--------*/

  let h1-size = 22pt
  let h2-size = 14pt
  let caption-size = body-size - 1pt
  let caption-font = if caption-font == auto { body-font } else { caption-font }

  /*-----[General Settings]-----*/

  set document(title: title, author: author, date: date)

  show std.title: it => text(font: heading-font, it)

  // Use measures to define text layout
  set text(font: body-font, size: body-size, lang: lang)
  show math.equation: set text(font: math-font, fallback: false)
  show raw: set text(font: (code-font, "DejaVu Sans Mono"))
  show raw.where(block: true): block.with(
    width: 100%,
    fill: luma(98%),
    stroke: 0.5pt + luma(70%),
    radius: 3pt,
    inset: 0.9em,
  )

  /*----[Fancy Hydra-Header]----*/

  let custom-header(title, dir, it) = {
    stack(
      dir: dir,
      [
        #if it.numbering != none [
          *#title #numbering(it.numbering, ..counter(heading).at(it.location()))*
        ]
        #h(7pt)
        #it.body
      ],
      [#h(7pt)|#h(7pt)],
      counter(page).display(),
    )
    v(5pt)
  }

  /*-------[Page Helpers]-------*/

  // Whether the page belongs to the body (incl. appendix)
  let is-body-page(page-num) = {
    let start = query(<benplate-body-start>).first().location().page()
    let end = query(<benplate-body-end>).first().location().page()
    start <= page-num and page-num <= end
  }

  // Whether the page was left blank by a page break to the next odd page
  let is-blank-page(page-num) = {
    let chapters = query(heading.where(level: 1))
    let next = chapters.position(h => h.location().page() > page-num)
    if next == none { return false }

    // Only consider breaks between the previous and the next chapter
    let next-loc = chapters.at(next).location()
    let breaks = selector(<benplate-break>).before(next-loc)
    if next > 0 { breaks = breaks.after(chapters.at(next - 1).location()) }

    let break-pages = query(breaks).map(m => m.location().page()).filter(p => p < next-loc.page())
    break-pages.len() > 0 and break-pages.last() < page-num
  }

  set page(
    paper: "a4",
    // Leave room for the binding in print, otherwise center the text on the page
    margin: if print {
      (bottom: 3cm, top: 4cm, inside: 4cm, outside: 3cm)
    } else {
      (bottom: 3cm, top: 4cm, x: 3.5cm)
    },
    header: context {
      // Only show headers on non-empty pages of the body, except where a chapter starts
      let page-num = here().page()
      let chapter-start = query(heading.where(level: 1)).any(h => h.location().page() == page-num)
      if not is-body-page(page-num) or is-blank-page(page-num) or chapter-start {
        return
      }

      // select header type based on page number
      if calc.even(page-num) {
        align(left, hydra(1, display: (_, it) => {
          custom-header("Chapter", rtl, it) // Chapter title on the left of even pages
        }))
      } else {
        align(right, hydra(
          2,
          display: (_, it) => {
            custom-header("Section", ltr, it) // Section title on the right of odd pages
          },
          skip-starting: false,
        ))
      }
    },
    // Show page numbers in the footer outside the body, where there is no header
    footer: context {
      let page-num = here().page()
      if page.numbering == none or is-body-page(page-num) or is-blank-page(page-num) { return }

      align(center, counter(page).display())
    },
  )

  set par(
    leading: 0.75em,
    spacing: 1.3em,
    justify: true,
  )

  /*---------[Headings]---------*/

  show heading: it => {
    v(2.5em, weak: true)
    it
    v(1.5em, weak: true)
  }

  show heading.where(level: 1): it => [
    // Reset figure and equation numbering on every chapter start
    #for kind in (image, table, raw, "code") {
      counter(figure.where(kind: kind)).update(0)
    }
    #counter(math.equation).update(0)

    // Start chapter headings on a new page
    #metadata(none) <benplate-break>
    #pagebreak(weak: true, to: "odd")

    #set text(size: h1-size, weight: "medium", font: heading-font)
    #set align(right)

    #if it.numbering != none {
      v(30pt)
      box(
        height: 30pt,
        stroke: (left: 0.75pt),
        inset: (left: 0.75em),
        align(horizon, text(26pt, counter(heading).display())),
      )
    }

    #it.body
    #v(30pt)
  ]

  show heading.where(level: 2): it => { text(size: h2-size, it) }
  show heading.where(level: 4): it => { text(weight: "semibold", it.body) + h(1em) }
  show heading.where(level: 5): it => { text(weight: "semibold", it.body) }

  /*----------[Figures]---------*/

  // Number figures as (chapter).(figure), e.g. "2.1" in the body and "A.1" in the appendix
  let chapter-numbering = state("chapter-numbering", "1")
  let in-chapter(pattern) = (..n) => {
    let chapter = counter(heading).get().first()
    numbering(pattern.replace("C", chapter-numbering.get()), chapter, ..n)
  }

  set figure(numbering: in-chapter("C.1"), placement: auto)

  // Restart subfigure numbering in every figure
  show figure: it => {
    if it.kind != "subfigure" { counter(figure.where(kind: "subfigure")).update(0) }
    it
  }

  // Draw horizontal rules only, unless a table has its own stroke
  let table-stroke = (_, y) => if y == 0 { (bottom: 0.5pt) }
  set table(stroke: table-stroke)

  show table: it => {
    if it.stroke != table-stroke { return it }

    layout(size => block(
      width: measure(it, width: size.width).width,
      stroke: (y: 0.75pt),
      it,
    ))
  }

  show figure.where(kind: "code"): set figure(supplement: [Algorithm])
  show figure.where(kind: "subfigure"): set figure(supplement: [], numbering: "(a)", outlined: false, placement: none)

  show figure.caption: it => {
    set text(font: caption-font, size: caption-size)

    layout(size => {
      let number = it.counter.display(it.numbering)

      // Make figure title bold and caption italic
      let caption = {
        if it.kind == "subfigure" {
          // don't display separator if it's a subfigure
          strong[#it.supplement #number ]
        } else {
          strong[#it.supplement #number#it.separator]
        }
        emph(it.body)

        // add spacing between mainfigure caption and subfigure
        if it.kind == "subfigure" and it.position == bottom { v(0.75em) }
      }

      // Center captions that fit on one line, longer ones span the full width
      if measure(caption).width > size.width {
        block(width: 100%, align(left, caption))
      } else {
        caption
      }
    })
  }

  /*---------[Equations]--------*/

  // Setup custom numbering of math functions: (chapter.number)
  set math.equation(number-align: bottom + end, supplement: none, numbering: (..n) => text(
    font: body-font,
    in-chapter("(C.1)")(..n),
  ))

  /*--------[References]--------*/

  // Color the content of citations, but not the brackets and separators around it
  show cite: it => {
    show regex("[^\[\](),;:]+"): set text(accent-color)
    it
  }

  // Give different types of references a custom style
  show ref: it => {
    let e = it.element
    if e == none { return it }

    // color figure numbering, but not the supplement in front of it
    if e.func() == figure {
      show regex("\u{a0}.+"): set text(accent-color)

      if e.kind == "subfigure" {
        // reference subfigures as "{supplement} {chapter}.{figure}{subfigure}"
        let parent = query(figure.where(outlined: true).before(e.location())).last()
        let loc = parent.location()
        parent.supplement
        link(e.location(), {
          [~]
          numbering(chapter-numbering.at(loc) + ".1", counter(heading).at(loc).first(), ..parent.counter.at(loc))
          numbering("a", ..e.counter.at(e.location()))
        })
      } else {
        it
      }
      // color equation numbering, but not parentheses
    } else if e.func() == math.equation {
      show regex("[^()]+"): set text(accent-color)
      it
      // reference l1 headers has "Chapter" and all others as "Section"
    } else if e.func() == heading {
      if e.numbering == none {
        link(e.location(), e.body)
      } else {
        if e.level == 1 [Chapter~] else [Section~]
        link(e.location(), numbering(e.numbering, ..counter(heading).at(e.location())))
      }
    } else {
      it
    }
  }

  //===========================//
  //------ Front Matter -------//
  //===========================//

  set page(numbering: "i")

  frontmatter

  [#metadata(none) <benplate-break>]
  pagebreak(weak: true, to: "odd")

  //===========================//
  //----------- Body ----------//
  //===========================//

  [#metadata(none) <benplate-body-start>]

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
  chapter-numbering.update("A")

  appendix

  [#metadata(none) <benplate-body-end>]
  set heading(numbering: none)

  //===========================//
  //------- Back Matter -------//
  //===========================//

  backmatter
}
