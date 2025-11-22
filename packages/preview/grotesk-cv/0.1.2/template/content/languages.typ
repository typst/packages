#import "@preview/grotesk-cv:0.1.2": *
#import "@preview/fontawesome:0.2.1": *

#let meta = toml("../info.toml")
#let language = meta.personal.language

== #fa-icon("language") #h(5pt) #if language == "en" [Languages] else if language == "es" [Idiomas]
//#get-header-by-language("Languages", "Idiomas")

#v(5pt)

#if language == "en" {

  language-entry(language: "English", proficiency: "Native")
  language-entry(language: "Spanish", proficiency: "Fluent")
  language-entry(language: "Machine Code", proficiency: "Fluent")

} else if language == "es" {

  language-entry(language: "Inglés", proficiency: "Nativo")
  language-entry(language: "Español", proficiency: "Fluido")
  language-entry(language: "Código de Máquina", proficiency: "Fluido")

}

