#import "@preview/tf-freiburg-thesis:0.1.0": *
// For local testing from this repository:
// #import "../main.typ": *

#show: thesis.with(
  mirror-book: false,
  draft: true,
  colored: true,
  title: "Thesis Title",
  author: "Author Name",
  email: "author@example.com",
  immatriculation: "",
  jury: (
    ([Supervisor], [Prof. Dr. Supervisor Name]),
    ([Examiner], [Prof. Dr. Examiner Name]),
  ),
  jury-title: auto,
  faculty: "Faculty of Engineering, University of Freiburg",
  department: "Department of Computer Science",
  research-group: "Research Group Name",
  website: "",
  location: "Freiburg im Breisgau",
  thesis-type: "phd",
  date: datetime.today(),
  language: "en",
  title-language: "de",

  declaration: auto,
  declaration-signature: auto,

  abstract-en: [
    #lorem(200)
  ],

  abstract-de: [
    #lorem(200)
  ],

  acknowledgments: [
    #lorem(200)
  ],

  chapters: (
    include "content/1_introduction.typ",
    include "content/2_related_work.typ",
    include "content/3_background.typ",
    include "content/4_methodology.typ",
    include "content/5_experiments.typ",
    include "content/6_discussion.typ",
  ),

  appendices: (
    include "content/A_appendix.typ",
  ),

  bibliography-content: bibliography("references.bib", style: "ieee", title: none),
)
