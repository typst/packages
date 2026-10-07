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
  filler: repeat([.], gap: 0.15em),
  row-gutter: 0.65em,
  separator: [~~],
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

      // What the user sees printed on the page: the value of the `page`
      // counter at the abbreviation's location. The counter can be reset
      // (e.g. `counter(page).update(1)`) so the printed numbering skips
      // unnumbered title/cover pages.
      let displayed = counter(page).at(item.location()).first()

      // What the link must target: the true physical page (1-based) of
      // the abbreviation's location. `link((page: ..., ...))` always
      // expects a physical page number, *not* the value of the counter.
      let physical = item.location().page()

      let previous = by-key.at(value.key, default: (
        short: value.short,
        long: value.long,
        pages: (),
      ))

      let pages = previous.pages
      pages.push((displayed: displayed, physical: physical))

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
        row-gutter: row-gutter,
        ..for key in _sorted-used-keys(definitions, by-key) {
          let item = by-key.at(key)

          let pages = _unique(item.pages).map(entry => {
            // Use the physical page for the link target, but show the
            // counter value (the number printed on the page).
            link(
              (page: entry.physical, x: 0pt, y: 0pt),
              str(entry.displayed),
            )
          })
          (
            [#item.short] + [#separator],
            grid(
              columns: (auto, auto, 1fr, auto, auto),
              [#item.long],
              [~],
              box(width: 100%)[#filler],
              [~],
              [#pages.join(", ")],
            ),
          )
        },
      )
    }
  }
}
