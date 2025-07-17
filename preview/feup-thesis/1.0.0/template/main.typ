#import "@preview/feup-thesis:1.0.0" as feup

#show: feup.template.with(
  // Document metadata
  title: "<DISSERTATION TITLE>",
  author: "<YOUR FULL NAME>",
  degree: "<YOUR COURSE NAME>",
  supervisor: "<SUPERVISOR NAME>",
  second-supervisor: "<SECOND SUPERVISOR NAME>", // Optional, use none if not applicable
  
  // Dates and copyright
  thesis-date: none, // Will use current date
  copyright-notice: "<YOUR NAME>, <YEAR OF PUBLICATION>",
  
  // Visual elements
  additional-front-text: none,
  
  // Committee information (example for final version), use none otherwise
  committee-text: "Approved in oral examination by the committee:",
  committee-members: (
    (role: "President", name: "<COMMITTEE PRESIDENT NAME>"),
    (role: "Referee", name: "<COMMITTEE MEMBER NAME>"),
    (role: "Referee", name: "<COMMITTEE MEMBER NAME>"),
  ),
  signature: false,
  
  // Configuration options
  stage: "final", // This is a final version
  language: "en",
  has-unsdg: false, // Include UN SDG section
  has-quote: true,
  bib-style: "ieee",
)

// Optional, remove this if you don't want a dedication
#feup.dedication(
  text("Dedication text, if you want to.", hyphenate: false),
)

#set page(numbering: "i", number-align: bottom + center)
#counter(page).update(1)

// Resumo
#include "prologue/resumo.typ"

// Abstract
#include "prologue/abstract.typ"

// UN-SDG (example)
#include "prologue/unsdg.typ"

// Acknowledgments
#include "prologue/acknowns.typ"

// Quote
#feup.epigraph(
  "The best way to predict the future is to invent it.",
  "Alan Kay"
)

// Table of Contents
#feup.table-of-contents()

// List of Acronyms
#feup.acronym-list((
    ("AI", "Artificial Intelligence"),
    ("API", "Application Programming Interface"),
    ("CNN", "Convolutional Neural Network"),
    ("CPU", "Central Processing Unit"),
    ("GPU", "Graphics Processing Unit"),
    ("ML", "Machine Learning"),
    ("NLP", "Natural Language Processing"),
    ("RNN", "Recurrent Neural Network"),
    ("SGD", "Stochastic Gradient Descent"),
    ("UI", "User Interface"),
  ),
)

// Start main body with arabic numbering
<main-content>
#show: feup.main-content-wrapper

// CHAPTERS - Include your chapter files here
// Follow the chapter-template.typ structure

#include "chapters/1-introduction.typ"
#include "chapters/2-literature-review.typ"
#include "chapters/3-theoretical-foundations.typ"
#include "chapters/4-methodology.typ"
#include "chapters/5-result-and-analysis.typ"
#include "chapters/6-conclusions-and-future-work.typ"

// Bibliography
#heading(level: 1, numbering: none)[Bibliography]
#bibliography("refs.bib", title: none, style: "ieee")
#pagebreak()

#set heading(numbering: "A.1", level: 1)
#counter(heading).update(0)

// Appendices
#include "appendixes/A-implementation-details.typ"
#include "appendixes/B-additional-results.typ"

// End of document
