#let fullref(label, ..args) = {
    ref(label, form: "normal", ..args)
    sym.space
    ref(label, form: "page")
}

#let vpageref(label, ..args) = context {
  if locate(label).page() != here().page() {
    ref(label, form: "page", ..args)
  }
}

#let vref(label, ..args) = context {
  ref(label, form: "normal", ..args)
  if locate(label).page() != here().page() {
    sym.space.nobreak
    ref(label, form: "page")
  }
}
