// --- UTILITIES ---

// Lowercase words that belong to the surname rather than to the given names.
#let surname-particles = (
  "abu",
  "af",
  "al",
  "av",
  "bin",
  "bint",
  "binte",
  "da",
  "das",
  "de",
  "degli",
  "del",
  "della",
  "dello",
  "den",
  "der",
  "di",
  "dos",
  "du",
  "e",
  "el",
  "i",
  "ibn",
  "la",
  "las",
  "le",
  "lo",
  "los",
  "ten",
  "ter",
  "van",
  "von",
  "y",
)

// Generational and honorific suffixes that trail the surname.
#let name-suffixes = (
  "dds",
  "esq",
  "esq.",
  "ii",
  "iii",
  "iv",
  "jr",
  "jr.",
  "md",
  "m.d.",
  "mba",
  "phd",
  "ph.d",
  "ph.d.",
  "rn",
  "sr",
  "sr.",
  "vi",
)

#let is-suffix(word) = lower(word) in name-suffixes

// Join a list of suffix words, safely handling the empty case.
#let join-suffixes(list) = if list.len() == 0 { "" } else {
  list.join(", ")
}

// Split a name written as a string into its parts.
#let parse-name-string(name) = {
  let raw = name.trim()
  if raw == "" {
    return none
  }
  if raw.contains(",") {
    let parts = raw
      .split(",")
      .map(part => part.trim())
      .filter(part => part != "")
    if parts.len() == 0 {
      return none
    }
    return (
      first: parts.at(1, default: ""),
      last: parts.at(0),
      suffix: join-suffixes(parts.slice(2)),
    )
  }
  let words = raw.split(regex("\s+")).filter(word => word != "")
  let suffixes = ()
  while words.len() > 1 and is-suffix(words.last()) {
    suffixes.insert(0, words.pop())
  }
  if words.len() == 1 {
    return (
      first: "",
      last: words.at(0),
      suffix: join-suffixes(suffixes),
    )
  }
  // Walk left from the final word for as long as the preceding word is a particle, always leaving at least one word as the given name.
  let split = words.len() - 1
  while (
    split > 1 and lower(words.at(split - 1)) in surname-particles
  ) {
    split -= 1
  }
  (
    first: words.slice(0, split).join(" "),
    last: words.slice(split).join(" "),
    suffix: join-suffixes(suffixes),
  )
}

// Normalise one author into `(first, last, suffix)`, or into `(body: …)` for values that cannot be taken apart.
#let parse-author(author) = {
  if author == none {
    return none
  }
  if type(author) == str {
    return parse-name-string(author)
  }
  if type(author) == dictionary {
    let first = author.at("firstname", default: author.at(
      "first",
      default: author.at("given", default: none),
    ))
    let last = author.at(
      "lastname",
      default: author.at("last", default: author.at(
        "surname",
        default: author.at("family", default: none),
      )),
    )
    let suffix = author.at("suffix", default: "")
    if first == none and last == none {
      let name = author.at("name", default: none)
      if name == none {
        return none
      }
      let parsed = parse-author(name)
      if parsed == none or "body" in parsed {
        return parsed
      }
      if suffix == "" {
        return parsed
      }
      return (..parsed, suffix: suffix)
    }
    return (
      first: if first == none { "" } else { first },
      last: if last == none { "" } else { last },
      suffix: suffix,
    )
  }
  (body: author)
}

// Accept a single author or an array of them.
#let parse-authors(author) = {
  let authors = if type(author) == array { author } else {
    (author,)
  }
  authors.map(parse-author).filter(author => author != none)
}

// Determine author names.
#let author-name(author) = {
  if "body" in author {
    return author.body
  }
  let name = (author.first, author.last)
    .filter(part => part != "")
    .join(" ")
  let suffix = author.at("suffix", default: "")
  if suffix == none or suffix == "" {
    name
  } else {
    name + ", " + suffix
  }
}

// Determine author surnames.
#let author-surname(author) = {
  if "body" in author {
    author.body
  } else if author.last != "" {
    author.last
  } else {
    author.first
  }
}

// The surnames as they appear in the running header: one author is named, two are joined with "and", and three or more are shortened to "et al.".
#let authors-header(authors) = {
  let surnames = authors.map(author-surname)
  if surnames.len() == 0 {
    none
  } else if surnames.len() == 1 {
    surnames.at(0)
  } else if surnames.len() == 2 {
    surnames.at(0) + " and " + surnames.at(1)
  } else {
    surnames.at(0) + "et al."
  }
}

// Resolve `date` into a `(value, format)` pair. Accepts a plain `datetime`, an array of `(datetime, format-string)`, or a dictionary with `value` and `format` keys.
#let resolve-date(date) = {
  // Default MLA date format, used whenever `date` doesn't carry its own.
  let default-date-format = "[day] [month repr:long] [year]"
  if date == none {
    (value: none, format: default-date-format)
  } else if type(date) == datetime {
    (value: date, format: default-date-format)
  } else if type(date) == dictionary {
    (
      value: date.value,
      format: date.at("format", default: default-date-format),
    )
  } else {
    (
      value: date.at(0),
      format: date.at(1, default: default-date-format),
    )
  }
}

// --- TEMPLATE ---

#let report(
  // -- Metadata --
  title: none,
  author: none,
  professor: none,
  date: none,
  course: none,
  // -- Document --
  paper-size: "a4",
  language: "en",
  // -- Fonts --
  font-face: "Liberation Serif",
  font-size: 12pt,
  line-height-ratio: 1.6,
  // -- Body --
  body,
) = {
  // ── Resolve authors --
  let authors = parse-authors(author)
  let author-names = authors.map(author-name)
  let header-surnames = authors-header(authors)

  // ── Resolve date --
  let resolved-date = resolve-date(date)

  // ── Configure metadata --
  set document(
    title: title,
    date: resolved-date.value,
    author: author-names.filter(name => type(name) == str),
  )

  // ── Configure page --
  set page(
    paper: paper-size,
    header: context {
      align(
        right + horizon,
        {
          if header-surnames != none {
            header-surnames
            h(0.5em)
          }
          counter(page).display()
        },
      )
    },
    header-ascent: 0%,
    margin: 1in,
  )

  // ── Configure paragraphs --
  set par(
    first-line-indent: (
      amount: 0.5in,
      all: true,
    ),
    justify: false,
    leading: font-size * line-height-ratio,
    spacing: font-size * line-height-ratio,
  )

  // ── Configure text --
  set text(
    font: font-face,
    size: font-size,
  )

  // ── Configure headings --
  set heading(
    numbering: none,
  )
  show heading: it => {
    let (weight, style) = if it.level == 1 {
      ("bold", "normal")
    } else if it.level == 2 {
      ("bold", "italic")
    } else {
      ("regular", "italic")
    }
    block(
      above: font-size + font-size * line-height-ratio,
      below: font-size * line-height-ratio,
      text(
        size: font-size,
        weight: weight,
        style: style,
        it.body,
      ),
    )
  }

  // ── Configure block quotes --
  set quote(block: true)
  show quote: set pad(left: 0.5in)
  show quote: set block(spacing: 2em)

  // -- Configure figures --
  show figure: set block(spacing: 1em)
  show figure: set par(
    first-line-indent: 0in,
    leading: 1em,
  )

  // ── Configure tables ──
  show figure.where(kind: table): it => {
    set table(
      stroke: none,
      align: center,
      row-gutter: 1em,
    )
    if it.caption != none {
      (
        "Table "
          + it.counter.display(it.numbering)
          + ". "
          + it.caption.body
      )
    }
    it.body
  }

  // ── Configure images --
  show figure.where(kind: image): it => {
    it.body
    if it.caption != none {
      align(
        center,
        "Fig. "
          + it.counter.display(it.numbering)
          + ". "
          + it.caption.body,
      )
    }
  }

  // ── Configure bibliography --
  set bibliography(style: "mla", title: "Works Cited")
  show bibliography: it => {
    pagebreak(weak: true)
    show heading: it => block(
      above: font-size + font-size * line-height-ratio,
      below: font-size + font-size * line-height-ratio,
      width: 100%,
      align(center, text(
        size: font-size,
        weight: "regular",
        it.body,
      )),
    )
    show bibliography: set par(
      first-line-indent: 0in,
      hanging-indent: 0.5in,
    )
    it
  }

  // ── Report information --
  block(below: font-size + font-size * line-height-ratio, {
    for name in author-names {
      par(first-line-indent: 0em, name)
    }
    if professor != none {
      par(first-line-indent: 0em, professor)
    }
    if course != none {
      par(first-line-indent: 0em, course)
    }
    if resolved-date.value != none {
      par(first-line-indent: 0em, resolved-date.value.display(
        resolved-date.format,
      ))
    }
  })

  // -- Report title --
  if title != none {
    block(
      below: font-size + font-size * line-height-ratio,
      width: 100%,
      align(center, title),
    )
  }

  // -- Report body --
  body
}

