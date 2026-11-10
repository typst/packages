#import "@preview/bme-vik-azslab-thesis:1.0.0": *
// ---------------------------------------------------------------------------
// ---------------------------------TEMPLATE----------------------------------
// ---------------------------------------------------------------------------
#include "content/guideline.typ" // To be removed in the final doc
#include "content/project.typ" // To be removed in the final doc

#let lang = "hu"  // LANGUAGE OF THE DOCUMENT

#show: thesis.with(
  authors: ("Gipsz Jakab"),
  lang: lang,
  supervisors: ("Dr. Első konzulens", "Második konzulens"),
  title: "Elektronikus Terelők"
)

// ---------------------------------------------------------------------------
// -------------------------------FRONT MATTER--------------------------------
// ---------------------------------------------------------------------------
#show: front-matter
#include "content/abstract.typ"

// ---------------------------------------------------------------------------
// -------------------------------MAIN MATTER---------------------------------
// ---------------------------------------------------------------------------
#show: main-matter

#include "content/introduction.typ"
#include "content/typst-tools.typ"
#include "content/thesis-format.typ"
#include "content/template-usage.typ"


#show: back-matter
// ---------------------------------------------------------------------------
// -----------------------------ACKNOWLEDGEMENT-------------------------------
// ---------------------------------------------------------------------------
#include "content/acknowledgement.typ"

// ---------------------------------------------------------------------------
// ------------------------LIST OF FIGURES OR TABLES--------------------------
// ---------------------------------------------------------------------------
// #show: list-of-figures
// #show: list-of-tables

// ---------------------------------------------------------------------------
// ------------------------------BIBLIOGRAPHY---------------------------------
// ---------------------------------------------------------------------------
#bibliography("bibliography/bib.bib")


// ---------------------------------------------------------------------------
// --------------------------------APPENDIX-----------------------------------
// ---------------------------------------------------------------------------
#show: appendix
#include "content/appendices.typ"

// ---------------------------------------------------------------------------
// ---------------------------GENAI-DECLARATION------------------------------
// ---------------------------------------------------------------------------
#show: genai-declaration.with(true)
#let gen-ai-names = gen-ai-names-all.at(lang) // To be adjusted to the language

#{
    show table.cell: set text(size: 10pt)

    table(
    columns: (1.3fr, 1fr, 1fr, 1fr),
    stroke: 0.5pt,
    align: horizon,
    table.header(
      gen-ai-names.titles.types, gen-ai-names.titles.names, gen-ai-names.titles.sections, gen-ai-names.titles.usage
    ),
    gen-ai-names.literature, [], [], [],
    ..gen-ai-prompt(),

    gen-ai-names.codegen, [], [], [],
    ..gen-ai-prompt(),

    gen-ai-names.ideas, [], [], [],
    ..gen-ai-prompt(),

    gen-ai-names.outline, [], [], [],
    ..gen-ai-prompt(),

    gen-ai-names.textblocks, [], [], [],
    ..gen-ai-prompt(),

    gen-ai-names.figures, [], [], [],
    ..gen-ai-prompt(),

    gen-ai-names.plots, [], [], [],
    ..gen-ai-prompt(),

    gen-ai-names.presentation, [], [], [],
    ..gen-ai-prompt(),

    gen-ai-names.others, [], [], [],
    ..gen-ai-prompt(),

    ..gen-ai-all-percentage(),
    gen-ai-all-text()
  )
}