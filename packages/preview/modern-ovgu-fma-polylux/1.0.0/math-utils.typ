#let conf-equations(document) = {
  set math.equation(numbering: "(1)", supplement: none)
  show ref: it => {
    // provide custom reference for equations
    if it.element != none and it.element.func() == math.equation {
      // optional: wrap inside link, so whole label is linked
      if text.lang == "de" {
        link(it.target)[Gl.~(#it)]
      } else {
        link(it.target)[eq.~(#it)]
      }
    } else {
      it
    }
  }
  show math.equation: it => {
    if it.block and not it.has("label") [
      #counter(math.equation).update(v => v - 1)
      #math.equation(it.body, block: true, numbering: none)#label("")
    ] else {
      it
    }
  }

  document
}
