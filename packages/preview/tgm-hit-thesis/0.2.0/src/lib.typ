#import "assets.typ"
#import "l10n.typ"
#import "glossary.typ"
#import "utils.typ"

#let _builtin_bibliography = bibliography

#let _authors = state("thesis-authors")
#let _current_authors = state("thesis-current-authors", ())

#import utils: chapter-end
#import glossary: register-glossary, glossary-entry, gls, glspl

/// The main template function. Your document will generally start with ```typ #show: thesis(...)```,
/// which it already does after initializing the template. Although all parameters are named, most
/// of them are really mandatory. Parameters that are not given may result in missing content in
/// places where it is not actually optional.
///
/// - title (content, string): The title of the thesis, displayed on the title page and used for PDF
///   metadata.
/// - subtitle (content, string): A descriptive one-liner that gives the reader an immediate idea
///   about the thesis' topic.
/// - authors (array): The thesis authors. Each array entry is a `dict` of the form
///   `(name: ..., class: ..., subtitle: ...)` stating their name, class, and the title of their
///   part of the whole thesis project. The names must be regular strings, for the PDF metadata.
/// - supervisor-label (content, string, auto): The term with which to label the supervisor name;
///   if not given or `auto`, this defaults to a language-dependent text. In German, this text is
///   gender-specific and can be overridden with this parameter.
/// - supervisor (content, string): The name of the thesis' supervisor.
/// - date (datetime): The date of submission of the thesis.
/// - year (content, string): The school year in which the thesis was produced.
/// - division (content, string): The division inside the HIT department (i.e. usually
///   "Medientechnik" or "Systemtechnik").
/// - logo (content): The image (```typc image()```) to use as the document's logo on the title page.
/// - bibliography (content): The bibliography (```typc bibliography()```) to use for the thesis.
/// - language (string): The language in which the thesis is written. `"de"` and `"en"` are
///   supported. The choice of language influences certain texts on the title page and in headings,
///   as well as the date format used on the title page.
/// - current-authors (string): The mode used to show the current authors in the footer; see
///   @@set-current-authors(). This can be `highlight` (all authors are shown, some *strong*) or
///   `only` (only the current authors are shown).
/// - paper (string): Changes the paper format of the thesis. Use this option with care, as it will
///   shift various contents around.
/// - strict-chapter-end (bool): This can be activated to ensure proper use of the
///   @@chapter-end() function. It is disabled by default because it slows down compilation. See
///   @@enforce-chapter-end-placement().
/// -> function
#let thesis(
  title: none,
  subtitle: none,
  authors: (),
  supervisor-label: auto,
  supervisor: none,
  date: none,
  year: none,
  division: none,
  logo: none,
  bibliography: none,

  language: "de",
  current-authors: "highlight",
  paper: "a4",
  strict-chapter-end: false,
) = body => {
  import "@preview/codly:1.0.0": codly, codly-init
  import "@preview/datify:0.1.2"
  import "@preview/hydra:0.4.0": hydra, anchor
  import "@preview/i-figured:0.2.4"
  import "@preview/outrageous:0.3.0"

  assert(current-authors in ("highlight", "only"))

  // basic document & typesetting setup
  set document(
    title: title,
    author: authors.map(author => author.name).join(", "),
    date: date,
  )
  set page(paper: paper)
  set text(lang: language)
  set par(justify: true)

  // title page settings - must come before the first content (e.g. state update)
  set page(margin: (x: 1in, top: 1in, bottom: 0.75in))

  // make properties accessible as state
  _authors.update(authors)

  // setup linguify
  l10n.set-database()

  // setup i-figured
  show heading: i-figured.reset-counters
  show figure: i-figured.show-figure
  show math.equation: i-figured.show-equation

  // setup glossarium
  show: glossary.make-glossary

  // setup codly & listing styles
  show: codly-init.with()
  show figure.where(kind: raw): block.with(width: 95%)

  // outline style
  set outline(indent: auto)
  show outline.entry: outrageous.show-entry.with(
    font: (auto,),
  )

  // general styles

  // figure supplements
  show figure.where(kind: image): set figure(supplement: l10n.figure)
  show figure.where(kind: table): set figure(supplement: l10n.table)
  show figure.where(kind: raw): set figure(supplement: l10n.listing)

  // table & line styles
  set line(stroke: 0.1mm)
  set table(stroke: (x, y) => if y == 0 {
    (bottom: 0.1mm)
  })

  // references to non-numbered headings
  show ref: it => {
    if type(it.element) != content { return it }
    if it.element.func() != heading { return it }
    if it.element.numbering != none { return it }

    link(it.target, it.element.body)
  }

  // title page

  {
    // header
    grid(
      columns: (auto, 1fr, auto),
      align: center+horizon,
      assets.tgm-logo(width: 3.1cm),
      {
        set text(1.2em)
        [Technologisches Gewerbemuseum]
        parbreak()
        set text(0.77em)
        [Höhere Technische Lehranstalt für Informationstechnologie]
        if division != none {
          linebreak()
          [Schwerpunkt #division]
        }
      },
      assets.htl-logo(width: 3.1cm),
    )
    line(length: 100%)

    v(1fr)

    // title & subtitle
    align(center, {
      if logo != none {
        logo
        v(0.5em)
      }
      text(1.44em, weight: "bold")[#l10n.thesis]
      v(-0.5em)
      text(2.49em, weight: "bold")[#title]
      if subtitle != none {
        v(-0.7em)
        text(1.44em)[#subtitle]
      }
    })

    v(1fr)

    // authors & supervisor
    authors.map(author => {
      grid(
        columns: (4fr, 6fr),
        row-gutter: 0.8em,
        grid.cell(colspan: 2, author.subtitle),
        author.name,
        author.class,
      )
    }).join(v(0.7em))
    v(2em)
    if supervisor-label == auto {
      supervisor-label = l10n.supervisor
    }
    [
      *#supervisor-label:* #supervisor \
      #l10n.performed-in-year #year
    ]

    // footer
    let date-formats = (
      "en": "Month DD, YYYY",
      "de": "DD. Month YYYY",
    )

    line(length: 100%)
    [
      #l10n.submission-note: \
      #context if text.lang in date-formats {
        datify.custom-date-format(date, date-formats.at(text.lang))
      } else {
        date.display()
      }
      #h(1fr)
      #l10n.approved:
      #h(3cm)
    ]
  }

  // regular page setup

  // show header & footer on "content" pages, show only page number in chapter title pages
  set page(
    margin: (x: 1in, y: 1.5in),
    header-ascent: 15%,
    footer-descent: 15%,
    header: context {
      if utils.is-chapter-page() {
        // no header
      } else if utils.is-empty-page() {
        // no header
      } else {
        hydra(
          1,
          prev-filter: (ctx, candidates) => candidates.primary.prev.outlined == true,
          display: (ctx, candidate) => {
            grid(
              columns: (auto, 1fr),
              column-gutter: 3em,
              align: (left+top, right+top),
              title,
              {
                set par(justify: false)
                if candidate.has("numbering") and candidate.numbering != none {
                  l10n.chapter
                  [ ]
                  numbering(candidate.numbering, ..counter(heading).at(candidate.location()))
                  [. ]
                }
                candidate.body
              }
            )
            line(length: 100%)
          },
        )
        anchor()
      }
    },
    footer: context {
      if utils.is-chapter-page() {
        align(center)[
          #counter(page).display("1")
        ]
      } else if utils.is-empty-page() {
        // no footer
      } else {
        hydra(
          1,
          prev-filter: (ctx, candidates) => candidates.primary.prev.outlined == true,
          display: (ctx, candidate) => {
            line(length: 100%)
            grid(
              columns: (5fr, 1fr),
              align: (left+bottom, right+bottom),
              if current-authors == "highlight" {
                authors.map(author => {
                  let is-current = author.name in _current_authors.get()
                  let author = author.name
                  if is-current {
                    author = strong(author)
                  }
                  box(author)
                }).join[, ]
              } else if current-authors == "only" {
                authors.filter(author => {
                  author.name in _current_authors.get()
                }).map(author => {
                  let author = author.name
                  box(author)
                }).join[, ]
              } else {
                panic("unreachable: current-authors not 'highlight' or 'only'")
              },
              counter(page).display("1 / 1", both: true),
            )
          },
        )
      }
    },
  )

  // front matter headings are not outlined
  set heading(outlined: false)
  // Heading supplements are section or chapter, depending on level
  show heading: set heading(supplement: l10n.section)
  show heading.where(level: 1): set heading(supplement: l10n.chapter)
  // chapters start on a right page and have very big, fancy headings
  show heading.where(level: 1): it => {
    set text(1.3em)
    pagebreak(to: "odd")
    v(12%)
    if it.numbering != none [
      #it.supplement #counter(heading).display()
      #parbreak()
    ]
    set text(1.3em)
    it.body
    v(1cm)
  }
  // the first section of a chapter starts on the next page
  show heading.where(level: 2): it => {
    if utils.is-first-section() {
      pagebreak()
    }
    it
  }

  // the body contains the declaration, abstracts, and then the main matter

  body

  // back matter

  // glossary is outlined
  {
    set heading(outlined: true)

    glossary.print-glossary(title: [= #l10n.glossary <glossary>])
    chapter-end()
  }

  // bibliography is outlined, and we use our own header for the label
  {
    set _builtin_bibliography(title: none)
    set heading(outlined: true)

    [= #l10n.bibliography <bibliography>]
    bibliography
    chapter-end()
  }

  // List of {Figures, Tables, Listings} only shown if there are any such elements
  context if query(figure.where(kind: image)).len() != 0 {
    [= #l10n.list-of-figures <list-of-figures>]
    i-figured.outline(
      title: none,
      target-kind: image,
    )
    chapter-end()
  }

  context if query(figure.where(kind: table)).len() != 0 {
    [= #l10n.list-of-tables <list-of-tables>]
    i-figured.outline(
      title: none,
      target-kind: table,
    )
    chapter-end()
  }

  context if query(figure.where(kind: raw)).len() != 0 {
    [= #l10n.list-of-listings <list-of-listings>]
    i-figured.outline(
      title: none,
      target-kind: raw,
    )
    chapter-end()
  }

  if strict-chapter-end {
    utils.enforce-chapter-end-placement()
  }
}

/// The statutory declaration that the thesis was written without improper help. The text is not
/// part of the template so that it can be adapted according to one's needs. Example texts are given
/// in the template. Heading and signature lines for each author are inserted automatically.
///
/// - signature-height (length): The height of the signature line. The default should be able to fit
///   up to seven authors on one page; for larger teams, the height can be decreased.
/// - body (content): The actual declaration.
/// -> content
#let declaration(
  signature-height: 1.1cm,
  body,
) = [
  #let caption-spacing = -0.2cm

  = #l10n.declaration-title <declaration>

  #body

  #v(0.2cm)

  #context _authors.get().map(author => {
    show: block.with(breakable: false)
    set text(0.9em)
    grid(
      columns: (4fr, 6fr),
      align: center,
      [
        #v(signature-height)
        #line(length: 80%)
        #v(caption-spacing)
        #l10n.location-date
      ],
      [
        #v(signature-height)
        #line(length: 80%)
        #v(caption-spacing)
        #author.name
      ],
    )
  }).join()

  #chapter-end()
]

/// Set the authors writing the current part of the thesis. The footer will highlight the names of
/// the given authors until a new list of authors is given with this function.
///
/// - ..authors (arguments): the names of the authors to highlight
/// -> content
#let set-current-authors(..authors) = {
  assert(authors.named().len() == 0, message: "named arguments not allowed")
  let authors = authors.pos()
  context {
    let names = _authors.get().map(author => author.name)
    for author in authors {
      assert(author in names, message: "invalid author: " + author)
    }
  }

  _current_authors.update(authors)
}

/// An abstract section. This should appear twice in the thesis regardless of language; first for
/// the German _Kurzfassung_, then for the English abstract.
///
/// - lang (string): The language of this abstract. Although it defaults to ```typc auto```, in
///   which case the document's language is used, it's preferable to always set the language
///   explicitly.
/// - body (content): The abstract text.
#let abstract(lang: auto, body) = [
  #set text(lang: lang) if lang != auto

  #context [
    #[= #l10n.abstract] #label("abstract-" + text.lang)
  ]

  #body

  #chapter-end()
]

/// Starts the main matter of the thesis. This should be called as a show rule (```typ #show: main-matter()```) after the abstracts and will insert
/// the table of contents. All subsequent top level headings will be treated as chapters and thus be
/// numbered and outlined.
///
/// -> function
#let main-matter() = body => {
  [= #l10n.contents <contents>]
  outline(title: none)
  chapter-end()

  set heading(outlined: true, numbering: "1.1")

  body
}
