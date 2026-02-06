//Import the header.typ with the layout settings and definitions
// you can make changes to the layout in the header.typ file
#import "@preview/simple-thesis-ger-host:1.0.1": thesis, show-glossary 
// ====================
// Deckblatt & Outline & layout
// ====================
// If you want to change something else on the title page Layout pls do so in the header.typ file
 #show: thesis.with(
    degree: [Abschlussarbeit],
    subject: [Studiengang Elektrotechnik Bachelor],
    title: [Titel der Abschlussarbeit, der viel zu lang ist, sowie sich das für eine Ordentliche Abschlussarbeit, die was aufsich hält, gehört],
    author: [Vorname Nachname],
    street: [Beispiel Straße 15],
    city: [18435 Stralsund],
    firstExaminer: [Prof. Dr. Ing. Beispielname],
    secondExaminer: [Prof. Dr. Zweitprüfer],
    faculty: [Fakultät Elektrotechnik und Informatik],
    company: [Beispiel GmbH],

  )

//==================
//content
//==================
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
  #show: show-glossary
   // Originally here whould be #print-glossary(entry-list), but the glossary is implementet via. header.typ so it changed


//Quellen
  = Quellenverzeichniss
  #bibliography("./bib/Abschlussarbeit.bib", title: none)
//Anhang
  = Anhang

 

 

