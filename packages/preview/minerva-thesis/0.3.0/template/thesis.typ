#import "@preview/minerva-thesis:0.3.0": *

#show: thesis.with(
  authors: ("Student 1", "Student 2"),
  title: (en: [A nice thesis title -- #lorem(10)], nl: [Een mooie masterproeftitel -- #lorem(10) ]  ),
// if only one language is used:
//   title: [A nice thesis title -- #lorem(10)],
  keywords: (en: ("Master's thesis", "Typst"), nl: ("Masterproef", "Typst") ),
  date: [Academic year XXXX-YYYY],
  description: [Master's dissertation submitted to obtain the academic degree of Master of Science in Some Discipline],
  supervisors: (
    (
      en: [Prof. Aa Bbbb, Ph.D.],
      nl: [Prof. dr. Aa Bbbb]
    ), (
      en: [Prof. Cc Dddd, Ph.D.],
      nl: [Prof. dr. Cc Dddd]
    )
  ),
// if only one language is used:
//   supervisors: ( [Prof. Aa Bbbb, Ph.D.], [Prof. Cc Dddd, Ph.D.]),
  counsellors: (
    en: [Ee Ffff, Ph.D.],
    nl: [Dr. Ee Ffff]
  ),
  faculty: "EA",
  language: "en",
  paper: "a4",
  font-size: 11pt,
  chapter-show: false, // do not show "Chapter", just the number
  figure-fill: none, //  auto = light gray, none = no background
  subfigure-numbering: "(a)", // default: "a"
  subfigure-caption-sep: sym.space, // default: sym.colon+sym.space (": ")
//   figure-ref-text: (weight: "semibold"), // References to figures (of all kinds) put in bold characters.
  caption-position: (table: top),
  header-text: (smallcaps, (size: 0.9em) ),
//   per-chapter-numbering: false,

  )

  
#show "et al.": [_et al._]

// #set figure(placement: auto) // puts figures at the top or bottom of pages

// The title-page function can only be used for Ghent University theses.
// Install the UGent Panno Text font on your system for a Ghent University thesis and uncomment the "font: ..." line below.
// Take care that the font name on your system is the same as the font argument below.

#show: front-matter.with(show-headings: false) 

#title-page( 
//   font: "UGent Panno Text"  
)

// optional:
#include "FrontMatter/confidentiality.typ"
#hide-page-number
  
#include "FrontMatter/explanation-exam.typ"
#hide-page-number


#show: front-matter

#include "FrontMatter/acknowledgement.typ"

#include "FrontMatter/use-of-ai.typ"

#include "FrontMatter/abstract.typ"

#include "FrontMatter/samenvatting.typ"

#include "FrontMatter/extended-abstract.typ"

#include "FrontMatter/uitgebreide-samenvatting.typ"


#set-page-number-width(2.3em) // manual setting of the width of the page numbering in the Table of contents such that the "fill" (dotted lines) does not overlap with the page numbers

#table-of-contents

#set-page-number-width(1.2em)

#list-of-tables

#list-of-figures

// #list-of-figure-kind("theorem") // user-defined kinds of figures

// List of Abbreviations via package abbr (which has been automatically imported)
#list-of-abbreviations

#show: chapter

// Parts are optional. 
#part("Introduction", label: <part:intro>) 

#include "Ch1/ch1.typ"
// #include "Ch2/ch2.typ"

// #part("Methods", label: <part:methods>)
//
// #include "Ch3/ch3.typ"
// #include "Ch4/ch4.typ"
//
// #part("Results", label: <part:results>)
//
// #include "Ch5/ch5.typ"


#show: appendix

#include "AppA/appA.typ"
// #include "AppB/appB.typ"
// #include "AppC/appC.typ"

#show: back-matter
//
// // #bibliography("references.bib")
#bibliography("references.yaml")
