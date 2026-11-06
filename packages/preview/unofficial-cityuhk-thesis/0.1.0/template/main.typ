#import "@preview/unofficial-cityuhk-thesis:0.1.0": thesis

// TODO:
// The title of the thesis
#let title = (
  en: "A Discussion on Higher Education Development in Hong Kong",
  zh: "論香港高等教育的發展",
)

// TODO:
// The author of the thesis
#let author = (
  firstname: "Tai Man",
  surname: "Chan",
  firstname-zh: "大文",
  surname-zh: "陳",
)

// TODO:
// Department to submit the thesis to
#let dept = (
  en: "Department of Public Policy",
  zh: "公共政策學系",
)

// TODO:
// Degree of the thesis
#let degree = (
  en: "Doctor of Philosophy",
  zh: "哲學博士學位",
  abbr: "PhD",
)

// TODO:
// Date
#let date = (
  en: "July 2021",
  zh: "二零二一年七月",
)

// TODO:
// Supervisors, panel members, and examiners
#let supervisor = (
  title: "Prof.",
  firstname: "Name",
  surname: "Surname",
  dept: "Department of Computer Science",
  university: "City University of Hong Kong",
)

#let panel-members = (
  (
    title: "Prof.",
    firstname: "Name",
    surname: "Surname",
    dept: "Department of Computer Science",
    university: "City University of Hong Kong",
  ),
  (
    title: "Prof.",
    firstname: "Name",
    surname: "Surname",
    dept: "Department of Computer Science",
    university: "City University of Hong Kong",
  ),
)

#let examiners = (
  (
    title: "Prof.",
    firstname: "Name",
    surname: "Surname",
    dept: "Department of Computer Science",
    university: "City University of Hong Kong",
  ),
  (
    title: "Prof.",
    firstname: "Name",
    surname: "Surname",
    dept: "Department of Computer Science",
    university: "City University of Hong Kong",
  ),
)

// TODO:
// Abstract and acknowledgement
// By default, they are included from `front-pages/abstract.typ`
// and `front-pages/acknowledgement.typ`
#let abstract = include "front-pages/abstract.typ"
#let ack = include "front-pages/acknowledgement.typ"

// TODO:
// Extra sections like Appendix, Publications, etc.
// This also can be included from ONE separate file
// and use normal headings such as `= Appendix`.
// NOTE: The format of the extra sections are controlled by you.
#let extra-sections = none

// Settings
#show: thesis.with(
  title: title,
  author: author,
  dept: dept,
  degree: degree,
  date: date,
  supervisor: supervisor,
  panel-members: panel-members,
  examiners: examiners,
  abstract: abstract,
  ack: ack,
  // TODO: Replace with your own bibliography file, style, and title, if needed
  bib: bibliography("thesis.bib", style: "nature", title: "References"),
  extras: extra-sections,
)

// TODO:
// The main body of the thesis.
// You can include from separate files, or write directly here.
// NOTE: If you prefer to write directly here, please import `chapater`
// to define chapters correctly, if not already.
#include "chapters/chapter1.typ"

#include "chapters/chapter2.typ"
