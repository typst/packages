#import "@preview/sos-ugent-style:0.2.0" as ugent: utils.flex-caption
#import ugent.utils.todo(): todo-change, todo-add, todo-unsure, todo-outline
#import "../abbreviations.typ" as abbrev

// ************ Useful functions ************
// Only for a few occasional code blocks, else use a specialized package
#let code-background = silver.lighten(30%)
#let code-block = block.with(fill: code-background, radius: 5pt, inset: 4pt)
// See https://github.com/typst/typst/pull/3526 (rounding between words :/ )
#let code-inline = highlight.with(radius:1pt, extent: 0.5pt, fill:code-background)

// ************ Metadata ************
// EDIT
#let datum = datetime(year: 2025, month: 9, day: 1)


// ************ The applied show rules ************
#let preamble-apply(body) = {
  // EDIT
  show: ugent.dissertation-template.with(
    glossary-entries: abbrev.glossary-entries,
    default-capitalize-heading-refs: true,
    reference-unnumbered-subheadings: true,
    color-internal-links: auto,
    language: "en",
    //font: , // Use show-set rules to change the font for specific elements, like headings
    //font-size: ,
    // Front page
    title: "My dissertation on a superinteresting subject",
    subtitle: none,
    author: "Your Name",
    faculty: "ea",
    secondary-faculty: none,
    wordcount: [0 #todo-change(pos: "inline")[UPDATE]], // TODO: extract this automatically. Contributions welcome
    student-number: "01234567",
    supervisors: ("Prof. dr. ir. person1", "person2"),
    commissaris: none,
    submitted-for: "Masterpraktijkproef (9SP) voorgelegd tot het behalen van de graad van de Educatieve Master in de wetenschappen en technologie: engineering en technologie",
    academic-year: [2024 -- 2025, Educatieve Masteropleiding],
  )

  set document(date: datum) // Specify for bit-for-bit reproducibility

  //abbrev.glossary-reset-usage // Only activate after reading the comments in abbreviations.typ
  body
}
