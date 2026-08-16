#let _abbr-definitions = state("abbr-definitions", (:))

#let define-abbreviations(definitions) = {
  _abbr-definitions.update(definitions)
}

#let _abbr-entry(definitions, key) = {
  if not definitions.keys().contains(key) {
    panic("unknown abbreviation: " + str(key))
  }

  let entry = definitions.at(key)

  if type(entry) == str {
    (short: str(key), long: entry)
  } else {
    panic(
      "definition for `"
        + str(key)
        + "` must be a string, but got: "
        + str(entry),
    )
  }
}

#let _abbr-render(entry, form: "short", suffix: "") = {
  let short = str(entry.short) + suffix
  let long = str(entry.long) + suffix

  if form == "short" {
    short
  } else if form == "long" {
    long
  } else if form == "full" {
    long + " (" + short + ")"
  } else {
    panic("unknown abbreviation form: " + str(form))
  }
}

#let abbr(key, form: "short", suffix: "") = context {
  let definitions = _abbr-definitions.get()
  let entry = _abbr-entry(definitions, key)

  [#metadata((
      key: key,
      short: entry.short,
      long: entry.long,
    ))<abbr-use>#_abbr-render(entry, form: form, suffix: suffix)]
}

#let _unique(values) = {
  let result = ()

  for value in values {
    if not result.contains(value) {
      result.push(value)
    }
  }

  result
}

#let _sorted-used-keys(definitions, by-key) = {
  let result = ()

  for key in definitions.keys() {
    if by-key.keys().contains(key) {
      result.push(key)
    }
  }

  for key in by-key.keys() {
    if not result.contains(key) {
      result.push(key)
    }
  }

  result
}

#let abbreviation-outline(
  title: [Abbreviations],
  level: 1,
  numbering: none,
  outlined: false,
  empty: [No abbreviations used.],
  leader: repeat([.], gap: 0.08em),
  inset: (x: 0.25em),
  row-gutter: 0.65em,
) = {
  heading(
    level: level,
    numbering: numbering,
    outlined: outlined,
  )[#title]

  context {
    let definitions = _abbr-definitions.get()
    let by-key = (:)

    for item in query(<abbr-use>) {
      let value = item.value
      let page = counter(page).at(item.location()).first()

      let previous = by-key.at(value.key, default: (
        short: value.short,
        long: value.long,
        pages: (),
      ))

      let pages = previous.pages
      pages.push(page)

      by-key.insert(value.key, (
        short: value.short,
        long: value.long,
        pages: pages,
      ))
    }

    if by-key.len() == 0 {
      empty
    } else {
      grid(
        columns: (auto, auto),
        align: (left, left, center, right),
        stroke: none,
        inset: inset,
        row-gutter: row-gutter,
        ..for key in _sorted-used-keys(definitions, by-key) {
          let item = by-key.at(key)

          let pages = _unique(item.pages).map(page => {
            // lien vers le coin haut-gauche de la page (page numérotée à partir de 1)
            link(
              (page: page, x: 0pt, y: 0pt),
              str(page),
            )
          })
          (
            [#item.short],
            grid(
              columns: (auto, 1fr, auto),
              [#item.long],
              [#box(width: 100%)[#leader]],
              [#pages.join(", ")],
            ),
          )
        },
      )
    }
  }
}
