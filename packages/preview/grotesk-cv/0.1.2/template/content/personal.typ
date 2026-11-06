#import "@preview/grotesk-cv:0.1.2": *
#import "@preview/fontawesome:0.2.1": *

#let meta = toml("../info.toml")
#let language = meta.personal.language


== #fa-icon("brain") #h(5pt) #if language == "en" [Personality] else if language == "es" [Personalidad]


#v(5pt)

#if language == "en" [

  - Analytic thinking
  - Quality conscious
  - Good communicator
  - Independent
  - Team player
  - Preemptive
  - Eager to learn

] else if language == "es" [

  - Pensamiento analítico
  - Consciente de la calidad
  - Buen comunicador
  - Independiente
  - Jugador de equipo
  - Preventivo
  - Ansioso por aprender
]
