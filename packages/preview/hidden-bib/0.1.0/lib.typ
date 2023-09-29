#let truely-hidden = (body) => hide( // make sure it's invisible
  place(
    center, float: false, // Stop adding lines and stuff
    body
  )
)

#let hidden-bibliography = (..args, style: "chicago-notes") => truely-hidden(bibliography(..args, style: style))

#let hidden-cite = (..args) => truely-hidden(
  cite(..args) // "Print" the hidden citation
)

#let hidden-citations(body) = {
  // Within this block, all citations should be hidden
  show cite: it => truely-hidden(it)
  body
}