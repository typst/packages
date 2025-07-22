#import "@preview/glossarium:0.5.7": make-glossary, register-glossary, print-glossary, gls, glspl

#import "content/titlepage.typ": titlepage
#import "content/declaration-of-authorship.typ": declaration-of-authorship

#let hdm-stuttgart(
    metadata, date, content,

    logo: none,
    bib: none,
    bib-style: "chicago-notes",
    glossary: none, acronyms: none, abstract-de: none, abstract-en: none
) = {
    assert(metadata != none, message: "Metadata missing")
    let data = metadata.data
    let layout = metadata.layout
    let resources = yaml("resources.yaml").at(metadata.lang).headings

    show: make-glossary

    // Typography
    set par(leading: 0.8em, spacing: 1.5em)
    set text(lang: metadata.lang, font: layout.fonts.body, size: 12pt)
    // https://github.com/typst/typst/discussions/2919#discussioncomment-7831644
    // "The defaults are 1.4em for level 1, 1.2em for level 2, and 1em for everything else"
    // default font is 12pt, with Major Second we get:
    // h4: 17pt
    // h3: 19pt
    // h2: 21pt
    // h1: 24pt
    show heading: set par(leading: 0.5em)
    show heading: set text(lang: metadata.lang, font: layout.fonts.heading)
    show heading: set block(spacing: 0pt, above: 1.5em, below: 1em)
    set heading(hanging-indent: 0pt)
    //
    show heading.where(level: 4): set text(size: 17pt)
    show heading.where(level: 3): set text(size: 19pt)
    show heading.where(level: 2): set text(size: 21pt)
    show heading.where(level: 1): set text(size: 24pt)

    set document(
        title: data.title,
        author: data.authors.map(a => a.Name).join(", "),
        description: data.title + ": " + data.subtitle,
        date: date)
    set page(
        paper: "a4",
        margin: (
            top: 3.5cm,
            bottom: 2.5cm,
            x: 2.5cm,
        ),
        header: context {
            let current = here().page()

            if current > 2 {
                // headings on even pages (if available)
                if calc.even(current) {
                    let headingCandidates = heading.where(level: 1)

                    let previousHeadings = query(headingCandidates.before(here()))
                    let currentHeadings  = query(headingCandidates).filter(h => current == h.location().page())

                    let renderHeading(body) = {
                        block()[
                            #show heading: set text(size: 16pt, weight: "semibold")
                            #body
                        ]
                    }

                    // check if we have headings on page and if the first one is numbered
                    // and thus should appear in the header
                    if currentHeadings.len() > 0 {
                        if currentHeadings.first().numbering == "1.1." {
                            renderHeading(currentHeadings.first())
                        }
                    } else if previousHeadings.len() > 0 and previousHeadings.last().numbering == "1.1." {
                        renderHeading(previousHeadings.last())
                    }

                // No headings, just logo on odd pages
                } else {
                    set image(height: 2.5em)
                    align(right, logo)
                }

                line(length: 100%, stroke: 0.25pt + black)
            }
        },
        footer: context {
            let current = here().page()
            if current > 2 {
                line(length: 100%, stroke: 0.25pt + black)
                if page.numbering != none {
                    align(center, counter(page).display())
                }
            }
        }
    )
    set page(numbering: none)
    set heading(numbering: none, outlined: false)
    register-glossary(acronyms)
    register-glossary(glossary)

    titlepage(metadata, logo, date)

    set par(justify: true)

    declaration-of-authorship(
        data.authors.map(a => a.Name),
        data.title + ": " + data.subtitle,
        layout.Location, date)
    pagebreak()

    // Abstracts
    let all_resources = yaml("resources.yaml")
    if abstract-en != none {
        heading(all_resources.at("en").headings.Abstract, bookmarked: true)
        show: abstract-en
    }
    if abstract-de != none {
        pagebreak(weak: true)
        heading(all_resources.at("de").headings.Abstract, bookmarked: true)
        show: abstract-de
    }

    set par(justify: false)

    pagebreak(weak: true)
    show outline: set heading(bookmarked: true)
    outline()

    set page(numbering: "I")
    set heading(outlined: true)
    show outline: set heading(outlined: true)
    counter(page).update(1)
    pagebreak(weak: true)

    // Acronyms
    heading(resources.Acronyms)
    print-glossary(acronyms)
    pagebreak(weak: true)

    // Glossary
    heading(resources.Glossary)
    print-glossary(glossary)
    pagebreak(weak: true)

    // Figures
    outline(
        title: resources.Figures,
        target: figure.where(kind: image))
    pagebreak(weak: true)

    // Figures
    outline(
        title: resources.Tables,
        target: figure.where(kind: table))
    pagebreak(weak: true)

    set heading(numbering: "1.1.")
    set page(numbering: "1 / 1")
    counter(page).update(1)
    pagebreak()

    // <CONTENT>
    set par(justify: true)

    content

    set par(justify: false)
    // </CONTENT>

    pagebreak(weak: true)
    counter(page).update(1)
    set page(numbering: "a")

    if bib != none {
        set bibliography(style: bib-style)
        bib
    }
}