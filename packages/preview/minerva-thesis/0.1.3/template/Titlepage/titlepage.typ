#import "@preview/minerva-thesis:0.1.3": *

#let showperson(person) = [
#person.prefix #person.given-name #person.surname#{if person.suffix!=none [, #person.suffix]}
]

// titlepage() can (for now) be used for Ghent University theses only, but you can build a title page manually.
// In this example, the names of the supervisors are extracted from ../Jury/jury.yaml, but you can also create the supervisor(s) argument of the titlepage function manually.

#titlepage(
  author: [The Master/PhD Student],
  title: text(hyphenate:false,[Thesis Title -- #lorem(10)]), 
  language: "EN",
  faculty: "EA", // Ghent University faculty code, only used for selecting the proper faculty icon 
  date: [Month Year], 
  description: [Master's/Doctoral dissertation submitted to obtain the academic degree of Master/Doctor in Some Discipline],
  supervisors: [#(for member in yaml("../Jury/jury.yaml").at("supervisors") {(showperson(member),)}).join([ -- ])\  Department of Some Discipline],
  ids: ([ISBN vvv-uu-zzzz-yyy-x], [NUR XXX], [Wettelijk depot: D/YYYY/aa.bbb/cc]), 
//   font: "UGent Panno Text", 
  fontsize: 11pt
)


