// ╔══════════════════════════════════════════════════════════════════════╗
// ║           UGR Notes - Professional Template for Academic Writing     ║
// ║       Designed for University of Granada Students & Researchers      ║
// ║                                                                      ║
// ║   Repository: https://github.com/Miguevrgo/Typst-ugr-notes           ║
// ║   License: MIT                                                       ║
// ╚══════════════════════════════════════════════════════════════════════╝

#import "@preview/fontawesome:0.5.0": *

/// Default color scheme - customize by modifying the `colors` variable
/// - primary: Used for definitions and main titles (Orange)
/// - secondary: Used for theorems and mathematical statements (Blue)
/// - accent: Used for examples and highlights (Green)
/// - text: Main text color (Dark gray)
/// - code-bg: Code block background (Light gray)
/// - proof-bg: Proof environment background (Light blue)
#let colors = (
  primary: rgb("#E67E22"), // Orange
  secondary: rgb("#3498DB"), // Blue
  accent: rgb("#2ECC71"), // Green
  text: rgb("#2C3E50"), // Dark gray
  code-bg: rgb("#F4F6F6"), // Light gray
  proof-bg: rgb("#EBF5FB"), // Light blue
)

// Language support for common terms
#let language-translations = (
  es: (
    "definition": "Definición",
    "theorem": "Teorema",
    "proposition": "Proposición",
    "corollary": "Corolario",
    "lemma": "Lema",
    "remark": "Observación",
    "example": "Ejemplo",
    "proof": "Demostración",
    "table-of-contents": "Índice",
  ),
  en: (
    "definition": "Definition",
    "theorem": "Theorem",
    "proposition": "Proposition",
    "corollary": "Corollary",
    "lemma": "Lemma",
    "remark": "Remark",
    "example": "Example",
    "proof": "Proof",
    "table-of-contents": "Table of Contents",
  ),
)

// Translation map available for consumers; internal helpers must use it directly.
// Generic color-box for mathematical environments
#let color-box(title: "", color: black, body) = {
  block(
    width: 100%,
    stroke: 0.5pt + color,
    radius: 3pt,
    clip: true,
    below: 1.5em,
  )[
    #block(
      fill: color.lighten(10%),
      width: 100%,
      inset: 8pt,
      below: 0pt,
    )[#text(fill: white, weight: "bold")[#title]]
    #block(
      fill: color.lighten(90%),
      width: 100%,
      inset: 12pt,
    )[#body]
  ]
}

// Mathematical environments
#let definicion(title, body) = color-box(
  title: "Definición: " + title,
  color: colors.primary,
  body,
)

#let definition(title, body) = color-box(
  title: "Definition: " + title,
  color: colors.primary,
  body,
)

#let teorema(title, body) = color-box(
  title: "Teorema: " + title,
  color: colors.secondary,
  body,
)

#let theorem(title, body) = color-box(
  title: "Theorem: " + title,
  color: colors.secondary,
  body,
)

#let proposicion(title, body) = color-box(
  title: "Proposición: " + title,
  color: colors.secondary,
  body,
)

#let proposition(title, body) = color-box(
  title: "Proposition: " + title,
  color: colors.secondary,
  body,
)

#let corolario(title, body) = color-box(
  title: "Corolario: " + title,
  color: colors.secondary,
  body,
)

#let corollary(title, body) = color-box(
  title: "Corollary: " + title,
  color: colors.secondary,
  body,
)

#let lema(title, body) = color-box(
  title: "Lema: " + title,
  color: colors.secondary,
  body,
)

#let lemma(title, body) = color-box(
  title: "Lemma: " + title,
  color: colors.secondary,
  body,
)

#let ejemplo(title, body) = color-box(
  title: "Ejemplo: " + title,
  color: colors.accent,
  body,
)

#let example(title, body) = color-box(
  title: "Example: " + title,
  color: colors.accent,
  body,
)

// Proof environment with QED symbol
#let demostracion(body) = block(
  fill: colors.proof-bg,
  stroke: (left: 4pt + colors.secondary.lighten(30%)),
  inset: (x: 12pt, y: 12pt),
  radius: 4pt,
  width: 100%,
  below: 1em,
)[
  #text(fill: colors.secondary.darken(10%), weight: "bold", style: "italic")[Demostración.]\
  #body
  #h(1fr) $square$ // QED symbol
]

#let proof(body) = block(
  fill: colors.proof-bg,
  stroke: (left: 4pt + colors.secondary.lighten(30%)),
  inset: (x: 12pt, y: 12pt),
  radius: 4pt,
  width: 100%,
  below: 1em,
)[
  #text(fill: colors.secondary.darken(10%), weight: "bold", style: "italic")[Proof.]\
  #body
  #h(1fr) $square$ // QED symbol
]

// Main template function
#let project(
  title: "",
  author: "",
  academic-year: "Curso 2025-2026",
  orcid: none,
  github: none,
  logo: "UGR-Logo.png",
  lang: "es",
  heading-color: colors.primary,
  body,
) = {
  set document(author: author, title: title)

  // Page setup
  set page(
    paper: "a4",
    margin: 2cm,
    header: context {
      if counter(page).get().first() > 1 {
        grid(
          columns: (1fr, 1fr),
          align(left)[#smallcaps(title)], align(right)[#counter(page).display()],
        )
        line(length: 100%, stroke: 0.5pt + gray)
      }
    },
  )

  // Text setup
  set par(justify: true, leading: 1.2em)

  // Code block styling - with inline and block support
  show raw.where(block: true): block.with(
    fill: colors.code-bg,
    inset: 10pt,
    radius: 4pt,
    width: 100%,
    stroke: 0.5pt + gray,
  )

  show raw.where(block: false): box.with(
    fill: colors.code-bg,
    inset: (x: 4pt, y: 2pt),
    radius: 2pt,
  )

  // Heading numbering
  set heading(numbering: "1.1.")

  // Level 1 headings - Chapter style
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(2em)
    text(size: 20pt, weight: "bold", fill: heading-color)[#it]
    v(1em)
    line(length: 100%, stroke: 1pt + heading-color)
    v(1em)
  }

  // Level 2 headings - Section style
  show heading.where(level: 2): it => {
    v(1.5em)
    text(size: 14pt, weight: "bold", fill: heading-color)[#it]
    v(0.75em)
  }

  // Level 3 headings - Subsection style
  show heading.where(level: 3): it => {
    v(1em)
    text(size: 12pt, weight: "bold", fill: heading-color.lighten(20%))[#it]
    v(0.5em)
  }

  // --- TITLE PAGE ---
  align(center + horizon)[
    #block(stroke: (bottom: 2pt + heading-color), width: 100%, inset: 1em)[
      #text(size: 30pt, weight: "bold", fill: heading-color)[#title]
    ]

    #v(3em)

    // Logo
    #if logo != "" {
      image(logo, width: 40%)
    }

    #v(3em)

    // Author
    #text(size: 16pt)[#author]
    #v(0.5em)

    // Author links
    #grid(
      columns: (auto, auto),
      gutter: 1em,
      if orcid != none {
        link(orcid)[#text(fill: rgb("#A6CE39"), size: 1.2em)[#image("orcid.svg", width: 2.5em)]]
      },
      if github != none {
        link(github)[#text(fill: black, size: 3.2em)[#fa-github()]]
      },
    )

    #v(2em)

    // Academic year
    #text(size: 14pt, weight: "bold", fill: colors.text.lighten(30%))[#academic-year]
  ]

  // Table of Contents
  heading(level: 1, numbering: none)[#get-translation("table-of-contents", lang: lang)]
  outline(title: none, indent: auto)

  // Document body
  body
}
