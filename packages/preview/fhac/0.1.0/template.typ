// Workaround for the lack of an `std` scope.
#let std-bibliography = bibliography

#let size = (
  xsm: 6pt,
  sm: 12pt,
  md: 16pt,
  lg: 24pt,
  xl: 32pt,
  xxl: 48pt
)

#let i18n = (
  de: (
    submittedBy: "Eingereicht von",
    studentId: "Matrikelnummer",
    date: "Datum",
    examiner: "Prüfer",
    toObtainDegree: "Zur Erlangung des akademischen Grades",
    disclaimerLabel: "Erklärung", 
    disclaimerText: "Hiermit versichere ich, dass ich die vorliegende Arbeit selbstständig verfasst und keine anderen als die im Literaturverzeichnis angegebenen Quellen benutzt habe. Stellen, die wörtlich oder sinngemäß aus veröffentlichten oder noch nicht veröffentlichten Quellen entnommen sind, sind als solche kenntlich gemacht. Die Zeichnungen oder Abbildungen in dieser Arbeit sind von mir selbst erstellt worden oder mit einem entsprechenden Nachweis versehen. Diese Arbeit ist in gleicher oder ähnlicher Form noch bei keiner anderen Prüfungsbehörde eingereicht worden."
  ),
  en: (
    submittedBy: "Submitted by",
    studentId: "Matriculation number",
    date: "Date",
    examiner: "Examiner",
    toObtainDegree: "To obtain the academic degree",
    disclaimerLabel: "I confirm that this is my own work and I have documented all sources and material used. ", 
    disclaimerText: "I confirm that this is my own work and I have documented all sources and material used."
  ),
)

#let getLanguage(lang: "en", key: "") = {
  if(lang in i18n){
    if(key in i18n.at(lang)){
      return [#i18n.at(lang).at(key)]
    }else{
      return [#key]
    }
  }else{
    return [#key]
  }
}

#let signatureBox(body) = {
    [
      #line(length: 100%) 
      #align(center)[#body]
    ]
}

#let CoverPage(title, faculty, field, degree, submittedBy, date, examiner, t) = {
  align(center, [
    #{
      place(top + right, dx: 96pt, dy: -32pt)[#image("img/logo.png", height: 128pt)]
      v(96pt)
      text(size: size.lg)[FH Aachen]
      v(size.xsm)
      text(size: size.md)[#faculty]
      v(50pt)
      text(size: size.xl)[Master Thesis]
      v(size.xsm)
      [#t(key: "toObtainDegree") \ #field ]
      v(size.xxl)
      text(size.md, weight: "semibold")[#title]
      v(size.xxl)
      v(size.xxl)
      
      let grid2x2 = grid.with(
        columns: 2, 
        column-gutter: size.sm, 
        align: start, 
        row-gutter: size.xsm
      )
      
      grid2x2(
        [#t(key: "submittedBy"):], [#submittedBy.name], 
        [#t(key: "studentId"):], [ #submittedBy.id]
      )

      v(size.xl)
      grid2x2([#t(key: "date"):], [#date])
      v(size.xl)

      grid2x2(..examiner.map(val => ([#t(key: "examiner"):], [#val])).flatten())
    }
  ])
}

#let template(
  title: [Title],
  faculty: [Faculty],
  field: [Field of study],
  degree: [Bachelor's Thesis or Master's Thesis],
  submittedBy: (),
  date: none,
  examiner: (),
  paper-size: "a4",
  language: "en",
  bibliography: none,
  body
) = {
  let t = getLanguage.with(lang: language)
  set document(title: title, author: submittedBy.name)
  set text(font: "STIX Two Text", size: 12pt)

  [#CoverPage(title, faculty, field, degree, submittedBy, date, examiner, t)]

  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 0.65em)

  // Configure appearance of equation references
  show ref: it => {
    if it.element != none and it.element.func() == math.equation {
      // Override equation references.
      link(it.element.location(), numbering(
        it.element.numbering,
        ..counter(math.equation).at(it.element.location())
      ))
    } else {
      // Other references as usual.
      it
    }
  }

  // Configure lists.
  set enum(indent: 10pt, body-indent: 9pt)
  set list(indent: 10pt, body-indent: 9pt)

  // Configure headings.
  set heading(numbering: "1.1.1")
  
  set page(
    paper: paper-size,
    numbering:none,
    number-align: right,
    binding:left,
  )
  show outline.entry.where(level: 1): it => {
    v(12pt, weak: true)
    strong(it) 
  }
  
  
  
  

  pagebreak()
  pagebreak()

  outline(indent: auto)

  pagebreak()
  place(bottom, dy: -40pt)[
    #heading(numbering: none, level: 1, [#t(key: "disclaimerLabel")])
    #t(key: "disclaimerText")
    #v(10%)
    #grid(
      columns: (1fr, 1fr), 
      rows: 1, 
      gutter: 30%,
      [#signatureBox()[#date]], 
      [#signatureBox()[#submittedBy.name]]
      )
  ]
 

  pagebreak()

  

  counter(page).update(1)

  body

}