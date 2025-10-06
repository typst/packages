#import "@preview/hydra:0.6.2": hydra
#let need_fix = it => text(it, fill: red, weight: "bold")

#let polito_thesis(
  title: need_fix("Your thesis title"),
  subtitle: none,
  student_name: need_fix("Mark Reds"),
  student_gender: none,
  lang: "en",
  degree_name: need_fix("Your degree name"),
  academic_year: need_fix("20xx/20xx"),
  graduation_session: need_fix("month year"),
  supervisors: (need_fix("Mary Whites"),),
  for_print: false,
  doc,
) = {
  // Set and show rules from before.
  set text(lang: lang)
  
  set align(center)
  v(6em)
  image("polito.png", width: 60%)
  v(2em)
  text(25pt, "Politecnico di Torino", weight: "medium")
  let academic_year_str = "A.a."
  if lang == "en" {
    academic_year_str = "A.y."
  }
  [
    
    #set text(size: 14pt)
    #degree_name
    
    #academic_year_str #academic_year
    
    #let session_str = "Sessione di laurea"
    #if lang == "en" {
      session_str = "Graduation session"
    }
    #session_str: #graduation_session
  
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
  let supervisor_str = "Relator"
  if supervisors.len() == 1 {
    supervisor_str += "e"
  } else {
    supervisor_str += "i"
  }
  // Supervisor EN
  if lang == "en" {
    supervisor_str = "Supervisor"
    if supervisors.len() > 1 {
      supervisor_str += "s"
    }
  }
  
  // Candidato IT
  let student_str = "Candidat"
  if (student_gender == "m") {
    student_str += "o"
  } else if (student_gender == "f") {
    student_str += "a"
  } else {
    student_str += "ə "
  }
  // Candidate EN
  if lang == "en" {
    student_str = "Candidate"
  }
  
  v(3em)
  // Section for candidate and supervisors (two columns)
  box(
    columns(2, gutter: 10em, [
      #set align(left)
      #text(supervisor_str + ":", weight: "bold")
      #set align(right)
      #{
        for sup in supervisors {
          [#sup \ ]
        }
      }
      
      
      #colbreak()
      #set align(left)
      #text(student_str + ":", weight: "bold")
      #set align(right)
      #student_name
      
    
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
  
  let x_margin = 8em
  let y_margin = 12em
  // If for_print == true we increase the left margin of the page
  let l_margin = x_margin
  if for_print {
    l_margin = 10em
  }
  set page(paper: "a4", margin: (y: y_margin, left: l_margin, right: x_margin), numbering: "1", header: context {
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

