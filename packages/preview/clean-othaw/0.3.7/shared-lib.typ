#let assert-in-dict(dict-type, state, element) = {
  context {
    let list = state.get()
    if element not in list {
      panic(element + " is not a key in the " + dict-type + " dictionary.")
    }
  }
}

#let display-link(dict-type, state, element, text) = {
  assert-in-dict(dict-type, state, element)
  link(label(dict-type + "-" + element), text)
}

#let display(dict-type, state, element, text, link: true) = {
  if link {
    display-link(dict-type, state, element, text)
  } else {
    text
  }
}
