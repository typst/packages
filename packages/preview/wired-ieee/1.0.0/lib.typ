// This function gets your whole document as its `body` and formats
// it as an article in the style of the IEEE.
#let ieee(
  // The paper's title.
  title: [Paper Title],
  // An array of authors. For each author you can specify a name,
  // department, organization, location, and email. Everything but
  // but the name is optional.
  authors: (),
  // The paper's abstract. Can be omitted if you don't have one.
  abstract: none,
  // Float and center abstract and index terms
  float-abstract: true,
  // A list of index terms to display after the abstract.
  index-terms: (),
  // Vertical text in the left margin
  aside: none,
  // The article's paper size. Also affects the margins.
  paper-size: "us-letter",
  // The result of a call to the `bibliography` function or `none`.
  //
  bibliography: none,
  // Show number line in code snippets
  raw-numbers: false,
  // Document language
  lang: "en",
  // Custom internationalization dictionary
  i18n: (:),
  // The paper's content.
  body,
) = {
  // Set document metadata.
  set document(title: title, author: authors.map(author => author.name))
  set text(lang: lang)

  // template translations. Match text.lang, defaults to "en"
  // TODO: comment what each entry is for
  let i18n-default = (
    en: (
      abstract: "Abstract", // Opening document summary
      index: "Index Terms", // Keywords following the abstract
      table: "TABLE", // Caption label for tables
      fig: "Fig.", // Caption label for figures
      fig-supplement: "Figure", // Full word used for in-text references
      references: "References", // Bibliography section title
      ack: ([Acknowledgment], [Acknowledgement], [Acknowledgments], [Acknowledgements]), // Unnumbered section variants
    ),
    es: (
      abstract: "Resumen",
      index: "Palabras clave",
      table: "TABLA",
      fig: "Fig.",
      fig-supplement: "Figura",
      references: "Referencias",
      ack: ([Agradecimientos],),
    ),
    pt: (
      abstract: "Resumo",
      index: "Palavras-chave",
      table: "TABELA",
      fig: "Fig.",
      fig-supplement: "Figura",
      references: "Referências",
      ack: ([Agradecimentos],),
    ),
    fr: (
      abstract: "Résumé",
      index: "Mots-clés",
      table: "TABLEAU",
      fig: "Fig.",
      fig-supplement: "Figure",
      references: "Références",
      ack: ([Remerciements],),
    ),
    de: (
      abstract: "Zusammenfassung",
      index: "Schlüsselwörter",
      table: "TABELLE",
      fig: "Abb.",
      fig-supplement: "Abbildung",
      references: "Literaturverzeichnis",
      ack: ([Danksagung], [Danksagungen]),
    ),
    it: (
      abstract: "Sommario",
      index: "Parole chiave",
      table: "TABELLA",
      fig: "Fig.",
      fig-supplement: "Figura",
      references: "Riferimenti",
      ack: ([Ringraziamenti],),
    ),
  )

  // extract the current translations.
  // For mathematicians: custom + (default - custom).
  i18n = (:
    ..i18n-default.at(lang, default: i18n-default.en),
    ..i18n.at(lang, default: (:)),
  )

  // Set the body font.
  // As of 2024-08, the IEEE LaTeX template uses wider interword spacing
  // - See e.g. the definition \def\@IEEEinterspaceratioM{0.35} in IEEEtran.cls
  set text(font: "TeX Gyre Termes", size: 10pt, spacing: .35em)

  // Enums numbering
  set enum(numbering: "1)a)i)")

  // Tables & figures
  show figure: set block(spacing: 15.5pt)
  show figure: set place(clearance: 15.5pt)
  show figure.where(kind: table): set figure.caption(position: top, separator: [\ ])
  show figure.where(kind: table): set text(size: 8pt)
  show figure.where(kind: table): set figure(numbering: "I")
  show figure.where(kind: image): set figure(supplement: i18n.fig-supplement, numbering: "1")
  show figure.caption: set text(size: 8pt)
  show figure.caption: set align(start)
  show figure.caption.where(kind: table): set align(center)

  // Adapt supplement in caption independently from supplement used for
  // references.
  set figure.caption(separator: [. ])
  show figure: fig => {
    let prefix = (
      if fig.kind == table [#(i18n.table)] else if fig.kind == image [#(i18n.fig)] else [#fig.supplement]
    )
    let numbers = numbering(fig.numbering, ..fig.counter.at(fig.location()))
    // Wrap figure captions in block to prevent the creation of paragraphs. In
    // particular, this means `par.first-line-indent` does not apply.
    // See https://github.com/typst/templates/pull/73#discussion_r2112947947.
    show figure.caption: it => block[#prefix~#numbers#it.separator#it.body]
    show figure.caption.where(kind: table): smallcaps
    fig
  }

  // Code blocks
  show raw: set text(
    font: "TeX Gyre Cursor",
    ligatures: false,
    size: 1em,
    spacing: 100%,
  )

  show raw.where(block: true): it => block(
    width: 100%,
    inset: 1em,
    fill: luma(97%),
  )[
    #set align(left)
    #set text(size: 0.8em)
    #grid(
      columns: (1fr, auto),
      gutter: 1em,
      [#{
        for (i, e) in it.lines.enumerate() [
          #if raw-numbers { text(fill: luma(60%))[#(if i + 1 < 10 { " " + str(i + 1) } else { str(i + 1) })] }
          #h(1em)#e#linebreak()]
      }],
      [#text(fill: luma(60%))[#it.lang]],
    )
  ]

  // Configure the page and multi-column properties.
  set columns(gutter: 12pt)
  set page(
    columns: 2,
    paper: paper-size,
    // The margins depend on the paper size.
    margin: if paper-size == "a4" {
      (x: 41.5pt, top: 80.51pt, bottom: 89.51pt)
    } else {
      (
        x: (50pt / 216mm) * 100%,
        top: (55pt / 279mm) * 100%,
        bottom: (64pt / 279mm) * 100%,
      )
    },
  )

  // aside
  set page(
    background: if aside != none {
      context {
        set text(size: 9pt, fill: luma(60%))
        place(
          left + horizon,
          dx: page.margin.left / 2,

          rotate(-90deg, reflow: true)[
            #align(center, aside)
          ],
        )
      }
    },
  )

  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 0.65em)

  // Configure appearance of equation references
  show ref: it => {
    if it.element != none and it.element.func() == math.equation {
      // Override equation references.
      link(it.element.location(), numbering(
        it.element.numbering,
        ..counter(math.equation).at(it.element.location()),
      ))
    } else {
      // Other references as usual.
      it
    }
  }

  // Configure lists.
  set enum(indent: 10pt, body-indent: 9pt)
  set list(indent: 10pt, body-indent: 9pt)

  // Configure headings.
  set heading(numbering: "I.A.a)")
  show heading: it => {
    // Find out the final number of the heading counter.
    let levels = counter(heading).get()
    let deepest = if levels != () {
      levels.last()
    } else {
      1
    }

    set text(10pt, weight: 400)
    if it.level == 1 {
      // First-level headings are centered smallcaps.
      // We don't want to number the acknowledgment section.
      let is-ack = it.body in i18n.ack
      set align(center)
      set text(12pt)
      show: block.with(above: 15pt, below: 13.75pt, sticky: true)
      show: smallcaps
      if it.numbering != none and not is-ack {
        numbering("I.", deepest)
        h(7pt, weak: true)
      }
      it.body
    } else if it.level == 2 {
      // Second-level headings are run-ins.
      set text(style: "italic")
      show: block.with(spacing: 10pt, sticky: true)
      if it.numbering != none {
        numbering("A.", deepest)
        h(7pt, weak: true)
      }
      it.body
    } else [
      // Third level headings are run-ins too, but different.
      #if it.level == 3 {
        numbering("a)", deepest)
        [ ]
      }
      _#(it.body):_
    ]
  }

  // Style bibliography.
  show std.bibliography: set text(8pt)
  show std.bibliography: set block(spacing: 0.5em)
  set std.bibliography(title: text(12pt)[#(i18n.references)], style: "ieee")

  // Display abstract and index terms.
  let display_abstract_and_index_terms() = {
    box(width: 90%)[
      #set par(justify: true, first-line-indent: (amount: 1em, all: true), spacing: 0.5em, leading: 0.5em)
      #if abstract != none {
        set align(left)
        set par(spacing: 0.45em, leading: 0.45em)
        set text(style: "italic", weight: "bold")

        [#(i18n.abstract)---#h(weak: true, 0pt)#abstract]

        if index-terms != () {
          parbreak()
          v(0.5em)
          text(weight: "bold")[
            #(i18n.index)---#h(weak: true, 0pt)#index-terms.join[, ]
          ]
        }
        v(2pt)
      }]
  }

  // Display the paper's title and authors at the top of the page,
  // spanning all columns (hence floating at the scope of the
  // columns' parent, which is the page).
  place(
    top + center,
    float: true,
    scope: "parent",
    clearance: 30pt,
    {
      show std.title: set align(center)
      show std.title: set par(leading: 0.5em)
      show std.title: set text(size: 24pt, weight: "regular")
      show std.title: set block(below: 8.35mm)
      std.title()

      // Display the authors list.
      set par(leading: 0.6em)
      for i in range(calc.ceil(authors.len() / 3)) {
        let end = calc.min((i + 1) * 3, authors.len())
        let is-last = authors.len() == end
        let slice = authors.slice(i * 3, end)
        grid(
          columns: slice.len() * (1fr,),
          gutter: 12pt,
          ..slice.map(author => align(center, {
            text(size: 11pt, author.name)
            if "department" in author [
              \ #emph(author.department)
            ]
            if "organization" in author [
              \ #emph(author.organization)
            ]
            if "location" in author [
              \ #author.location
            ]
            if "email" in author {
              if type(author.email) == str [
                \ #link("mailto:" + author.email)
              ] else [
                \ #author.email
              ]
            }
          }))
        )

        if not is-last {
          v(16pt, weak: true)
        }
      }
    },
  )

  set par(justify: true, first-line-indent: (amount: 1em, all: true), spacing: 0.5em, leading: 0.5em)

  if (float-abstract) {
    place(
      top + center,
      float: true,
      scope: "parent",
      display_abstract_and_index_terms(),
    )
  }

  if (not float-abstract) { display_abstract_and_index_terms() }

  // Display the paper's contents.
  body

  // Display bibliography.
  bibliography
}
