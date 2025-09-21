#import "@preview/dmi-basilea-thesis:0.1.2": *
// or for local testing:
// #import "../main.typ": *  // This is for local testing

#show: thesis.with(
  draft: true,
  colored: true,
  title: "Thesis Template in Typst",
  author: "Nico Bachmann",
  email: "nico@nifalu.ch",
  immatriculation: "2020-123-456",
  supervisor: "Prof. Dr. John Smith",
  examiner: "Prof. Dr. Alice Johnson",
  faculty: "Faculty of Science, University of Basel",
  department: "Department of Mathematics and Computer Science",
  research-group: "Your Research Group",
  website: "",
  thesis-type: "Bachelor Thesis",
  date: datetime.today(),
  language: "en",

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
