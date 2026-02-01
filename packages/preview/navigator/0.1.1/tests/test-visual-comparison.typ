#import "../lib.typ": render-transition

// Configuration de type présentation
#set page(width: 25cm, height: 15cm, margin: 0pt)
#set text(font: "Lato", size: 22pt)
#set heading(numbering: "1.1", outlined: true)

// Fonction de slide simple qui occupe toute la page
#let slide(fill: white, body) = {
  set page(fill: fill)
  set text(fill: if fill == white { black } else { white })
  block(width: 100%, height: 100%, inset: 2em, {
    align(center + horizon, body)
  })
}

// Règle de transition globale
#show heading: h => render-transition(
  h,
  mapping: (section: 1, subsection: 2),
  theme-colors: (primary: rgb("#1a5fb4"), accent: orange),
  slide-func: slide,
)

= Première Section

== Sous-section 1.1
#slide[Contenu de la sous-section 1.1]

== Sous-section 1.2
#slide[Contenu de la sous-section 1.2]

= Deuxième Section
#slide[Contenu de la section 2]
