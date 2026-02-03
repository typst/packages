//Imports
  #import "../header.typ": thesis // import "header" everything what is defined globally, except glossarium because its not working than (print-glossary funktion is missing)
  #import "@preview/glossarium:0.5.10":  make-glossary,  register-glossary,  print-glossary,  gls,  glspl
  #import "./chapter/glossar.typ": entry-list
// Glossary setup
  #register-glossary(entry-list)
  #show: make-glossary

// ====================
// Deckblatt
// ====================
  #include "./chapter/TitlePage.typ"

  #set page(margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 2.5cm))


// Inhaltsverzeichnis
  #pagebreak()
  #set heading(numbering: "1.")
  #set page(numbering: "I")
  #outline(title: "Inhaltsverzeichnis ")
   
  #outline( title: "Abbildungsverzeichnis", target: figure.where(kind: image))

//Start Real Numbering 
  #set page(numbering: "1")
  #counter(page).update(1)
  #include "./chapter/vorwort.typ"
  = Chapter 1
  #lorem(20) @host #lorem(60) @hostWebsite #lorem(800)
  = Chapter 2
  #lorem(20) @host #lorem(60) @hostWebsite #lorem(80) @hostWebsite #lorem(200)
  = Chapter 3 
   #lorem(500)
//Glossar
  #pagebreak()
  = Glossar
  #print-glossary(entry-list)
//Quellen
  = Quellenverzeichniss
  #bibliography("Bib/Abschlussarbeit.bib", title: none)
//Anhang
  = Anhang

 

 

