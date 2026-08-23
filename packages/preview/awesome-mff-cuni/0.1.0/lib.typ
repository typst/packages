#import "@preview/ctheorems:1.1.3": *

#let mff-cuni-thesis(
  doc,
  author: "Author's name",
  thesis-type: "Master",
  
  thesis-title: "Thesis title",
  department: "Department",
  supervisor: "Supervisor",
  study-program: "Study program",
  abstract: "Abstract",
  keywords: "Keywords",
  dedication: "Dedication..",

  thesis-title-cs: "Název práce",
  department-cs: "Katedra",
  study-program-cs: "Studijní program",
  abstract-cs: "Abstrakt",
  keywords-cs: "Klíčová slova",
) = {
  show: thmrules
  set document(
    title: thesis-title,
    author: author,
    keywords: keywords,
    description: abstract,
    date: auto
  )

  show math.equation: set block(breakable: true)

  set par(justify: true)

  align(center)[
    #image("img/logo.svg")

    #v(1fr)
    
    #upper(text(size: 20pt, weight: "bold")[#thesis-type thesis])

    #v(15mm)

    #text(size: 20pt)[#author]
    
    #v(1fr)

    #text(size: 20pt, weight: "bold")[#smallcaps(thesis-title)]

    #v(1fr)

    #department

    #v(1fr)

    Supervisor: #supervisor

    Study program: #study-program

    #v(1fr)

    Prague, #datetime.today().year()
  ]

  pagebreak()

  align(left + bottom)[
    I declare that I carried out this #lower(thesis-type) thesis on my own, and only with the
  cited sources, literature and other professional sources. I understand that my
  work relates to the rights and obligations under the Act No. 121/2000 Sb., the
  Copyright Act, as amended, in particular the fact that the Charles University has
  the right to conclude a license agreement on the use of this work as a school work
  pursuant to Section 60 subsection 1 of the Copyright Act.

    #v(1cm)
      
    In #box(width: 1fr, repeat[.]), date #box(width: 1fr, repeat[.])#h(1fr)#box(width: 1fr, repeat[.])
    #align(right)[
      Author's signature
    ]

    #v(2cm)
  ]

  pagebreak()

  dedication

  pagebreak()

  {
    set par(spacing: 2em)
    
    [Title: #thesis-title

    Author: #author

    Department: #department

    Supervisor: #supervisor, #department

    Abstract: #abstract

    Keywords: #keywords

    #v(1fr)

    Název práce: #thesis-title-cs

    Autor: #author

    Katedra: #department-cs

    Vedoucí práce: #supervisor, #department-cs

    Abstrakt: #abstract-cs

    Klíčová slova: #keywords-cs
    
    #v(1fr)]
  }

  set page(numbering: "— 1 —")
  set heading(numbering: "I.1")

  show heading: smallcaps
  show outline: it => if query(it.target) != () { it }

  outline()

  show heading.where(depth: 1): body => {
    pagebreak(weak: true)
    body
  }

  doc

  outline(
    title: [List of Figures],
    target: figure.where(kind: image),
  )

  outline(
    title: [List of Tables],
    target: figure.where(kind: table),
  )
}

#let thmmff = thmbox.with(
  padding: (top: 0em, bottom: 0em),
  breakable: true,
  inset: (top: 0em, left: 1.2em, right: 1.2em),
  namefmt: name => emph([(#name)]),
  titlefmt: strong,
  base_level: 1,
)

#let theorem = thmmff("theorem", "Theorem")
#let lemma = thmmff("theorem", "Lemma")
#let corollary = thmmff("corollary", "Corollary", base: "theorem", base_level: 2)
#let definition = thmmff("theorem", "Definition")
#let proof = thmproof("proof", "Proof")
