#let ok(value) = {
  return (value, none)
}

#let error(err) = {
  return (none, err)
}
