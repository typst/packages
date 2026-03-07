#import "packages.typ": package

#import package("abbr") as abbr
#import package("tum-tastic-thesis"): dissertation, thesis


#show: abbr.show-rule
#abbr.load("abbreviations.csv")

// Import each chapter here
#import "theory.typ" as theory
#import "introduction.typ" as introduction

// We configure the template. Check more parameters in the template
// documentation: https://typst.app/universe/package/tum-tastic-thesis
#show: dissertation.with(
  author-info: (
    name: "Your Name Here",
    group-name: "Your Group Or Chair Here",
    school-name: "Your School Here",
  ),
  title: [Your Title Here],
  subtitle: none,
  degree-name: "Dr. In Something",
  committee-info: (
    chair: "Prof. Chair Here",
    first-evaluator: "Prof. First Evaluator Here",
    second-evaluator: "Prof. Second Evaluator Here",
  ),
  date-submitted: datetime(
    year: 2020,
    month: 10,
    day: 4,
  ),
  date-accepted: datetime(
    year: 2021,
    month: 10,
    day: 4,
  ),
  acknowledgements: [#lorem(100)],
  abstract: [#lorem(100)],
)

// If you are doing a bachelor/master thesis, use instead the code below.
// Check more parameters in the template documentation:
// https://typst.app/universe/package/tum-tastic-thesis
//
// #show: thesis.with(
//   author-info: (
//     name: "Your Name Here",
//     group-name: "Your Group Or Chair Here",
//     school-name: "Your School Here",
//   ),
//   title: [Your Title Here],
//   subtitle: none,
//   degree-name: "Bachelor in Science",
//   committee-info: (
//     examiner: "Prof. Chair Here",
//     supervisor: "Supervisor goes here",
//   ),
//   date-submitted: datetime(
//     year: 2020,
//     month: 10,
//     day: 4,
//   ),
//   acknowledgements: [#lorem(100)],
//   abstract: [#lorem(100)],
// )

// Your chapters go here
#introduction.content

#pagebreak()
#theory.content

// After your chapters:

#set heading(numbering: none)

// Print bibliography
#set page(header: [
  #set text(style: "italic")
  #align(right)[Bibliography]
])

#pagebreak()
#bibliography("bibliography.bib")

// Print abbreviations
#set page(header: [
  #set text(style: "italic")
  #align(right)[Abbreviations]
])

#pagebreak()
#abbr.list()
