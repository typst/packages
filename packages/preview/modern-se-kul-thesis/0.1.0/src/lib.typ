#import "assets/text-blobs.typ": copyright, submission-text
#import "core/component.typ"
#import "core/utils.typ"

/// The function used to instantiate the template for the thesis
/// -> content
#let template(
  /// The title of the thesis.
  /// -> content
  title: [A very cool thesis],
  /// An optional subtitle.
  /// -> content
  subtitle: none,
  /// the starting year of the thesis or a tuple of years denoting the starting and ending years.
  /// -> int | (array, int)
  academic-year: datetime.today().year(),
  /// the name(s) of the author.
  /// -> array
  authors: (),
  /// the name of the promotor(s), or a list of authors.
  /// -> array
  promotors: (),
  /// the name of the assessors(s).
  /// -> array
  assessors: (),
  /// the name of the supervisors(s) (aka mentors).
  /// -> array
  supervisors: (),
  /// your studies, should specify (master, elective and color (in hsv)).
  /// -> array
  degree: (
    master: "Computer Science",
    elective: "Software engineering",
    color: (0, 0, 1, 0),
  ),
  /// the language of the thesis, supported languages are "nl" and "en".
  /// -> string
  language: "en",
  /// whether to print the document as an electronic version or for printing.
  /// -> bool
  electronic-version: false,
  /// toggle to notify the template that you don't need any Dutch things.
  /// -> bool
  english-master: false,
  /// Whether to automatically add a list of figures
  /// -> bool
  list-of-figures: false,
  /// Whether to automatically add a list of listings (code blocks)
  /// -> bool
  list-of-listings: false,
  /// the size of the text, can choose between 10pt and 11pt.
  /// -> pt
  font-size: 11pt,
  /// The preface (voorwoord).
  /// -> content
  preface: none,
  /// The abstract (samenvatting).
  /// -> content
  abstract: none,
  /// (optional) Summary needed if writing a English thesis for the Dutch master.
  /// -> content
  dutch-summary: none,
  /// List of abbreviations
  /// -> content
  abbreviations: none,
  /// List of symbols
  /// -> content
  symbols: none,
  /// the bibliography.
  /// -> content
  bibliography: none,
  /// The appendiceses
  /// -> content
  appendices: none,
  /// Logo to be added to the front page
  /// -> content
  logo: none,
  /// automatically inserted content of the thesis.
  /// -> content
  body,
) = {
  // Set document matadata.
  set document(title: title, author: authors)

  set text(font: "New Computer Modern", lang: language, size: font-size)
  set par(first-line-indent: 1em, spacing: 0.65em, justify: true)

  /////////////////////////// Heading config
  // Configure headings
  set heading(numbering: "1.1.1")

  /////////////////////////// figure numbering
  set figure(numbering: it => context {
    let count = counter(heading).get()
    numbering("1.1", count.at(0), it)
  })
  /////////////////////////// frontpage
  // Print cover page
  if not electronic-version {
    component.insert-cover-page(
      title,
      subtitle,
      authors,
      promotors,
      assessors,
      supervisors,
      academic-year,
      degree,
      english-master,
      logo,
      cover: true,
      lang: language,
    )
  }
  // Actual cover page
  component.insert-cover-page(
    title,
    subtitle,
    authors,
    promotors,
    assessors,
    supervisors,
    academic-year,
    degree,
    english-master,
    logo,
    cover: false,
    lang: language,
  )

  /////////////////////////// pre-body content
  // copyright
  component.insert-copyright(english-master, language)

  // numbering setup + header + footer
  // TODO: fix margins for RL pages
  set page(
    paper: "a4",
    numbering: (num, ..) => {
      // subtract 2 for header page + copyright notice
      numbering("i", num - 2)
    },
    margin: (left: 28mm, right: 28mm, bottom: 45mm, top: 37mm),
    header: context utils.custom-header(),
    footer: context utils.custom-footer(),
    // header-ascent: 10mm,
    footer-descent: 15%,
  )

  // header stuff
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    pad(top: 19mm, bottom: 19mm, {
      set text(1.55em, weight: "bold")
      it.body
    })
  }


  // citations
  show ref: it => {
    let el = it.element
    if el != none {
      // All other references in the document, such as figures
      show regex("\d(\.\d)*|[A-Z] |[A-Z](\.\d)+"): it => {
        text(red)[#it]
      }
      it
    } else {
      // Bibliography reference
      show regex("\d"): it => {
        text(rgb("#00ff00"))[#it]
      }
      it
    }
  }

  let spacing = 0.5em
  set par(first-line-indent: 0.5cm, leading: spacing, spacing: spacing)
  // preface
  component.insert-preface(preface, authors, lang: language)

  // outline
  component.insert-heading-outline(lang: language)

  // abstract
  component.insert-abstract(abstract, lang: language)

  // Optional dutch abstract
  if (not english-master) and language == "en" {
    component.insert-abstract(dutch-summary, lang: "nl")
  }

  if list-of-figures { component.insert-image-outline(lang: language) }
  if list-of-listings { component.insert-listing-outline(lang: language) }
  if abbreviations != none or symbols != none {
    component.insert-list-of-abbrv-symbol(
      lang: language,
      symbols: symbols,
      abbreviations: abbreviations,
    )
  }

  let chapter-numbering = "1.1.1"
  set page(
    numbering: (num, ..) => {
      let starting-heading = query(
        heading.where(level: 1, numbering: chapter-numbering),
      )
        .first()
        .location()
        .page()
      numbering("1", num - starting-heading + 1)
    },
  )
  // counter(page).update(1)
  set heading(supplement: "Chapter")
  set heading(numbering: chapter-numbering)
  /////////////////////////// show rules
  show heading.where(level: 1): it => {
    pagebreak(weak: true, to: "odd")
    context counter(figure.where(kind: image)).update(0)
    block[
      #pad(top: 25mm, text(
        size: 1.3em,
        weight: "semibold",
      )[
        #it.supplement #numbering(
          it.numbering,
          counter(heading).at(here()).at(0),
        )
      ])
      #pad(top: 1em, bottom: 2em, text(
        size: 1.7em,
      )[#it.body])

    ]
  }

  show heading.where(level: 2): it => block(width: 100%)[
    #set text(1.1em, weight: "bold")
    #pad(top: 0.4em, bottom: 0.8em)[
      #numbering(chapter-numbering, ..counter(heading).get()) #it.body
    ]
  ]
  show heading.where(level: 3): it => block(width: 100%)[
    #set text(1em, weight: "bold")
    #pad(top: 0.2em, bottom: 0.5em)[
      #numbering(chapter-numbering, ..counter(heading).get()) #it.body
    ]
  ]
  show heading.where(level: 4): it => block(width: 100%)[
    #set text(1em, weight: "bold")
    #pad(top: 0em, bottom: 0.5em)[
      #it.body
    ]
  ]
  show pagebreak.where(to: "odd", weak: true): set page(
    header: none,
    footer: none,
  )
  show pagebreak.where(to: "even", weak: true): set page(
    header: none,
    footer: none,
  )

  body

  if appendices != none {
    component.insert-appendices(appendices)
  }
  component.insert-bibliography(bibliography, lang: language)
}
