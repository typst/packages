#let compute-shortname(body) = {
  if body.keys().contains("shortName"){return body}

  // TODO: add some decent logic over here :)
  body.insert("shortName", "asd")

  return body
}