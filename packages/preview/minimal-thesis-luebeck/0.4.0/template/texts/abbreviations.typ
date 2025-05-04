#import "@preview/abbr:0.2.3"

#abbr.make(
  ("PDE", "Partial Differential Equation"),
  ("BC", "Boundary Condition"),
  ("DOF", "Degree of Freedom", "Degrees of Freedom"),
)
#abbr.config(space-char: {sym.space.nobreak})

#context {
  let lang = text.lang
  let abbr-title = ""
  if lang == "de" {
    abbr-title = "Abkürzungsverzeichnis"
  } else {
    abbr-title = "List of Abbreviations"
  }
  abbr.list(
    title: abbr-title
  )
}
