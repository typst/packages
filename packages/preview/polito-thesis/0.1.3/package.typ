#import "@preview/hydra:0.6.2": hydra
#let need-fix = it => text(it, fill: red, weight: "bold")

#let polito-blue = rgb("002B49")
#let polito-black = rgb("000000")
#let polito-orange = rgb("#EF7B00")

#let polito-thesis(
  title: need-fix("Your thesis title"),
  subtitle: none,
  student-name: need-fix("Student Name"),
  student-gender: none,
  lang: "en",
  degree-name: need-fix("Your degree name"),
  academic-year: need-fix("20xx/20xx"),
  graduation-session: need-fix("month year"),
  supervisors: (need-fix("Name Surname"),),
  for-print: false,
  cover-font: "Century Gothic",
  text-font: "Libertinus Serif",
  heading-font: "Century Gothic",
  bibliography: none,
  custom-outline: none,
  appendix: none,
  doc,
) = {
  // Set and show rules from before.
  set text(lang: lang, font: cover-font)

  set align(center)
  image("polito.png", width: 75mm)
  v(10mm)
  text(20pt, "Politecnico di Torino", weight: "medium")
  v(3mm)
  let academic-year-str = "A.a."
  if lang == "en" {
    academic-year-str = "A.y."
  }
  [

    #set text(size: 14pt)
    #if degree-name != none {
      degree-name
    }

    #if academic-year != none {
      [#academic-year-str #academic-year]
    }

    #let session-str = "Sessione di laurea"
    #if lang == "en" {
      session-str = "Graduation session"
    }
    #if graduation-session != none {
      [#session-str: #graduation-session]
    }

  ]
  v(40mm)

  // Title
  box(
    width: 90%,
    text(title, size: 24pt, weight: "bold", fill: polito-blue),
  )
  v(2mm)
  text(subtitle, size: 14pt, weight: "medium")


  // Relatore IT
  let supervisor-str = "Relator"
  if supervisors != none and supervisors.len() == 1 {
    supervisor-str += "e"
  } else {
    supervisor-str += "i"
  }
  // Supervisor EN
  if lang == "en" {
    supervisor-str = "Supervisor"
    if supervisors != none and supervisors.len() > 1 {
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

  // Section for candidate and supervisors (two columns)
  [
    #set align(bottom)
    #box(
      columns(2, gutter: 0em, [
        #if supervisors != none {
          set align(left)
          move(
            dx: -15mm,
            text(supervisor-str + ":"),
          )
          move(
            dx: 10mm,
            {
              for sup in supervisors {
                [#sup #v(0.2em)]
              }
            },
          )
        }


        #colbreak()
        #if student-name != none {
          set align(left)
          move(dx: 15mm, text(student-str + ":"))
          move(
            dx: 40mm,
            student-name,
          )
        }


      ]),
      width: 80%,
    )
  ]

  pagebreak()
  pagebreak()
  set align(left)


  // FONTS
  set text(font: text-font, size: 12pt)
  show heading: set text(font: heading-font)

  // Outline
  if custom-outline == none {
    [
      #show heading: set text(size: 2em)
      #outline()
    ]
  } else {
    custom-outline
  }
  pagebreak()

  let x-margin = 8em
  let y-margin = 12em
  // If for-print == true we increase the left margin of the page
  let l-margin = x-margin
  if for-print {
    l-margin = 10em
  }

  // PAGE MARGINS
  set page(paper: "a4", margin: (y: y-margin, left: l-margin, right: x-margin), numbering: "1", header: context {
    if calc.odd(here().page()) {
      align(right, emph(hydra(1)))
    } else {
      align(left, emph(hydra(2)))
    }
    line(length: 100%)
  })


  set par(justify: true)

  set heading(numbering: "1.")
  show heading.where(level: 1): set heading(
    supplement: if lang == "en" { [Chapter] } else { [Capitolo] },
  )

  // show heading.where(level: 1): it => {
  //   pagebreak(weak: true)
  //   [
  //     #set text(size: 28pt)
  //     #it.supplement #counter(heading).display("1")
  //   ]
  //   set text(size: 30pt)
  //   it.body
  // }

  show heading.where(level: 2): it => {
    set text(size: 18pt)
    it
  }
  {
    show heading.where(level: 1): it => {
      pagebreak(weak: true)
      pad(
        bottom: 1em,
        block(
          [
            #set text(size: 28pt)
            #set par(spacing: 0.5em, first-line-indent: 0em, justify: false)
            #it.supplement #counter(heading).display("1")

            #set text(size: 30pt)
            #h(0.7em) #it.body
          ],
        ),
      )
    }
    doc
  }

  if appendix != none {
    let appendix-supplement = if lang == "it" { [Appendice] } else { [Appendix] }
    // outline(target: heading.where(supplement: appendix-supplement), title: appendix-supplement)
    // {
    //   show heading.where(level: 1): it => {
    //     // pagebreak(weak: true)
    //     set text(size: 30pt)

    //     it.body
    //   }
    //   heading([#appendix-supplement])
    // }

    counter(heading).update(0)
    show heading.where(level: 1): it => {
      pagebreak(weak: true)
      set text(size: 30pt)
      it.body
      v(0.1em)
    }
    set heading(numbering: "A.1", supplement: appendix-supplement)
    set math.equation(numbering: (..nums) => {
      let section = counter(heading).get().first()
      numbering("(A.1)", section, ..nums)
    })

    appendix
  }

  {
    show heading.where(level: 1): it => {
      pagebreak(weak: true)
      set text(size: 30pt)
      it.body
    }
    bibliography
  }
}

#let opinionated-polito-style(body) = {
  // Reset equation numbering at each chapter
  set math.equation(numbering: (..nums) => {
    let section = counter(heading).get().first()
    numbering("(1.1)", section, ..nums)
  })
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    it
  }

  // References are converted to lower case
  // #show ref: it => {
  //   let eq = math.equation
  //   let el = it.element
  //   // Skip all other references.
  //   if el == none { return it }
  //   // Override references.
  //   lower(it)
  // }

  set cite(form: "normal")

  // Indent first line of a paragraph and add spacing before
  set par(
    first-line-indent: (amount: 1em, all: true),
    spacing: 0.8em,
    justify: true,
  )

  // Add spacing around level 4 headings and remove numbering
  show heading.where(level: 4): it => {
    block(
      [
        // #v(0.6em)
        #set text(size: 0.9em)
        #pad(it.body, top: 0.6em, bottom: 0.3em)
        // #v(0.3em)
      ],
    )
  }

  set figure(placement: auto)


  body
}
