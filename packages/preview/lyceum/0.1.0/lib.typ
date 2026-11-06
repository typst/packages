#import "meta-parsing.typ": meta-parse

// Auxiliary FMT function
#let FMT(w, size: 12pt) = {
  if type(w) == type("") {
    if      w == "top-gap" { return 7.5 * size }        // Shared by all level-1 headings
    else if w == "sq-side" { return 5.0 * size }        // Shaded square within the top-gap
    else if w == "it-hght" { return 6.5 * size }        // Room for level-1 heading bodies
    else if w == "it-size" { return 2.0 * size }        // Level-1 heading text size
    else if w == "sn-size" { return 3.5 * size }        // Square-bound number text-size
    else if w == "sq-shad" { return rgb("#00000070") }  // Shaded square shade color
    else if w == "sq-text" { return rgb("#000000A0") }  // Shaded text color
  }
  return none
}

//--------------------------------------------------------------------------------------------//
//                            Fundamental, Front-Matter show rule                             //
//--------------------------------------------------------------------------------------------//

#let FRONT-MATTER(
  // Document metadata
  title: (
    title: "Default Lyceum Title",
    subtitle: "A Default Exposition",
    sep: " \u{2014} ",
    short: "Default",
  ),
  authors: (
    (
      preffix: "Dr.",
      given-name: "Lyceum",
      name: "Default",
      suffix: "Jr.",
      email: "default@organized.org",
      affiliation: "Organized Organization",
      location: "Foo City, Bar Country",
    ),
  ),
  editors: (
    (
      preffix: "Dr.",
      given-name: "Erudit",
      name: "Wise",
      suffix: "FRS",
    ),
  ),
  publisher: "Default Lyceum Publisher",
  location: "Default City, Lyceum Country",
  affiliated: (
    illustrator: (
      "Alfreda D. Ballew",
      "Jim M. McKinnis",
    ),
    organizer: "Nicholas D. Gladstone",
  ),
  keywords: ("lyceum", "default"),
  date: auto,
  // Document general format
  page-size: (width: 155mm, height: 230mm),
  page-margin: (inside: 30mm, rest: 25mm),
  page-binding: left,
  page-fill: color.hsl(45deg, 15%, 85%),  // ivory
  text-font: ("EB Garamond", "Libertinus Serif"),
  text-size: 12pt,
  lang-name: "en",
  par-indent: 12mm,
  front-matter-material
) = {
  // Parse metadata information
  let (META, AUTHORS) = meta-parse((
    title: title,
    authors: authors,
    editors: editors,
    publisher: publisher,
    location: location,
    affiliated: affiliated,
    keywords: keywords,
    date: date,
    lang: lang-name,
  ))

  // Sets up document metadata
  set document(
    title: [#META.title.value],
    author: AUTHORS.join(" and "),
    keywords: META.keywords,
  )

  // Page parameters controlled by input arguments
  set page(
    width: page-size.width,
    height: page-size.height,
    flipped: false,
    margin: page-margin,
    binding: page-binding,
    columns: 1,
    fill: page-fill,
    numbering: "i",
    footer: context {
      let cur-pag-num = counter(page).at(here()).first()
      let ALIGN = if calc.even(cur-pag-num) { left } else { right }
      set align(ALIGN)
      [#counter(page).display("i")]
    },
    header: [],
  )

  // Paragraph settings
  set par(
    leading: 0.65em,
    justify: true,
    linebreaks: "optimized",
    first-line-indent: par-indent,
    hanging-indent: 0pt,
  )

  // Text parameters controlled by input arguments
  set text(
    font: text-font,
    fallback: true,
    weight: "regular",
    size: text-size,
    lang: lang-name,
  )

  // Heading numbering and outlining controls
  set heading(
    numbering: none,
    outlined: true,
  )

  // Main headings in FRONT-MATTER
  show heading.where(level: 1): it => {
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(math.equation).update(0)
    // Layout
    pagebreak(weak: true, to: "odd")
    v(FMT("top-gap", size: text-size))
    block(
      width: 100%,
      height: FMT("it-hght", size: text-size),
      align(
        center + top,
        text(
          font: ("EB Garamond", "Libertinus Serif"),
          size: FMT("it-size", size: text-size),
          weight: "extrabold",
        )[#it.body]
      )
    )
  }

  // Math equation numbering and layout settings
  set math.equation(
    block: true,
    numbering: "(1.1)",
    number-align: right,
  )

  // Metadata writings
  [#metadata(META)<lyceum-meta>]

  // Writes the root metadata into the document
  [#metadata(AUTHORS)<lyceum-auth>]

  // Writes the self-bib-entry
  [#metadata(META.self-bib-entry.join("\n"))<self-bib-entry>]

  // Title page
  page(
    header: [],
    footer: [],
  )[
    #let PARS = (auth-chunk-size: 2, )
    // Book Title on Title Page
    // #v(1fr)
    #if META.title.title.len() > 0 {
      if META.title.subtitle.len() > 0 {
        block(width: 100%,)[
          #align(center, text(size: (8/3) * text-size)[*#META.title.title* \ ])
          #align(center, text(size: (6/3) * text-size)[*#META.title.subtitle*])
        ]
      } else {
        block(width: 100%,)[
          #align(center, text(size: (8/3) * text-size)[*#META.title.title*])
        ]
      }
    } else {
      block(width: 100%,)[
        #align(center, text(size: (8/3) * text-size)[*#META.title.value*])
      ]
    }
    #v(4fr)
    // First Author on Title Page
    #block(width: 100%,)[
      #let CHU = range(META.authors.len()).chunks(PARS.auth-chunk-size)
      #for the-CHU in CHU {
        grid(
          columns: (1fr,) * the-CHU.len(),
          gutter: 1em,
          ..the-CHU.map(
            auth-indx => [
              #align(center)[
                #set text(size: (4/3) * text-size)
                *#META.authors.at(auth-indx).name,*
                *#META.authors.at(auth-indx).given-name* \
                #set text(size: (3/3) * text-size)
                #META.authors.at(auth-indx).affiliation \
                #set text(size: (5/6) * text-size)
                #raw(META.authors.at(auth-indx).email) \
                #META.authors.at(auth-indx).location
              ]
            ]
          )
        )
        if the-CHU.last() < CHU.flatten().last() [
          #v((4/3) * text-size)
        ]
      }
    ]
    #v(4fr)
    // Publisher block
    #block(width: 100%,)[
      #set text(size: text-size)
      #META.publisher, \
      #META.location
    ]
    #v(1fr)
    // Date block
    #block(width: 100%,)[
      #set text(size: text-size)
      #align(center)[#META.date.display()]
    ]
  ]

  // Front-matter material
  front-matter-material
}


//--------------------------------------------------------------------------------------------//
//                                   Body-Matter show rule                                    //
//--------------------------------------------------------------------------------------------//

#let BODY-MATTER(
  text-size,
  lang-chapter,
  ship-part-page: true,
  body-matter-material
) = {
  // New Page
  pagebreak(to: "odd", weak: false)

  // Counter reset
  counter(heading).update(0)
  counter(page).update(1)

  // Page settings adjustments
  set page(
    numbering: "1",
    footer: context {
      let cur-pag-num = counter(page).at(here()).first()
      let ALIGN = if calc.even(cur-pag-num) { left } else { right }
      set align(ALIGN)
      [#counter(page).display("1")]
    },
    header: [],
    /*
    header: context {
      let META = query(<lyceum-meta>).first().value
      let AUTH = query(<lyceum-auth>).first().value.join(" and ")
      let cur-pag-num = counter(page).at(here()).first()
      let l1-headings = query(heading.where(level: 1))
      if l1-headings.any(it => it.location().page() == cur-pag-num) {
        [(level-1 heading detected)]
      } else {
        if calc.even(cur-pag-num) {
          set align(left)
          [#smallcaps(META.title.value)]
        } else {
          set align(left)
          [#smallcaps(AUTH)]
        }
      }
    },
    */
  )

  // Paragraph settings
  // --- Unnecesssary ---

  // Text parameters controlled by input arguments
  // --- Unnecesssary ---

  // Main Body Page
  if ship-part-page {
    pagebreak(weak: true, to: "odd")
    page(
      header: [],
      footer: [],
    )[
      #v(1fr)
      #block(
        width: 100%,
        align(
          center,
          text(size: (8/3) * 1em)[
            *Main Part*
          ]
        )
      )
      #v(1fr)
    ]
  }

  // Heading numbering and outlining controls
  set heading(
    numbering: "1.1.1.",
    outlined: true,
  )

  // Main headings in BODY-MATTER
  show heading.where(level: 1): it => {
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(math.equation).update(0)
    // Layout
    pagebreak(weak: true, to: "odd")
    place( // Shaded square
      top + right,
      box(
        width: FMT("sq-side", size: text-size),
        height: FMT("sq-side", size: text-size),
        fill: FMT("sq-shad", size: text-size), radius: 4pt, inset: 0pt,
        align(
          center + horizon,
          text(
            font: ("Alegreya", "Libertinus Serif"),
            size: FMT("sn-size", size: text-size),
            weight: "extrabold",
            fill: FMT("sq-text", size: text-size)
          )[#counter(heading).display("1")]
        )
      )
    )
    place( // Rotated "Chapter"
      top + right,
      dx: -1.275 * FMT("sq-side", size: text-size),
      rotate(
        -90deg,
        origin: top + right,
        box(
          width: FMT("sq-side", size: text-size),
          align(
            center + horizon,
            text(
              font: ("EB Garamond", "Libertinus Serif"),
              size: 0.275 * FMT("sn-size", size: text-size),
              weight: "bold",
              fill: FMT("sq-text", size: text-size)
            )[#lang-chapter]
          )
        )
      )
    )
    v(FMT("top-gap", size: text-size))
    block( // Chapter title
      width: 100%,
      height: FMT("it-hght", size: text-size),
      align(
        center + top,
        text(
          font: ("EB Garamond", "Libertinus Serif"),
          size: FMT("it-size", size: text-size),
          weight: "extrabold",
        )[#it.body]
      )
    )
  }

  // Book body material
  body-matter-material
}


//--------------------------------------------------------------------------------------------//
//                                Optional, Appendix show rule                                //
//--------------------------------------------------------------------------------------------//

#let APPENDIX(
  text-size,
  lang-appendix,
  ship-part-page: true,
  appendix-material
) = {
  // New Page
  pagebreak(to: "odd", weak: false)

  // Counter reset
  counter(heading).update(0)

  // Appendix Page
  if ship-part-page {
    pagebreak(weak: true, to: "odd")
    page(
      header: [],
      footer: [],
    )[
      #v(1fr)
      #block(
        width: 100%,
        align(
          center,
          text(size: (8/3) * 1em)[
            *#lang-appendix*
          ]
        )
      )
      #v(1fr)
    ]
  }

  // Page settings adjustments
  set page(
    numbering: "1",
    footer: context {
      let cur-pag-num = counter(page).at(here()).first()
      let ALIGN = if calc.even(cur-pag-num) { left } else { right }
      set align(ALIGN)
      [#counter(page).display("1")]
    },
    header: [],
    /*
    header: context {
      let META = query(<lyceum-meta>).first().value
      let AUTH = query(<lyceum-auth>).first().value.join(" and ")
      let cur-pag-num = counter(page).at(here()).first()
      let l1-headings = query(heading.where(level: 1))
      if l1-headings.any(it => it.location().page() == cur-pag-num) {
        [(level-1 heading detected)]
      } else {
        if calc.even(cur-pag-num) {
          set align(left)
          [#smallcaps(META.title.value)]
        } else {
          set align(left)
          [#smallcaps(AUTH)]
        }
      }
    },
    */
  )

  // Paragraph settings
  // --- Unnecesssary ---

  // Text parameters controlled by input arguments
  // --- Unnecesssary ---

  // Heading numbering and outlining controls
  set heading(
    numbering: "A.1.1.",
    outlined: true,
  )

  // Main headings in APPENDIX
  show heading.where(level: 1): it => context {
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(math.equation).update(0)
    // Layout
    pagebreak(weak: true, to: "odd")
    place( // Shaded square
      top + right,
      box(
        width: FMT("sq-side", size: text-size),
        height: FMT("sq-side", size: text-size),
        fill: FMT("sq-shad", size: text-size), radius: 4pt, inset: 0pt,
        align(
          center + horizon,
          text(
            font: ("Alegreya", "Libertinus Serif"),
            size: FMT("sn-size", size: text-size),
            weight: "extrabold",
            fill: FMT("sq-text", size: text-size)
          )[#counter(heading).display("A")]
        )
      )
    )
    place( // Rotated "Appendix"
      top + right,
      dx: -1.275 * FMT("sq-side", size: text-size),
      rotate(
        -90deg,
        origin: top + right,
        box(
          width: FMT("sq-side", size: text-size),
          align(
            center + horizon,
            text(
              font: ("EB Garamond", "Libertinus Serif"),
              size: 0.275 * FMT("sn-size", size: text-size),
              weight: "bold",
              fill: FMT("sq-text", size: text-size)
            )[#lang-appendix]
          )
        )
      )
    )
    v(FMT("top-gap", size: text-size))
    block( // Appendix title
      width: 100%,
      height: FMT("it-hght", size: text-size),
      align(
        center + top,
        text(
          font: ("EB Garamond", "Libertinus Serif"),
          size: FMT("it-size", size: text-size),
          weight: "extrabold",
        )[#it.body]
      )
    )
  }

  // Appendix material
  appendix-material
}


//--------------------------------------------------------------------------------------------//
//                              Optional, Back-matter show rule                               //
//--------------------------------------------------------------------------------------------//

#let BACK-MATTER(
  text-size,
  ship-part-page: true,
  back-matter-material
) = {
  // Page settings adjustments
  set page(
    numbering: "1",
    footer: context {
      let cur-pag-num = counter(page).at(here()).first()
      let ALIGN = if calc.even(cur-pag-num) { left } else { right }
      set align(ALIGN)
      [#counter(page).display("1")]
    },
    header: [],
  )

  // Paragraph settings
  // --- Unnecesssary ---

  // Text parameters controlled by input arguments
  // --- Unnecesssary ---

  // Back Part Page
  if ship-part-page {
    pagebreak(weak: true, to: "odd")
    page(
      header: [],
      footer: [],
    )[
      #v(1fr)
      #block(
        width: 100%,
        align(
          center,
          text(size: (8/3) * 1em)[
            *Back Part*
          ]
        )
      )
      #v(1fr)
    ]
  }

  // Heading numbering and outlining controls
  set heading(
    numbering: none,
    outlined: true,
  )

  // Main headings in BACK-MATTER
  show heading.where(level: 1): it => {
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(math.equation).update(0)
    // Layout
    pagebreak(weak: true, to: "odd")
    v(FMT("top-gap", size: text-size))
    block(
      width: 100%,
      height: FMT("it-hght", size: text-size),
      align(
        center + top,
        text(
          font: ("EB Garamond", "Libertinus Serif"),
          size: FMT("it-size", size: text-size),
          weight: "extrabold",
        )[#it.body]
      )
    )
  }

  // back-matter material
  back-matter-material
}


