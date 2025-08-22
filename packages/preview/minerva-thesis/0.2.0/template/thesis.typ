#import "@preview/minerva-thesis:0.2.0": *



#show: thesis.with(
  authors: "The Student", // or array: ("Student 1", "Student 2") 
  title: [The thesis title],
  keywords: ("Keyword 1", "Keyword 2", "Keyword 3"),
  date: [Academic year XXXX-YYYY],
  description: [Master's disseration submitted to obtain the academic degree of Master of Science in Some Discipline],
  supervisors: ([Prof. Aa Bbb, Ph.D.], [Prof. Cc Dddd, Ph.D.]), 
  counsellors: [Ee Ffff], // or array
  faculty: "EA",
  language: "EN",
  paper: "a4",
//   font-size: auto, // auto (= default) means default Typst text size (11pt)    
  figure-fill: none, // auto = colour-tertiary of Ghent University corporate identity, none = no background
  )

  
#show "et al.": [_et al._]

// #set figure(placement: auto) // puts figures at the top or bottom of pages

// The title-page function can only be used for Ghent University theses.
// Install the UGent Panno Text font on your system for a Ghent University thesis and uncomment the "font: ..." line below.
// Take care that the font name on your system is exactly the same as the font argument below.
#title-page( 
//   font: "UGent Panno Text"  
)

#show: front-matter.with(show-headings: false) 
// optional:
  #include "FrontMatter/confidentiality.typ"
  #hide-page-number()
  
  #include "FrontMatter/explanation-exam.typ"
  #hide-page-number()


#show: front-matter

#include "FrontMatter/acknowledgement.typ"

#include "FrontMatter/use-of-ai.typ"

#include "FrontMatter/abstract.typ"

#show: front-matter.with(show-headings: false) // commenting this line will insert a flyleaf with "Extended Abstract"
#include "FrontMatter/extended-abstract.typ"

#show: front-matter // is not needed if the line #show: front-matter.with(show-headings: false) above is commented

// #set-page-number-width(2em) // use this function to adjust the space for the page number in the outlines

#outline(
  title:[Table of Contents], 
  target: heading
)

#outline(
  title: [List of Tables],
  target: figure.where(kind: table),
)

#outline(
  title: [List of Figures],
  target: figure.where(kind: image)
)


// List of Abbreviations via package abbr (which has been automatically imported)
#abbr.list()



#show: chapter

// Parts are optional. 
#part("First Part") 

#include "Ch1/ch1.typ"

// #include "Ch2/ch2.typ"
// 
// 
// #part("Methods") 
// 
// #include "Ch3/ch3.typ"
// 
// #include "Ch4/ch4.typ"
// 
// #part("Results")
// 
// #include "Ch5/ch5.typ"

// #show: appendix.with(flyleaf:[Appendix]) // if there is only one Appendix
#show: appendix //otherwise

#include "AppA/appA.typ"
// #include "AppB/appB.typ"

#show: back-matter

// #bibliography("references.bib", style: "ieee")  // refer to your bibliography  file here
