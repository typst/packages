#import "hpi-title-page.typ": hpi-title-page

// On-demand document sections. Their content is collected and rendered by
// `project`, so calls can stay next to the source they describe.
#let abstract(body) = [#metadata(body) <abstract-marker>]
#let abstract-de(body) = [#metadata(body) <abstract-de-marker>]
#let acknowledgements(body) = [#metadata(body) <acknowledgements-marker>]
#let acronyms(body) = [#metadata(body) <acronyms-marker>]
#let ai-declaration(body) = [#metadata(body) <ai-declaration-marker>]
#let appendix(body) = [#metadata(body) <appendix-marker>]

// Default label sets for English and German.
// English labels use German strings for the title page because HPI requires
// a German title page regardless of thesis language. Only structural labels
// (abstract, contents, declaration, etc.) are translated to English.
#let default-labels-en = (
  abstract: "Abstract",
  abstract-de: "Zusammenfassung",
  acknowledgements: "Acknowledgements",
  acronyms: "List of Acronyms",
  chapter: "Chapter",
  appendix: "Appendix",
  ai-declaration-title: "Declaration of Authorship and Use of Generative AI",
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
  examiners: "Gutachter",
  advisor: "Betreuer",
  advisors: "Betreuer",
  bachelor-thesis-kind: "Universitätsbachelorarbeit",
  bachelor-degree: "Bachelor of Science",
  bachelor-abbreviation: "B.Sc.",
  master-thesis-kind: "Universitätsmasterarbeit",
  master-degree: "Master of Science",
  master-abbreviation: "M.Sc.",
)

#let default-labels-de = default-labels-en + (
  abstract: "Zusammenfassung (Englisch)",
  abstract-de: "Zusammenfassung",
  acknowledgements: "Danksagung",
  acronyms: "Abkürzungsverzeichnis",
  chapter: "Kapitel",
  appendix: "Anhang",
  ai-declaration-title: [
    Eigenständigkeitserklärung mit Angaben zur Nutzung von KI-Werkzeugen
  ],
  contents: "Inhaltsverzeichnis",
  bibliography: "Literaturverzeichnis",
  declaration-title: "Eigenständigkeitserklärung",
  declaration-text: [
    Ich erkläre hiermit, dass ich die vorliegende Arbeit selbstständig verfasst
    und keine anderen als die angegebenen Quellen und Hilfsmittel verwendet
    habe.
  ],
)

// Default typography settings (font, sizes, spacing).
#let default-typography = (
  font: "Libertinus Serif",
  body-text-size: 11pt,
  line-spacing: 0.65em,
  justify: true,
  table-text-size: 9pt,
  caption-text-size: 9pt,
  heading-sizes: (h1: 20pt, h2: 16pt, h3: 14pt, h4: 12pt, fallback: 11pt),
)

// Default layout settings (margins, print mode, ToC depth).
#let default-layout = (
  margin: (left: 35mm, right: 35mm, top: 30mm, bottom: 30mm),
  for-print: false,
  chapter-pagebreak: true,
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
  // Ordered tuple of examining professors
  professors: (),
  // Ordered tuple of advisors
  advisors: (),
  // Document language (e.g., "en", "de"). Affects label defaults.
  lang: "en",
  // Typography settings (font, sizes, spacing). Merged with defaults.
  typography: (:),
  // Layout settings (margins, print mode, chapter breaks, ToC depth).
  layout: (:),
  // Appearance settings (colors, logos). Merged with defaults.
  appearance: (:),
  // Override any translatable string. Merged on top of the language defaults.
  labels: (:),
  body,
) = {
  // Merge group defaults with user overrides.
  let typo = default-typography + typography
  let typo = (
    typo
      + (
        heading-sizes: default-typography.heading-sizes
          + typography.at("heading-sizes", default: (:)),
      )
  )
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
  set page(margin: lay.margin)
  set text(font: typo.font, size: typo.body-text-size, lang: lang)
  set par(leading: typo.line-spacing, justify: typo.justify)
  show table: set text(size: typo.table-text-size)
  show figure.caption: set text(size: typo.caption-text-size)
  show figure.where(kind: table): set figure.caption(position: top)
  show math.equation: set text(weight: 400)

  // Workaround for https://github.com/typst/typst/issues/2722
  let is-page-empty() = {
    let page-num = here().page()
    query(<empty-page-start>)
      .zip(query(<empty-page-end>))
      .any(((start, end)) => (
        start.location().page() < page-num and page-num < end.location().page()
      ))
  }

  // Mark inserted print pages so their headers and footers can be suppressed.
  let section-pagebreak() = if lay.for-print {
    [#metadata(none) <empty-page-start>]
    pagebreak(to: "odd")
    [#metadata(none) <empty-page-end>]
  } else {
    pagebreak()
  }

  let page-footer = context {
    if not is-page-empty() {
      align(
        if lay.for-print and calc.even(here().page()) { start } else { end },
        counter(page).display(),
      )
    }
  }

  hpi-title-page(
    professors: professors,
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
  let styled-heading(it, size, spacing-before, spacing-after) = {
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
      h(7pt, weak: true)
    }

    v(spacing-before)
    text(
      size: size,
      fill: app.accent-color,
      weight: "bold",
      block([#number #it.body]),
    )
    v(spacing-after)
  }

  // Configure chapter headings (level 1).
  show heading.where(level: 1): set heading(supplement: l.at("chapter"))
  show heading.where(level: 1): it => {
    if lay.chapter-pagebreak { pagebreak(weak: true) }
    styled-heading(it, typo.heading-sizes.at("h1"), 5%, 1.5em)
  }

  // Configure section headings (levels 2-4).
  show heading.where(level: 2): it => styled-heading(
    it,
    typo.heading-sizes.at("h2"),
    2%,
    0.75em,
  )
  show heading.where(level: 3): it => styled-heading(
    it,
    typo.heading-sizes.at("h3"),
    2%,
    0pt,
  )
  show heading.where(level: 4): it => styled-heading(
    it,
    typo.heading-sizes.at("h4"),
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
    section-pagebreak()
  }

  let marker-content(label) = query(label).map(it => it.value)

  // Front matter (unnumbered pages).
  set page(numbering: none)
  section-pagebreak()

  // Roman-numbered front matter.
  counter(page).update(1)
  set page(numbering: "i", footer: page-footer)

  context {
    for (label, title) in (
      (<abstract-marker>, l.at("abstract")),
      (<abstract-de-marker>, l.at("abstract-de")),
      (<acknowledgements-marker>, l.at("acknowledgements")),
      (<acronyms-marker>, l.at("acronyms")),
    ) {
      let content = marker-content(label)
      if content != () { front-section(title, content.join(parbreak())) }
    }

    // Table of contents.
    outline(
      title: [
        #text(
          size: typo.heading-sizes.at("h1"),
          fill: app.accent-color,
          l.at("contents"),
        )
      ],
      depth: lay.toc-depth,
    )
    section-pagebreak()
  }

  // Main body.

  // Configure page properties.
  set page(
    numbering: "1",
    footer: page-footer,
    header: context {
      if is-page-empty() {
        return
      }

      // Skip headers on pages that start a chapter heading.
      if query(heading.where(level: 1)).any(it => (
        it.location().page() == here().page()
      )) {
        return
      }

      // Find the heading of the section we are currently in.
      let before = query(selector(heading).before(here()))
      if before != () {
        set text(0.95em)
        align(
          center,
          if calc.even(here().page()) {
            text(style: "italic", name)
          } else {
            title
          },
        )
      }
      align(center, line(length: 100%, stroke: 0.5pt + app.accent-color))
    },
  )
  set heading(numbering: "1.1.1.1")
  // Native bibliographies keep their source position while sharing the
  // template's localized title and page-break behavior.
  set bibliography(title: l.at("bibliography"))
  show bibliography: it => {
    pagebreak()
    it
  }

  counter(page).update(1)
  body

  context {
    let appendices = marker-content(<appendix-marker>)
    if appendices != () {
      section-pagebreak()
      heading(level: 1, numbering: none, l.at("appendix"))
      counter(heading).update(0)
      set heading(numbering: (..numbers) => numbering(
        "A.1.1",
        ..numbers.pos().slice(1),
      ))
      show heading.where(level: 2): set heading(supplement: l.at("appendix"))
      appendices.join()
    }

    section-pagebreak()
    let disclosures = marker-content(<ai-declaration-marker>)
    heading(
      level: 1,
      numbering: none,
      if disclosures == () {
        l.at("declaration-title")
      } else {
        l.at("ai-declaration-title")
      },
    )

    v(0.5cm)
    block(l.at("declaration-text"))

    for disclosure in disclosures {
      v(1cm)
      block(disclosure)
    }

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
}
