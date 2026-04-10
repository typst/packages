#let theorem-style = it => {
  let number = if it.numbering != none [ #it.counter.display(
    it.numbering,
  )] else []
  let name = if (
    it.caption != none
  ) [#set strong(delta: -300);~*(#it.caption.body)*] else []
  block(width: 100%)[
    *#it.supplement#number#name.*
    #it.body
  ]
}

#let proof-style = (title, body) => block(width: 100%)[
  _#title._
  #body
]
