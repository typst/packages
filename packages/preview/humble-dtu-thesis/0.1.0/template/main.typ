#import "@preview/humble-dtu-thesis:0.1.0": *

// ---- FONT ----
// #set text(font: "Neo Sans Pro",lang: "en")
// #set text(font: "New Computer Modern")
#set text(font: "Noto Sans", lang: "en")
  

#show: dtu-project.with(
  //General details
  title: 
  "Using Typst Instead Of Latex To Write A \nThesis, DTU Template",
  description: "Master Thesis",
  authors: (
    "Name Namesen", 
  ),
  date: datetime.today().display("[day] [month repr:long] [year]"),
  
  //Department
  university: "Technical University of Denmark",
  department: "DTU Compute",
  department-full-title: "Department of Applied Mathematics and Computer Science",
  address-i: "Richard Petersens Plads, Bygning 321",
  address-ii: "2800 Kgs. Lyngby Denmark",
  departmentwebsite: "www.compute.dtu.dk",  

  //preface
  before: (
    summary-english: include "sections/preface/english.typ",
    summary-danish: include "sections/preface/danish.typ",
    preface: include "sections/preface/preface.typ",
    acknowledgement: include "sections/preface/acknowledgement.typ",
    contents: include "sections/preface/contents.typ", // consider keeping this one
    readers-guide: include "sections/preface/readers-guide.typ",
  ),

  //extra
  // frontpage-input: include "path-to-frontpage", //if wanting to create a custom frontpage
  // background-color: rgb("#224ea9"), //change background color of last page
)

// *Todos*
// #show-all-notes()
// #pagebreak()

#include "sections/introduction.typ"
#include "sections/conclusion.typ"

#pagebreak()
#bibliography("works.bib")


#pagebreak()
#include "sections/appendix.typ"



