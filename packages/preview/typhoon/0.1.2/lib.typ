#let _plugin = plugin("main.wasm")
#let tailwind-classes = state("tailwind-classes", "")

#let tailwind-css(config-bytes) = context {
  let classes = tailwind-classes.get()
  let s = str(_plugin.generate(bytes(classes), config-bytes))
  html.style(s)
}

#let update-elem(elem) = {
  // this is safe because when the class attr is array
  // type typst would ensure that every single element
  // inside the array doesn't contain whitespaces
  let classes = elem.fields().attrs.at("class", default: ())
  if type(classes) == array {
    classes = classes.join(" ")
  }
  tailwind-classes.update(it => it + " " + classes)
  elem
}

#let tailwind-page(c, config: auto) = {
  show html.elem: update-elem
  c
  tailwind-css(if config == auto { bytes("") } else { cbor.encode(config) })
}
