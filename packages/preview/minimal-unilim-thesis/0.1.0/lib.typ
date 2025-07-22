

#let cover(
  color,
  lang,
  data
) = {

let degree = data.at(5).degree
let name-degree = data.at(6).name-degree
let degree-description = data.at(7).degree-description
let student = data.at(8).student
let author = data.at(9).author
let date = data.at(10).date
let thesis-title = data.at(11).thesis-title
let organization = data.at(12).organization
let supervisors = data.at(13).supervisors
let fac-supervisors = data.at(14).fac-supervisors

block(
    spacing: 0pt,
    inset: 20pt,
    fill: color,
    [
      #grid(
        columns: ( auto, auto),
        gutter: 1fr,
        block(spacing: 0pt,
            inset: 10pt,
          )[
              #text(
                font: "Arial",
                weight: "bold",
                fill: rgb("#FFFFFF"),
                size: 20pt,
                [
                  #if lang=="fr" {
                    [Mémoire de #degree]
                  }else{
                    [#degree thesis]
                  }
                ]
              )
            ], 
      image("resources/logo.svg", width: 100pt)
      )        
    ]
    )
  v(5%)
  text(
    font: "Arial",
    weight: "bold",
    fill: rgb("#4B575F"),
    size: 16pt
  )[
    #if lang=="fr" {
      [Université de Limoges - #name-degree]
    }else{
      [University of Limoges - #name-degree]
    }
  ]
    
  v(1%)
  text(
    font: "Arial",
    fill: rgb("#4B575F"),
    size: 12pt
  )[
    #if lang=="fr" {
      [Mémoire pour l'obtention du grade de #degree]
    }else{
      [Thesis submitted in partial fulfillment of the requirements for the degree of #degree ]
    }
    #linebreak()
  ]
    
    

  upper(text(
    font: "Arial",
    fill: rgb("#4B575F"),
    size: 12pt,
  )[#degree-description])
  v(3%)
  text(
    font: "Arial",weight: "bold",
    fill: rgb("#4B575F"),
    size: 12pt,
  )[
    #if lang=="fr" {
      if student=="W"{
        [Présentée et soutenue par]
      }
      if student=="M"{
        [Présenté et soutenu par]
      }
      if student!="M" and student!="W"{
        [Présenté.e et soutenu.e par]
      }
    }else{
      [Presented and defensed by]
    }
    
    ]

  text(
    font: "Arial",
    
    fill: rgb("#4B575F"),
    size: 14pt,
  )[#author]
  v(1pt)
  text(
    font: "Arial",
    fill: rgb("#4B575F"),
    size: 12pt,
  )[
    #if lang=="fr" {
      [Le #date]
    }else{
      [On #date]
    }
    
    ]
    
  v(8%)
  upper(text(
    font: "Arial",
    weight: "light",
    fill: color,
    size: 16pt,
  )[#thesis-title])
  v(10%)
  text(
    font: "Arial",
    fill: rgb("#4B575F"),
    size: 12pt,
  )[
    #if lang=="fr" {
      [*Etablissement d'accueil* #linebreak()
      #organization]
    }else{
      [*Host organization* #linebreak()
      #organization]
    }
    
    ]
    
    
  v(15pt)
  if(supervisors.len() < 2) {
    text(
    font: "Arial",
    fill: rgb("#4B575F"),
    size: 12pt,
  )[ #if (lang=="fr") {
    [*Encadrant*#linebreak()]
  }else{
    [*Supervisor*#linebreak()]
  }]
  }else{
    text(
    font: "Arial",
    fill: rgb("#4B575F"),
    size: 12pt,
  )[ #if (lang=="fr") {
    [*Encadrants*#linebreak() ]
  }else{
    [*Supervisors*#linebreak()]
  }]
  }
  [
    #for perso in supervisors {
      text(
        font: "Arial",
        fill: rgb("#4B575F"),
        size: 12pt,
      )[#perso.at("name"), #perso.at("function")#linebreak()]
    }
  ]
  v(15pt)
  if(fac-supervisors.len() < 2) {
    text(
    font: "Arial",
    fill: rgb("#4B575F"),
    size: 12pt,
  )[ #if (lang=="fr") {
    [*Encadrant académique*#linebreak()]
  }else{
    [*Faculty Supervisor*#linebreak()]
  }]
    
    
  }else{
    text(
    font: "Arial",
    fill: rgb("#4B575F"),
    size: 12pt,
  )[ #if (lang=="fr") {
    [*Encadrants académique*#linebreak()]
  }else{
    [*Faculty Supervisosr*#linebreak()]
  }]
  }
   [
    #for perso in fac-supervisors {
      text(
        font: "Arial",
        fill: rgb("#4B575F"),
        size: 12pt,
      )[#perso.at("name"), #perso.at("function")#linebreak()]
    }
  ]
  align(right,
 image("./resources/footer-cover.svg", width: 20%)
  )
  
  set page(
    margin: auto,
    footer: context [
      #align(left)[
        #text(
          font: "Arial",
          fill: rgb("#7F7F7F"),
          size: 8pt,
        )[ #if (lang=="fr") {
          [#author | Mémoire de #degree | Université de Limoges #h(1fr)#counter(page).display() ]
        }else{
          [#author | #degree thesis | University of Limoges #h(1fr)#counter(page).display() ]
        }]
        
      ]
    ]
  )
  pagebreak()

}
}


#let epigraphy(
    citation: highlight("The citation text"),
    author: highlight("The author of the citation"),
  )={
    align(
      right
    )[
    #text[#citation]
    #linebreak()
   *#text[#author]*

    ]

}

#let table-of-contents(titre)={
  pagebreak()
  outline(
    title: [
      #text([#titre], size: 14pt, weight: "bold"),
      #line(length: 100%)
    ],
  )
}
#let table-of-figures(titre)={
  pagebreak()
  outline(
    title: [
      #text([#titre], size: 14pt, weight: "bold"),
      #line(length: 100%)
    ],
    target: figure.where(kind: image)
  )
}

#let table-of-tables(titre)={
  pagebreak()
  outline(
    title: [
      #text([#titre], size: 14pt, weight: "bold"),
      #line(length: 100%)
    ],
    target: figure.where(kind: table)
  )
  
}

#let title(my-title)={
  pagebreak(weak: true)
  [= #my-title]
  line(length: 100%)
}

#let pseudocode(
  content,
  caption: highlight("Missing caption"),
  size: 80%
  ) = {
set par(justify: false)
figure(
  block(
    fill: luma(250), 
    radius: 3pt,
    stroke: .6pt + luma(200),
    inset:	(x: .45em, y: .65em),
    width: size,
    clip: false,
  [#align(left)[#content]]),
  caption: [#caption],
  supplement: "Codice",
  kind: "code",
)}

#let def(
  term,
  detail,
  define,  
)={
  [
    *#term* (#detail) : #define
  ]
}

#let unilim-thesis-template(
  data,
  epigra,
  acknow,
  intro,
  my-content,
  conclusion,
  src-biblio,
  glossary,
  appendix,
  body
)={
let faculty = data.at(0).faculty
let lang = data.at(1).lang

let color-tpl = rgb("#B51621")

if upper(faculty)=="FST" {
  color-tpl = rgb("#E85412")
}
if upper(faculty)=="FLSH" {
  color-tpl = rgb("#A2A93F")

}
if upper(faculty)=="FDSE" {
  color-tpl = rgb("#7E388A")

}
cover(color-tpl, lang, data)

pagebreak()

if data.at(4).epigraphy!="N" {
  epigraphy(
    citation: epigra.citation,
    author: epigra.author,
  ) 
}

if lang=="fr" {
  title("Remerciements")
  acknow

  table-of-contents("Table des Matières")
  table-of-figures("Table des Figures")
  table-of-tables("Table des Tableaux")

  title("Introduction")
  intro

  pagebreak(weak: true)
  my-content

  title("Conclusion")
  conclusion

  pagebreak(weak: true)

  if data.at(2).glossary!="N" {
    title("Glossaire")
    glossary
    pagebreak(weak: true)
  }

  title("Références Bibliographiques")
  src-biblio
  if data.at(3).appendix!="N" {
    title("Annexes")
    appendix
  }
} else {
  title("Acknowlegments")
  acknow

  table-of-contents("Table of Contents")
  table-of-figures("List of Figures")
  table-of-tables("List of Tables")

  title("Introduction")
  intro

  pagebreak(weak: true)
  my-content

  title("Conclusion")
  conclusion

  pagebreak(weak: true)

  if data.at(2).glossary!="N" {
    title("Glossary")
    glossary
    pagebreak(weak: true)
  }

  title("Bibliography")
  src-biblio
  
  if data.at(3).appendix!="N" {
    title("Appendix")
    appendix
  }
  }

body
}
