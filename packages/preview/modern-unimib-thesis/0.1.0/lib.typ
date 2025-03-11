#let template(
  title: [Thesis title],
  candidate: (),
  supervisor: (),
  co-supervisor: (),
  department: (),
  university: (),
  school: (),
  course:(),
  date: (),
  logo: none,
  lang: "en",
  body
) = {
  // Language dictionary
  let translations = (
    "en": (
      "contents": "Contents",
      "bibliography": "Bibliography",
      "acknowledgments": "Acknowledgments",
      "chapter": "Chapter",
      "supervisor": "Supervisor",
      "co-supervisor": "Co-Supervisor",
      "candidate": "Candidate",
      "matriculation_number": "Matriculation number",
      "academic_year": "Academic year"
    ),
    "it": (
      "contents": "Indice",
      "bibliography": "Bibliografia",
      "acknowledgments": "Ringraziamenti",
      "chapter": "Capitolo",
      "supervisor": "Relatore",
      "co-supervisor": "Correlatore",
      "candidate": "Candidato",
      "matriculation_number": "Numero di matricola",
      "academic_year": "Anno accademico"
    )
  )
  
  // Get translation dictionary for selected language, default to English
  let t = if lang in translations { translations.at(lang) } else { translations.at("en") }
  
  set document(title: title, author: candidate.name)
  show link: underline
  set text(size: 13pt, lang: lang)
  set math.equation(numbering: "(1)")
  set heading(numbering: "1.1.1")
  show heading.where(level: 1): item => {
    if item.body == [#t.contents] {
      item
    } else if item.body == [#t.bibliography] or item.body == [#t.acknowledgments] {
      pagebreak()
      block(width: 100%, height: 20%)[
        #set align(left + horizon)
        #set text(1.3em, weight: "bold")
        #text([#item.body])
      ]
    } else {
      pagebreak()
      block(width: 100%, height: 20%)[
            #set align(left + horizon)
            #set text(1.3em, weight: "bold")
            #text([#t.chapter #counter(heading).display() \ #item.body])
          ]
    }
  }

  show outline.entry: it => {
    if it.element.body == [#t.acknowledgments] or it.element.body == [#t.bibliography] {
      []
    } else {
      it
    }
  }
  
  align(center, block[
    #text(smallcaps(university), stretch: 142%) \
    *#school* \
    *#department* \
    *#course* \
  ])

  v(40pt)
  if logo != none {
    align(center, logo)
  }

  v(40pt)
  align(center, text(size: 20pt, title, weight: "bold"))

  v(40pt)
  text([*#t.supervisor*: \ #supervisor])
  v(20pt)
  text([*#t.co-supervisor*: \ #co-supervisor.map(item => [
          #item
        ]).join(linebreak())])

  align(right, block[
    #text(weight: "bold", [#t.candidate: ]) \
    #candidate.name \
    #text([#t.matriculation_number: #candidate.number]) \
  ])

  align(center + bottom, text(weight: "bold", [#t.academic_year: #date]))
  pagebreak()
  outline()
  pagebreak()
  
  set page(header: context {
    let page = counter(page).get().first()
    align(if calc.odd(page) { right } else { left })[#page]
  })
  body

  pagebreak()
  bibliography("refs.bib")
}