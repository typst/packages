#let titlepage(
  title: [],
  author: [],
  course: [],
  mat-number: [],
  course-acronym: [],
  start-date: datetime,
  end-date: datetime,
  company-location: [],
  project: [],
  project-type: [],
  supervisor: [],
  university-supervisor: [],
  company: [],
  university: [],
  company-logo: [],
  university-logo: [],
  text-lang: []
) = {

  let cover(source) = {
    set image(width: 6cm)
    source
  }

  set text(size: 14pt)
  if text-lang == "en" { 
    v(-1cm)

    align(top,
      block(
        width: 100%,
        inset: (x: -1cm))[
          #stack(
          dir: ltr,
          if company-logo != [] {
            align(left, cover(company-logo))
          },
          align(right, cover(university-logo)),
        )
      ]
    )

    v(6em)

    set align(center)
    
    par(leading: 1em, text(20pt)[*#title*])
    
    v(4em)

    text(size: 16pt)[#project-type (#project)]

    v(2em)

    [of Degree Course #course \ at #university]

    v(4em) 

    [by \ #author]

    v(2em)
    end-date

    v(2em)

    set rect(width: 100%, inset: 0.5em)

    let parsed = ()

    if supervisor != [] {
      parsed.push([Company Supervisor])
      parsed.push(supervisor)
    }

    if university-supervisor != [] {
      parsed.push([University Supervisor])
      parsed.push(university-supervisor)
    }

    align(left,
      grid(
        columns: (1fr, 1fr),
        align: left,
        inset: 0.5em,
        [
          Completion Period
        ],[
          #start-date - #end-date 
        ],[
           Student ID, Course
        ],[
          #mat-number, #course-acronym
        ],[
          Cooperation Partner
        ],[
          #par(justify: true)[#company, #company-location]
        ], ..parsed
      )
    )
  }
  else {
    v(-1cm)

    align(top,
      block(
        width: 100%,
        inset: (x: -1cm))[
          #stack(
          dir: ltr,
          if company-logo != [] {
            align(left, cover(company-logo))
          },
          align(right, cover(university-logo)),
        )
      ]
    )


    v(6em)

    set align(center)
    
    par(leading: 1em, text(20pt)[*#title*])
    
    v(4em)

    text(size: 16pt)[#project-type (#project)]

    v(2em)

    [Des Studienganges #course \ an der #university]

    v(4em) 

    [von \ #author]

    v(2em)
    end-date

    v(2em)

    set rect(width: 100%, inset: 0.5em)

    let parsed = ()

    if supervisor != [] {
      parsed.push([Betreuer der Ausbildungsfirma])
      parsed.push(supervisor)
    }

    if university-supervisor != [] {
      parsed.push([Gutachter der DHBW])
      parsed.push(university-supervisor)
    }

    align(left,
      grid(
        columns: (1fr, 1fr),
        align: left,
        inset: 0.5em,
        [
          Bearbeitungszeitraum
        ],[
          #start-date - #end-date 
        ],[
          Matrikelnummer, Kurs
        ],[
          #mat-number, #course-acronym
        ],[
          Dualer Partner
        ],[
          #par(justify: true)[#company, #company-location]
        ], ..parsed
      )
    )
  }
}
