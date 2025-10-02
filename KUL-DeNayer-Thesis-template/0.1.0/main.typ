#import "@preview/template.typ" : titlepage, start
#import "@preview/hydra:0.6.1": hydra

#titlepage(
  auteurs: ("First name LAST NAME",),
  promotor:  "Promotor",
  Co-promotor : "Co-promotor",
  evaluatoren : ("evaluator1","evaluator2"),
  begeleider : "begeleider",
  start : "2025",
  einde : "2026",
  title : "Title of Master Thesis",
  subtitle : "Subtitle",
)
#start(
  voorwoord: [preface],
  naam: [My name],
  samenvatting: [My Summary],
  afkortingen: [*CFG* Context Free Grammar],
)

// End start pages ---------------------


#set page(paper: "a4", margin: (inside: 120pt, outside: 80pt, y:120pt), numbering: "1", header: context {
  if calc.odd(here().page()) {
    align(right, emph(hydra(1, skip-starting: false)))
  } else {
    align(left, emph(hydra(1, skip-starting: false)))
  }
  line(length: 100%,
  stroke: luma(50%),
)
})
#set heading(numbering: "1.1")

#counter(page).update(1) // Reset numbering to start at 1
#set page(footer: context {
  if calc.even(counter(page).get().first()) {
    align(left, counter(page).display("1"))
} else {
    align(right, counter(page).display("1"))
  }
})

#set par(
  spacing: 0.65em,
  justify: true,
)

// // Customize Level 1 headings
#show heading.where(level: 1): it => [
  #pagebreak(weak: true);
  #block(it)\
]

#set math.equation(numbering: "(1)")

#show ref: it => {
  let eq = math.equation
  let el = it.element
  if el != none and el.func() == eq {
    // Override equation references.
    link(el.location(),numbering(
      el.numbering,
      ..counter(eq).at(el.location())
    ))
  } else {
    // Other references as usual.
    it
  }
}

// Document starts here
= Introduction



#bibliography("bib.bib")
