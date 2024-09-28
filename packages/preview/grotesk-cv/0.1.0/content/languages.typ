#import "../lib.typ": *
#import "@preview/fontawesome:0.2.1": *


== #fa-icon("language") #h(5pt) #getHeaderByLanguage("Languages", "Idiomas")

#v(5pt)

#if isEnglish() {

  languageEntry(language: "English", proficiency: "Native")
  languageEntry(language: "Spanish", proficiency: "Fluent")
  languageEntry(language: "Machine Code", proficiency: "Fluent")

} else if isSpanish() {

  languageEntry(language: "Inglés", proficiency: "Nativo")
  languageEntry(language: "Español", proficiency: "Fluido")
  languageEntry(language: "Código de Máquina", proficiency: "Fluido")

}

