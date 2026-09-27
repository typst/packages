#let azbuka = "АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ".clusters()

/// Numbering with format "А.1" where the letter is enumerated according to serbian cyrl azbuka.
#let sr-numbering(first, ..others, azbuka: azbuka) = {
  let n = first - 1
  let rem = calc.rem(n, azbuka.len())
  let quo = calc.quo(n, azbuka.len())

  (
    azbuka.at(rem) * (1 + quo),
    ..others.pos().map(str),
  ).join(".")
}

#let graph = "график"
