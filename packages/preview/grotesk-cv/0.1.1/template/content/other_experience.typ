#import "@preview/grotesk-cv:0.1.0": *
#import "@preview/fontawesome:0.2.1": *


== #fa-icon("wrench") #h(5pt) #get-header-by-language("Other experience", "Otra experiencia")

#v(5pt)

#if is-english() [

  #experience-entry(
    title: [Combat Training],
    date: [2029],
    company: [Resistance],
    location: [Los Angeles, CA],
  )

] else if is-spanish() [

  #experience-entry(
    title: [Entrenamiento de combate],
    date: [2029],
    company: [Resistencia],
    location: [Los Ángeles, CA],
  )

]

