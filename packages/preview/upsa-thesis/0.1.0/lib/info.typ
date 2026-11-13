#import "typeface.typ"

#let author-name = state("author-name", none)
#let author-email = state("author-email", none)
#let author-uni-id = state("author-uni-id", none)
#let work-title = state("work-title", none)
#let multi-part = state("is-multi-part", false)
#let in-back-matter = state("in-back-matter", false)
#let supervisor = state("supervisor", none)
#let thesis-modality = state("thesis-modality", none)
#let thesis-modality-short = state("thesis-modality-short", none)
#let degree-level = state("degree-level", none)
#let degree-program = state("degree-program", none)
#let work-date = state("work-date", none)
#let work-abstract = state("work-abstract", none)
#let university = state("university", [Universidad Privada de Santa Cruz de la Sierra])
#let university-short = state("university-short", [UPSA])
#let faculty = state("faculty", none)
#let city = state("city", [Santa Cruz de la Sierra, Bolivia])
#let volumes = state("volumes", none)
#let keywords = state("keywords", none)
#let print-layout = state("print-layout", "screen")
#let font = state("font", typeface.default)
#let font-family = state("font-family", "Alegreya")
#let paper-size = state("paper-size", "us-letter")
#let work-pages = state("work-pages", 0)
#let title-page-mode = state("title-page-mode", "old")

#let supervisor-entries(value) = {
  if value == none {
    return ()
  }

  let entries = if type(value) == array { value } else { ([Guía], value) }
  assert(calc.even(entries.len()), message: "supervisor debe ser un nombre o una lista de pares (rol, nombre).")
  for index in range(0, entries.len(), step: 2) {
    let role = entries.at(index)
    let name = entries.at(index + 1)
    assert(type(role) in (str, content), message: "Cada rol de supervisor debe ser texto o contenido.")
    assert(type(name) in (str, content), message: "Cada nombre de supervisor debe ser texto o contenido.")
  }
  entries
}

#let supervisor-names(value) = {
  let entries = supervisor-entries(value)
  range(0, entries.len(), step: 2).map(index => entries.at(index + 1))
}
