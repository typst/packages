#import "@preview/clean-ualberta-thesis:0.1.0": thesis, appendices

// Replace the metadata and sample text before submitting your thesis.
#show: thesis.with(
  title: "Your Thesis Title",
  author: "First Middle Last",
  degree: "Master of Science",
  department: "Department of Mechanical Engineering",
  year: 2026,
  specialization: none,
  abstract: [
    Replace this paragraph with your thesis abstract. State the research
    problem, approach, principal findings, and contribution. The abstract must
    be no longer than 700 words and must not contain citations, tables,
    figures, or unexplained abbreviations. Its double spacing is supplied by
    the template.
  ],
  preface: [
    Replace this paragraph with a preface appropriate to your own work.
    Describe your contributions and any collaboration, previously published
    material, ethics approvals, artificial intelligence use, and funding as
    applicable under the current GPS requirements. Have your supervisor review
    the final statement. This sample does not make any declarations about
    your research.
  ],
  dedication: [Replace this text with your dedication, or set `dedication: none`.],
  acknowledgements: [
    Replace this text with your acknowledgements, or set `acknowledgements: none`.
  ],
  symbols: [
    / $x$: Illustrative input value.
    / $y$: Illustrative response value.
  ],
  abbreviations: [
    / GPS: Graduate and Postdoctoral Studies.
  ],
  glossary: [
    / Model: A representation used to describe a relationship or process.
  ],
)

#include "chapters/introduction.typ"

#include "chapters/methods.typ"

#include "chapters/conclusion.typ"

#bibliography("references.bib", title: [Bibliography], style: "ieee")

#appendices[
  #include "appendices/supporting-material.typ"
]
