// Set numbering in the given format for figures of different kinds, as well as equations.
// Does NOT apply to figures with subfigures. Those update the format automatically.
#let set-figure-numbering(new-format: none, body) = {

  let figure-numbering = super => numbering(new-format, counter(heading).get().first(), super)
  let equation-numbering = super => numbering("("+new-format+")", counter(heading).get().first(), super)

  set figure(numbering: figure-numbering)
  set math.equation(numbering: equation-numbering)

  body
}
