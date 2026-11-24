// Abbreviations and glossary entries, used like references: `@ai`.
//
// The first use of an abbreviation prints "Artificial Intelligence (AI)",
// later uses print "AI". The lists at the end of the document give all pages
// on which an entry was used (glossaries-style back references).
#import "metrics.typ" as m
#import "state.typ": *

#let abbr-kind = "kao-abbr"
#let gloss-kind = "kao-gloss"

#let pluralize(x) = if type(x) == str { x + "s" } else { [#x] + [s] }

#let normalize-abbreviation(key, value) = {
  let (short, long) = if type(value) == array { (value.at(0), value.at(1)) } else { (value.short, value.long) }
  let get(name, default) = if type(value) == dictionary { value.at(name, default: default) } else { default }
  (
    kind: abbr-kind,
    key: key,
    short: short,
    long: long,
    short-plural: get("short-plural", pluralize(short)),
    long-plural: get("long-plural", pluralize(long)),
    description: get("description", none),
    sort: get("sort", if type(short) == str { short } else { key }),
  )
}

#let normalize-glossary(key, value) = (
  kind: gloss-kind,
  key: key,
  short: value.name,
  long: value.name,
  short-plural: value.at("plural", default: pluralize(value.name)),
  long-plural: value.at("plural", default: pluralize(value.name)),
  description: value.at("description", default: none),
  sort: value.at("sort", default: if type(value.name) == str { value.name } else { key }),
)

// All entries: key -> (kind, key, short, long, short-plural, long-plural, description, sort)
// The entries are passed around as values (not via state), so that the
// anchors and `@key` references exist from the first layout iteration on.
#let make-entries(abbreviations, glossary) = {
  let all = (:)
  for (key, value) in abbreviations { all.insert(key, normalize-abbreviation(key, value)) }
  for (key, value) in glossary { all.insert(key, normalize-glossary(key, value)) }
  all
}

#let use-marker(key) = [#metadata(key)<kao-entry-use>]

// form: "auto" (first use long, then short), "short", "long", "full"
#let show-entry(e, form: "auto", plural: false) = context {
  let key = e.key
  let uses = counter("kao-entry-" + key)
  let first = uses.get().first() == 0
  let short = if plural { e.short-plural } else { e.short }
  let long = if plural { e.long-plural } else { e.long }
  let form = if form == "auto" {
    if e.kind == abbr-kind and first { "full" } else { "short" }
  } else { form }
  let target = label(key)
  if form == "short" {
    link(target, short)
  } else if form == "long" {
    link(target, long)
  } else {
    [#long (#link(target, short))]
  }
  uses.step()
  use-marker(key)
}

// Explicit forms (like the acronym/glossaries packages). They are references
// with a supplement, i.e. `#acl("ai")` is the same as `@ai[long]`.
#let acs(key) = ref(label(key), supplement: [short])
#let acl(key) = ref(label(key), supplement: [long])
#let acf(key) = ref(label(key), supplement: [full])
#let acp(key) = ref(label(key), supplement: [pl])
#let acsp(key) = ref(label(key), supplement: [short-pl])
#let aclp(key) = ref(label(key), supplement: [long-pl])

// `@key` references to entries.
#let reference-rules(entries: (:), ref-color: none, body) = {
  show ref: it => {
    let key = str(it.target)
    let e = entries.at(key, default: none)
    if e == none {
      // ordinary cross-reference (citations are coloured by the citation rules)
      if ref-color == none or it.element == none { return it }
      return text(fill: ref-color, it)
    }
    // `@ai[pl]` gives the plural, `@ai[long]`, `@ai[short]`, `@ai[full]` the forms
    let supplement = if it.supplement == auto or it.supplement == none { "" } else {
      if it.supplement.has("text") { it.supplement.text } else { "" }
    }
    let plural = supplement in ("pl", "s", "short-pl", "long-pl")
    let form = supplement.trim("-pl", at: end)
    if form not in ("long", "short", "full") { form = "auto" }
    show-entry(e, form: form, plural: plural)
  }
  show figure.where(kind: abbr-kind): it => align(left, it.body)
  show figure.where(kind: gloss-kind): it => align(left, it.body)
  body
}

// "iii, iv, ix, 3–15, 17" from a list of locations.
#let page-list(locations) = {
  let seen = ()
  let items = ()
  for loc in locations {
    let p = loc.page()
    if p in seen { continue }
    seen.push(p)
    let style = loc.page-numbering()
    let n = counter(page).at(loc).first()
    items.push((page: p, n: n, style: style, label: page-label(loc), loc: loc))
  }
  // compress runs of at least three consecutive arabic page numbers
  let out = ()
  let i = 0
  while i < items.len() {
    let j = i
    while (
      j + 1 < items.len()
        and items.at(j + 1).n == items.at(j).n + 1
        and items.at(j + 1).style == items.at(i).style
        and items.at(i).style == "1"
    ) { j += 1 }
    if j - i >= 2 {
      out.push([#link(items.at(i).loc, items.at(i).label)–#link(items.at(j).loc, items.at(j).label)])
      i = j + 1
    } else {
      out.push(link(items.at(i).loc, items.at(i).label))
      i += 1
    }
  }
  out.join(", ")
}

// Prints the list of abbreviations or the glossary as in the reference
// dissertation: grouped by initial letter, bold term, long form, pages.
#let print-entries(entries, kind, grouped: true, only-used: true) = context {
  let all = entries.values().filter(e => e.kind == kind)
  let uses = query(<kao-entry-use>)
  let used = uses.map(u => u.value)
  let sort-key(e) = lower(if type(e.sort) == str { e.sort } else { e.key })
  let sorted = all.sorted(key: sort-key)
  let group = none
  set par(justify: false, hanging-indent: 13.2pt, leading: m.leading-for("normalsize"))
  for e in sorted {
    // like glossaries: entries that are never used are not listed, but their
    // anchors are kept so that references always resolve
    if only-used and e.key not in used {
      place(hide[#figure([], kind: kind, supplement: none, numbering: none, outlined: false)#label(e.key)])
      continue
    }
    let initial = upper(sort-key(e).first())
    if grouped and initial != group {
      if group != none { v(m.baselineskip.normalsize, weak: true) }
      group = initial
      block(above: 0pt, below: m.leading-for("normalsize"), sticky: true, strong(initial))
    }
    let pages = page-list(uses.filter(u => u.value == e.key).map(u => u.location()))
    let desc = if kind == abbr-kind { [#e.long.] } else if e.description != none { e.description } else { [] }
    let entry = block(width: 100%, spacing: m.leading-for("normalsize"), [#strong(e.short)#h(0.5em)#desc #pages])
    [#figure(entry, kind: kind, supplement: none, numbering: none, outlined: false)#label(e.key)]
  }
}

// Anchors for entries without printing them (when no list is wanted).
#let hidden-entries(entries) = {
  for e in entries.values() {
    place(hide[#figure([], kind: e.kind, supplement: none, numbering: none, outlined: false)#label(e.key)])
  }
}
