#import "assets.typ"
#import "l10n.typ"
#import "glossary.typ" as glossary: register-glossary, glossary-entry, gls, glspl
#import "bib.typ" as bib: bibliography
#import "utils.typ"

#let _authors = state("thesis-authors")
#let _current_authors = state("thesis-current-authors", ())

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
  import "@preview/alexandria:0.1.1"
  import "@preview/codly:1.2.0": codly, codly-init
  import "@preview/datify:0.1.3"
  import "@preview/hydra:0.6.0": hydra, anchor
  import "@preview/i-figured:0.2.4"
  import "@preview/outrageous:0.4.0"

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

  // setup glossarium
  show: glossary.make-glossary

  // setup Alexandria
  show: bib.alexandria.alexandria(prefix: "cite:", read: read)

  // setup codly & listing styles
  show: codly-init.with()
  show figure.where(kind: raw): block.with(width: 95%)

  // outline style
  show outline.where(target: selector(heading)): it => {
    show outline.entry: outrageous.show-entry.with(
      font: (auto,),
    )
    it
  }
  show outline.entry: outrageous.show-entry.with(
    ..outrageous.presets.outrageous-figures,
  )

  // general styles

  // figure supplements
  show figure.where(kind: image): set figure(supplement: l10n.figure)
  show figure.where(kind: table): set figure(supplement: l10n.table)
  show figure.where(kind: raw): set figure(supplement: l10n.listing)

  show quote.where(block: false): it => {
    it
    if it.attribution != none [ #it.attribution]
  }

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

  show: utils.mark-empty-pages()

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

  // main body with i-figured
  // scope i-figured to now interact with Glossarium
  {
    show heading: i-figured.reset-counters
    show figure: i-figured.show-figure
    show math.equation: i-figured.show-equation

    // the body contains the declaration, abstracts, and then the main matter

    body
  }

  // back matter

  // glossary is outlined
  {
    set heading(outlined: true)

    glossary.print-glossary(title: [= #l10n.glossary <glossary>])
  }

  // bibliography is outlined, and we use our own header for the label
  if bibliography != none {
    set heading(outlined: true)

    bibliography

    let is-prompt(x) = x.details.type == "misc" and x.details.title.starts-with("PROMPT")

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

  // List of {Figures, Tables, Listings} only shown if there are any such elements
  context if query(figure.where(kind: image)).len() != 0 {
    [= #l10n.list-of-figures <list-of-figures>]
    i-figured.outline(
      title: none,
      target-kind: image,
    )
  }

  context if query(figure.where(kind: table)).len() != 0 {
    [= #l10n.list-of-tables <list-of-tables>]
    i-figured.outline(
      title: none,
      target-kind: table,
    )
  }

  context if query(figure.where(kind: raw)).len() != 0 {
    [= #l10n.list-of-listings <list-of-listings>]
    i-figured.outline(
      title: none,
      target-kind: raw,
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
  [= #l10n.contents <contents>]
  outline(title: none)

  set heading(outlined: true, numbering: "1.1")

  body
}
