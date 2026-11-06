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

#let _abbr-render(
  entry,
  form: "short",
  suffix: none,
  alt-long: none,
) = {
  let short = str(entry.short) + suffix
  let long = if alt-long == none {
    str(entry.long) + suffix
  } else { alt-long + suffix }

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

#let abbr(
  key,
  form: "short",
  suffix: none,
  alt-long: none,
) = context {
  let definitions = _abbr-definitions.get()
  let entry = _abbr-entry(definitions, key)

  [#metadata((
      key: key,
      short: entry.short,
      long: entry.long,
    ))<abbr-use>#_abbr-render(
      entry,
      form: form,
      suffix: suffix,
      alt-long: alt-long,
    )]
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
  fill: repeat([.], gap: 0.15em),
  gutter: auto,
  row-gutter: auto,
  column-gutter: auto,
  separator: none,
) = {
  let default-gutter = if gutter == auto {
    0.65em
  } else {
    gutter
  }

  let column-gutter = if column-gutter == auto {
    default-gutter
  } else {
    column-gutter
  }

  let row-gutter = if row-gutter == auto {
    default-gutter
  } else {
    row-gutter
  }

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

      let displayed-page = counter(page)
        .at(item.location())
        .first()

      let physical-page = item.location().page()

      let previous = by-key.at(value.key, default: (
        short: value.short,
        long: value.long,
        pages: (),
      ))

      let pages = previous.pages
      pages.push((
        displayed-page: displayed-page,
        physical-page: physical-page,
      ))

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
        gutter: gutter,
        row-gutter: row-gutter,
        column-gutter: column-gutter,
        ..for key in _sorted-used-keys(definitions, by-key) {
          let item = by-key.at(key)

          let pages = _unique(item.pages).map(entry => {
            link(
              (page: entry.physical-page, x: 0pt, y: 0pt),
              str(entry.displayed-page),
            )
          })
          (
            [#item.short] + [#separator],
            grid(
              column-gutter: 0.25em,
              columns: (auto, 1fr, auto),
              [#item.long],
              box(width: 100%)[#fill],
              [#pages.join(", ")],
            ),
          )
        },
      )
    }
  }
}

