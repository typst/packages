#import "@preview/grotesk-cv:0.1.4": experience-entry
#import "@preview/fontawesome:0.4.0": *

#let meta = toml("../info.toml")
#let language = meta.personal.language
#let include-icon = meta.personal.include_icons


= #if include-icon [#fa-wrench() #h(5pt)] #if language == "en" [Other] else if language == "es" [Otra experiencia]


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

