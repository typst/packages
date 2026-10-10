#import "@preview/simple-cs:1.0.0" : template, logo-list

#show: template.with(
  title: [Rapport de stage de 1#super[ère] année],
  title-page-header: logo-list(),
  name: "Prenom NOM",
  dates: "01/01/2026 - 01/02/2026",


  tuteur-company: [
    Prenom NOM \
    #link("mailto:prenom.nom@example.fr")
  ],
  tuteur-school: [
    Prenom NOM \
    #link("mailto:prenom.nom@centralesupelec.fr")
  ],
)


= Introduction
#lorem(10)

== Foo
#lorem(20)
=== Foobarbaz
#lorem(20)

== Bar
#lorem(20)

= Mes missions
#lorem(100)

== Bar
#lorem(200)

== Baz
#lorem(300)
