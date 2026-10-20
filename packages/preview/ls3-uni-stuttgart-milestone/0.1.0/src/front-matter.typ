// front-matter.typ
//
// Optional front-matter sections (abstract, abbreviations, notation) plus
// the table of contents.

#let _labels(language) = {
  if language == "german" {
    (
      contents: "Inhaltsverzeichnis",
      abstract: "Zusammenfassung",
      abbreviations: "Abkürzungsverzeichnis",
      notation: "Symbolverzeichnis",
    )
  } else {
    (
      contents: "Contents",
      abstract: "Abstract",
      abbreviations: "Abbreviations",
      notation: "Notation",
    )
  }
}

#let abstract-section(body, language: "english") = {
  let labels = _labels(language)
  heading(level: 1, numbering: none, outlined: true)[#labels.abstract]
  body
}

// Built-in abbreviation list renderer.
//
// The `abbr` package (https://typst.app/universe/package/abbr) keeps its data
// in global state under the fixed keys "abbr" (all defined entries) and
// "abbr-list" (the entries actually referenced). Reading those states by key
// lets the template render the list itself without depending on the package.
// It reproduces the package's own output with two changes. The sort is
// case-insensitive, so a lowercase short form such as "rMAE" lands in
// alphabetical order instead of after every uppercase entry. The default is a
// single column, which suits the short lists these reports carry.
#let _abbr-entries = state("abbr", (:))
#let _abbr-used = state("abbr-list", ())

#let _abbr-short(short) = {
  let val = if text.weight <= "medium" { 15% } else { 30% }
  set text(fill: black.lighten(val))
  show: strong
  short
}

#let abbreviations-list(columns: 1) = context {
  let used = _abbr-used.final()
  let entries = _abbr-entries.final().pairs()
    .filter(it => it.at(0) in used)
    .map(((key, entry)) => {
      entry.s = key
      entry
    })
    .sorted(key: it => lower(it.s))
  if entries.len() == 0 { return }

  let make-entry(e) = {
    let alt = if "alt" in e { [,~#e.alt] } else { none }
    (_abbr-short[#e.s #e.lbl], [#e.l#alt])
  }

  if columns == 2 {
    let n = int(entries.len() / 2)
    let last = if calc.odd(entries.len()) { entries.remove(n) }
    entries = entries.slice(0, n).zip(entries.slice(n)).flatten()
    if last != none { entries.push(last) }
  } else if columns != 1 {
    panic("abbreviations-list only supports 1 or 2 columns")
  }

  grid(
    columns: (auto, 1fr) * columns,
    inset: 5pt,
    ..for entry in entries { make-entry(entry) }
  )
}

#let abbreviations-section(body, language: "english") = {
  let labels = _labels(language)
  heading(level: 1, numbering: none, outlined: true)[#labels.abbreviations]
  if body == auto { abbreviations-list() } else { body }
}

#let notation-section(body, language: "english") = {
  let labels = _labels(language)
  heading(level: 1, numbering: none, outlined: true)[#labels.notation]
  body
}

#let toc(language: "english") = {
  let labels = _labels(language)
  heading(level: 1, numbering: none, outlined: false)[#labels.contents]

  // Override the global mittelblau link color so TOC entries render black.
  show link: set text(fill: black)

  show outline.entry.where(level: 1): it => {
    v(1.5em, weak: true)
    link(
      it.element.location(),
      strong[
        #it.prefix() #it.element.body
        #h(1fr)
        #it.page()
      ],
    )
  }

  show outline.entry.where(level: 2): it => {
    v(0.55em, weak: true)
    it
  }

  show outline.entry.where(level: 3): it => {
    v(0.35em, weak: true)
    it
  }

  outline(title: none)
}
