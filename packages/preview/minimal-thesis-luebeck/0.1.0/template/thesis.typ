#import "@preview/minimal-thesis-luebeck:0.1.0": *
#import "config/utils/todo.typ": TODO

#let title-english = "Towards Smart Inventions and their Novelty"
#let author = "Findus"

#set document(title: title-english, author: author)

#show: thesis.with(
  title: title-english,
  author: author,
  title-german: "Über schlaue Erfindungen und deren Neuartigkeit",
  degree: "Master",
  institute: "Institut für schlaue Erfindungen",
  program: "Tüfteln und Basteln",
  company: "Pettersson's Patentideen",
  university: "Universität Småland",
  supervisor: "Pettersson",
  advisor: "Gustravsson",
  submission-date: datetime.today(), // or use: datetime(day: 1, month: 1, year: 2025)
  place: "Lübeck",
  abstract-en: include "texts/abstract-en.typ",
  abstract-de: include "texts/abstract-de.typ"
)

#TODO[
  Write your thesis here!
]
#include "texts/tutorial.typ"