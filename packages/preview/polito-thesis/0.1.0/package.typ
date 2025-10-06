#import "@preview/hydra:0.6.2": hydra
#let need-fix = it => text(it, fill: red, weight: "bold")

#let polito-thesis(
  title: need-fix("Your thesis title"),
  subtitle: none,
  student-name: need-fix("Mark Reds"),
  student-gender: none,
  lang: "en",
  degree-name: need-fix("Your degree name"),
  academic-year: need-fix("20xx/20xx"),
  graduation-session: need-fix("month year"),
  supervisors: (need-fix("Mary Whites"),),
  for-print: false,
  doc,
) = {
  // Set and show rules from before.
  set text(lang: lang)
  
  set align(center)
  v(6em)
  image("polito.png", width: 60%)
  v(2em)
  text(25pt, "Politecnico di Torino", weight: "medium")
  let academic-year-str = "A.a."
  if lang == "en" {
    academic-year-str = "A.y."
  }
  [
    
    #set text(size: 14pt)
    #degree-name
    
    #academic-year-str #academic-year
    
    #let session-str = "Sessione di laurea"
    #if lang == "en" {
      session-str = "Graduation session"
    }
    #session-str: #graduation-session
  
  ]
  v(4em)
  
  // Title
  box(
    width: 90%,
    text(title, size: 20pt, weight: "bold"),
  )
  v(0.5em)
  text(subtitle, size: 14pt, weight: "medium")
  
  
  // Relatore IT
  let supervisor-str = "Relator"
  if supervisors.len() == 1 {
    supervisor-str += "e"
  } else {
    supervisor-str += "i"
  }
  // Supervisor EN
  if lang == "en" {
    supervisor-str = "Supervisor"
    if supervisors.len() > 1 {
      supervisor-str += "s"
    }
  }
  
  // Candidato IT
  let student-str = "Candidat"
  if (student-gender == "m") {
    student-str += "o"
  } else if (student-gender == "f") {
    student-str += "a"
  } else {
    student-str += "ə "
  }
  // Candidate EN
  if lang == "en" {
    student-str = "Candidate"
  }
  
  v(3em)
  // Section for candidate and supervisors (two columns)
  box(
    columns(2, gutter: 10em, [
      #set align(left)
      #text(supervisor-str + ":", weight: "bold")
      #set align(right)
      #{
        for sup in supervisors {
          [#sup \ ]
        }
      }
      
      
      #colbreak()
      #set align(left)
      #text(student-str + ":", weight: "bold")
      #set align(right)
      #student-name
      
    
    ]),
    width: 80%,
  )
  
  pagebreak()
  pagebreak()
  set align(left)
  
  // Outline
  [
    #show heading: set text(size: 2em)
    #outline()
  ]
  pagebreak()
  
  let x-margin = 8em
  let y-margin = 12em
  // If for-print == true we increase the left margin of the page
  let l-margin = x-margin
  if for-print {
    l-margin = 10em
  }
  set page(paper: "a4", margin: (y: y-margin, left: l-margin, right: x-margin), numbering: "1", header: context {
    if calc.odd(here().page()) {
      align(right, emph(hydra(1)))
    } else {
      align(left, emph(hydra(2)))
    }
    line(length: 100%)
  })
  set heading(numbering: "1.1")
  set par(justify: true)
  
  // Main heading
  set heading(numbering: "1.")
  show heading.where(level: 1): set heading(supplement: if lang == "en" { [Chapter] } else { [Capitolo] })
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    [
      #set text(size: 28pt)
      #it.supplement #it.numbering
    ]
    set text(size: 30pt)
    v(0em)
    it.body
    v(0em)
  }
  
  show heading.where(level: 2): it => {
    set text(size: 18pt)
    it
  }
  
  set text(size: 12pt)
  
  doc
}

