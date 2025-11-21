#import "@preview/unofficial-cityu-phd-thesis:1.0.0": graduate-general
#import graduate-general: *

#let info = (
  univ-en: "CITY UNIVERSITY OF HONG KONG",
  univ-zh: "香港城市大學",
  title: ("一二三", "四五六"),
  title-en: ("abc", "def"),
  author: "七八九",
  author-en: "ghi",
  surname: "八九",
  firstname: "七",
  department: "Department of Electrical Engineering",
  department-zh: "電機工程系",
  degree: "PhD",
  submit-date: "二零九九年五月",
  submit-date-en: "May, 2099",
  
  supervisor: ("jkl", "mno"),
  superdep: ("Department of Electrical Engineering", "pqr"),
  superunvi: ("City University of Hong Kong", "stu"),
  
  panels: ("abc", "de"),
  paneldep: ("fhi", "jk"),
  panelunvi: ("lmn", "op"),

  examiner: ("abc", "de"),
  examinerdep: ("fhi", "jk"),
  examinerunvi: ("lmn", "op"),

  isjoint: false,
)

#let doc = graduate-general(info: info, twoside: true)
#show: doc.style

#show: frontmatter

#doc.pages.cover
<mzt:no-header-footer>

#let individual = doc.pages.individual

#individual("Abstract")[
  #h(2em)
  testing
]

#doc.pages.panel-exam
#individual("Acknowledgements")[
  testing
]

#doc.pages.outline
#doc.pages.figure-outline
#doc.pages.table-outline

#show: mainmatter

// TODO: include your main file
// #include "main.typ"
= Testing Section
== Testing Subsection
testing sentence with ref @testref.

// `ref.bib` is the same as the reference papers in LaTeX
#individual("References", outlined: true)[
  #bibliography("ref.bib", style: "ieee", title: none)
]

// #individual("Appendix", outlined: true)[
//   #appendix(level: 1)[
//     == One <app1>
//     @app1
//     == Two

//   ]
// ]

#individual("Publications", outlined: true)[
  testing
]
