// Original frontpage design by Fernando Herrera (ferherre@broadpark.no), made
// in LaTeX originaly, converted to Typst by Augustin Winther (https://winther.io).

// TEMPLATE FUNCTION
#let report(
  task-no: none,
  task-name: none,
  authors: none,
  mails: none,
  group: none,
  date: none,
  supervisor: none,
  body
) = {
  
  // DOCUMENT METADATA
  set document(title: [PHYS114 - Laboppgave #task-no - Gruppe #group], 
               author: authors.map(author => author),
               date: datetime.today())
             
  // DOCUMENT LANGUAGE
  set text(lang: "nb")
  
  // CREATE MAIL LINK ARRAY
  let mail-links = mails.map(mail => link("mailto:" + mail))
  
  // DOCUMENT FONTS
  set text(font: "STIX Two Text", size: 12pt)
  show math.equation: set text(font: "STIX Two Math")
  
  // FRONT PAGE
  set page(paper: "a4", margin: (left: 27mm, right: 20mm, top: 20mm, bottom:30mm))
  
  v(10mm)
  line(length: 16cm, stroke: 0.1cm)
  v(2mm)
  h(5mm) 
  text(size: 48pt, weight: "bold", "PHYS114") 
  h(45mm) 
  box(image("media/uib-emblem.svg", width: 20%, fit: "contain"), baseline: 18mm)
  v(-12mm)
  line(length: 11cm, stroke: 0.1cm)
  v(12mm)
  h(5mm) 
  box(text(size: 36pt, [*Grunnleggende målevitenskap og eksperimentalfysikk*]))
  v(12mm)
  align(center, text(size: 20pt, [*Laboratorierapport*]))
  
  table(
    columns: 2,
    stroke: none,
    align: left,
    row-gutter: 4mm,
    [*Lab.oppgave:*],                [#task-no: #task-name],
    [*Navn (alle i lab.gruppen):*],  [#authors.join(", ")],
    [*Epost (alle i lab.gruppen):*], [#mail-links.join(" ")],
    [*Lab.gruppe\#:*],               [#group],
    [*Dato utført:*],                [#date],
    [*Veileder:*],                   [#supervisor],
    [*Godkjent:*],                   []
  )
  
  line(length: 16cm, stroke: 0.1cm)
  v(4mm)
  h(5mm)
  text(size: 18pt, [*Institutt for fysikk og teknologi*])
  linebreak()
  h(5mm)
  text(size: 18pt, [*Det matematisk-naturvitenskapelige fakultet*])
  pagebreak()
  
  // PAGE SETUP FOR REST OF DOCUMENT
  set page(
    paper: "a4",
    margin: (left: 27mm, right: 20mm, top: 20mm, bottom:30mm),
    numbering: "1",
    header: align(center, text(size: 10pt, [PHYS114 - Laboppgave #task-no - Gruppe #group])),
  )
  counter(page).update(1) // Skip first page in numbering
  
  // PARAGRAPH SETUP
  set par(justify: true,)
  show par: set block(spacing: 0.65em)
  show par: it => {
    it
    v(15pt, weak: true)
  }
  
  // HEADING SETUP
  set heading(numbering: "1.1.1 -")
  show heading: it => {
    v(5mm)
    text(weight: "semibold", it)
    v(2mm)
  }
  
  // LIST SETUP
  set enum(indent: 10pt, body-indent: 9pt)
  set list(indent: 10pt, body-indent: 9pt)
  
  // EQUATION SETUP
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 0.65em)
  
  // FIGURE SETUP
  show figure: it => {
    align(center, 
    if it.kind == image or it.kind == raw {
      it.body
      v(-6pt)
      text(10pt, [*#it.supplement #it.counter.display(it.numbering)*: _ #it.caption.body _])
    } else if it.kind == table {
      text(10pt, [*#it.supplement #it.counter.display(it.numbering)*: _ #it.caption.body _])
      v(-6pt)
      it.body
    })
  v(15pt, weak: true)
  }
  
  // TABLE SETUP
  set table(fill: (_, row) => if row == 0 { luma(220) } else { white })
  show table: it => {
    set par(justify: false,)
    set align(center)
    it
  }

  // LINK SETUP
  show link: it => {
      text(fill: rgb("#00F"), it)
  }
  
  // REFERENCE SETUP
  show ref: it => {
      text(fill: rgb("#00F"), it)
  }

  // FOOTNOTE SETUP
  show footnote: it => {
      text(fill: rgb("#00F"), it)
  }
  
  // OUTLINE SETUP
  set outline(indent: auto, depth: 2)
  show outline.entry: it => {
    
    let heading = it.element

    // Adds "Appendiks " prefix to level 1 chapters if it is an appendix
    // and overwrites link color to black from blue.
    if heading.level == 1 {    
      v(12pt, weak: true)
      
      if heading.supplement == [Appendiks] {
        link(heading.location(), text(fill: rgb("#000"), 
            [*Appendiks #it.body #box(width: 1fr,  it.fill) #it.page*]))
      } else {
        link(heading.location(), text(fill: rgb("#000"),
            [*#it.body #box(width: 1fr,  it.fill) #it.page*]))
      }
    }
    
    // Do not show appendiks level 2 in outline, replace with vertical space. 
    // Show other level 2 chapters tho.
    if heading.level == 2 {
      if heading.supplement == [Appendiks] {
        v(-38pt)
      } else {
        it
      }
    }
  }
  
  // BIBLIOGRAPHY SETUP
  set bibliography(title: "Referanser")
  
  // DISPLAY CONTENT
  body
}

// APPENDIX FUNCTION
#let appendices(body) = {
  
  // Reset heading counter as appendicies uses own number system
  counter(heading).update(0)
  
  set heading(numbering: "A.1 -", supplement: "Appendiks")
  show heading: it => {
    v(19pt)
    if it.level == 1 {
      text(weight: "semibold")[Appendiks #counter(heading).display() #it.body]
    }
    else {
      text(weight: "semibold")[#counter(heading).display() #it.body]
    }
  }

  // Include content
  body
}
