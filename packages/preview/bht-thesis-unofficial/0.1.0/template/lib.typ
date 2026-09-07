#let std-bibliography = bibliography

#import "bht-title-page.typ": bht-title-page

// Outline of all image figures.
#let list-of-figures(title: auto) = context outline(
  title: if title == auto {
    if text.lang == "de" { "Abbildungsverzeichnis" } else { "List of Figures" }
  } else { title },
  target: figure.where(kind: image),
)

// Outline of all table figures.
#let list-of-tables(title: auto) = context outline(
  title: if title == auto {
    if text.lang == "de" { "Tabellenverzeichnis" } else { "List of Tables" }
  } else { title },
  target: figure.where(kind: table),
)

// BHT corporate colors (from bhtThesis.sty).
#let bht-colors = (
  gray: rgb("#555555"),
  turquoise: rgb("#00A0AA"),
  yellow: rgb("#FFC900"),
  red: rgb("#EA3B06"),
  blue: rgb("#004282"),
)

// Default label sets for English and German.
#let default-labels-en = (
  contents: "Contents",
  bibliography: "Bibliography",
  submitted-by: "submitted by",
  student-id-label: "Matrikelnummer",
  department-prefix: "to the Department",
  university-prefix: "of the",
  university: "Berliner Hochschule für Technik",
  thesis-submission: "submitted as a",
  thesis-purpose: "in fulfilment of the requirements for the academic degree",
  study-program-label: "in the study program",
  date-label: "Date of submission:",
  bachelor-thesis-kind: "Bachelor's Thesis",
  bachelor-degree: "Bachelor of Science",
  bachelor-abbreviation: "B.Sc.",
  master-thesis-kind: "Master's Thesis",
  master-degree: "Master of Science",
  master-abbreviation: "M.Sc.",
  chapter-supplement: "Chapter",
  appendix-supplement: "Appendix",
)

#let default-labels-de = (
  contents: "Inhaltsverzeichnis",
  bibliography: "Literatur- und Quellenverzeichnis",
  submitted-by: "vorgelegt von",
  student-id-label: "Matrikelnummer",
  department-prefix: "dem Fachbereich",
  university-prefix: "der",
  university: "Berliner Hochschule für Technik",
  thesis-submission: "vorgelegte",
  thesis-purpose: "zur Erlangung des akademischen Grades",
  study-program-label: "im Studiengang",
  date-label: "Tag der Abgabe",
  bachelor-thesis-kind: "Bachelorarbeit",
  bachelor-degree: "Bachelor of Science",
  bachelor-abbreviation: "B.Sc.",
  master-thesis-kind: "Masterarbeit",
  master-degree: "Master of Science",
  master-abbreviation: "M.Sc.",
  chapter-supplement: "Kapitel",
  appendix-supplement: "Anhang",
)

// Default typography settings (font, sizes, spacing).
#let default-typography = (
  font: "Libertinus Serif",
  cover-font: ("Arial", "Helvetica", "Liberation Sans"),
  body-text-size: 12pt,
  caption-text-size: 9pt,
  table-text-size: 9pt,
  line-spacing: 0.65em,
  justify: true,
  heading-sizes: (h1: 20pt, h2: 16pt, h3: 14pt, h4: 12pt, fallback: 12pt),
)

// Default layout settings (margins, print mode, ToC depth).
#let default-layout = (
  margin: (left: 35mm, right: 35mm, top: 30mm, bottom: 30mm),
  for-print: false,
  chapter-pagebreak: true,
  toc-depth: 4,
  show-header: true,
)

// Default appearance settings (colors, logos).
#let default-appearance = (
  accent-color: bht-colors.blue,
  bht-logo: "assets/bht-logo-vertical.svg",
  bht-logo-width: 2.25cm,
  bht-elements: "assets/bht-elements.svg",
  bht-studiere: "assets/bht-studiere-vertical.svg",
)

// The project function defines how your document looks.
// It takes your content and some metadata and formats it.
// Go ahead and customize it to your liking!
#let project(
  // The title of the thesis
  title: "",
  // An optional subtitle shown below the title
  subtitle: "",
  // The name of the student writing the thesis
  name: "",
  // The student ID (Matrikelnummer)
  student-id: "",
  // Date of handing in the thesis
  date: none,
  // "Bachelor" or "Master"
  degree: "",
  // Degree field: "Science", "Engineering", or "Arts"
  field: "Science",
  // Study program of the student
  study-program: "",
  // Department (Fachbereich), e.g. "VI – Informatik und Medien"
  department: "",
  // Committee shown on the cover, in order. Entries are strings or dictionaries
  // of (role: "...", name: "...", institution: "..."), e.g.
  // (role: "Betreuer und Erstgutachter", name: "...", institution: "...").
  // Consecutive entries with the same role share one role header.
  committee: (),
  // Front matter sections between the title page and the table of contents (e.g.,
  // a confidentiality clause, a statement on AI use, and the abstract). Provide an
  // array of `(title: [...], body: [...])` dictionaries; the template renders each
  // title as a level-1 heading and starts each section on its own roman-numbered
  // page. Add `own-page: false` to an entry to continue on the previous section's
  // page (e.g. Kurzfassung and Abstract sharing one page).
  pre-toc: (),
  // Optional bibliography content (e.g., bibliography("references.bib")).
  // If provided, a bibliography section will be added at the end.
  bibliography: none,
  // Optional appendix content, rendered after the bibliography with
  // "A.1.1.1"-style heading numbering.
  appendix: none,
  // Optional content to insert between the TOC and the main body (e.g., a glossary,
  // list of figures, etc.). Rendered without header, with roman page numbering.
  // When for-print is true, a blank page is inserted after it if needed so the
  // first chapter starts on an odd page.
  pre-body: none,
  // Optional content rendered at the very end, after bibliography and appendix
  // (e.g. list-of-figures(), list-of-tables(), a list of abbreviations).
  post-body: none,
  // Document language (e.g., "en", "de"). Affects label defaults.
  lang: "en",
  // Typography settings (font, sizes, spacing). Merged with defaults.
  typography: (:),
  // Layout settings (margins, print mode, ToC depth). Merged with defaults.
  layout: (:),
  // Appearance settings (colors, logos). Merged with defaults.
  appearance: (:),
  // Override any translatable string. Merged on top of the language defaults.
  labels: (:),
  body,
) = {
  // Merge group defaults with user overrides.
  let typo = default-typography + typography
  let typo = typo + (heading-sizes: default-typography.heading-sizes + typography.at("heading-sizes", default: (:)))
  let lay = default-layout + layout
  let app = default-appearance + appearance

  // Merge label defaults with user overrides.
  let base-labels = if lang == "de" { default-labels-de } else {
    default-labels-en
  }
  let valid-keys = base-labels.keys()
  for key in labels.keys() {
    assert(key in valid-keys, message: "Unknown label key: " + key)
  }
  let l = base-labels + labels

  // Override degree name and abbreviation based on the field parameter.
  let degree-labels = if field == "Engineering" {
    (
      bachelor-degree: "Bachelor of Engineering",
      bachelor-abbreviation: "B.Eng.",
      master-degree: "Master of Engineering",
      master-abbreviation: "M.Eng.",
    )
  } else if field == "Arts" {
    (
      bachelor-degree: "Bachelor of Arts",
      bachelor-abbreviation: "B.A.",
      master-degree: "Master of Arts",
      master-abbreviation: "M.A.",
    )
  } else {
    (:)
  }
  let l = l + degree-labels

  // Creates a pagebreak to the given parity where empty pages
  // can be detected via `is-page-empty`.
  let detectable-pagebreak(to: "odd") = {
    [#metadata(none) <empty-page-start>]
    pagebreak(to: to)
    [#metadata(none) <empty-page-end>]
  }

  // Workaround for https://github.com/typst/typst/issues/2722
  let is-page-empty() = {
    let page-num = here().page()
    query(<empty-page-start>)
      .zip(query(<empty-page-end>))
      .any(((start, end)) => {
        (
          start.location().page() < page-num
            and page-num < end.location().page()
        )
      })
  }

  // Set the document's basic properties.
  set document(author: name, title: title)
  set page(margin: lay.margin)
  set text(font: typo.font, size: typo.body-text-size, lang: lang)
  set par(leading: typo.line-spacing)
  set math.equation(numbering: "(1)")
  show math.equation: set text(weight: 400)

  // Figure captions and table defaults.
  show figure.caption: set text(size: typo.caption-text-size)
  show table.cell.where(y: 0): set text(weight: "bold")
  show table.cell: set text(size: typo.table-text-size)
  set table.cell(inset: 1.5mm)
  set table(stroke: (_, y) => if y > 0 { (top: 0.2pt) }, align: left)
  set table.vline(stroke: 0.2pt)
  set table.hline(stroke: 0.2pt)

  bht-title-page(
    title: title,
    subtitle: subtitle,
    name: name,
    student-id: student-id,
    department: department,
    study-program: study-program,
    degree: degree,
    date: date,
    committee: committee,
    accent-color: app.accent-color,
    cover-font: typo.cover-font,
    bht-logo: app.bht-logo,
    bht-logo-width: app.bht-logo-width,
    bht-elements: app.bht-elements,
    bht-studiere: app.bht-studiere,
    labels: l,
  )

  // Helper to render a heading with its numbering.
  let styled-heading(
    it,
    size,
    fill,
    spacing-before,
    spacing-after,
    underline: false,
  ) = {
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
      h(7pt, weak: true)
    }

    v(spacing-before)
    text(size: size, fill: fill, weight: "bold", block([#number #it.body]))
    if underline { line(length: 100%, stroke: 2pt + fill) }
    v(spacing-after)
  }

  // Configure chapter headings (level 1).
  show heading.where(level: 1): set heading(supplement: [#l.at("chapter-supplement")])
  show heading.where(level: 1): it => {
    if lay.chapter-pagebreak and it.numbering != none { pagebreak(weak: true) }
    styled-heading(it, typo.heading-sizes.at("h1"), app.accent-color, 5%, 1.5em)
  }

  // Configure section headings (levels 2-4).
  show heading.where(level: 2): it => styled-heading(
    it,
    typo.heading-sizes.at("h2"),
    app.accent-color,
    2%,
    0.75em,
  )
  show heading.where(level: 3): it => styled-heading(
    it,
    typo.heading-sizes.at("h3"),
    app.accent-color,
    2%,
    0pt,
  )
  show heading.where(level: 4): it => styled-heading(
    it,
    typo.heading-sizes.at("h4"),
    app.accent-color,
    2%,
    0pt,
  )

  // Fallback for deeper heading levels.
  show heading: set text(typo.heading-sizes.at("fallback"), weight: 400)

  // Footer for numbered pages (roman and arabic).
  let the-footer = context {
    if is-page-empty() { return }
    let page-align = if lay.for-print and calc.even(here().page()) { start } else { end }
    align(page-align, counter(page).display())
  }

  // Front matter (roman-numbered).
  if lay.for-print { detectable-pagebreak() }
  counter(page).update(1)
  set page(
    numbering: "i",
    footer: the-footer,
  )

  // Helper: render a front matter section heading with its body.
  let front-section(title-text, content) = {
    heading(level: 1, numbering: none, outlined: false, title-text)
    v(0.5cm)
    set par(justify: true)
    content
  }
  let front-pagebreak() = if lay.for-print { detectable-pagebreak() } else { pagebreak() }

  // Front matter sections between the title page and the TOC (confidentiality
  // clause, statement on AI use, abstract, ...). The template owns the heading and
  // pagination. Entries with `own-page: false` continue on the previous page.
  for (i, section) in pre-toc.enumerate() {
    if i > 0 {
      if section.at("own-page", default: true) { front-pagebreak() } else { v(2em) }
    }
    front-section(section.title, section.body)
  }
  if pre-toc.len() > 0 { front-pagebreak() }

  // Table of contents.
  set outline.entry(fill: none)
  show outline.entry.where(level: 1): it => context {
    let entries = query(outline.entry.where(level: 1))
    if entries.first().location() != it.location() {
      v(1.2em, weak: true)
    }
    strong(it)
  }
  outline(
    title: [
      #text(size: typo.heading-sizes.at("h1"), fill: app.accent-color, l.at("contents"))
    ],
    depth: lay.toc-depth,
  )

  // Optional pre-body content (e.g., glossary, table of figures).
  if pre-body != none {
    pagebreak()
    pre-body
    if lay.for-print { detectable-pagebreak(to: "odd") } else { pagebreak() }
  } else if lay.for-print {
    detectable-pagebreak(to: "odd")
  } else {
    pagebreak()
  }

  // Main body.
  set par(justify: typo.justify)

  // Mark the start of the main body for header page number calculation.
  [#metadata(none) <body-start>]

  // Configure page properties.
  set page(
    numbering: "1",
    footer: the-footer,
    header: context {
      if not lay.show-header { return }
      if is-page-empty() {
        return
      }

      // Find all level-1 headings before the current position.
      let before-h1 = query(selector(heading.where(level: 1)).before(here()))

      // Show the chapter title only when no level-1 heading starts on this page.
      let current-page = here().page()
      let h1-on-this-page = query(heading.where(level: 1)).filter(h => h.location().page() == current-page)

      if before-h1 != () and h1-on-this-page == () {
        set text(0.95em)
        align(center, before-h1.last().body)
        align(center, line(length: 100%, stroke: 0.5pt + app.accent-color))
      }
    },
  )
  set heading(numbering: "1.1.1.1")

  counter(page).update(1)
  body

  // Bibliography.
  if bibliography != none {
    pagebreak()
    set std-bibliography(title: l.at("bibliography"))
    bibliography
  }

  // Appendix, numbered "A.1.1.1" and labeled with the appendix supplement.
  if appendix != none {
    counter(heading).update(0)
    set heading(numbering: "A.1.1.1")
    show heading.where(level: 1): set heading(supplement: [#l.at("appendix-supplement")])
    pagebreak(weak: true)
    appendix
  }

  // Optional back matter (e.g. list of figures, list of tables, abbreviations).
  // Back matter headings are not numbered.
  if post-body != none {
    pagebreak(weak: true)
    set heading(numbering: none)
    post-body
  }
}
