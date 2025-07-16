#import "@preview/dmi-thesis:0.1.0": *
// or for local testing:
// #import "../src/main.typ": *  // This is for local testing

#show: thesis.with(
  colored: true,
  title: "Thesis Template in Typst",
  author: "Nico Bachmann",
  email: "nico@nifalu.ch",
  immatriculation: "2020-123-456",
  supervisor: "Prof. Dr. John Smith",
  examiner: "Prof. Dr. Alice Johnson",
  department: "Department of Mathematics and Computer Science",
  faculty: "Faculty of Science, University of Basel",
  research-group: "Databases and Information Systems (DBIS) Group",
  website: "https://dbis.dmi.unibas.ch",
  thesis-type: "Bachelor Thesis",
  date: datetime.today(),
  language: "en",
  body-font: "Helvetica",

  abstract: [
    This is a demonstration / tutorial on the usage of the UniBasel Typst template.
  ],

  acknowledgments: [
    Special thanks to the Typst community for creating such an excellent typesetting system.
  ],

  chapters: (
    include "content/introduction.typ",
    include "content/background.typ",
    include "content/methodology.typ",
    include "content/implementation.typ",
    include "content/evaluation.typ",
    include "content/discussion.typ",
    include "content/conclusion.typ",
    include "content/future_work.typ",
    include "content/related_work.typ",
    include "content/ai_notice.typ"
  ),

  appendices: (
    include "content/appendix.typ",
  ),

  bibliography-content: bibliography("references.bib", style: "ieee", title: none),
)
