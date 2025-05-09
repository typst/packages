#import "lib.typ": template, createAppendices

// Your acknowledgments (Ringraziamenti) go here
#let acknowledgements = [
  If you want to thank people, do it here, on a separate right-hand page. Both the U.S. _acknowl_-_edgments_ and the British _acknowledgements_ spellings are acceptable.

  We would like to thank Lennart Andersson for his feedback on this template.

  We would also like thank Camilla Lekebjer for her contribution on this template, as well as Magnus Hultin for his popular science summary class and example document.

  Thanks also go to the following (former) students for helping with feedback and suggestions on this template: Mikael Persson, Christoffer Lundgren, Mahmoud Nasser.
]

// Your abstract goes here
#let abstract = [

#show link: underline

First of all, this document is a Typst version of MScTemplateCS by Flavius Gruian and Camilla Lekebjer, which can be found at #link( "https://bitbucket.org/flavius_gruian/msccls/src/master/")[bitbucket/flavius_gruian]. Having found typst.app some time before writing our Master's thesis, we were just not willing to go back to LaTeX due to its slow compile times and non-intuitive styling, justifing the creation of this Typst template. The following text is straight up copied from the original LaTeX template for sake of comparison. If you want to see a practical example we used this template for our master's thesis which can be found at #link("https://lup.lub.lu.se/student-papers/record/9185623")[https://lup.lub.lu.se/student-papers/record/9185623].
#v(20pt)
#line(length:100%, stroke: 0.3pt)
#v(15pt)
This document describes the Master’s Thesis format for the theses carried out
at the Department of Computer Science, Lund University.
Your abstract should capture, in English, the whole thesis with focus on the
problem and solution in 150 words. It should be placed on a separate right-hand
page, with an additional 1cm margin on both left and right. Avoid acronyms,
footnotes, and references in the abstract if possible.
Leave a 2cm vertical space after the abstract and provide a few keywords rel-
evant for your report. Use five to six words, of which at most two should be from
the title.
]

#show: template.with(
  title: [Formatting a Master’s Thesis
and a bunch of other things that
are not really needed in here],
  se_title: [Infoga den Svenska titeln här!],
  thesis_number: [LU-CS-EX: XXXX-XX],
  issn: [XXXX-XXXX],


  subtitle: [(A Typst class)],

  students: (
    (
      name: [Theodor Lundqvist], 
      email: "theodor.lundqvist@gmail.com"
    ),
    (
      name: [Ludvig Delvret], 
      email: "ludvig.delvret@gmail.com"
    )
  ),

  // Change to your supervisor's name
  supervisors: (
    (
      name: [John Deer], 
      email: "jdeer@company.se"
    ),
    (
      name: [Don Jeer], 
      email: "djeer@xy.lth.se"
    ),
  ),
  
  // Change to your examiner's name
  examiner: (
    (
      name: [Jane Doe],
      email: "jane.doe@cs.lth.se"
    )
  ),

  // Customize with your own school and degree
  affiliation: (
    university: [LTH | Lund University],
    department: [Department of Computer Science],
    company: [AFRY AB]
  ),

  lang: "GB",

  acknowledgements: acknowledgements,
  abstract: abstract,

  keywords: [first keyword, second keyword],

  popular_science_summary: (
    title: [#lorem(6)],
    abstract: include("popsci/abstract.typ"),
    body: include("popsci/body.typ"),
  )

)

#include "chapters/formatting.typ"
#include "chapters/language.typ"
#include "chapters/structure.typ"


  // Bibliography
#if bibliography != none {
  show link: underline
  heading(level: 1, "References")
  show bibliography: set text(size: 1.0em)
  show bibliography: set par(spacing: 1.5em)
  set bibliography(title: none, style: "ieee.csl")
  bibliography("references.bib")
}

#createAppendices([
  #include "chapters/appendixA.typ"
])

