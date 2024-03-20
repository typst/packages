#import "@preview/modern-unito-thesis:0.1.0": template

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

  // Add as many keywords as you need, or remove the entry if none
  // are needed
  keywords: [keyword1, keyword2, keyword3]
)

// I suggest adding each chapter in a separate typst file under the
// `chapters` directory, and then importing them here.

#include "chapters/introduction.typ"

#include "chapters/example.typ"

#include "chapters/conclusions.typ"
