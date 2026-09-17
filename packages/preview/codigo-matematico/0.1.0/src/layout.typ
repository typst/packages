// Page, title, outline, and heading layout helpers.

#import "./palette.typ": *
#import "./settings.typ": *
#import "./counters.typ": *


#let figure-numbering(chapter-depth) = n => context {
  let chapter-number = current-heading-number(chapter-depth)
  str(chapter-number) + "." + str(n)
}

#let page-header(tablet) = if tablet {
  none
} else {
  context {
    let headings = query(selector(heading).before(here()))
    if headings.len() == 0 {
      return
    }

    let heading = headings.last()
    let this-page = counter(page).display()

    block[
      #text(style: "italic")[
        // TODO Solucionar el problema con esto.
        // #counter(selector(heading).before(here())).display(heading.numbering)
        ---
        #heading.body
        #h(1fr)
        #this-page
      ]
    ]
  }
}

#let page-settings(sheet, tablet) = (
  fill: palette.bg,
  paper: if tablet { "a5" } else { sheet },
  margin: if tablet { (x: 8pt, y: 8pt) } else { auto },
  footer: none,
  header: page-header(tablet),
)

#let title-page(document-title, authors, abstract, lang: "en", web: false) = if web {
  html.header(class: "document-header")[
    #title(document-title)

    #if authors.len() > 0 {
      html.ul(class: "document-authors")[
        #for author in authors {
          let affiliation = author.at("affiliation", default: none)
          let email = author.at("email", default: none)
          html.li(class: "document-author")[
            #html.span(class: "document-author__name")[#author.name]
            #if affiliation != none {
              html.span(class: "document-author__affiliation")[#affiliation]
            }
            #if email != none {
              html.span(class: "document-author__email")[
                #link("mailto:" + email)[#email]
              ]
            }
          ]
        }
      ]
    }

    #if abstract != none and abstract != [] {
      html.section(class: "document-abstract")[
        #html.div(class: "document-abstract__label")[
          #if lang == "es" { [Resumen] } else { [Abstract] }
        ]
        #abstract
      ]
    }
  ]
} else {
  set align(center + horizon)
  text(weight: heading_weight, size: 18pt, document-title)

  v(2em)

  let ncols = calc.min(authors.len(), 3)
  grid(
    columns: (1fr,) * ncols,
    row-gutter: 24pt,
    ..authors.map(author => [#author.name \ #author.affiliation \ #link("mailto:" + author.email)]),
  )

  v(3em)

  par(justify: false)[
    *Abstract* \
    #abstract
  ]
}

#let outline-page(depth, web: false) = if web {
  html.section(class: "table-of-contents")[
    #outline(depth: depth)
  ]
} else {
  pagebreak()
  set align(left + top)
  v(3cm)
  outline(depth: depth)
  pagebreak()
}

#let heading-layout(parts, chapter-depth, reset-depth, web: false) = it => {
  let section-depth = chapter-depth + 1
  let subsection-depth = chapter-depth + 2

  if it.level == reset-depth and it.supplement != [Outline] {
    reset-section-counters()
  }

  if it.level == chapter-depth and it.supplement != [Outline] {
    reset-figure-counters()
  }

  if web {
    it
  } else if it.level == 1 or (parts and it.level == chapter-depth) {
    if it.supplement != [Outline] {
      pagebreak(weak: true)
    }
    v(4cm)
    it
    v(1.3em)
  } else if it.level == section-depth {
    v(2cm)
    it
    v(1em)
  } else if it.level == subsection-depth {
    v(1.5em)
    it
    v(0.7em)
  } else {
    it
  }
}
