#import "style/colored.typ" as colored
#import "style/normal.typ" as normal

#let maths-style-state = state("maths-style", "normal")
#let maths-num-state = state("maths-num", "normal")


#let def(title, content) = context {
  if maths-style-state.get() == "colored" { colored.def(title, content) } else { normal.def(title, content) }
}

#let prop(title, content) = context {
  if maths-style-state.get() == "colored" { colored.prop(title, content) } else { normal.prop(title, content) }
}

#let theorem(title, content) = context {
  if maths-style-state.get() == "colored" { colored.theorem(title, content) } else { normal.theorem(title, content) }
}

#let remarque(title, content) = context {
  if maths-style-state.get() == "colored" { colored.remarque(title, content) } else { normal.remarque(title, content) }
}

#let corollaire(title, content) = context {
  if maths-style-state.get() == "colored" { colored.corollaire(title, content) } else { normal.corollaire(title, content) }
}

#let lemme(title, content) = context {
  if maths-style-state.get() == "colored" { colored.lemme(title, content) } else { normal.lemme(title, content) }
}

#let exemple(title, content) = context {
  if maths-style-state.get() == "colored" { colored.exemple(title, content) } else { normal.exemple(title, content) }
}

#let rappel(title, content) = context {
  if maths-style-state.get() == "colored" { colored.rappel(title, content) } else { normal.rappel(title, content) }
}

#let exercice(title, content) = context {
  if maths-style-state.get() == "colored" { colored.exercice(title, content) } else { normal.exercice(title, content) }
}

#let correction(content) = context {
  if maths-style-state.get() == "colored" { colored.correction(content) } else { normal.correction(content) }
}

#let demo(content) = context {
  if maths-style-state.get() == "colored" { colored.demo(content) } else { normal.demo(content) }
  


}