#import "@preview/ttt-utils:0.1.2": assignments, components, grading, helpers
#import "i18n.typ": *

#import components: *
#import assignments: *
#import grading: *

#import "points.typ": *
#import "headers.typ": *

#let _appendix(body, title: auto, ..args) = [
  #set page(footer: none, header:none, ..args.named())
  #if-auto-then(title, heading(linguify("appendix", from: ling_db)))
  #label("appendix")
  
  #body
]
// The exam function defines how your document looks.
#let exam(
  // metadata 
  logo: none,
  title: "exam", // shoes the title of the exam -> 1. Schulaufgabe | Stegreifaufgabe | Kurzarbeit
  subtitle: none,
  date: none,     // date of the exam
  class: "",
  subject: "" ,
  authors: "",
  // config
  solution: auto, // auto | false | true
  cover: false, // false | true
  header: auto, // auto | false | true
  eval-table: true,
  appendix: none,
  footer-msg: auto,
  body
) = {
 
  // Set the document's basic properties.
  set document(author: authors, title: "exam-"+subject+"-"+class)
  // set page properties
  set page(
    margin: (left: 20mm, right: 20mm, top: 20mm, bottom: 20mm),
    footer: {
      // Copyright symbol
      sym.copyright; 
      // YEAR
      if type(date) == datetime { date.display("[year]") } else { datetime.today().display("[year]") }
      // Authors
      if (type(authors) == array) [
        #authors.join(", ", last: " and ")
      ] else [
        #authors
      ]
      h(1fr)
      // Footer message: Default Good luck
      if footer-msg == auto {
        text(10pt, weight: "semibold", font: "Atma")[
            #linguify("good_luck", from: ling_db)  #box(height: 1em, image("assets/four-leaf-clover.svg"))
        ]
      } else {
        footer-msg
      }

      h(1fr)
      // Page Counter
      counter(page).display("1 / 1", both: true)
    },
    header: context if (counter(page).get().first() > 1) { box(stroke: ( 0.5pt), width: 100%, inset: 6pt)[ Name: ] },
  )

  // check cli input for solution
  if solution == auto {
    set-solution-mode(helpers.bool-input("solution"))
  } else {
    set-solution-mode(solution)
  }

  let cover-page = header-page(
    logo: logo,
    title, 
    subtitle: subtitle, 
    class, 
    subject, 
    date,
    point-field: point-sum-box  
  )

  let header-block = header-block(
    title, 
    subtitle: subtitle ,
    class, 
    subject, 
    date, 
    logo: logo
  )

  // Include Header-Block
  if (cover) {
    cover-page 
  } else if (header != false) { 
    header-block 
  }


  // Predefined show rules
  show par: set block(above: 1.2em, below: 1.2em)

  // Content-Body
  body

  if not cover and eval-table {

    align(bottom + end,block[
      #set align(start)
      *#ling("points"):* \
      #point-sum-box
    ])
  }

  if appendix != none {
    _appendix(appendix)
  }

}

