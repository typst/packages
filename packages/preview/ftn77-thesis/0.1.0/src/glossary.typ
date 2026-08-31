#import "@preview/glossy:0.9.2" as glossy
#import "../style.typ" as style

#let abbr = "abbr"
#let term = "term"

// #let _entries = state("glsentries", (:))
#let _counts = state("glscount", (:))

#let init-glossary(
  entries,
  term-links: false,
  body,
) = context {
  show: glossy.init-glossary.with(entries, term-links: term-links)

  assert(entries != none)

  let counts = entries
    .values()
    .fold(
      (:),
      (counts, item) => {
        let group = item.at("group", default: "")
        counts.insert(group, counts.at(group, default: 0) + 1)
        counts
      },
    )

  _counts.update(counts)

  body
}


#let glossary(
  body: none,
  show-all: false,
  style: style,
  abbr-title: [Списак коришћених скраћеница],
  terms-title: [Списак коришћених појмова],
) = context {
  let counts = _counts.final()
  let has_abbr = counts.at(abbr, default: 0) > 0
  let has_terms = counts.at(term, default: 0) > 0
  let has_both = counts.at("", default: 0) > 0

  if has_abbr or has_both {
    let groups = (abbr,) * int(has_abbr) + ("",) * int(has_both)

    glossy.glossary(
      title: abbr-title,
      groups: groups,
      theme: style.abbr,
      show-all: show-all,
    )
  }

  if has_terms or has_both {
    let groups = (term,) * int(has_terms) + ("",) * int(has_both)

    glossy.glossary(
      title: terms-title,
      groups: groups,
      theme: style.terms,
      show-all: show-all,
    )
  }
}
