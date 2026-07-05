#import "@preview/minerva-thesis:0.1.3": *


#show: thesis.with( // Here default values of the arguments are used for your reference. 
//   font: "UGent Panno Text",
  font: "Libertinus Sans", 
  fontsize: 10pt,
  mathfont: "Libertinus Math",
  mathfontsize: 10pt,
  figurefont: "Libertinus Sans",
  figurefontsize: 10pt,
  captionfont: "Libertinus Sans",
  captionfontsize: 10pt,
  equation-left-margin: auto, // auto=centered equations
  figure-fill: none, // background colour of figures
  figure-inset: auto,
//   paper: none,
  page-width: 160mm, 
  page-height: 240mm
  )


// #set figure(placement: auto) // puts figures at the top or bottom of pages

#include "Titlepage/titlepage.typ"

#include "Jury/jury.typ"
// For including the Examination Board in the Table of Contents, comment the previous line and uncomment the following 5 lines:
// #frontmatter(showheading:false)[
//   = Examination Board
//   #hidepagenumber(outline: false)
//   #include "Jury/jury.typ"
// ]

#show: frontmatter
 
#include "Acknowledgement/acknowledgement.typ"

#include "Summaries/samenvatting.typ" // Dutch summary

#include "Summaries/summary.typ" // English summary

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
 


#show: chapter 

// Parts are optional
#part("First Part") 

#include "Ch1/ch1.typ"

// #include "Ch2/ch2.typ"
// 
// #part("Second Part") 
// 
// #include "Ch3/ch3.typ"
// 
// #include "Ch4/ch4.typ"

#show: appendix.with(flyleaf:[Appendix]) // if there is only one Appendix
// #show: appendix //otherwise

#include "AppA/appA.typ"


#show: backmatter

// #bibliography(<your bibfile>)


