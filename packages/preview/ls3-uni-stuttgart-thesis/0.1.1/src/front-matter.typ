// front-matter.typ
//
// Optional front-matter sections (abbreviations, notation) plus the standard
// table of contents and list-of-X helpers.

// Localized strings.
#let _labels(language) = {
  if language == "german" {
    (
      contents: "Inhaltsverzeichnis",
      figures: "Abbildungsverzeichnis",
      tables: "Tabellenverzeichnis",
      listings: "Programmauflistung",
      abbreviations: "Abkürzungsverzeichnis",
      notation: "Symbolverzeichnis",
    )
  } else {
    (
      contents: "Contents",
      figures: "List of Figures",
      tables: "List of Tables",
      listings: "List of Listings",
      abbreviations: "Abbreviations",
      notation: "Notation",
    )
  }
}

// Abbreviations chapter. Pass content as the `body` argument.
#let abbreviations-section(body, language: "english") = {
  let labels = _labels(language)
  heading(level: 1, numbering: none, outlined: true)[#labels.abbreviations]
  body
}

// Notation chapter. Pass content as the `body` argument.
#let notation-section(body, language: "english") = {
  let labels = _labels(language)
  heading(level: 1, numbering: none, outlined: true)[#labels.notation]
  body
}

// Table of contents.
// Chapter-level entries (heading level 1, both numbered chapters and
// unnumbered front-matter chapters) render in bold with no dotted leader and
// extra vertical space above. Subsection entries (level 2 and deeper) keep
// the default dotted leader and render in regular weight, matching how
// KOMA-script's `\tableofcontents` lays out a thesis TOC.
#let toc(language: "english") = {
  let labels = _labels(language)
  heading(level: 1, numbering: none, outlined: false)[#labels.contents]

  // TOC entries are internal links. The global mittelblau link color from
  // apply-style would tint every entry blue. Override to keep the TOC
  // entirely black while still hyperlinked.
  show link: set text(fill: black)

  // Level 1: bold, no leader, ~1.5em above each entry.
  show outline.entry.where(level: 1): it => {
    v(1.5em, weak: true)
    link(
      it.element.location(),
      strong[
        #it.prefix() #it.element.body
        #h(1fr)
        #it.page()
      ],
    )
  }

  // Level 2: regular weight, dotted leader (default `it`), modest space.
  show outline.entry.where(level: 2): it => {
    v(0.55em, weak: true)
    it
  }

  // Level 3: regular weight, dotted leader, tighter spacing.
  show outline.entry.where(level: 3): it => {
    v(0.35em, weak: true)
    it
  }

  outline(title: none)
}

// List of figures.
#let lof(language: "english") = {
  let labels = _labels(language)
  heading(level: 1, numbering: none, outlined: true)[#labels.figures]
  outline(title: none, target: figure.where(kind: image))
}

// List of tables.
#let lot(language: "english") = {
  let labels = _labels(language)
  heading(level: 1, numbering: none, outlined: true)[#labels.tables]
  outline(title: none, target: figure.where(kind: table))
}

// List of listings.
#let lol(language: "english") = {
  let labels = _labels(language)
  heading(level: 1, numbering: none, outlined: true)[#labels.listings]
  outline(title: none, target: figure.where(kind: raw))
}
