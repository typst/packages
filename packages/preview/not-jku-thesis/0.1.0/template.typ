#import "titlepage.typ": *
#import "disclaimer.typ": *
#import "acknowledgement.typ": *
#import "abstract.typ": *

#import "@preview/wordometer:0.1.2": word-count, total-words


#let jku-thesis(
  thesis-type: "Bachlor/Maser/etc",
  degree: "The degree",
  program: "The Program",
  supervisor: "Your Supervisor",
  advisors: ("The first advisor", "The second advisor"),
  department: "The Deparment",
  author: "The Author",
  date: "The Submission Date",
  place-of-submission: "Place of Submission", // for declaration
  title: "Title",
  abstract-en: [English Abstract],
  abstract-de: none,
  acknowledgements: none,
  show-title-in-header: true,
  draft: true,
  body,
) = {

  let draft_string = ""
  if draft{
    draft_string = "DRAFT - "
  }

  set document(author: author, title: draft_string + title)

  
  set page(
    numbering: "1", // this is necessary for the glossary
    //number-align: center,
    margin: (left: 2.5cm+1cm, // binding correction of 1cm for single sided printing
              right: 2.5cm,
              y: 2.9cm),
    header: context{[
      #if counter(page).get().first() > 2 [
        #place(top+right ,float: false, dx: 0cm, dy:1cm)[
          #box(width: 25%)[
              #align(right)[#image("JKU.png", height: 35pt)]
          ]
        ] 
      ]
      #set text(8pt)
      #if show-title-in-header [
        #author - #title
      ]
      
      #if draft [
        DRAFT
      ]
    ]}, 
    footer: context [//overwrite numbering
  #text(size:9pt)[
    #table(
      stroke: none,
      columns:  (1fr, auto, 1fr),
      align: (left, center, right),
      inset: 5pt,
      [],[],[],
      
    )
  ]
]

)
  





  



  titlepage(
    thesis-type: thesis-type,
    degree: degree,
    program: program,
    supervisor: supervisor,
    advisors: advisors,
    department: department,
    author: author,
    date: date ,
    title: title
  )
  pagebreak()


  disclaimer(
    date: date,
    place-of-submission: place-of-submission,
    thesis-type: thesis-type,
    author: author,
  )
  if acknowledgements != none [ // optional
    #acknowledgement(acknowledgements)
  ]

  abstract(lang: "en")[#abstract-en]

  if abstract-de != none [ // optional
    #abstract(lang: "de")[#abstract-de]
  ]

  counter(page).update(1)

  body

}