// University of Melbourne Thesis Template - Utilities

#import "../assets/colors/unimelb-colors.typ": *

// Package imports
#import "@preview/cetz:0.3.1"
#import "@preview/cetz:0.3.1": plot
#import "@preview/codly:1.1.0": *
#import "@preview/i-figured:0.2.4"
#import "@preview/tablex:0.0.8": tablex, gridx, hlinex, vlinex
#import "@preview/unify:0.7.0": unit
#import "@preview/theorion:0.4.0": *
#import "@preview/fletcher:0.5.1" as fletcher: diagram, node, edge
#import "@preview/lovelace:0.3.0": *
#import "@preview/numbly:0.1.0": numbly
#import "@preview/zebraw:0.4.0": zebraw
#import "@preview/equate:0.2.1": *
#import "@preview/showybox:2.0.1": showybox
#import "@preview/codetastic:0.2.2": qrcode
#import "@preview/glossarium:0.5.1": make-glossary, print-glossary, gls, glspl

// Font configuration
#let font-covers = (
  latin: (
    "Fraunces",
    "Source Sans Pro",
    "Times New Roman",
    "Liberation Serif",
    "DejaVu Serif",
    "Latin Modern Roman",
    "STIX Two Text",
  ),
  cjk: (
    "SimSun",
    "MS Mincho",
    "Hiragino Mincho Pro",
    "Source Han Serif",
    "Noto Serif CJK SC",
  ),
  mono: (
    "JetBrains Mono",
    "Fira Code",
    "Cascadia Code",
    "Source Code Pro",
    "Consolas",
  ),
)

// Font coverage control function
#let font-with-coverage(base-font, covers) = {
  if type(covers) == str {
    covers = (covers,)
  }
  (base-font,) + covers.map(c => font-covers.at(c, default: ())).flatten()
}

// =================================
// Global Style Configuration
// =================================

#let thesis-style = (
  fonts: (
    serif: font-with-coverage("Fraunces", ("latin", "cjk")),  // Official UoM primary font
    sans: font-with-coverage("Source Sans Pro", ("latin", "cjk")),  // Official UoM secondary font
    mono: font-with-coverage("JetBrains Mono", ("latin", "cjk")),
  ),
  colors: (
    primary: rgb(traditional-heritage-100),      // Official UoM blue #000F46
    secondary: rgb(magpie-dark-100),             // Official dark grey #2D2D2D
    accent: rgb(sheoak-light-100),               // Official red #FF2D3C
    success: rgb(red-gum-light-100),             // Official green #9FB825
    warning: rgb(yam-daisy-100),                 // Official yellow #FFD629
    link: rgb(link),                             // Official link color #083973
    background: rgb(white),                      // White background
    surface: rgb(magpie-light-25),               // Light grey surface #F1F1F1
  ),
  spacing: (
    paragraph-leading: 1.2em,
    heading-above: ("1": 2em, "2": 1.5em, "3": 1em),
    heading-below: ("1": 1em, "2": 0.8em, "3": 0.5em),
  ),
)

// =================================
// Theorem Environment Setup
// =================================

// Configure theorion for theorem environments (no init function needed)
// #show: theorion-init

#let theorem-counter = counter("theorem")
#let theorem(title: none, body) = {
  theorem-counter.step()
  block[
    *Theorem #theorem-counter.display().*#h(1em)
    #if title != none [*#title.* #h(1em)]
    #body
  ]
}

#let lemma-counter = counter("lemma")
#let lemma(title: none, body) = {
  lemma-counter.step()
  block[
    *Lemma #lemma-counter.display().*#h(1em)
    #if title != none [*#title.* #h(1em)]
    #body
  ]
}

#let corollary-counter = counter("corollary")
#let corollary(title: none, body) = {
  corollary-counter.step()
  block[
    *Corollary #corollary-counter.display().*#h(1em)
    #if title != none [*#title.* #h(1em)]
    #body
  ]
}

#let definition-counter = counter("definition")
#let definition(title: none, body) = {
  definition-counter.step()
  block[
    *Definition #definition-counter.display().*#h(1em)
    #if title != none [*#title.* #h(1em)]
    #body
  ]
}

#let example-counter = counter("example")
#let example(title: none, body) = {
  example-counter.step()
  block[
    *Example #example-counter.display().*#h(1em)
    #if title != none [*#title.* #h(1em)]
    #body
  ]
}

#let remark(title: none, body) = {
  block[
    *Remark.*#h(1em)
    #if title != none [*#title.* #h(1em)]
    #body
  ]
}

// =================================
// Algorithm Environment
// =================================

#let algorithm-counter = counter("algorithm")

#let algorithm(body, caption: none) = {
  algorithm-counter.step()
  figure(
    kind: "algorithm",
    supplement: "Algorithm",
    caption: caption,
    pseudocode(
      body,
      booktabs: true,
      numbered-title: [Algorithm #algorithm-counter.display()],
    )
  )
}

// =================================
// Enhanced Code Display
// =================================

// Configure codly for code highlighting
#show: codly-init.with()

#codly(
  languages: (
    rust: (name: "Rust", icon: "🦀", color: rgb("#000000")),
    python: (name: "Python", icon: "🐍", color: rgb("#3776AB")),
    typst: (name: "Typst", icon: "📝", color: rgb("#239DAD")),
  ),
  display-name: true,
  display-icon: true,
)

// Code with line numbers using zebraw
#let code-block(body, lang: none, numbers: true) = {
  if numbers {
    zebraw(body, lang: lang)
  } else {
    raw(body, lang: lang, block: true)
  }
}

// =================================
// Enhanced Table and Figure Functions
// =================================

#let thesis-table = tablex.with(
  auto-lines: false,
  header-rows: 1,
  header-hlines-have-priority: true,
  column-gutter: 1em,
)

#let thesis-figure = figure.with(
  gap: 1em,
  placement: auto,
)

// Subfigure support
#let subfigure = figure.with(
  kind: "subfigure",
  supplement: "Figure",
  numbering: numbly("{1.1}a)", default: "1.1)"),
)

// =================================
// Word Count and Statistics
// =================================

#let word-count(text) = {
  let words = text.split(regex("\\s+")).filter(w => w != "")
  words.len()
}

#let char-count(text) = {
  text.len()
}

#let page-count = context {
  counter(page).final().first()
}

// =================================
// Utility Functions
// =================================

// Format dates
#let format-date(date) = {
  let months = ("January", "February", "March", "April", "May", "June",
                "July", "August", "September", "October", "November", "December")
  [#date.day() #months.at(date.month() - 1) #date.year()]
}

// Create a placeholder for unimelb logo
#let unimelb-logo = image.with(width: 4cm)

// =================================
// Advanced Package Utilities
// =================================
  italic-greek: true,
  bold-greek: false,
)

// Equation numbering and referencing
#let equation-env = equate.with(
  sub-numbering: true,
  number-mode: "label",
)

// Showybox for highlighted content
#let info-box = showybox.with(
  frame: (
    border-color: rgb(traditional-heritage-100),
    title-color: rgb(traditional-heritage-100),
    body-color: rgb(traditional-heritage-100).lighten(95%)
  ),
  title-style: (
    color: white,
    weight: "bold"
  )
)

#let warning-box = showybox.with(
  frame: (
    border-color: rgb(sheoak-light-100),
    title-color: rgb(sheoak-light-100),
    body-color: rgb(sheoak-light-100).lighten(95%)
  ),
  title-style: (
    color: white,
    weight: "bold"
  )
)

#let success-box = showybox.with(
  frame: (
    border-color: rgb(red-gum-light-100),
    title-color: rgb(red-gum-light-100),
    body-color: rgb(red-gum-light-100).lighten(95%)
  ),
  title-style: (
    color: white,
    weight: "bold"
  )
)

// =================================
// QR Code Generation
// =================================

#let generate-qr = qrcode.with(
  width: 2cm,
  height: 2cm,
  error-correction: "M"
)

// =================================
// Landscape Page Support
// =================================

#let landscape-page(body) = {
  set page(
    height: auto,
    width: auto,
    margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 3cm),
    flipped: true
  )
  body
  set page(
    height: auto,
    width: auto,
    margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 3cm),
    flipped: false
  )
}

// =================================
// Advanced Theorem Environments
// =================================

#let proposition(title: none, body) = {
  block[
    *Proposition.*#h(1em)
    #if title != none [*#title.* #h(1em)]
    #body
  ]
}

#let axiom(title: none, body) = {
  block[
    *Axiom.*#h(1em)
    #if title != none [*#title.* #h(1em)]
    #body
  ]
}

#let conjecture(title: none, body) = {
  block[
    *Conjecture.*#h(1em)
    #if title != none [*#title.* #h(1em)]
    #body
  ]
}

// =================================
// Code Highlighting Setup
// =================================

// Configure codly for code highlighting
#show: codly-init.with()
#codly(languages: (
  typst: (
    name: "Typst",
    icon: "",
    color: rgb("#239dad"),
  ),
  python: (
    name: "Python",
    icon: "",
    color: rgb("#ffd43b"),
  ),
  rust: (
    name: "Rust",
    icon: "",
    color: rgb("#000000"),
  ),
  javascript: (
    name: "JavaScript",
    icon: "",
    color: rgb("#f7df1e"),
  ),
))

// =================================
// Export all utilities
// =================================

// =================================
// Export all utilities
// =================================
