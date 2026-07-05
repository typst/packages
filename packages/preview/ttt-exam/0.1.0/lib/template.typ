#import "@preview/ttt-utils:0.1.0": assignments, components, grading
#import "i18n.typ": *

#import components: *
#import assignments: *
#import grading: *

#import "points.typ": *
#import "headers.typ": *

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
  solutions: false,
  header: "block",  // "block" or "page"
  point-field: "sum",  // "sum" or "table"
  body
) = {
  // Error checks
  if header != none { assert(header in ("block", "page"), message: "Expected 'header' parameter to be \"block\" or \"page\", found " + header) }
  if point-field != none { assert(point-field in ("sum", "table"), message: "Expected 'point-view' parameter to be \"sum\" or \"table\", found " + point-field) }

  // Set the document's basic properties.
  set document(author: authors, title: "exam-"+subject+"-"+class)
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
      // Erfolg
      h(1fr)
      text(10pt, weight: "semibold", font: "Atma")[
          #linguify("good_luck", from: ling_db)  #box(height: 1em, image("assets/four-leaf-clover.svg"))
      ]
      h(1fr)
      // Page Counter
      counter(page).display("1 / 1", both: true)
    },
    header: context if (counter(page).get().first() > 1) { box(stroke: ( 0.5pt), width: 100%, inset: 6pt)[ Name: ] },
  )

  // check cli input for solution
  let cli_arg_lsg = sys.inputs.at("solution", default: none)
  if (cli_arg_lsg != none) { solutions = json.decode(cli_arg_lsg) }
  assert.eq(type(solutions), bool, message: "expected bool, found " + type(solutions))

  set-solution-mode(solutions)

  // Include Header-Block
  if (header == "page") {
    header-page(
      logo: logo,
      title, 
      subtitle: subtitle, 
      class, 
      subject, 
      date,
      point-field: if (point-field == "sum" ) { point-sum-box } else { point-table }
    )
  } else if (header == "block") {
    header-block(
      title, 
      subtitle: subtitle ,
      class, 
      subject, 
      date, 
      logo: logo
    )
  }

  // Predefined show rules
  show par: set block(above: 1.2em, below: 1.2em)

  // Content-Body
  body


}

#let appendix(body, title: auto, ..args) = [
  #set page(footer: none, header:none, ..args.named())
  #if-auto-then(title, heading(linguify("appendix", from: ling_db)))
  #label("appendix")
  
  #body
]
