#import "core/component.typ"
#import "core/utils.typ"
#import "core/utils/margins.typ": thesis-margins
#import "assets/text-blobs.typ": address-default, faculty-default, normalise-degree

/// Instantiate the thesis template.
/// -> content
#let template(
  /// The title of the thesis.
  /// -> content
  title: [A very cool thesis],
  /// An optional subtitle.
  /// -> content
  subtitle: none,
  /// Starting year of the academic year, or (start, end).
  /// -> int | array
  academic-year: datetime.today().year(),
  /// The name(s) of the author(s).
  /// -> array
  authors: (),
  /// The promotor(s) / supervisor(s).
  /// -> array
  promotors: (),
  /// The assessor(s) / evaluator(s).
  /// -> array
  assessors: (),
  /// The assistant-supervisor(s) / begeleider(s).
  /// -> array
  supervisors: (),
  /// Your programme. Free text, and your responsibility: copy the official
  /// wording for your programme and option from
  /// https://eng.kuleuven.be/docs/kulemt and paste it verbatim.
  ///
  ///   degree: (
  ///     name: "Master of Science in Electrical Engineering",
  ///     options: ("option Electronics and Chip Design",),
  ///   )
  ///
  /// Each option carries its own "option " / "hoofdoptie " prefix, exactly as
  /// the faculty lists it. Nothing is looked up and nothing is checked.
  /// -> dictionary
  degree: (
    name: "Master of Science in Engineering: Computer Science",
    options: ("option Artificial Intelligence",),
  ),
  /// The language the thesis is written in: "en" or "nl".
  /// -> str
  language: "en",
  /// Whether your master's programme is taught in English. This -- not
  /// `language` -- decides the language of the cover, title and copyright
  /// pages, and which faculty logo is used, as in kulemt.
  /// -> bool
  english-master: true,
  /// Skip the separate cover page and use non-mirrored margins. kulemt
  /// generates no cover page by default either.
  /// -> bool
  electronic-version: false,
  /// kulemt's `bind` option: paper lost to the binding, added to the inside.
  /// -> length
  bind: 0mm,
  /// kulemt's `twoside` option: mirror margins on facing pages.
  /// -> bool
  twoside: false,
  /// kulemt's `twosidelrequal`: twoside with equal visible margins.
  /// -> bool
  twoside-lr-equal: false,
  /// kulemt's `coverpageonly`.
  /// -> bool
  cover-page-only: false,
  /// kulemt's `frontpagesonly`.
  /// -> bool
  front-pages-only: false,
  /// kulemt's `article` layout: no cover, no front pages, no front matter.
  /// -> bool
  article: false,
  /// Add a list of figures.
  /// -> bool
  list-of-figures: false,
  /// Add a list of tables. Shares one section with the figures, as
  /// \listoffiguresandtables does.
  /// -> bool
  list-of-tables: false,
  /// Add a list of listings (code blocks). Not part of kulemt.
  /// -> bool
  list-of-listings: false,
  /// Body text size. kulemt defines a page layout for 10pt and 11pt only.
  /// -> length
  font-size: 11pt,
  /// Faculty name. `auto` is the Faculty of Engineering Science.
  /// -> dictionary | auto
  faculty: auto,
  /// Your department's contact address for the copyright page, as
  /// (en: "...", nl: "..."). `auto` falls back to the faculty address,
  /// exactly as kulemt does when a programme defines none.
  /// -> dictionary | auto
  address: auto,
  /// hyperref colorlinks, as in the reference PDF: internal links red,
  /// citations green, URLs magenta. Set to none for black.
  /// -> color | none
  link-color: red,
  /// -> color | none
  cite-color: green,
  /// -> color | none
  url-color: rgb("#ee2299"),
  /// Append the official GenAI transparency statement. Mandatory for a
  /// master's thesis. In LaTeX this is \usetransparencystatement.
  /// -> bool
  transparency-statement: true,
  /// Boxes to tick on the statement: "course-assignment", "bachelor",
  /// "master-thesis", "not-used", "used".
  /// -> array
  transparency-ticks: (),
  /// Values written on the statement's rules.
  /// -> dictionary
  transparency-answers: (:),
  /// Category index (as a string, "0" to "10") -> "yes" or "no".
  /// -> dictionary
  transparency-uses: (:),
  /// The preface (voorwoord).
  /// -> content
  preface: none,
  /// The abstract (samenvatting).
  /// -> content
  abstract: none,
  /// Dutch summary, needed when writing in English for a Dutch programme.
  /// -> content
  dutch-summary: none,
  /// List of abbreviations: (term, description) pairs, or raw content.
  /// -> array | content
  abbreviations: none,
  /// List of symbols: (term, description) pairs, or raw content.
  /// -> array | content
  symbols: none,
  /// The bibliography.
  /// -> content
  bibliography: none,
  /// The appendices.
  /// -> content
  appendices: none,
  /// Logo for the cover and title page. `auto` picks the official KU Leuven /
  /// faculty logo for the programme language, as kulemt does from
  /// faculty.logo.dutch / faculty.logo.english.
  /// -> content | auto | none
  logo: auto,
  /// Automatically inserted body of the thesis.
  /// -> content
  body,
) = {
  set document(title: title, author: authors)

  // ---- programme -----------------------------------------------------------
  let deg = normalise-degree(degree)
  let fac = if faculty == auto { faculty-default } else { faculty }
  let addr = if address == auto { address-default } else { address }

  // ---- geometry ------------------------------------------------------------
  // kulemt-layout.dtx: 11pt -> 140 x 215 mm, 10pt -> 130 x 200 mm.
  // foremargin = 0.6(paper - text - bind), spinemargin = 0.4(...) + bind,
  // lower margin = 1.2 * upper. On A4 at 11pt: 28 / 42 / 37.3 / 44.7 mm.
  let mirror = (twoside or twoside-lr-equal) and not electronic-version
  // Chapters, appendices and the bibliography start on an odd page only when
  // the document is actually two-sided; otherwise that inserts blank fillers.
  let chapter-to = if mirror { "odd" } else { none }
  let body-margin = thesis-margins(
    font-size: font-size,
    bind: bind,
    twoside: mirror,
    lr-equal: twoside-lr-equal,
  )

  set text(font: "New Computer Modern", lang: language, size: font-size)
  set par(first-line-indent: 1em, spacing: 0.65em, justify: true)
  set heading(numbering: "1.1.1")
  set figure(numbering: it => context {
    let count = counter(heading).get()
    numbering("1.1", count.at(0), it)
  })

  // Installed unconditionally: a `show` rule inside an `if` block would only
  // apply to the rest of that block.
  show ref: it => if link-color == none { it } else { text(link-color, it) }
  show cite: it => if cite-color == none { it } else { text(cite-color, it) }
  show link: it => if url-color == none { it } else { text(url-color, it) }

  let cover(is-cover) = component.insert-cover-page(
    title,
    subtitle,
    authors,
    promotors,
    assessors,
    supervisors,
    academic-year,
    deg,
    english-master,
    logo,
    cover: is-cover,
    lang: language,
  )

  let statement = {
    if transparency-statement {
      component.insert-transparency-statement(
        academic-year: academic-year,
        lang: if english-master { "en" } else { "nl" },
        ticks: transparency-ticks,
        answers: transparency-answers,
        uses: transparency-uses,
      )
    }
  }

  // Branches are nested rather than written as early returns: `set` and `show`
  // rules apply to the remainder of the block they appear in, so an early
  // `return` would silently drop them.
  if article {
    set page(paper: "a4", margin: body-margin, numbering: "1")
    body
    if appendices != none {
      component.insert-appendices(appendices, lang: language, to: chapter-to)
    }
    component.insert-bibliography(bibliography, lang: language, to: chapter-to)
    statement
  } else {
    let show-cover = cover-page-only or not electronic-version

    if show-cover { cover(true) }

    if not cover-page-only {
      cover(false)
      component.insert-copyright(
        english-master,
        language,
        authors,
        academic-year,
        fac,
        addr,
        margin: body-margin,
      )

      if not front-pages-only {
        // Roman numbering starts after the title and copyright pages, plus the
        // cover page when there is one.
        let front-offset = (if show-cover { 1 } else { 0 }) + 2

        set page(
          paper: "a4",
          numbering: (num, ..) => numbering("i", num - front-offset),
          margin: body-margin,
          header: context utils.custom-header(),
          footer: context utils.custom-footer(),
          footer-descent: 15%,
        )

        show heading.where(level: 1): it => {
          pagebreak(weak: true)
          pad(top: 19mm, bottom: 19mm, {
            set text(1.55em, weight: "bold")
            it.body
          })
        }

        let spacing = 0.5em
        set par(first-line-indent: 0.5cm, leading: spacing, spacing: spacing)

        component.insert-preface(preface, authors, lang: language)
        component.insert-heading-outline(
          lang: language,
          link-color: link-color,
        )
        component.insert-abstract(abstract, lang: language)

        if (not english-master) and language == "en" {
          component.insert-abstract(dutch-summary, lang: "nl")
        }

        if list-of-figures or list-of-tables {
          component.insert-figures-tables-outline(
            lang: language,
            figures: list-of-figures,
            tables: list-of-tables,
            link-color: link-color,
          )
        }
        if list-of-listings {
          component.insert-listing-outline(
            lang: language,
            link-color: link-color,
          )
        }
        if abbreviations != none or symbols != none {
          component.insert-list-of-abbrv-symbol(
            lang: language,
            symbols: symbols,
            abbreviations: abbreviations,
          )
        }

        // ---- main matter ----------------------------------------------------
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
        set heading(supplement: "Chapter")
        set heading(numbering: chapter-numbering)

        show heading.where(level: 1): it => {
          pagebreak(weak: true, to: chapter-to)
          context counter(figure.where(kind: image)).update(0)
          block[
            // An unnumbered level-1 heading in the main matter -- the
            // transparency statement, for one -- has `numbering: none`, and
            // numbering(none, ..) is an error rather than an empty string.
            #if it.numbering != none {
              pad(top: 25mm, text(size: 1.3em, weight: "semibold")[
                #it.supplement #numbering(
                  it.numbering,
                  counter(heading).at(here()).at(0),
                )
              ])
            } else {
              v(25mm)
            }
            #pad(top: 1em, bottom: 2em, text(size: 1.7em)[#it.body])
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
          #pad(top: 0em, bottom: 0.5em)[#it.body]
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
          component.insert-appendices(
            appendices,
            lang: language,
            to: chapter-to,
          )
        }
        component.insert-bibliography(
          bibliography,
          lang: language,
          to: chapter-to,
        )
        statement
      }
    }
  }
}
