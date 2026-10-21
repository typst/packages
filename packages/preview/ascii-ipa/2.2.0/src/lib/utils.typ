#let sanitize(value) = {
  if (type(value) == str) { return value }
  if (type(value) == content and value.func() == raw) { return value.text }

  panic("Cannot convert value " + repr(value) + ". Please make sure the value is wrapped in \" or `")
}

#let replace-raw = (
  converter,
  font: "Linux Libertine O",
  size: 1em / 0.8,
  skip: <code>,
) => body => {
  show raw.where(block: false): it => {
    if it.at("label", default: none) != skip {
      text(font: font, size: size, converter(it))
    } else {
      it
    }
  }
  body
}
