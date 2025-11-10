#let cover(
  title: none,
  subtitle: none, 
  subject: none, 
  author: (),
  tutors: (),
  abstract: [],
  logo-company: none,
  logo-school: none,
  logo-company-header: none,
  logo-school-header: none,
  doc,
) = {


  set text(lang: "FR")
  set heading(numbering: "I.1.1.1")
  // Espacement des paragraphes
  set par(spacing: 1.2em)
  
  // Espacement spécifique pour les titres de niveau 1
  show heading.where(level: 1): set block(above: 3em, below: 1.8em)
  
  // Espacement pour les sous-titres (niveau 2 et plus)
  show heading.where(level: 2): set block(above: 2em, below: 1.5em)
  show heading.where(level: 3): set block(above: 1.5em, below: 1.2em)
  show heading.where(level: 4): set block(above: 1.2em, below: 1em)

  set align(center)
  
  set page(paper: "a4")

  grid(
    columns: (30%,110%),
    row-gutter: 24pt,
    logo-school,
    logo-company,
  )
  v(0.2fr)
  text(26pt, title)
  v(0.05fr)
  text(16pt, [#author.name - #author.job])
   v(0.02fr)
   
  text(10pt,[
    #author.date \
    #author.email
  ])
   
  v(0.2fr)
  

  v(0.1pt)
  text(14pt, subject)
   v(0.4fr)


  set align(left)

  let count = tutors.len()
  let ncols = calc.min(count, 3)
  grid(
    columns: (70%,) * ncols,
    row-gutter: 24pt,
    ..tutors.map(tutor => [
      #tutor.name \
      #tutor.affiliation \
      #link("mailto:" + tutor.email)
    ]),
  )


  pagebreak()

  set page(
    numbering: "1/1",
    number-align: right,
    margin: 100pt,
    header: pad( 
      left: -50pt,   // Réduire la marge gauche
      right: -50pt
    )[
        #grid(
          columns: (1fr, 1fr),
          align: (left, right),
          logo-school-header,
          logo-company-header,
      )],

    footer: pad(
      left: -50pt,   // Même réduction de marge
      right: -50pt,
    )[#context[
      #align(right, [#counter(page).display("1/1", both: true)])
    ]
    ]
    
  )
  doc
}
