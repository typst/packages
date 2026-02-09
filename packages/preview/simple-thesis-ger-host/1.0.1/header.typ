// ===== Imports (package responsibility)
#import "@preview/glossarium:0.5.10":  make-glossary,  register-glossary,  print-glossary,  gls,  glspl
#import "template/chapter/glossar.typ":entry-list

// ===== Layout Config and glossary setup
  // import "header" everything what is defined globally, except glossarium because its not working than (print-glossary funktion is missing)

//======== Glossary printing in main dokument
#let show-glossary(body) = {
  print-glossary(entry-list)  
  body
}

//=========== Thesis Title Page setup
#let thesis-layout(  
  thesis-title: [],
  subject: [],
  author: [],
  street: [], 
  city: [],  
  examiner-first: [], 
  examiner-second: [], 
  company: [], 
  degree: [],
  faculty: [], 
  body
)= {
  set text(lang: "de")
  set page(paper: "a4")
  set par(justify: true)
  set page(  margin: (top: 0cm, bottom: 0cm, left: 0cm, right: 0cm ))
  register-glossary(entry-list)
  show: make-glossary

  align(center)[
    #v(1cm)  // Vertikal zentrieren (oben)

    // ---------- Logo ----------
    #image("template/dat/HOSTLogo.png", width: 8cm)
    #v(0.5cm)

    // ---------- Hauptblock (zentriert, schmale Spalte) ----------
    #block(width: 75%)[
      #align(center)[
        #text(size: 16pt, weight: "bold")[#degree]
        #v(0.5cm)
        #text(size: 12pt, weight: "bold")[#subject]
        #v(0.5cm)

        // Linie
        //#hline()
        #v(0.2cm)

        // ---------- Titel ----------
        #line(length: 100%)
        #text(size: 24pt, weight: "bold")[#thesis-title]
        #line(length: 100%)
        #v(0.2cm)

        // Linie
        //#hline()
        #v(0.5cm)

        #text(size: 11pt)[von]
        #text(size: 12pt, weight: "bold")[#author]
      ]
    ]
  ]
    v(2cm)

    block(width: 100%)[
    #set align(center)
    

    #table(
      columns: (auto, auto),
      stroke: none,
      align: (left),
        [Erstprüfer:], [#examiner-first],
        [Zweitprüfer:], [#examiner-second],
        [durchgeführt in der:], [#faculty],
        [durchgeführt für:], [#company],
        [Verfasser:], [#author],
        [], [#street],
        [], [#city],

        [Arbeit vorgelegt am:], [#datetime.today().display("[year]-[month]-[day]")],
      
    )

    #v(1fr)  // Vertikal zentrieren (unten)
  ]
  set page(margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 2.5cm))
  pagebreak()
  set heading(numbering: "1.")
  set page(numbering: "I")
  outline(title: "Inhaltsverzeichnis ")
  outline( title: "Abbildungsverzeichnis", target: figure.where(kind: image))
  set page(numbering: "1")
  counter(page).update(1)
 body
}