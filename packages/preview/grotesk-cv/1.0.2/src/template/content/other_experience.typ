#let meta = toml("../info.toml")
#import meta.import.path: experience-entry
#import meta.import.fontawesome: *

#let icon = meta.section.icon.other_experience
#let language = meta.personal.language
#let include-icon = meta.personal.include_icons


= #if include-icon [#fa-icon(icon) #h(5pt)] #if language == "en" [Other] else if language == "es" [Otra experiencia]


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

