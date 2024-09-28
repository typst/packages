#import "../lib.typ": *
#import "@preview/fontawesome:0.2.1": *


== #fa-icon("wrench") #h(5pt) #getHeaderByLanguage("Other experience", "Otra experiencia")

#v(5pt)

#if isEnglish() [

  #experienceEntry(
    title: [Combat Training],
    date: [2029],
    company: [Resistance],
    location: [Los Angeles, CA],
  )

] else if isSpanish() [

  #experienceEntry(
    title: [Entrenamiento de combate],
    date: [2029],
    company: [Resistencia],
    location: [Los Ángeles, CA],
  )

]

