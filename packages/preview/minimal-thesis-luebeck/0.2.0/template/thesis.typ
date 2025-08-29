#import "@preview/minimal-thesis-luebeck:0.2.0": *
#import "@preview/abbr:0.1.1"

#show: thesis.with(
  title-english: "Towards Smart Inventions and their Novelty",
  title-german: "Über schlaue Erfindungen und deren Neuartigkeit",
  author: "Findus",
  degree: "Master",
  submission-date: datetime.today(), // or use: datetime(day: 1, month: 1, year: 2025)
  institute: "Institut für schlaue Erfindungen",
  program: "Tüfteln und Basteln",
  company: "Pettersson's Patentideen",
  university: "Universität Småland",
  supervisor: "Pettersson",
  advisor: "Gustravsson",
  place: "Lübeck",
  top-left-img: image("images/top-left.png"),
  top-right-img: image("images/top-right.png"),
  slogan-img: image("images/slogan.png"),
  acknowledgement-text: include "texts/acknowledgement.typ",
  appendix: include "texts/appendix.typ",
  abstract-en: include "texts/abstract-en.typ",
  abstract-de: include "texts/abstract-de.typ",
  abbreviations: include "texts/abbreviations.typ",
  bib-file: bibliography("thesis.bib"),
  body-font: "New Computer Modern",
  sans-font: "New Computer Modern Sans",
  is-print: false,
  make-list-of-figures: false,
  make-list-of-tables: false
)


= Fist Chapter
#TODO[
  Write your thesis here! Just start typing (and citing: @alley1996craft).
]

// You can remove this when you are done looking at the examples.
#include "texts/tutorial.typ"
