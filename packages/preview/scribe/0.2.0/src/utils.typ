#let did-load-operations = state("scribe-operations", false)
#let did-load-caligraphics = state("scribe-caligraphics", false)
#let did-load-logicals = state("scribe-logicals", false)
#let did-load-grouping-brackets = state("scribe-grouping-brackets", false)
#let did-load-miscellaneous = state("scribe-miscellaneous", false)
#let did-load-relations = state("scribe-relations", false)

// TODO: add ignore regex here.

#let safe-wrap(module, is-legal, funcion-name, content) = {
  // TODO: do type assertion here
  context if is-legal.get() != true {
    let msg = "scribe: To use '" + funcion-name + "' you must invoke scribe with '" + module + "'. E.g. 'show: scribe.with(\"" + module + "\", ...)'"
    panic(msg)
  } 
  content
}
