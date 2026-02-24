/// This function gets your whole document as its `body` and format it as an
/// article in the style of the IEEE with the first page needed by a ENSIMAG
/// internship report
///
/// -> content
#let ensimag(
  /// Logos shown in the header of the first page
  /// -> dict
  logos: (
    /// The logo of the company
    /// -> content | none
    company: none,

    /// The logo of the ENSIMAG
    ///
    /// Due to copyright restrictions, the logo cannot be included within the
    /// package.
    ///
    /// -> content | none
    ensimag: none,
  ),

  /// The document title
  /// -> content | none
  title: none,

  /// The author's informations
  /// -> dict
  author: (
    /// The author's name
    /// -> str | array
    name: "",

    /// The author's school year
    /// -> content | none
    year: none,

    /// The author's option
    /// -> content | none
    option: none,
  ),

  /// The period of the internship
  /// -> dict
  period: (
    /// The begin date
    /// -> datetime
    begin: none,

    /// The end date
    /// -> datetime
    end: none,
  ),

  /// Date format string
  ///
  /// Please see the #link(https://typst.app/docs/reference/foundations/datetime/#format)[format syntax].
  ///
  /// -> auto | str
  date-fmt: auto,

  /// The informations about the company
  /// -> dict
  company: (
    /// The name of the company
    /// -> content | none
    name: none,

    /// The address of the company
    /// -> content | none
    address: none,
  ),

  /// The internship tutor
  /// -> content | none
  internship-tutor: none,

  /// The school tutor
  /// -> content | none
  school-tutor: none,

  /// The paper's abstract
  ///
  /// It can be omitted if you don't have one.
  ///
  /// -> content | none
  abstract: none,

  /// A list of index terms to display after the abstract
  /// -> array
  index-terms: (),

  /// The article's paper size
  ///
  /// It also affects the margins.
  ///
  /// -> str
  paper-size: "a4",

  /// The result of a call to the `bibliography` function or `none`
  /// -> content | none
  bibliography: none,

  /// How figures are referred to from within the text
  ///
  /// Use "Figure" instead of "Fig." for computer-related publications.
  ///
  /// -> content | none
  figure-supplement: [Fig.],

  /// The paper's content
  /// -> content | none
  body,
) = {
  // Set document metadata.
  set document(title: title, author: author.name)

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
  show figure.where(kind: image): set figure(supplement: figure-supplement, numbering: "1")
  show figure.caption: set text(size: 8pt)
  show figure.caption: set align(start)
  show figure.caption.where(kind: table): set align(center)

  // Adapt supplement in caption independently from supplement used for
  // references.
  set figure.caption(separator: [. ])
  show figure: fig => {
    let prefix = (
      if fig.kind == table [TABLE]
      else if fig.kind == image [Fig.]
      else [#fig.supplement]
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
    size: 1em / 0.8,
    spacing: 100%,
  )

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
    }
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
        ..counter(math.equation).at(it.element.location())
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
      // First-level headings are centered smallcaps. We don't want to number
      // the acknowledgment section.
      let is-ack = it.body == [Remerciements]
      set align(center)
      set text(if is-ack { 10pt } else { 11pt })
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
  set std.bibliography(title: text(10pt)[Réferences], style: "ieee")

  // Display the paper's first page, spanning all columns (hence floating at
  // the scope of the columns' parent, which is the page).
  let first = grid(
    columns: (50%, 50%),
    rows: (5%, 90%, 5%),
    align: (left, right),
    logos.company,
    logos.ensimag,
    grid.cell(
      align: center,
      colspan: 2,
      {
        let top-title = text(14pt)[
          Grenoble INP --- ENSIMAG \
          École Nationale Supérieure d'Informatique et de Mathématiques Appliquées
        ]

        let main-title = text(22pt)[Rapport de Stage Assistant Ingénieur]
        let subtitle = text(14pt)[Effectué chez #company.name]

        let big-title = rect(
          inset: 8pt,
          stroke: 2pt,
          width: 100%,
          text(20pt, title),
        )

        let extra = text(12pt)[
          #author.name \
          #author.year --- #author.option
        ]

        let date = text(12pt)[
          #period.begin.display(date-fmt)
          ---
          #period.end.display(date-fmt)
        ]

        top-title
        v(3fr)
        main-title
        v(1fr)
        subtitle
        v(2fr)
        big-title
        v(2fr)
        extra
        v(10pt)
        date
        v(2fr)
      }
    ),
    [
      #strong(company.name) \
      #company.address
    ],
    [
      *Responsable de stage* \
      #internship-tutor

      *Tuteur de l'école* \
      #school-tutor
    ],
  )

  place(
    top,
    float: true,
    scope: "parent",
    clearance: 30pt,
    first
  )

  set par(justify: true, first-line-indent: (amount: 1em, all: true), spacing: 0.5em, leading: 0.5em)

  // Display abstract and index terms.
  if abstract != none {
    set par(spacing: 0.45em, leading: 0.45em)
    set text(9pt, weight: 700, spacing: 150%)


    [_Résumé_ --- #abstract]


    if index-terms != () {
      parbreak()
      [_Mots-clefs_ --- #index-terms.join[, ]]
    }
    v(2pt)
  }

  // Display the paper's contents.
  body

  // Display bibliography.
  bibliography
}
