#let format-single-name(person, show-mail) = {
  if type(person) == str {
    return person
  }

  let name-text = person.name
  if "mail" in person and person.mail != none {
    name-text = link("mailto:" + person.mail)[#person.name]
  }

  if show-mail and "mail" in person and person.mail != none {
    block(spacing: 0.4em, [
      #name-text \
      #text(size: 0.8em, fill: luma(100), link("mailto: " + person.mail))
    ])
  } else {
    name-text
  }
}

#let format-names(names, show-mail: false) = {
  let name-list = if type(names) == array { names } else { (names,) }
  let count = name-list.len()
  if count == 0 { return }

  let formatted = name-list.map(p => format-single-name(p, show-mail))

  if count == 1 { return align(center, formatted.first()) }

  let even-count = if calc.rem(count, 2) == 0 { count } else { count - 1 }
  let half = int(even-count / 2)

  let left-half = formatted.slice(0, half)
  let right-half = formatted.slice(half, even-count)

  grid(
    columns: (1fr, 1fr),
    align(center, stack(spacing: 1em, ..left-half)),
    align(center, stack(spacing: 1em, ..right-half)),
  )

  if calc.rem(count, 2) != 0 {
    v(1em)
    align(center, formatted.last())
  }
}
