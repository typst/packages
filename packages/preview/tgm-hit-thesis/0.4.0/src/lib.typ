#import "assets.typ"
#import "bib.typ" as bib: bibliography
#import "glossary.typ" as glossary: register-glossary, glossary-entry, gls, glspl
#import "l10n.typ"

/// The main template function. Your document will generally start with ```typ #show: thesis(...)```,
/// which it already does after initializing the template. Although all parameters are named, most
/// of them are really mandatory. Parameters that are not given may result in missing content in
/// places where it is not actually optional.
///
/// -> function
#let thesis(
  /// The title of the thesis, displayed on the title page and used for PDF metadata.
  /// -> content | string
  title: none,
  /// A descriptive one-liner that gives the reader an immediate idea about the thesis' topic.
  /// -> content | string
  subtitle: none,
  /// The thesis authors. Each array entry is a `dict` of the form `(name: ..., class: ..., subtitle: ...)` stating their name, class, and the title of their part of the whole thesis project. The names must be regular strings, for the PDF metadata.
  /// -> array
  authors: (),
  /// The term with which to label the supervisor name; if not given or `auto`, this defaults to a language-dependent text. In German, this text is gender-specific and can be overridden with this parameter.
  /// -> content | string | auto
  supervisor-label: auto,
  /// The name of the thesis' supervisor.
  /// -> content | string
  supervisor: none,
  /// The date of submission of the thesis.
  /// -> datetime
  date: none,
  /// The school year in which the thesis was produced.
  /// -> content | string
  year: none,
  /// The division inside the HIT department (i.e. usually "Medientechnik" or "Systemtechnik").
  /// -> content | string
  division: none,
  /// The image (```typc image()```) to use as the document's logo on the title page.
  /// -> content
  logo: none,
  /// pass ```typc path => read(path)``` into this parameter so that Alexandria can read your
  /// bibliography files.
  /// -> function
  read: none,
  /// The (Alexandria) bibliography (```typc bibliography()```) to use for the thesis.
  /// -> content
  bibliography: none,

  /// The language in which the thesis is written. `"de"` and `"en"` are supported. The choice of language influences certain texts on the title page and in headings, as well as the date format used on the title page.
  /// -> string
  language: "de",
  /// The mode used to show the current authors in the footer; see @@set-current-authors(). This can be `highlight` (all authors are shown, some *strong*) or `only` (only the current authors are shown).
  /// -> string
  current-authors: "highlight",
  /// Changes the paper format of the thesis. Use this option with care, as it will shift various contents around.
  /// -> string
  paper: "a4",
) = body => {
  import "libs.typ": *
  import hydra: hydra, anchor

  import "authors.typ" as _authors
  import "figures.typ"
  import "structure.typ"

  _authors.check-current-authors(current-authors)

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
  _authors.set-authors(authors)

  // setup linguify
  l10n.set-database()

  // setup glossarium
  show: glossary.make-glossary

  // setup Alexandria
  show: bib.alexandria.alexandria(prefix: "cite:", read: read)

  // figure numbering
  show: figures.numbering()

  // general styles

  // figure supplements
  show: figures.figure-style(supplement: l10n.figure)
  show: figures.table-style(supplement: l10n.table)
  show: figures.listing-style(supplement: l10n.listing)

  show quote.where(block: false): it => {
    it
    if it.attribution != none [ #it.attribution]
  }

  // references to non-numbered headings
  show: structure.plain-heading-refs()

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
    context _authors.get-authors().map(author => {
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
      if structure.is-chapter-page() {
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
      if structure.is-chapter-page() {
        align(center)[
          #counter(page).display("1")
        ]
      } else {
        hydra(
          1,
          prev-filter: (ctx, candidates) => candidates.primary.prev.outlined == true,
          display: (ctx, candidate) => {
            line(length: 100%)
            grid(
              columns: (5fr, 1fr),
              align: (left+bottom, right+bottom),
              {
                let authors = _authors.get-names-and-current()
                let authors = {
                  if current-authors == "highlight" {
                    authors
                      .map(((author, is-current)) => {
                        if is-current {
                          author = strong(author)
                        }
                        author
                      })
                  } else if current-authors == "only" {
                    authors
                      .filter(((author, is-current)) => is-current)
                      .map(((author, is-current)) => author)
                  } else {
                    panic("unreachable: current-authors not 'highlight' or 'only'")
                  }
                }
                authors.map(box).join[, ]
              },
              counter(page).display("1 / 1", both: true),
            )
          },
        )
      }
    },
  )

  show: structure.skip-empty-page-headers-footers()

  show: structure.chapters-and-sections(
    chapter: l10n.chapter,
    section: l10n.section,
  )

  show: structure.front-matter()

  // main body: declaration, abstracts, and then the main matter
  body

  // back matter: references
  {
    show: structure.back-matter-references()

    glossary.print-glossary(title: [= #l10n.glossary <glossary>])

    if bibliography != none {
      bibliography

      let is-prompt(x) = {
        if x.details.type != "misc" { return false }

        let title = x.details.title
        if type(title) == dictionary {
          title = title.value
        }

        title.starts-with("PROMPT")
      }

      context {
        let (references, ..rest) = bib.alexandria.get-bibliography(auto)
        let prompts = references.filter(x => is-prompt(x))
        let references = references.filter(x => not is-prompt(x))

        if references.len() != 0 {
          [= #l10n.bibliography <bibliography>]
          bib.alexandria.render-bibliography(title: none, (references: references, ..rest))
        }

        if prompts.len() != 0 {
          [= #l10n.prompts <prompts>]
          bib.alexandria.render-bibliography(title: none, (references: prompts, ..rest))
        }
      }
    }
  }

  // List of {Figures, Tables, Listings}
  {
    show: structure.back-matter-lists()

    figures.outlines(
      figures: [= #l10n.list-of-figures <list-of-figures>],
      tables: [= #l10n.list-of-tables <list-of-tables>],
      listings: [= #l10n.list-of-listings <list-of-listings>],
    )
  }
}

/// The statutory declaration that the thesis was written without improper help. The text is not
/// part of the template so that it can be adapted according to one's needs. Example texts are given
/// in the template. Heading and signature lines for each author are inserted automatically.
///
/// -> content
#let declaration(
  /// The height of the signature line. The default should be able to fit up to seven authors on one page; for larger teams, the height can be decreased.
  /// -> length
  signature-height: 1.1cm,
  /// The actual declaration.
  /// -> content
  body,
) = [
  #import "authors.typ" as _authors

  #let caption-spacing = -0.2cm

  = #l10n.declaration-title <declaration>

  #body

  #v(0.2cm)

  #context _authors.get-authors().map(author => {
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
]

/// Set the authors writing the current part of the thesis. The footer will highlight the names of
/// the given authors until a new list of authors is given with this function.
///
/// -> content
#let set-current-authors(
  /// the names of the authors to highlight
  /// -> arguments
  ..authors,
) = {
  import "authors.typ" as _authors

  _authors.set-current-authors(..authors)
}

/// An abstract section. This should appear twice in the thesis regardless of language; first for
/// the German _Kurzfassung_, then for the English abstract.
///
/// -> content
#let abstract(
  /// The language of this abstract. Although it defaults to ```typc auto```, in which case the document's language is used, it's preferable to always set the language explicitly.
  /// -> string
  lang: auto,
  /// The abstract text.
  /// -> content
  body,
) = [
  #set text(lang: lang) if lang != auto

  #context [
    #[= #l10n.abstract] #label("abstract-" + text.lang)
  ]

  #body
]

/// Starts the main matter of the thesis. This should be called as a show rule (```typ #show: main-matter()```) after the abstracts and will insert
/// the table of contents. All subsequent top level headings will be treated as chapters and thus be
/// numbered and outlined.
///
/// -> function
#let main-matter() = body => {
  import "structure.typ"

  show: structure.main-matter(
    contents: l10n.contents,
  )

  body
}
