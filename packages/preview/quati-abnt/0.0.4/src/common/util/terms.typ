// # Terms. Termos.

#let get_term(
  capitalize: false,
  field: "short",
  plural: false,
  terms_entries: (),
  term_key,
) = {
  let entry = terms_entries.find(
    e => e.key == term_key,
  )

  if entry == none {
    panic("Termo não encontrado: " + term_key + ".")
  }

  if field == "short" {
    if capitalize == false {
      if plural == false {
        entry.at("short", default: none)
      } else {
        entry.at("plural", default: none)
      }
    } else {
      entry.at("short_capitalized", default: none)
    }
  } else if field == "long" {
    if plural == false {
      entry.at("long", default: entry.at("short", default: none))
    } else {
      entry.at("long_plural", default: entry.at("short", default: none))
    }
  } else if field == "custom" {
    entry.at("custom", default: entry.at("short", default: none))
  } else {
    panic("Campo inválido: " + field + ". Use 'short', 'long' ou 'custom'.")
  }
}
