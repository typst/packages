#import "@preview/uo-pup-thesis-manuscript:0.1.0": *


#let bib-file = "ref.bib"

#show: template.with(
  // NOTE: thesis title must be in inverted pyramid style. Other
  // rules--font size and uppercase rule are already
  // configured
  [
    Fanum Tax and Sales Prediction of Lunchly Using
    CNN-FR-LMFAO-BERT Hybrizz Model
  ],

  // authors
  (
    "Kai C. Enat",
    "Fanu M. Tax",
    "Speed I. Show",
    "Kay S. Eye"
  ),

  // don't abbreviate
  "College of Computer and Information Sciences",
  "Bachelor of Science in Computer Science",

  "October 2024"
)

#include "chapt1.typ"
#include "chapt2.typ"
#include "chapt3.typ"


// Bibliography
#set par(first-line-indent: 0pt, hanging-indent: 0.5in)
#set page(header: context [
  #h(1fr)
  #counter(page).get().first()
])
#align(center)[ #heading("REFERENCES") ]
#set par(spacing: 1.5em)
#bibliography(title: none, style: "./apa.csl", bib-file)


// Appendix
#show: appendices-section
#include "appendices.typ"
