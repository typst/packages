#import "@preview/modern-unito-thesis:0.1.0": template

// Your acknowledgments (Ringraziamenti) go here
#let acknowledgments = [ 
  I would like to thank you for using my template and the team of typst for the great work they have done and the awesome tool they developed. Remember that it's best practice to thank the people you worked with before thanking your family and friends.
]

// Your abstract goes here
#let abstract = [ 
  In this theis, we will talk about this template I made for the University of Turin, remember that the abstract should be concise and clear but should also be able to give a good idea of what the thesis is about, always ask your advisor for feedback if you are unsure.
]

#show: template.with(
  // Your title goes here
  title: "My Beautiful Thesis",

  // Change to the correct academic year, e.g. "2024/2025"
  academic-year: [2023/2024],

  // Change to the correct subtitle, i.e. "Tesi di Laurea Triennale",
  // "Master's Thesis", "PhD Thesis", etc.
  subtitle: "Bachelor's Thesis",

  // Change to your name and matricola
  candidate: (
    name: "Eduard Antonovic Occhipinti",
    matricola: 947847
  ),

  // Change to your supervisor's name
  supervisor: (
    "Prof. Luigi Paperino"
  ),

  // Add as many co-supervisors as you need or remove the entry
  // if none are needed
  co-supervisor: (
    "Dott. Pluto Mario",
    "Dott. Minni Topolino"
  ),

  // Customize with your own school and degree
  affiliation: (
    university: "Università degli Studi di Torino",
    school: "Scuola di Scienze della Natura",
    degree: "Corso di Laurea Triennale in Informatica",
  ),

  // Change to "it" for the Italian template
  lang: "en",

  // University logo
  logo: image("imgs/logo.svg", width: 40%),

  // Hayagriva bibliography is the default one, if you want to use a
  // BibTeX file, pass a .bib file instead (e.g. "works.bib")
  bibliography: bibliography("works.yml"),

  // See the `acknowledgments` and `abstract` variables above
  acknowledgments: acknowledgments,
  abstract: abstract,

  // Add as many keywords as you need, or remove the entry if none
  // are needed
  keywords: [keyword1, keyword2, keyword3]
)

// I suggest adding each chapter in a separate typst file under the
// `chapters` directory, and then importing them here.

#include "chapters/introduction.typ"

#include "chapters/example.typ"

#include "chapters/conclusions.typ"
