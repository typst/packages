#import "lib.typ": *
#import "@preview/ccicons:1.0.1": cc-by-nc-nd-eu

#let upb-cn-baseline(title, author, body) = {
  set document(title: title)
  if author != none {
    set document(author: author)
  }

  set page(
    margin: (top: 1.3in, left: 1in, right: 1in, bottom: 1in),
  )
  
  // Text size and paragraph spacing
  set text(size: 9.95pt) // Compatibility with the Latex template
  set par(leading: 0.68em, justify: true, spacing: 1.3em)
  set grid(column-gutter: 1em, row-gutter: 0.8em)

  // Headings
  set heading(numbering: "1.1")
  show heading: set text(font: heading-font)
  show heading: set block(above: 1.3em, below: 1.3em)
  show heading: it => {
    block(
      if it.numbering == none {
        it.body
      } else {
        counter(heading).display(it.numbering) + h(1em) + it.body
      }
    )
  }

  // Lists and enumerations
  set list(indent: 1em, marker: ([•], [-]))
  set enum(indent: 1em)
  set enum(numbering: "1.a.i.")

  // Tables
  set table(
    stroke: (x, y) => (
      top: if y == 0 { 1pt } else { 0pt },
      bottom: 1pt,
    ),
  )
  set table.hline(stroke: 0.5pt)
  show figure.where(kind: table): set figure.caption(position: top)

  // Colorful hyperlinks
  show link: set text(fill: upb-colors.ultra-blue)

  // Gray background for code blocks
  show raw.where(block: true): set block(fill: luma(245), width: 100%, inset: .5em)

  // Figures
  set figure(placement: top)
  show figure: set block(above: 2em, below: 2em)
  show figure.where(kind: image): set figure(gap: 1.5em)
  show figure.caption: it => context {
    strong(it.supplement + " " + it.counter.display(it.numbering) + it.separator)
    it.body
  }

  set bibliography(title: "References")
  
  body
}

#let upb-cn-report(
  title: "Title",
  author: none,
  matriculation-number: none,
  left-header: none, // defaults to title
  right-header: none, // defaults to author
  meta: none, // e.g. (([key1], [value1]), ([key2], [value2]))
  body,
) = {
  if left-header == none {
    left-header = title
  }
  if right-header == none {
    right-header = author
  }

  show: upb-cn-baseline.with(title, author)

  // Headings
  show heading.where(level: 1): set text(
    size: 0.86em,
    fill: upb-colors.ultra-blue,
  )
  show heading.where(level: 2): set text(size: 0.97em)
  show heading.where(level: 3): set text(size: 1.05em)

  set page(
    numbering: "1",
    header: context {
        set align(bottom)
        if(counter(page).get().at(0) == 1) {
          // First page
          set align(center)
          box(
            width: 100% + 36pt * 2,
            overlay(
              white.transparentize(50%),
              stack(
                dir: ltr,
                image("upb-logo.svg", height: 42pt),
                h(1fr),
                stack(image("upb-triangles.svg", height: 27.7pt), v(1.8pt)),
                h(3.8pt),
              ),
            ),
          )
          v(-3pt)
        } else {
          // All other pages
          left-header
          h(1fr)
          right-header
          
          v(-0.9em)
          line(length: 100%, stroke: .4pt)
          v(-.7em)
        }
    },
    footer: context {
      set align(right)
      counter(page).display()
      "/"
      numbering(page.numbering, ..counter(page).final())
    }
  )

  {
    set text(size: 1.2em)
    heading(numbering: none,  outlined: false, title)
  }

  v(-.5em)

  if author != none {
    set text(weight: "bold", font: heading-font, size: 1.2em)
    author
    if matriculation-number != none [~(#matriculation-number)]
    v(.5em)
  }

  if meta != none {
    notebox(
      grid(
        columns: 2,
        ..meta.map(((key, value)) => ([*#key:*], value)).flatten(),
      )
    )
  }

  body
}

#let upb-cn-thesis(
  title: "The Title",
  author: "The Author",
  degree: "Master of Sciences",
  submission-date: datetime.today().display("[month repr:long] [day], [year]"),
  second-reviewer: "The Second Reviewer",
  supervisors: ("Supervisor 1",),
  acknowledgement: lorem(100), // or `none`
  abstract: lorem(100),
  body,
) = {
  show: upb-cn-baseline.with(title, author)

  // https://github.com/typst/typst/issues/2722#issuecomment-2481508318
  show pagebreak: it => {
    [#metadata(none) <empty-page-start>]
    it
    [#metadata(none) <empty-page-end>]
  }

  let is-page-empty() = {
    let pageNumber = here().page()
    query(selector.or(<empty-page-start>, <empty-page-end>)).chunks(2).any(((start, end)) => {
      start.location().page() < pageNumber and pageNumber < end.location().page()
    })
  }

  let is-primary-heading-on-page() = {
    return query(
        selector(heading.where(level: 1))
      )
      .filter(heading => heading.location().page() == here().page())
      .len() > 0
  }

  // Primary/Chapter headings
  show heading.where(level: 1): it => {
    pagebreak(weak: true, to: "odd")
    set align(right)
    set text(font: "Libertinus Serif")
    v(0.3em)
    if it.numbering != none {
      box(
        width: 2cm,
        height: 2cm,
        fill: upb-colors.ultra-blue,
        align(
          center+horizon,
          text(
            fill: white,
            size: 0.85cm,
            counter(heading).display(it.numbering),
          ),
        )
      )
    }
    v(0.4em)
    text(
      size: 1.475em,
      weight: "bold",
      fill: upb-colors.ultra-blue,
      smallcaps(it.body),
    )
    v(2.7em)
  }

  // Section headings
  show heading.where(level: 2): set text(
    fill: upb-colors.ultra-blue,
  )
  show heading.where(level: 3): set text(size: 1em)
  show heading.where(level: 4): set text(size: 0.9em)

  // Title page
  {
    set text(size: 1.2em)
    set par(spacing: 0.85em)
    align(center)[
      #v(1mm)
      #image("upb-logo.svg", height: 24mm)
      #v(30pt)
      #text(weight: "bold", size: 1.44em, title)
      #v(43pt)

      by

      #text(size: 1.2em, author)
      #v(45pt)

      Submitted to the Computer Networks Group \
      in partial fulfillment of the requirements for the degree of
      #v(14pt)
      #smallcaps(text(size: 1.2em, degree))

      at

      #smallcaps(text(size: 1.2em)[Paderborn University])

      #submission-date
      #v(77pt)

      #grid(
        columns: 2,
        align: (right, left),
        row-gutter: 0.625em,
        [First reviewer:], [Prof. Dr. Lin Wang],
        [Second reviewer:], second-reviewer,
        "Daily supervisor" + if supervisors.len() > 1 {"s"} else {""} + ":",
        supervisors.join(", "),
      )
      #v(50pt)

      Computer Networks Group \
      Department of Computer Science \
      Paderborn University
    ]
  }

  // Copyright page
  pagebreak()
  [
    #title

    #author

    The research reported in this thesis has been carried out in the Computer Networks group at the Department of Computer Science of Paderborn University.

    #v(1fr)

    Copyright #sym.copyright#datetime.today().year() #author

    #scale(114%, origin: left + horizon, cc-by-nc-nd-eu)

    Unless otherwise stated, the content of this work is licensed under Attribution-NonCommercial-NoDerivs~4.0 International.
    To view a copy of this license, visit: https://creativecommons.org/licenses/by-nc-nd/4.0/.
  ]

  let preface-heading = (title) => {
    heading(outlined: false, numbering: none, title)
    v(-1em)
  }

  // Legal page
  [
    #preface-heading(text(lang: "de", [Erklärung]))

    #text(lang: "de")[
      Ich versichere, dass ich die Arbeit ohne fremde Hilfe und ohne Benutzung anderer als der angegebenen Quellen angefertigt habe und dass die Arbeit in gleicher oder ähnlicher Form noch keiner anderen Prüfungsbehörde vorgelegen hat und von dieser als Teil einer Prüfungsleistung angenommen worden ist.
      Alle Ausführungen, die wörtlich oder sinngemäß übernommen worden sind, sind als solche gekennzeichnet.
    ]

    _I certify that I have written this thesis without outside help and without using sources other than those specified and that the thesis has not been submitted in the same or a similar form to any other examination authority and has not been accepted by them as part of an examination.
    All statements that have been adopted verbatim or analogously are labeled as such._

    #v(6.5em)

    #block(
      inset: (x: .5em),
      grid(
        columns: (1fr, 1fr),
        column-gutter: 5.75em,
        row-gutter: .7em,
        align: center,
        ..(
          2 * (line(length: 100%, stroke: .4pt) + v(-0.5em),)
        ),
        text(lang: "de", [Ort, Datum]),
        text(lang: "de", [Unterschrift]),
        [_Place, Date_],
        [_Signature_]
      )
    )
  ]

  // Acknowledgement
  if acknowledgement != none {
    preface-heading([Acknowledgement])
    acknowledgement
  }

  // Abstract
  preface-heading([Abstract])
  abstract
  pagebreak(to: "odd", weak: true)

  set page(
    numbering: "i",
    // `scrbook`-style headings:
    header: context if not is-page-empty() and not is-primary-heading-on-page() {
      let isCurrentPageLeft = calc.rem(here().page(), 2) == 0
      
      let primaryHeadingsBeforeThisPage = query(
        selector(heading.where(level: 1)).before(here()),
      )
      if primaryHeadingsBeforeThisPage.len() == 0 {
        // No primary headings up to this point - omitting the header
        return
      }

      let primaryHeading = primaryHeadingsBeforeThisPage.last()

      if primaryHeading != none {
        if isCurrentPageLeft {
          if(primaryHeading.numbering != none) {
            numbering(primaryHeading.numbering, ..counter(heading).at(primaryHeading.location())) + ". "
          }
          upper(to-string(primaryHeading.body))
        } else {
          // Find last secondary heading after the primary heading, up to this page
          let secondaryHeadingsUpToThisPage = query(
            selector(heading.where(level: 2)).after(primaryHeading.location()),
          ).filter(
            heading => heading.location().page() <= here().page()
          )

          if secondaryHeadingsUpToThisPage.len() > 0 {
            let lastSecondaryHeading = secondaryHeadingsUpToThisPage.last()
            let lastSecondaryHeadingNumber = numbering(heading.numbering, ..counter(heading).at(lastSecondaryHeading.location()))
            
            align(right,
              upper(
                lastSecondaryHeadingNumber + ".  " + to-string(lastSecondaryHeading)
              )
            )
          } else {
            // Some content to avoid layout divergence
            sym.space
          }
        }

        v(-0.9em)
        line(length: 100%, stroke: .4pt)
        v(-.7em)
      }
    },
    footer: context if not is-page-empty() and not (is-primary-heading-on-page()) {
      let isEvenPage = calc.even(here().page())
      set align(if isEvenPage { left } else { right })
      counter(page).display(page.numbering)
    },
  )

  counter(page).update(1)

  // Outline styling
  set outline(title: none, depth: 3)
  set outline.entry(
    fill: block(
      inset: (right: 1.2em),
      repeat([.], gap: 0.5em, justify: false),
    ),
  )
  show outline.entry: set align(right)
  show outline.entry: set block(above: 1.28em)
  show outline.entry: it => {
    show link: set text(fill: black)
    link(
      it.element.location(),
      it.indented(it.prefix(), it.inner(), gap: 1em),
    )
  }

  let outlinePage = (title, target) => context {
    if query(selector(target)).len() > 0 {
      preface-heading(title)
      v(1.5em)
      outline(target: target)
    }
  }

  // Contents
  {
    show outline.entry.where(level: 1): it => strong(it)
    show outline.entry.where(level: 1): set outline.entry(fill: none)
    show outline.entry.where(level: 1): set block(above: 2.28em)
    outlinePage([Contents], heading)
  }

  outlinePage([List of Figures], figure.where(kind: image))
  outlinePage([List of Tables], figure.where(kind: table))

  pagebreak(weak: true, to: "odd")

  // Page numbering and headers
  set page(numbering: "1")
  counter(page).update(1)

  // Equation numbering
  set math.equation(numbering: "(1)")

  // Heading numbering and names
  set heading(
    numbering: "1.1",
    supplement: it => {
      if (it.has("level")) {
        if it.level == 1 [Chapter]
        else [Section]
      }
    },
  )

  // Bibliography
  set bibliography(title: none)
  show bibliography: it => {
    pagebreak(to: "odd")
    heading(outlined: false, numbering: none, [Bibliography])
    it
  }

  body
}
