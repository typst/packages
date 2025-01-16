#import "../thesis_template.typ": *
#import "config/utils/todo.typ": TODO

#let titleEnglish = "Towards Smart Inventions and their Novelty"
#let author = "Findus"

#set document(title: titleEnglish, author: author)

#show: thesis.with(
  title: titleEnglish,
  author: author,
  titleGerman: "Über schlaue Erfindungen und deren Neuartigkeit",
  degree: "Master",
  institute: "Institut für schlaue Erfindungen",
  program: "Tüfteln und Basteln",
  company: "Pettersson's Patentideen",
  university: "Universität Småland",
  supervisor: "Pettersson",
  advisor: "Gustravsson",
  submissionDate: datetime.today(), // or use: datetime(day: 1, month: 1, year: 2025)
  place: "Lübeck",
  abstract_en: include "texts/abstract_en.typ",
  abstract_de: include "texts/abstract_de.typ"
)

#TODO[
  Write your thesis here!
]
#include "texts/tutorial.typ"