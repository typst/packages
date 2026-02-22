#import "/pages/bibliography.typ": _set-biblography

#let bib = bibliography("/template/refs.bib")

@Feynman82

#_set-biblography(bibliography-object: bib, citation-style: "ieee")
