#let check-and-insert(info, key, value) = {
  assert(type(info) == dictionary, message: "info's type is " + str(type(info)))
  if not (key in info) {
    info.insert(key, value)
  }
  return info
}
