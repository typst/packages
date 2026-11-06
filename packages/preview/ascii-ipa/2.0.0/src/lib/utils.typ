#let sanitize(value) = {
  if (type(value) == str) { return value }
  if (type(value) == content and value.func() == raw) { return value.text }

  panic("Cannot convert value " + repr(value) + ". Please make sure the value is wrapped in \" or `")
}
