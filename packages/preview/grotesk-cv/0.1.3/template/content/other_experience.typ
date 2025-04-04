#import "@preview/grotesk-cv:0.1.3": experience-entry
#import "@preview/fontawesome:0.4.0": *

#let meta = toml("../info.toml")
#let language = meta.layout.language


== #fa-wrench() #h(5pt) #if language == "en" [Other experience] else if language == "es" [Otra experiencia]


#v(5pt)

#if language == "en" [

  #experience-entry(
    title: [Combat Training],
    date: [2029],
    company: [Resistance],
    location: [Los Angeles, CA],
  )

] else if language == "es" [

  #experience-entry(
    title: [Entrenamiento de combate],
    date: [2029],
    company: [Resistencia],
    location: [Los Ángeles, CA],
  )

]

