#import "@preview/grotesk-cv:0.1.6": language-entry
#import "@preview/fontawesome:0.4.0": *

#let meta = toml("../info.toml")
#let language = meta.personal.language
#let include-icon = meta.personal.include_icons

= #if include-icon [#fa-language() #h(5pt)] #if language == "en" [Languages] else if language == "es" [Idiomas]
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

