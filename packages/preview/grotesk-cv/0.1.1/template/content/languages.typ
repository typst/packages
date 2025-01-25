#import "@preview/grotesk-cv:0.1.0": *
#import "@preview/fontawesome:0.2.1": *


== #fa-icon("language") #h(5pt) #get-header-by-language("Languages", "Idiomas")

#v(5pt)

#if is-english() {

  language-entry(language: "English", proficiency: "Native")
  language-entry(language: "Spanish", proficiency: "Fluent")
  language-entry(language: "Machine Code", proficiency: "Fluent")

} else if is-spanish() {

  language-entry(language: "Inglés", proficiency: "Nativo")
  language-entry(language: "Español", proficiency: "Fluido")
  language-entry(language: "Código de Máquina", proficiency: "Fluido")

}

