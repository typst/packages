#import "dtu-template/frontpage-dtu.typ": *
#import "dtu-template/copyright.typ": *
#import "dtu-template/last-page.typ": *
#import "preamble.typ": *

#let hide-formalities = false
// #let hide-formalities = true

#let dtu-project(
  //General details
  title: "", 
  description: "",
  authors: (), 
  date: none, 
  //Department
  university: "", 
  department: "",
  department-full-title: "",
  address-i: "",
  address-ii: "",
  departmentwebsite: "",
  //preface
  before: (),
  //extra
  frontpage-input: none,
  background-color: rgb("#224ea9"),
  body) = {
  
  // ---- FRONTPAGE ----
  if frontpage-input == none {
    show: frontpage.with(
      title: title,
      description: description,
      authors: authors,
      date: date,
      university: university,
      department: department,
      department-full-title: department-full-title,
    )
  } else {
    frontpage-input
  }

  // ---- SETUP ----
  // Set the document's basic properties.
  set text(size: 10pt, fill: black)
  set document(author: authors, title: title)
  
  //make typst look like latex
  set page(numbering: none, number-align: center, fill: none, margin: auto)
  set par(leading: 0.65em)
  set heading(numbering: none)
  show heading: set block(above: 1.4em, below: 1em)

  // ---- FORMALITIES ----
  if not hide-formalities {
    // ---- COPYRIGHT ----
    show: copyright.with(
      title: title,
      description: description,
      authors: authors,
      date: date,
      university: university, 
      department: department,
      department-full-title: department-full-title,
      address-i: address-i,
      address-ii: address-ii,
    )
  
    // ---- IncludePagesBefore ----
    set page(numbering: "i", number-align: center)
    counter(page).update(1)
    include-files(before)
  
     //---- EMPTY PAGE ---- 
    pagebreak()
    
  } else {
    set page(numbering: "i", number-align: center)
    counter(page).update(1)
    before.contents
  }

  // ---- Main Report body ----
  set page(numbering: "1", number-align: center)
  set heading(numbering: "1.1")
  counter(page).update(1)
  set par(justify: true)
  set text(hyphenate: false)

  // ---- CUSTOM HEADINGS
  show heading.where(level: 1): it => custom-heading(it)

  //---- CUSTOM FOOTER ----
  set page(footer: context{
    if calc.rem(here().page(), 2) == 0 [           // even pages
      #text(current-h(level: 1)) #h(1fr) #counter(page).display() 
    ] else [                                       //odd pages
      #counter(page).display() #h(1fr) #text(current-h(level: 1))
    ]
  })

  // BODY
  body

  // ---- LAST PAGE ----
  show: last-page.with(
    department: department,
    university: university,
    address-i: address-i,
    address-ii: address-ii,
    departmentwebsite: departmentwebsite,
    background-color: background-color
  )
}