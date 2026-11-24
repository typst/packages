///////////////////////////////
// This Typst template is for working paper draft.
// It is based on the general SSRN paper.
// Copyright (c) 2026
// Author:  Academic Template Collective
// License: MIT
// Version: 0.10.0
// Date:    2026-07-30
// Email:   maintainers@example.invalid
///////////////////////////////

#let default-paper-font = ("Times New Roman", "Libertinus Serif")

#let default-paper-style = (
  text: rgb("#111111"),
  heading: rgb("#111111"),
  muted: rgb("#444444"),
  accent: rgb("#111111"),
  rule: rgb("#8a8a8a"),
  heading-font: default-paper-font,
)

// Rhythm presets provide a coherent title-page and manuscript rhythm. A
// document can select one preset, then override only the exceptional token.
// Names match modernpro-cv and modernpro-coverletter so the whole suite takes
// the same `preset:` vocabulary; the older density names still resolve.
#let paper-rhythm(preset) = if preset == "compact" {
  (
    cover-spacing: 12pt,
    cover-author-row-gap: 12pt,
    cover-line-leading: 0.5em,
    cover-paragraph-spacing: 0.44em,
    frontmatter-gap: 6pt,
    frontmatter-heading-gap: 0.5em,
    inline-author-row-gap: 8pt,
    body-line-leading: 0.52em,
    body-paragraph-spacing: 0.44em,
    body-start-gap: 4pt,
    heading-1-before: 0.8em,
    heading-1-after: 0.3em,
    heading-2-before: 0.68em,
    heading-2-after: 0.28em,
    heading-3-before: 0.56em,
    heading-3-after: 0.24em,
    cover-meta-gap: 10pt,
  )
} else if preset == "relaxed" or preset == "spacious" {
  (
    cover-spacing: 24pt,
    cover-author-row-gap: 18pt,
    cover-line-leading: 0.72em,
    cover-paragraph-spacing: 0.68em,
    frontmatter-gap: 12pt,
    frontmatter-heading-gap: 0.7em,
    inline-author-row-gap: 14pt,
    body-line-leading: 0.72em,
    body-paragraph-spacing: 0.72em,
    body-start-gap: 8pt,
    heading-1-before: 1.3em,
    heading-1-after: 0.56em,
    heading-2-before: 1.04em,
    heading-2-after: 0.46em,
    heading-3-before: 0.86em,
    heading-3-after: 0.38em,
    cover-meta-gap: 16pt,
  )
} else {
  (
    cover-spacing: 18pt,
    cover-author-row-gap: 14pt,
    cover-line-leading: 0.6em,
    cover-paragraph-spacing: 0.54em,
    frontmatter-gap: 8pt,
    frontmatter-heading-gap: 0.55em,
    inline-author-row-gap: 10pt,
    body-line-leading: 0.62em,
    body-paragraph-spacing: 0.55em,
    body-start-gap: 6pt,
    heading-1-before: 1.08em,
    heading-1-after: 0.42em,
    heading-2-before: 0.8em,
    heading-2-after: 0.32em,
    heading-3-before: 0.66em,
    heading-3-after: 0.28em,
    cover-meta-gap: 12pt,
  )
}

#let author-column-count(count, override) = if override != none {
  calc.max(1, override)
} else if count <= 1 {
  1
} else if count == 2 {
  2
} else if count == 4 {
  2
} else {
  calc.min(count, 3)
}

#let author-block(
  author,
  name-size: 14pt,
  heading-font: default-paper-font,
  heading-colour: rgb("#111111"),
  text-colour: rgb("#111111"),
  muted-colour: rgb("#444444"),
) = box(width: auto)[
  #text(name-size, font: heading-font, fill: heading-colour, [
    #strong(author.name)
    #if "note" in author { footnote(author.note) }
  ])
  #if "department" in author [
    \ #text(fill: text-colour, style: "italic")[#author.department]
  ]
  #if "affiliation" in author [
    \ #text(fill: text-colour, style: "italic")[#author.affiliation]
  ]
  #if "email" in author [
    \ #text(fill: muted-colour)[#link("mailto:" + author.email)]
  ]
]

#let render-author-grid(
  authors,
  columns: none,
  alignment: center,
  name-size: 14pt,
  heading-font: default-paper-font,
  heading-colour: rgb("#111111"),
  text-colour: rgb("#111111"),
  muted-colour: rgb("#444444"),
  gutter: 24pt,
  row-gap: 16pt,
) = {
  if authors.len() == 0 {
    none
  } else {
    let total = authors.len()
    let column-count = author-column-count(total, columns)
    let rows = calc.ceil(total / column-count)
    {
      for row in range(rows) {
        let start = row * column-count
        let end = calc.min((row + 1) * column-count, total)
        let slice = authors.slice(start, end)
        grid(
          columns: slice.len() * (1fr,),
          gutter: gutter,
          ..slice.map(author => align(alignment, author-block(
            author,
            name-size: name-size,
            heading-font: heading-font,
            heading-colour: heading-colour,
            text-colour: text-colour,
            muted-colour: muted-colour,
          )))
        )
        if row < rows - 1 {
          v(row-gap, weak: true)
        }
      }
    }
  }
}

#let render-frontmatter(
  abstract,
  keywords,
  JEL,
  text-width: 80%,
  section-gap: 10pt,
  leading: 0.62em,
  paragraph-spacing: 0.55em,
  heading-gap: 0.62em,
  heading-font: default-paper-font,
  text-colour: rgb("#111111"),
) = {
  if abstract == none and keywords == none and JEL == none {
    none
  } else {
    box(width: text-width)[
      #set par(
        leading: leading,
        spacing: paragraph-spacing,
        first-line-indent: 0em,
        justify: true,
      )
      #set text(fill: text-colour)
      #set align(left)
      #if abstract != none {
        block(width: 100%, sticky: true)[
          #align(center, text(
            11pt,
            font: heading-font,
            fill: text-colour,
            weight: "bold",
          )[Abstract])
          #v(heading-gap)
        ]
        par(justify: true)[#abstract]
      }
      #if abstract != none and (keywords != none or JEL != none) {
        v(section-gap, weak: true)
      }
      #if keywords != none {
        par(justify: true)[
          #text(font: heading-font, fill: text-colour, style: "italic", weight: "bold")[Keywords:] #keywords
        ]
      }
      #if keywords != none and JEL != none {
        v(section-gap, weak: true)
      }
      #if JEL != none {
        par(justify: true)[
          #text(font: heading-font, fill: text-colour, style: "italic", weight: "bold")[JEL Classification:] #JEL
        ]
      }
    ]
  }
}

#let _option(source, key, default) = if source == none {
  default
} else {
  source.at(key, default: default)
}

#let _option-any(source, keys, default) = {
  let value = default
  if source != none {
    for key in keys {
      value = source.at(key, default: value)
    }
  }
  value
}

#let resolve-paper-config(
  font,
  fontsize,
  title,
  subtitle,
  maketitle,
  authors,
  date,
  abstract,
  keywords,
  JEL,
  acknowledgments,
  bibliography,
  author-columns,
  author-alignment,
  cover-title-size,
  cover-subtitle-size,
  cover-author-name-size,
  cover-spacing,
  cover-author-gutter,
  cover-author-row-gap,
  cover-text-width,
  cover-line-leading,
  cover-paragraph-spacing,
  frontmatter-gap,
  inline-title-size,
  inline-subtitle-size,
  inline-author-name-size,
  inline-author-gutter,
  inline-author-row-gap,
  body-line-leading,
  body-paragraph-spacing,
  body-text-spacing,
  meta: none,
  theme: none,
  layout: none,
) = {
  let preset = _option-any(layout, ("density", "preset"), "default")
  let rhythm = paper-rhythm(preset)
  let resolved-cover-spacing = if cover-spacing != none { cover-spacing } else { rhythm.cover-spacing }
  let resolved-cover-author-row-gap = if cover-author-row-gap != none { cover-author-row-gap } else { rhythm.cover-author-row-gap }
  let resolved-cover-line-leading = if cover-line-leading != none { cover-line-leading } else { rhythm.cover-line-leading }
  let resolved-cover-paragraph-spacing = if cover-paragraph-spacing != none { cover-paragraph-spacing } else { rhythm.cover-paragraph-spacing }
  let resolved-frontmatter-gap = if frontmatter-gap != none { frontmatter-gap } else { rhythm.frontmatter-gap }
  let resolved-inline-author-row-gap = if inline-author-row-gap != none { inline-author-row-gap } else { rhythm.inline-author-row-gap }
  let resolved-body-line-leading = if body-line-leading != none { body-line-leading } else { rhythm.body-line-leading }
  let resolved-body-paragraph-spacing = if body-paragraph-spacing != none { body-paragraph-spacing } else { rhythm.body-paragraph-spacing }

  (
    font: _option-any(theme, ("font", "body-font"), font),
    heading-font: _option-any(theme, ("display-font", "heading-font"), default-paper-style.heading-font),
    text: _option(theme, "text", default-paper-style.text),
    heading: _option(theme, "heading", default-paper-style.heading),
    muted: _option(theme, "muted", default-paper-style.muted),
    accent: _option(theme, "accent", default-paper-style.accent),
    rule: _option(theme, "rule", default-paper-style.rule),
    fontsize: _option-any(theme, ("fontsize", "font-size", "body-size"), fontsize),
    margin: _option(layout, "margin", (left: 2.54cm, right: 2.54cm, top: 2.54cm, bottom: 2.54cm)),
    title: _option(meta, "title", title),
    subtitle: _option(meta, "subtitle", subtitle),
    maketitle: _option(layout, "maketitle", maketitle),
    authors: _option(meta, "authors", authors),
    date: _option(meta, "date", date),
    abstract: _option(meta, "abstract", abstract),
    keywords: _option(meta, "keywords", keywords),
    JEL: _option-any(meta, ("JEL", "jel"), JEL),
    acknowledgments: _option-any(meta, ("acknowledgments", "acknowledgements"), acknowledgments),
    bibliography: _option(meta, "bibliography", bibliography),
    author-columns: _option(layout, "author-columns", author-columns),
    author-alignment: _option(layout, "author-alignment", author-alignment),
    cover-title-size: _option(theme, "title-size", _option(layout, "cover-title-size", cover-title-size)),
    cover-subtitle-size: _option(theme, "subtitle-size", _option(layout, "cover-subtitle-size", cover-subtitle-size)),
    cover-author-name-size: _option(theme, "author-size", _option(layout, "cover-author-name-size", cover-author-name-size)),
    cover-spacing: _option(layout, "cover-spacing", resolved-cover-spacing),
    cover-author-gutter: _option(layout, "cover-author-gutter", cover-author-gutter),
    cover-author-row-gap: _option(layout, "cover-author-row-gap", resolved-cover-author-row-gap),
    cover-text-width: _option(layout, "cover-text-width", cover-text-width),
    cover-line-leading: _option(layout, "cover-line-leading", resolved-cover-line-leading),
    cover-paragraph-spacing: _option(layout, "cover-paragraph-spacing", resolved-cover-paragraph-spacing),
    frontmatter-gap: _option(layout, "frontmatter-gap", resolved-frontmatter-gap),
    frontmatter-heading-gap: _option(layout, "frontmatter-heading-gap", rhythm.frontmatter-heading-gap),
    inline-title-size: _option(layout, "inline-title-size", inline-title-size),
    inline-subtitle-size: _option(layout, "inline-subtitle-size", inline-subtitle-size),
    inline-author-name-size: _option(layout, "inline-author-name-size", inline-author-name-size),
    inline-author-gutter: _option(layout, "inline-author-gutter", inline-author-gutter),
    inline-author-row-gap: _option(layout, "inline-author-row-gap", resolved-inline-author-row-gap),
    body-line-leading: _option(layout, "body-line-leading", resolved-body-line-leading),
    body-paragraph-spacing: _option(layout, "body-paragraph-spacing", resolved-body-paragraph-spacing),
    body-text-spacing: _option(layout, "body-text-spacing", body-text-spacing),
    body-first-line-indent: _option(layout, "body-first-line-indent", 0em),
    body-start-gap: _option(layout, "body-start-gap", rhythm.body-start-gap),
    heading-1-before: _option(layout, "heading-1-before", rhythm.heading-1-before),
    heading-1-after: _option(layout, "heading-1-after", rhythm.heading-1-after),
    heading-2-before: _option(layout, "heading-2-before", rhythm.heading-2-before),
    heading-2-after: _option(layout, "heading-2-after", rhythm.heading-2-after),
    heading-3-before: _option(layout, "heading-3-before", rhythm.heading-3-before),
    heading-3-after: _option(layout, "heading-3-after", rhythm.heading-3-after),
    cover-meta-gap: _option(layout, "cover-meta-gap", rhythm.cover-meta-gap),
    preset: preset,
  )
}

#let render-title-block(cfg, mode: "cover") = {
  let title-size = if mode == "cover" { cfg.cover-title-size } else { cfg.inline-title-size }
  let subtitle-size = if mode == "cover" { cfg.cover-subtitle-size } else { cfg.inline-subtitle-size }
  let author-name-size = if mode == "cover" { cfg.cover-author-name-size } else { cfg.inline-author-name-size }
  let author-gutter = if mode == "cover" { cfg.cover-author-gutter } else { cfg.inline-author-gutter }
  let author-row-gap = if mode == "cover" { cfg.cover-author-row-gap } else { cfg.inline-author-row-gap }
  let subtitle-gap = if mode == "cover" { cfg.cover-spacing } else { 6pt }
  let title-align = center

  set footnote(numbering: "*")
  set par(
    leading: cfg.cover-line-leading,
    spacing: cfg.cover-paragraph-spacing,
    first-line-indent: 0em,
    justify: false,
  )

  if mode == "cover" {
    set align(center)
  } else {
    set align(left)
  }

  if cfg.title != none {
    text(
      title-size,
      font: cfg.heading-font,
      fill: cfg.heading,
      weight: "bold",
      align(title-align, [
      #cfg.title
      #if cfg.acknowledgments != none { footnote(cfg.acknowledgments) }
    ]))
  }

  if cfg.subtitle != none {
    v(subtitle-gap, weak: true)
    text(
      subtitle-size,
      font: cfg.heading-font,
      fill: cfg.text,
      weight: "regular",
      align(title-align, cfg.subtitle),
    )
  }

  if cfg.authors.len() > 0 {
    v(cfg.cover-spacing, weak: true)
    set align(center)
    render-author-grid(
      cfg.authors,
      columns: cfg.author-columns,
      alignment: cfg.author-alignment,
      name-size: author-name-size,
      heading-font: cfg.heading-font,
      heading-colour: cfg.heading,
      text-colour: cfg.text,
      muted-colour: cfg.muted,
      gutter: author-gutter,
      row-gap: author-row-gap,
    )
    if mode != "cover" {
      set align(left)
    }
  }

  if cfg.date != none {
    v(cfg.cover-meta-gap, weak: true)
    align(center, text(
      11pt,
      font: cfg.heading-font,
      fill: cfg.muted,
      weight: "regular",
    )[This Version: #cfg.date])
  }

  let frontmatter = render-frontmatter(
    cfg.abstract,
    cfg.keywords,
    cfg.JEL,
    text-width: cfg.cover-text-width,
    section-gap: cfg.frontmatter-gap,
    leading: cfg.cover-line-leading,
    paragraph-spacing: cfg.cover-paragraph-spacing,
    heading-gap: cfg.frontmatter-heading-gap,
    heading-font: cfg.heading-font,
    text-colour: cfg.text,
  )
  if frontmatter != none {
    v(cfg.cover-spacing, weak: true)
    frontmatter
  }

  set align(left)
}

#let paper(
  font: default-paper-font,
  fontsize: 11pt,
  title: none,
  subtitle: none,
  maketitle: true,
  authors: (),
  date: none,
  abstract: none,
  keywords: none,
  JEL: none,
  acknowledgments: none,
  bibliography: none,
  author-columns: none,
  author-alignment: center,
  cover-title-size: 20pt,
  cover-subtitle-size: 13pt,
  cover-author-name-size: 14pt,
  cover-spacing: none,
  cover-author-gutter: 24pt,
  cover-author-row-gap: none,
  cover-text-width: 86%,
  cover-line-leading: none,
  cover-paragraph-spacing: none,
  frontmatter-gap: none,
  inline-title-size: 18pt,
  inline-subtitle-size: 12pt,
  inline-author-name-size: 12pt,
  inline-author-gutter: 18pt,
  inline-author-row-gap: none,
  body-line-leading: none,
  body-paragraph-spacing: none,
  body-text-spacing: 100%,
  preset: none,
  meta: none,
  theme: none,
  layout: none,
  doc,
) = {
  if preset != none {
    layout = if layout == none { (preset: preset) } else { layout + (preset: preset) }
  }
  let cfg = resolve-paper-config(
    font,
    fontsize,
    title,
    subtitle,
    maketitle,
    authors,
    date,
    abstract,
    keywords,
    JEL,
    acknowledgments,
    bibliography,
    author-columns,
    author-alignment,
    cover-title-size,
    cover-subtitle-size,
    cover-author-name-size,
    cover-spacing,
    cover-author-gutter,
    cover-author-row-gap,
    cover-text-width,
    cover-line-leading,
    cover-paragraph-spacing,
    frontmatter-gap,
    inline-title-size,
    inline-subtitle-size,
    inline-author-name-size,
    inline-author-gutter,
    inline-author-row-gap,
    body-line-leading,
    body-paragraph-spacing,
    body-text-spacing,
    meta: meta,
    theme: theme,
    layout: layout,
  )

  set math.equation(numbering: "(1)", supplement: auto)

  set text(
    font: cfg.font,
    size: cfg.fontsize,
    fill: cfg.text,
    spacing: cfg.body-text-spacing,
  )
  show link: set text(fill: cfg.accent)

  set page(margin: cfg.margin, numbering: "1")

  set document(
    title: cfg.title,
    author: cfg.authors.map(author => author.name),
  )

  set footnote.entry(separator: line(length: 100%, stroke: 0.4pt + cfg.rule))
  set footnote.entry(indent: 0em, gap: 0.6em)
  show footnote.entry: set align(left)

  if cfg.maketitle == true {
    render-title-block(cfg, mode: "cover")
    pagebreak()
  } else {
    render-title-block(cfg, mode: "inline")
  }

  set footnote(numbering: "1")
  set footnote.entry(separator: line(length: 100%, stroke: 0.4pt + cfg.rule))
  set footnote.entry(indent: 0em, gap: 0.6em)

  set align(left)

  v(cfg.body-start-gap)

  set heading(numbering: "1.")
  set math.equation(numbering: "(1)", supplement: auto)
  show heading.where(level: 1): set text(
    font: cfg.heading-font,
    size: 14pt,
    fill: cfg.heading,
    weight: "bold",
  )
  show heading.where(level: 2): set text(
    font: cfg.heading-font,
    size: 12pt,
    fill: cfg.heading,
    weight: "bold",
  )
  show heading.where(level: 3): set text(
    font: cfg.heading-font,
    size: 11pt,
    fill: cfg.heading,
    weight: "bold",
  )
  show heading.where(level: 1): it => block(
    above: cfg.heading-1-before,
    below: cfg.heading-1-after,
    sticky: true,
  )[#it]
  show heading.where(level: 2): it => block(
    above: cfg.heading-2-before,
    below: cfg.heading-2-after,
    sticky: true,
  )[#it]
  show heading.where(level: 3): it => block(
    above: cfg.heading-3-before,
    below: cfg.heading-3-after,
    sticky: true,
  )[#it]
  set text(spacing: cfg.body-text-spacing)
  set par(
    leading: cfg.body-line-leading,
    spacing: cfg.body-paragraph-spacing,
    first-line-indent: cfg.body-first-line-indent,
    justify: true,
  )

  columns(1, doc)

  set par(
    leading: cfg.body-line-leading,
    spacing: cfg.body-paragraph-spacing,
    first-line-indent: cfg.body-first-line-indent,
    justify: true,
  )

  if cfg.bibliography != none {
    colbreak()
    show heading: set text(
      font: cfg.heading-font,
      size: 14pt,
      fill: cfg.heading,
      weight: "bold",
    )
    cfg.bibliography
  }
}
