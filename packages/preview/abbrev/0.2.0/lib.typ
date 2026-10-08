// Abbrev v0.2.0
// author: Luca P.
// license: GPL v3
#let abbrev-version = version(0, 2, 0)

// state contaning the definitions
#let _catalog = state("abbrev-catalog", (
  _names: (
    abbrev: "abbreviations",
    term: "glossary terms",
    symbol: "symbols",
    acronym: "acronyms",
  ),
  abbrev: (:),
  term: (:),
  symbol: (:),
  acronym: (:),
))

// utils
#let _require(condition, message: "error") = if not condition {
  panic(message)
}
#let _is-non-empty-str(v) = {
  v.trim() != ""
}
#let _strip(body) = {
  show regex("\\s+"): none
  body
}
#let _is-non-empty-text(v) = (
  if type(v) == str {
    _is-non-empty-str(v)
  } else {
    _strip(v) != []
  }
)
#let _is-str(v) = type(v) == str
#let _is-content(v) = type(v) == content
#let _is-text(v) = _is-str(v) or _is-content(v)
#let _is-def-dict(v) = (
  type(v) == dictionary and "short" in v and "long" in v
)
#let _is-path(v) = type(v) == path
#let _is-bytes(v) = type(v) == bytes
#let _is-file-or-bytes(v) = (
  _is-str(v) or _is-path(v) or _is-bytes(v)
)
#let _file-has-ext(file, ext) = {
  let ext-to-check = ""
  if _is-path(file) {
    ext-to-check = "." + lower(ext) + "\")"
  } else if _is-str(file) {
    ext-to-check = "." + lower(ext)
  }
  lower(repr(file)).contains(ext-to-check)
}
#let _is-json(file) = _file-has-ext(file, "json")
#let _is-csv(file) = _file-has-ext(file, "csv")
#let _capitalise(s) = s.replace(regex("^\w"), m => upper(m.text))

// read definitions from CSV file or bytes
#let _read-csv(source) = {
  let rows = csv(source, row-type: array)
  let result = (:)

  for row in rows {
    if (
      row.len() == 0
        or (row.len() == 1 and _is-non-empty-str(row.at(0)))
    ) {
      continue
    }
    if row.len() != 2 {
      panic(
        "invalid CSV row: expected exactly two columns, got "
          + str(row.len()),
      )
    }
    let key = row.at(0).trim()
    let value = row.at(1).trim()
    _require(
      _is-non-empty-str(key),
      message: "CSV abbreviation cannot be empty",
    )
    _require(
      _is-non-empty-text(value),
      message: "CSV definition cannot be empty for abbreviation `"
        + key
        + "`",
    )
    result.insert(key, value)
  }
  result
}

// read definitions from JSON file or bytes
#let _read-json(source) = {
  let result = json(source)
  if type(result) != dictionary {
    panic(
      "JSON root must be an object",
    )
  }
  for (key, value) in result {
    _require(
      _is-str(key) and _is-non-empty-str(key),
      message: "JSON abbreviation cannot be empty",
    )
    _require(
      _is-str(value) and _is-non-empty-text(value),
      message: "JSON definition must be a non-empty string for abbreviation `"
        + key
        + "`",
    )
  }
  return result
}

// read definitions from file or bytes
#let _read-definitions(source) = {
  if _is-bytes(source) {
    // bytes sequence contains JSON or CSV?
    let bra = str.to-unicode("{")
    let ket = str.to-unicode("}")
    if source.first == bra and source.last == ket {
      // bytes sequence contains JSON?
      return _read-json(source)
    } else {
      // bytes sequence contains CSV?
      return _read-csv(source)
    }
  } else {
    // file string or path?
    if _is-json(source) {
      _read-json(source)
    } else if _is-csv(source) {
      _read-csv(source)
    } else {
      panic(
        "unsupported definitions format: expected a .csv or .json file, or a sequence of bytes",
      )
    }
  }
}

// update the state containing the definitions
#let _update-definition(category, abbreviation, definition) = {
  _catalog.update(catalog => {
    _require(
      _is-str(category),
      message: "category must be a string",
    )
    _require(
      category != "_names" and category in catalog.keys(),
      message: "unknown abbreviation category: "
        + repr(category),
    )
    _require(
      _is-str(abbreviation),
      message: "abbreviation must be a string",
    )
    _require(
      _is-text(definition) or _is-def-dict(definition),
      message: "definition must be a string, a content, or a dictionary (with `short` and `long` entries)",
    )
    _require(
      _is-non-empty-str(abbreviation),
      message: "abbreviation cannot be empty",
    )

    if _is-str(definition) {
      _require(
        _is-non-empty-text(definition),
        message: "definition cannot be empty",
      )
    } else if _is-def-dict(definition) {
      _require(
        _is-non-empty-text(definition.short),
        message: "short abbreviation cannot be empty",
      )
      _require(
        _is-non-empty-text(definition.long),
        message: "definition cannot be empty",
      )
    }

    let key = abbreviation
    let entry = definition

    if _is-str(entry) {
      entry = (
        short: key,
        long: entry,
      )
    }

    let definitions = catalog.at(category)
    definitions.insert(key, entry)
    catalog.insert(category, definitions)
    catalog
  })
}

// add category
#let add-category(name, title: none) = {
  _catalog.update(catalog => {
    _require(
      _is-str(name),
      message: "category name must be a string",
    )
    _require(
      _is-non-empty-str(name),
      message: "category name cannot be empty",
    )
    _require(
      name != "_names",
      message: "category name cannot be `_names`",
    )
    _require(
      not name in catalog.keys(),
      message: "category already exists: " + repr(name),
    )
    _require(
      _is-str(title),
      message: "category title must be a string",
    )
    _require(
      _is-non-empty-str(title),
      message: "category title cannot be empty",
    )
    catalog.insert(name, (:))
    let category-title = if title == none {
      name
    } else {
      title
    }
    catalog.at("_names").insert(name, category-title)
    catalog
  })
}

// define abbreviations
// use:
//   - def(abbreviation:str, definition:str|content|dictionary)
//   - def(list:dictionary)
//   - def(file:str|path)
// positional args:
//   1) abbreviation: e.g. "PDF", or alias "H2O" (used with a definition as a dictionary containig `short` and `long`)
//   2) definition: e.g. "Portable Document Format", or [Molecule H#sub("2")O stands for watter], or (short:[H#sub("2")O], long: "Watter")
//   1) list: e.g. ("PDF": "Portable Document Format", "H2O": (short:[H#sub("2")O],long:"Watter"),)
//   1) file: e.g. "/path/to/file.json", or path("file.csv")
// named args:
//   - category: category of definition, default "abbrev"
#let abbrev-def(..args) = {
  let positional = args.pos()
  let named = args.named()
  let category = named.at("category", default: "abbrev")
  let nb-pos-args = positional.len()
  if nb-pos-args == 2 {
    // single definition
    let abbreviation = positional.at(0)
    let definition = positional.at(1)
    _require(
      _is-str(abbreviation),
      message: "abbreviation must be a string",
    )
    _update-definition(category, abbreviation, definition)
  } else if nb-pos-args == 1 {
    let source = positional.at(0)
    if type(source) == dictionary {
      // definitions in dictionary
      for (abbreviation, definition) in source {
        _update-definition(category, abbreviation, definition)
      }
    } else if _is-file-or-bytes(source) {
      // definitions in file or bytes
      abbrev-def(_read-definitions(source))
    }
  } else {
    panic(
      "definition requires 2 positional arguments (abbreviation and definition) or 1 positional argument (a dictionary, or a file string or path)",
    )
  }
}

// render entry
#let _render-entry(
  entry,
  form: "short",
  suffix: none,
  alt-long: none,
) = {
  let short = entry.short + suffix
  let long = if alt-long == none {
    entry.long + suffix
  } else { alt-long + suffix }
  if form == "short" {
    short
  } else if form == "long" {
    long
  } else if form == "full" {
    long + " (" + short + ")"
  } else {
    panic("unknown abbreviation form: " + repr(form))
  }
}


#let _get-entry(definitions, key) = {
  _require(
    _is-str(key),
    message: "abbreviation key must be a string",
  )
  if not definitions.keys().contains(key) {
    panic("unknown abbreviation: " + repr(key))
  }
  let entry = definitions.at(key)
  if _is-text(entry) {
    (short: str(key), long: entry)
  } else if (
    type(entry) == dictionary
      and "short" in entry
      and "long" in entry
  ) {
    entry
  } else {
    panic(
      "definition for `"
        + str(key)
        + "` must be a string, but got: "
        + repr(entry),
    )
  }
}

#let abbrev(
  key,
  form: "short",
  suffix: none,
  alt-long: none,
  category: "abbrev",
) = context {
  let definitions = _catalog.get().at(category)
  let entry = _get-entry(definitions, key)

  [#metadata((
      key: key,
      category: category,
      short: entry.short,
      long: entry.long,
    ))<abbrev-use>#_render-entry(
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

// print outline
#let abbrev-outline(
  title: auto,
  level: 1,
  numbering: none,
  outlined: false,
  empty: auto,
  fill: repeat([.], gap: 0.15em),
  gutter: auto,
  row-gutter: auto,
  column-gutter: auto,
  separator: none,
  category: "abbrev",
  show-pages: true,
) = {
  if title == auto {
    title = [#context {
      _capitalise(_catalog.get().at("_names").at(category))
    }]
  }
  if empty == auto {
    empty = [No #context { _catalog.get().at("_names").at(category) } used.]
  }
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
    let definitions = _catalog.get().at(category)
    let by-key = (:)

    for item in query(<abbrev-use>) {
      let value = item.value
      if value.category != category {
        continue
      }
      let displayed-page = counter(page)
        .at(item.location())
        .at(0)
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
              box(width: 100%)[#if show-pages { fill }],
              if show-pages [#pages.join(", ")] else [],
            ),
          )
        },
      )
    }
  }
}

// aliases for glossary terms, symbols, and acronyms
// - definitions
#let _def(..args) = {
  let positional = args.pos()
  let named = args.named()
  let category = named.at("category")
  abbrev-def(..positional, category: category)
}
#let term-def(..args) = _def(..args, category: "term")
#let symbol-def(..args) = _def(..args, category: "symbol")
#let acronym-def(..args) = _def(..args, category: "acronym")

// - entry
#let _entry(
  key,
  form: "short",
  suffix: none,
  alt-long: none,
  category: "abbrev",
) = {
  abbrev(
    key,
    form: form,
    suffix: suffix,
    alt-long: alt-long,
    category: category,
  )
}
#let abbrev-entry(..args) = _entry(..args, category: "abbrev")
#let term-entry(..args) = _entry(..args, category: "term")
#let symbol-entry(..args) = _entry(..args, category: "symbol")
#let acronym-entry(..args) = _entry(..args, category: "acronym")

// - outlines
#let term-outline(..args) = abbrev-outline(..args, category: "term")
#let symbol-outline(..args) = abbrev-outline(..args, category: "symbol")
#let acronym-outline(..args) = abbrev-outline(..args, category: "acronym")


// aliases for backward compatibility with v0.1.*
#let define-abbreviations(..args) = _def(
  ..args,
  category: "abbrev",
)
#let abbr(..args) = _entry(..args, category: "abbrev")
#let abbreviation-outline(..args) = abbrev-outline(..args)

// replace space with narrow non-breaking space
#let to-nnbsp(abbreviation) = {
  _require(
    _is-str(abbreviation) and _is-non-empty-str(abbreviation),
    message: "abbreviation must be a non-empty string",
  )
  abbreviation.replace(sym.space, sym.space.nobreak.narrow)
}
