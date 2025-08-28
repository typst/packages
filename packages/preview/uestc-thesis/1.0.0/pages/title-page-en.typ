#import "../thesis-vars.typ": *

#set page(
  paper: "a4",
  margin: (top: 0pt, bottom: 0pt, left: 0pt, right: 0pt),
)

#set text(font: ("Times New Roman", "SimSun"))

// English Title page layout
#align(center)[
  #v(100pt)
  
  // Main title
  #text(font: "Times New Roman", size: 22pt, weight: "bold")[
    #thesis-title-en
  ]
  
  #v(150pt)
  
  #text(font: "Times New Roman", size: 16pt, style: "italic")[
    A Master Thesis Submitted to
    
    University of Electronic Science and Technology of China
  ]
  
  #v(150pt)
  
  // Author and advisor information
  #table(
    columns: (180pt, 320pt),
    stroke: none,
    align: (left, left),
    row-gutter: 20pt,
    inset: 10pt,
    [Discipline], [#box(width: 100%, height: auto, stroke: (bottom: 0.75pt))[#v(2pt) #text(font: "Times New Roman", size: 16pt, weight: "bold")[#discipline-en]]],
    [Student ID], [#box(width: 100%, height: auto, stroke: (bottom: 0.75pt))[#v(2pt) #text(font: "Times New Roman", size: 16pt)[#student-id]]],
    [Author], [#box(width: 100%, height: auto, stroke: (bottom: 0.75pt))[#v(2pt) #text(font: "Times New Roman", size: 16pt, weight: "bold")[#author-name-en]]],
    [Supervisor], [#box(width: 100%, height: auto, stroke: (bottom: 0.75pt))[#v(2pt) #text(font: "Times New Roman", size: 16pt, weight: "bold")[#advisor-name-en]]],
    [School], [#box(width: 100%, height: auto, stroke: (bottom: 0.75pt))[#v(2pt) #text(font: "Times New Roman", size: 16pt)[#school-name-en]]],
  )
] 