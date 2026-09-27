// LTeX: enabled=false

#import "@preview/glossarium:0.5.10": (
  gls, glspl, make-glossary, print-glossary, register-glossary,
)
#import "@preview/hydra:0.6.3": hydra
#import "@preview/codly:1.3.0": codly, codly-init
#import "@preview/drafting:0.2.2": note-outline, set-margin-note-defaults
#import "@preview/linguify:0.5.0": (
  linguify, linguify-raw, load-ftl-data, set-database,
)
#import "utils.typ": __in-outline, __linguify-content

/// Default heading numbering pattern.
/// -> str
#let __heading-numbering = "1.1.1"

/// Creates a signature line for statutory declarations.
///
/// Generates a formatted signature block with place, date, and signature fields.
/// When `digital` is true, displays the author's name or signature image;
/// when false, leaves the fields blank for handwritten signatures.
/// -> content
#let __signature-line(
  /// Whether this is a digital submission with pre-filled signature. -> bool
  digital: true,
  /// City name for the signature location. -> str | none
  city: none,
  /// Date of the signature. -> str | none
  date: none,
  /// Format string for displaying the date. (see #link("https://typst.app/docs/reference/foundations/datetime/#format")[datetime formats]) -> str
  date-format: "[day].[month].[year]",
  /// Author dictionary with `firstname`, `lastname`, and optionally `signature`
  /// (an image). -> dictionary
  author: (
    firstname: none,
    lastname: none,
  ),
) = {
  // TODO: only for compatibility reasons: Remove with v3.0.0 release
  if type(date) == datetime {
    date = date.display(date-format)
  }

  let signature-content = if digital {
    (
      city,
      date,
      [],
      grid.cell(
        if not author.keys().contains("signature") or author.signature == none {
          author.firstname + " " + author.lastname
        } else {
          set image(height: 25mm)
          place(bottom, author.signature)
        },
        align: center,
      ),
    )
  } else {
    ([], [], [], [])
  }

  v(20mm)

  align(center, grid(
    stroke: none,
    columns: (30mm, 30mm, 20mm, 80mm),
    ..signature-content,
    grid.hline(end: 2), grid.hline(start: 3),
    __linguify-content("place-of-signature"),
    __linguify-content("date-of-signature"),
    [],
    grid.cell(__linguify-content("signature"), align: center),
  ))
}


/// Base template for thesis documents.
///
/// This is the core template function that sets up the document structure,
/// styling, and layout. It handles the cover page, table of contents,
/// lists of figures/tables/code, bibliography, and appendices.
///
/// Institution-specific adapters should wrap this function to add their
/// specific requirements. However the parameters shown here can be used with all adapters.
/// -> content
#let project(
  /// The primary language of the document. Affects hyphenation, quotes,
  /// and localized strings. Supported: `"en"`, `"de"`. -> str
  lang: "en",
  /// Full thesis title displayed on the cover page. -> str | none
  title-long: none,
  /// Shortened title displayed in the page header. -> str | none
  title-short: none,
  /// Type of thesis (e.g., "Projektarbeit 1", "Bachelorarbeit").
  /// Displayed below the title on the cover. -> str | none
  thesis-type: none,
  /// Optional acknowledgements page to thank your scientific supervisor,
  /// company mentor, or family and friends. If `none`, the page is omitted. -> str | content | none
  acknowledgements: none,
  /// List of abstract tuples. Each tuple contains:
  /// `(language-code, language-name, content)` e.g., `("en", "English", [Abstract text...])`. -> array
  abstracts: (),
  /// List of appendix dictionaries. Each should have `title` (str)
  /// and `content`, optionally `reference` (label string). Set to `none` to disable appendices. -> array | none
  appendices: (
    (
      title: none,
      reference: none,
      content: none,
    ),
  ),
  /// Path to the bibliography file (`.bib` or `.yaml`), relative to the
  /// template directory. -> str
  library: (),
  /// List of abbreviation entries for the glossary. See the
  /// #link("https://typst.app/universe/package/glossarium/")[glossarium package]
  /// for the expected format. -> array
  abbreviations: (),
  /// List of glossary entries for term explanations (not abbreviations). See the
  /// #link("https://typst.app/universe/package/glossarium/")[glossarium package]
  /// for the expected format. -> array
  glossary: (),
  /// Whether the content page numbering should include total pages ("3 / 24") or not ("3"). -> bool
  numbering-show-total: false,
  /// Adapter-internal options forwarded by the adapters
  /// (`dhbw-ka`, `dhbw-ma`, `ihk`). End users should not set these directly.
  ///
  /// Recognized named keys (all optional):
  /// - `__logo-left` (content | none): top-left cover logo (e.g. company logo).
  /// - `__logo-right` (content | none): top-right cover logo (institution logo).
  /// - `__submission-info` (content | none): submission block under the title.
  /// - `__metadata` (array): flat key/value pairs for the cover meta table.
  /// - `__authors` (array): list of author dictionaries with `firstname` /
  ///   `lastname` (and optionally `signature`).
  /// - `__confidentiality-clause` (bool): whether to print the confidentiality
  ///   stamp on the title page. Adapters enabling this must create a
  ///   `<__confidentiality-clause>` label somewhere in the document.
  /// - `__postamble` (array): content elements appended after the indices.
  ..__opts,
  body,
) = {
  // Unpack adapter-supplied internal options.
  let __logo-left = __opts.named().at("__logo-left", default: none)
  let __logo-right = __opts.named().at("__logo-right", default: none)
  let __submission-info = __opts.named().at("__submission-info", default: none)
  let __metadata = __opts.named().at("__metadata", default: ())
  let __authors = __opts
    .named()
    .at(
      "__authors",
      default: ((firstname: none, lastname: none),),
    )
  let __confidentiality-clause = __opts
    .named()
    .at("__confidentiality-clause", default: false)
  let __postamble = __opts.named().at("__postamble", default: ())

  // load linguify
  set-database(eval(load-ftl-data("l10n", ("en", "de"))))

  set bibliography(title: __linguify-content("bibliography"))

  // page setup
  set document(title: title-long)
  set page(paper: "a4", margin: (rest: 2.5cm))

  // set text language (e. g. for smart quotes)
  set text(lang: lang)

  // font setup (LaTeX Look: 'New Computer Modern')
  set text(font: "New Computer Modern", size: 12pt)

  // justify content.
  // Values researched in https://github.com/dhbw-typst/oderso-template-dev/pull/64 to match Arial 12pt and 1.5 line spacing in Microsoft Word
  set par(justify: true, leading: 1.05em, spacing: 1.5em)

  // tables settings
  show table: set par(justify: false)

  // heading setup
  set heading(numbering: __heading-numbering)

  show heading: it => {
    it
    v(0.5cm)
  }

  show heading.where(level: 2): it => {
    v(weak: true, 1.2cm)
    it
  }

  // fancy inline code
  // if you don't like them, just remove this section.
  show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: 2pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )

  // fancy code blocks
  // if you don't like them, just remove this section.
  show: codly-init.with()

  codly(
    zebra-fill: none,
    display-icon: false,
    display-name: false,
    number-align: right + top,
  )

  show figure.where(kind: raw): set figure(supplement: "Code")

  // set table numbering to roman
  show figure.where(kind: table): set figure(numbering: "I")

  show: make-glossary

  // fancy inline links
  // if you don't like them, just remove this section.
  show link: it => {
    if type(it.dest) == str {
      set text(fill: gray.darken(80%))
      underline(
        stroke: (paint: gray, thickness: 0.5pt, dash: "densely-dashed"),
        offset: 4pt,
        it,
      )
    } else {
      it
    }
  }

  // Block quotes
  set quote(block: true)

  // Configure inline notes
  let caution-rect = rect.with(radius: 0.5em)
  set-margin-note-defaults(rect: caution-rect, fill: orange.lighten(80%))

  // Coversheet
  // Show notes before everything else, so you don't miss them
  context {
    // Check wether there are any notes in the document
    if (query(selector(<margin-note>).or(<inline-note>)).len() > 0) {
      set heading(numbering: none, outlined: false)
      note-outline(title: __linguify-content("list-of-notes"))
      pagebreak()
    }
  }

  // Allow code blocks to span multiple pages
  show figure.where(kind: raw): set block(breakable: true)

  // Equation figures
  set math.equation(numbering: "(1)")
  // follow IEEE style for equation references: `(1)` instead of `equation 1`
  show ref: it => {
    if it.element != none and it.element.func() == math.equation {
      numbering("(1)", ..counter(math.equation).at(it.target))
    } else {
      it
    }
  }

  // Coversheet
  grid(
    rows: (1fr, auto, 1fr),
    align: (_, row) => (center + top, center + top, center + bottom).at(row),
    // Left and right logo
    {
      set image(height: 2.5cm)

      grid(
        columns: (1fr, 1fr),
        align(left, __logo-left), align(right, __logo-right),
      )
    },

    // Title
    align(center)[
      #set par(justify: false)

      #text(20pt)[*#title-long*]

      #smallcaps(text(1.25em, weight: "semibold")[#thesis-type])

      #__submission-info

      #__linguify-content("by")

      #for author in __authors {
        [*#author.firstname #author.lastname*\ ]
      }
    ],

    // Meta
    place(center + bottom, {
      show table.cell.where(x: 0): set text(weight: "semibold")

      set par(leading: .6em)

      table(
        columns: (1fr, 1fr),
        align: (right + top, left + top),
        stroke: none,
        ..__metadata
      )
    }),
  )

  if __confidentiality-clause {
    place(top + center, dy: 5cm, link(<__confidentiality-clause>)[
      #text(
        size: 12pt,
        weight: "bold",
        fill: gray,
        linguify("confidentiality-stamp"),
      )
    ])
  }

  pagebreak()

  // start page count on second page
  counter(page).update(1)
  set page(numbering: "I")

  // register abbreviations before content so references resolve
  if abbreviations.len() > 0 {
    register-glossary(abbreviations)
  }

  // register glossary entries before content so references resolve
  if glossary.len() > 0 {
    register-glossary(glossary)
  }

  // acknowledgements
  if acknowledgements != none {
    pagebreak(weak: true)
    align(center + horizon, {
      heading(outlined: false, numbering: none, [#text(
        0.85em,
        smallcaps(__linguify-content("acknowledgments")),
      )\ ])
      align(left, acknowledgements)
      v(20%)
    })
  }

  // abstracts
  for a in abstracts {
    let (abstract-lang, abstract-lang-long, abstract-body) = a
    pagebreak(weak: true)
    align(center + horizon, {
      heading(outlined: false, numbering: none, [#text(
          0.85em,
          smallcaps(__linguify-content("abstract")),
        )\ #text(
          0.75em,
          weight: "light",
          style: "italic",
          [\- #abstract-lang-long -],
        )])
      align(left, text(lang: abstract-lang, abstract-body))
      v(20%)
    })
  }

  // captions with caption_with_source shouldn't show source in outline
  show outline: it => {
    __in-outline.update(true)
    it
    __in-outline.update(false)
  }

  // table of contents
  // show level 1 headings in outline in a fancier way, if not desired feel free to remove it
  pagebreak(weak: true)
  {
    show outline.entry.where(level: 1): strong
    set par(leading: 0.65em)
    outline(
      title: __linguify-content("table-of-contents"),
      depth: 3,
      indent: auto,
      target: selector(heading).before(
        <__appendix-start>,
      ),
    )
  }

  {
    // display header
    set page(
      margin: (top: 4cm),
      header: {
        context {
          grid(
            columns: (auto, 1fr),
            align(left, text(title-short)),
            align(right, emph(hydra(1, display: (_, it) => {
              it.body
            }))),
          )
          line(length: 100%, stroke: (paint: gray))
        }
      },
      numbering: "1",
      footer: context align(center, {
        if numbering-show-total {
          numbering(
            "1 / 1",
            counter(page).get().at(0),
            ..counter(page).at(<__content-end>),
          )
        } else {
          numbering("1", counter(page).get().at(0))
        }
      }),
    )
    show heading.where(level: 1): it => {
      pagebreak(weak: true)
      it
    }

    // reset page counter and show content
    counter(page).update(1)

    body
    [#[] <__content-end>]
  }

  // display bibliography
  set page(numbering: "a", footer: auto)
  counter(page).update(1)

  // This is just for supporting the old method of usage, but it is deprecated
  // TODO: probably rework with Typst 0.15.0
  if type(library) == str {
    bibliography(
      "../" + library,
    )
  } else {
    library
  }

  // lists and declarations (between content and appendix)
  {
    set heading(numbering: none)

    // index of abbreviations
    if abbreviations.len() > 0 {
      pagebreak()
      heading(__linguify-content("abbreviations"))
      print-glossary(abbreviations, deduplicate-back-references: true)
    }

    // index of glossary terms
    if glossary.len() > 0 {
      pagebreak()
      heading(__linguify-content("glossary"))
      print-glossary(glossary, deduplicate-back-references: true)
    }

    // only display certain outlines if elements for it exist
    context {
      // list of figures
      if query(figure.where(kind: image)).len() > 0 {
        pagebreak()
        heading(__linguify-content("list-of-figures"))
        outline(
          target: figure.where(kind: image).before(<__appendix-start>),
          title: none,
        )
      }

      // list of tables
      if query(figure.where(kind: table)).len() > 0 {
        pagebreak()
        heading(__linguify-content("list-of-tables"))
        outline(
          target: figure.where(kind: table).before(<__appendix-start>),
          title: none,
        )
      }

      // list of source code
      if query(figure.where(kind: raw)).len() > 0 {
        pagebreak()
        heading(__linguify-content("list-of-code"))
        outline(
          target: figure.where(kind: raw).before(<__appendix-start>),
          title: none,
        )
      }
    }

    // postamble (statutory declaration, confidentiality, AI declaration)
    for p in __postamble {
      p
    }
  }

  // display appendix
  appendices = appendices.filter(item => (
    item.title != none and item.content != none
  ))
  if appendices.len() > 0 {
    set heading(
      outlined: true,
      numbering: (..nums) => {
        "Appendix "
        numbering("1.1", ..nums)
      },
      supplement: none,
    )
    set page(numbering: "A", footer: auto)
    counter(page).update(1)
    counter(heading).update(0)

    heading(
      __linguify-content("list-of-appendices"),
      numbering: none,
    )

    outline(
      depth: 1,
      indent: auto,
      title: none,
      target: selector(heading).after(<__appendix-start>),
    )

    pagebreak(weak: true)
    [#[] <__appendix-start>]

    for appendix in appendices {
      pagebreak(weak: true)
      [#heading(appendix.title) #label(appendix.reference)]

      appendix.content
    }
  }
}
