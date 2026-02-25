#let text-normal = 10pt
#let text-small = 9pt
#let text-sub = 12pt
#let text-subsub = 11pt
#let text-big = 14pt
#let text-huge = 18pt
#let text-title = 22pt


#let build-author-grid(
  authors,
  max-columns: 3,
  spacing: 1em,
  show-email-links: true,
) = {
  // Helper to render a single author entry
  let render-author(author) = {
    let name = author.at("name", default: "")
    let email = author.at("email", default: none)

    // Get additional fields excluding name and email
    let extra-fields = author
      .pairs()
      .filter(
        ((key, val)) => (
          key not in ("name", "email") and val != none and str(val) != ""
        ),
      )

    align(center)[
      // Name
      #if name != "" [
        #strong(name) \
      ]

      // Email
      #if email != none [
        #if show-email-links [
          #link("mailto:" + email, email) \
        ] else [
          #email \
        ]
      ]

      // Additional fields
      #for (key, val) in extra-fields [
        #val \
      ]
    ]
  }

  let num-cols = calc.min(authors.len(), max-columns)

  block(
    above: 10mm,
    grid(
      columns: (1fr,) * num-cols,
      gutter: spacing,
      ..authors.map(render-author)
    ),
  )
}

// A template for writing a thesis
// This function gets the whole document as its `body` and formats it
#let thesis(
  // The paper's title.
  title: [Title],
  // An optional subtitle
  subtitle: "",
  // An array of authors. For each author you can specify a required name and
  // email and optional arbitrary fields such as a department etc.
  authors: (),
  // The paper's abstract. Can be omitted if you don't have one.
  abstract: none,
  // An optional logo to use on the frontpage.
  logo: none,
  footer-logo: none,
  // The result of a call to the `bibliography` function or `none`.
  bibliography: none,
  /// Other settings
  lang: "en",
  outlines: (),
  toc: outline(),
  // Fonts
  font-heading: "Latin Modern Sans",
  font-normal: "Latin Modern Roman",
  date-format: "[day].[month].[year]",
  doc,
) = {
  assert(authors.len() > 0, message: "Authors array cannot be empty")

  set document(
    title: title,
    author: authors.first().name,
    date: datetime.today(),
  )

  // Page settings
  set page(
    header: [
      #block(below: .6em)[
        #title
        #h(1fr)
        #subtitle
      ]
      #line(length: 100%, stroke: 0.5pt)
    ],
    footer: [
      #grid(
        columns: (1fr, 1fr),
        rows: 100%,
        align: (left + horizon, right + horizon),

        footer-logo, context counter(page).display("1"),
      )
    ],
    numbering: "1",
  )

  // Text settings
  set heading(numbering: "1.1")
  show heading: set text(font: font-heading, weight: "bold")
  show heading: set block(below: 1.2em, above: 2.4em, sticky: true)
  show heading.where(level: 1): set text(size: text-big)
  show heading.where(level: 2): set text(size: text-sub)
  show heading.where(level: 3): set text(size: text-subsub)

  set text(lang: lang)
  set text(font: font-normal)
  set par(justify: true, justification-limits: (
    spacing: (min: 66.67% + 0pt, max: 150% + 0pt),
    tracking: (min: -0.01em, max: 0.02em),
  ))

  show std.title: set align(center)
  show std.title: set block(below: 0mm)
  show std.title: set text(
    size: text-title,
    weight: "bold",
    font: font-heading,
  )

  show outline.entry.where(level: 1): it => {
    text(font: font-heading)[#strong(it)]
  }

  // Frontpage
  {
    set page(header: none, footer: none)
    set align(center)

    // Title and subtitle with logo
    logo

    std.title()
    linebreak()
    text(subtitle, text-huge, weight: "semibold", font: font-heading)

    build-author-grid(authors)
    block(datetime.today().display(date-format))

    set align(left)
    toc
  }
  pagebreak()

  for outline in outlines [
    #outline
    #pagebreak()
  ]

  // Content
  doc

  // Bibliography
  if bibliography != none {
    pagebreak()
    bibliography
  }
}
