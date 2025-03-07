#let meta = toml("../info.toml")
#import meta.import.path: language-entry
#import meta.import.fontawesome: *

#let icon = meta.section.icon.languages
#let language = meta.personal.language
#let include-icon = meta.personal.include_icons

= #if include-icon [#fa-icon(icon) #h(5pt)] #if language == "en" [Languages] else if language == "es" [Idiomas]

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

