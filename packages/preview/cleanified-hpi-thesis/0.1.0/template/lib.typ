#let std-bibliography = bibliography

#import "hpi-title-page.typ": hpi-title-page

// Default label sets for English and German.
// English labels use German strings for the title page because HPI requires
// a German title page regardless of thesis language. Only structural labels
// (abstract, contents, declaration, etc.) are translated to English.
#let default-labels-en = (
  abstract: "Abstract",
  abstract-de: "Zusammenfassung",
  acknowledgements: "Acknowledgements",
  contents: "Contents",
  bibliography: "Bibliography",
  declaration-title: "Declaration of Authorship",
  declaration-text: [
    I hereby declare that this thesis is my own unaided work. All direct or
    indirect sources used are acknowledged as references.
  ],
  declaration-city: "Potsdam",
  thesis-purpose: "zur Erlangung des akademischen Grades",
  study-program-label: "im Studiengang",
  submitted-on: "eingereicht am",
  submitted-on-suffix: "am",
  chair-label: "Fachgebiet",
  chair-suffix: "der",
  faculty: "Digital-Engineering-Fakultät",
  university: "der Universität Potsdam",
  examiner: "Gutachter",
  advisor: "Betreuer",
  bachelor-thesis-kind: "Universitätsbachelorarbeit",
  bachelor-degree: "Bachelor of Science",
  bachelor-abbreviation: "B.Sc.",
  master-thesis-kind: "Universitätsmasterarbeit",
  master-degree: "Master of Science",
  master-abbreviation: "M.Sc.",
)

#let default-labels-de = (
  abstract: "Zusammenfassung (Englisch)",
  abstract-de: "Zusammenfassung",
  acknowledgements: "Danksagung",
  contents: "Inhaltsverzeichnis",
  bibliography: "Literaturverzeichnis",
  declaration-title: "Eigenständigkeitserklärung",
  declaration-text: [
    Ich erkläre hiermit, dass ich die vorliegende Arbeit selbstständig verfasst
    und keine anderen als die angegebenen Quellen und Hilfsmittel verwendet
    habe.
  ],
  declaration-city: "Potsdam",
  thesis-purpose: "zur Erlangung des akademischen Grades",
  study-program-label: "im Studiengang",
  submitted-on: "eingereicht am",
  submitted-on-suffix: "am",
  chair-label: "Fachgebiet",
  chair-suffix: "der",
  faculty: "Digital-Engineering-Fakultät",
  university: "der Universität Potsdam",
  examiner: "Gutachter",
  advisor: "Betreuer",
  bachelor-thesis-kind: "Universitätsbachelorarbeit",
  bachelor-degree: "Bachelor of Science",
  bachelor-abbreviation: "B.Sc.",
  master-thesis-kind: "Universitätsmasterarbeit",
  master-degree: "Master of Science",
  master-abbreviation: "M.Sc.",
)

// Default typography settings (font, sizes, spacing).
#let default-typography = (
  font: "Libertinus Serif",
  body-text-size: 11pt,
  line-spacing: 0.65em,
  justify: true,
  heading-sizes: (h1: 20pt, h2: 16pt, h3: 14pt, h4: 12pt, fallback: 11pt),
)

// Default layout settings (margins, print mode, ToC depth).
#let default-layout = (
  margin: (left: 35mm, right: 35mm, top: 30mm, bottom: 30mm),
  for-print: false,
  chapter-pagebreak: false,
  toc-depth: 4,
)

// Default appearance settings (colors, logos).
#let default-appearance = (
  accent-color: rgb("#4f5358"),
  university-logo: "up-logo.svg",
  institute-logo: "hpi-logo.svg",
)

// The project function defines how your document looks.
// It takes your content and some metadata and formats it.
// Go ahead and customize it to your liking!
#let project(
  // The title of the thesis
  title: "",
  // The translated title of the thesis
  translation: "",
  // The name of the student writing the thesis
  name: "",
  // Date of handing in the thesis
  date: none,
  // "Bachelor" or "Master"
  type: "",
  // Study Program of the student
  study-program: "",
  // Chair where the thesis is written
  chair: "",
  // First advising professor
  professor: "",
  // List of Advisors (e.g., ("Karla Musterfrau", "Max Mustermann"))
  advisors: (),
  // The abstract of the thesis
  abstract: "",
  // The German translation of the abstract
  // If not given, the page for German translation of abstract will not appear
  abstract-de: "",
  // The student may want to add acknowledgements
  // If not given, the page for acknowledgements will not appear
  acknowledgements: "",
  // Optional bibliography content (e.g., bibliography("references.bib")).
  // If provided, a bibliography section will be added at the end.
  bibliography: none,
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

  // Set the document's basic properties.
  set document(author: name, title: title)
  set page(
    margin: lay.margin,
    numbering: "1",
    number-align: end,
  )
  set text(font: typo.font, size: typo.body-text-size, lang: lang)
  set par(leading: typo.line-spacing)
  show math.equation: set text(weight: 400)

  hpi-title-page(
    professor: professor,
    name: name,
    advisors: advisors,
    title: title,
    translation: translation,
    study-program: study-program,
    chair: chair,
    type: type,
    date: date,
    accent-color: app.accent-color,
    university-logo: app.university-logo,
    institute-logo: app.institute-logo,
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
  show heading.where(level: 1): it => {
    if lay.chapter-pagebreak { pagebreak(weak: true) }
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

  // Helper: insert a front matter section followed by a page break.
  let front-section(title-text, content) = {
    heading(level: 1, numbering: none, title-text)
    v(0.5cm)
    content
    pagebreak()
    if lay.for-print { pagebreak() }
  }

  // Front matter (unnumbered pages).
  set page(numbering: none)
  pagebreak()
  if lay.for-print { pagebreak() }

  // Roman-numbered front matter.
  counter(page).update(1)
  set page(numbering: "i")

  front-section(l.at("abstract"), abstract)

  if abstract-de != "" {
    front-section(l.at("abstract-de"), abstract-de)
  }

  if acknowledgements != "" {
    front-section(l.at("acknowledgements"), acknowledgements)
  }

  // Table of contents.
  outline(
    title: [
      #text(size: typo.heading-sizes.at("h1"), fill: app.accent-color, l.at("contents"))
    ],
    depth: lay.toc-depth,
  )
  pagebreak()
  if lay.for-print { pagebreak() }

  // Main body.
  set par(justify: typo.justify)

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

  // Mark the start of the main body for header page number calculation.
  [#metadata(none) <body-start>]

  // Configure page properties.
  set page(
    numbering: "1",
    header: context {
      if is-page-empty() {
        return
      }

      // Calculate the body page number relative to the start of the main body.
      let body-start-page = query(<body-start>).first().location().page()
      let i = here().page() - body-start-page + 1

      // Skip headers on pages that start a chapter heading (level 1 only).
      if query(heading.where(level: 1)).any(it => (
        it.location().page() == here().page()
      )) {
        return
      }

      // Find the heading of the section we are currently in.
      let before = query(selector(heading).before(here()))
      if before != () {
        set text(0.95em)
        let author = text(style: "italic", name)
        grid(
          columns: (1fr, 10fr, 1fr),
          align: (left, center, right),
          if calc.even(i) [#i],
          if calc.even(i) { author } else { title },
          if calc.odd(i) [#i],
        )
      }
      align(center, line(length: 100%, stroke: 0.5pt + app.accent-color))
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

  pagebreak()
  if lay.for-print { pagebreak() }
  heading(level: 1, numbering: none, l.at("declaration-title"))

  v(0.5cm)
  block(l.at("declaration-text"))

  v(1.5cm)
  [#l.at("declaration-city"), #date]
  v(1cm)
  grid(
    columns: (1fr, 1fr),
    [],
    [
      #line(length: 100%, stroke: 0.5pt)
      #align(center, name)
    ],
  )
}
