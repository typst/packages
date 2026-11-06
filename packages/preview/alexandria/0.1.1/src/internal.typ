#let locale() = {
  let locale = text.lang
  if text.region != none { locale += "-" + text.region }
  locale
}

#let csl-to-string(csl) = {
  if type(csl) == str { return csl }

  let csl = repr(csl).slice(1, -1)
  assert.ne(csl, "..", message: "only named CSL styles can be converted to strings")
  csl
}
