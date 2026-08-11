// ============================================================================
// ENSAM RABAT - Template File (template.typ)
// ============================================================================
// This file contains the template function that formats your document.
// Import this in your main.typ file with: #import "template.typ": *
// ============================================================================

#let project(
  title: "",
  authors: (),
  supervisor: "",
  department: "",
  program: "",
  module: "",
  year: "",
  subtitle: "Rapport de Projet Académique",
  body,
) = {
  
  // Set document properties
  set document(author: authors, title: title)
  
  // Set page configuration
  set page(
    paper: "a4",
    margin: (top: 2.5cm, bottom: 1.5cm, left: 2.5cm, right: 2.5cm),
    footer: context [
      #set align(center)
      #set text(10pt)
      #counter(page).display("1")
    ]
  )
  
  // Set text defaults
  set text(
    font: "New Computer Modern",
    size: 12pt,
    lang: "fr",
  )
  
  // Set paragraph defaults
  set par(justify: true)
  
  // Set heading numbering
  set heading(numbering: "1.1")
  
  // Format chapters
  show heading.where(level: 1): it => {
    if it.numbering != none {
      pagebreak(weak: true)
      v(1.5cm)
      text(size: 16pt, weight: "bold")[
        Chapitre #counter(heading).display() : #it.body
      ]
      v(1cm)
    } else {
      pagebreak(weak: true)
      v(1.5cm)
      text(size: 16pt, weight: "bold")[#it.body]
      v(1cm)
    }
  }
  
  // Configure links
  show link: underline
  
  // ============================================================================
  // TITLE PAGE
  // ============================================================================
  
  align(center)[
    #v(0.5cm)
    
    #grid(
      columns: (1fr, 1fr),
      align: (left, right),
      image("images/logo_um5.png", width: 50%),
      image("images/logo_ensam.png", width: 50%),
    )
    
    #v(1cm)
    
    #text(size: 20pt, weight: "bold")[
      #title
    ]
    
    #v(0.5cm)
    
    #text(size: 16pt)[#subtitle]
    
    #v(1cm)
    
    #grid(
      columns: (1fr, 1fr),
      align: (left, right),
      [
        #text(size: 13pt)[
          _Réalisé par :_\
          #for author in authors [
            *#author*\
          ]
        ]
      ],
      [
        #text(size: 13pt)[
          _Encadré par :_\
          *#supervisor*
        ]
      ]
    )
    
    #v(3cm)
    
    #text(size: 13pt)[
      *Université Mohammed V de Rabat*\
      *École Nationale Supérieure d'Arts et Métiers*\
      *ENSAM RABAT*\
      *Département* : #department\
      *Filière* : #program\
      *Module* : #module\
      \
      *Année Académique* : #year
    ]
    
    #v(0.5cm)
    
    #line(length: 100%, stroke: 0.5pt)
    
    #v(0cm)
    
    #datetime.today().display()
  ]
  

  
  // ============================================================================
  // TABLE OF CONTENTS
  // ============================================================================
  
  outline(
    title: "Table des Matières",
    indent: auto,
  )

  // ============================================================================
  // MAIN BODY
  // ============================================================================
  
  body
}