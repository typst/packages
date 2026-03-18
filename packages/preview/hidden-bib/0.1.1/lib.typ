#let truly-hidden = (body) => hide( // make sure it's invisible
  place(
    center, float: false, // Stop adding lines and stuff
    body
  )
)

#let hidden-bibliography = (b) => {
	set bibliography(style: "chicago-notes")
	set heading(outlined: false)
	truly-hidden(b)
}

#let hidden-cite = (..args) => truly-hidden(
  cite(..args) // "Print" the hidden citation
)

#let hidden-citations(body) = {
  // Within this block, all citations should be hidden
  show cite: it => truly-hidden(it)
  body
}