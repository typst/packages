#import "core.typ": citation-tally-of

#let label-of(elem) = if elem.has("label") { str(elem.label) } else { none }

#let paged() = if "target" in dictionary(std) { target() == "paged" } else { true }

#let figure-kind(fig) = {
  let kind = fig.kind
  if kind == table { return "table" }
  if kind == raw { return "listing" }
  if type(kind) == str { return kind }
  "figure"
}

#let references() = {
  let labels = (:)
  let order = ()
  for elem in query(selector(std.ref).or(link)) {
    let target = if elem.func() == std.ref {
      str(elem.target)
    } else if type(elem.dest) == label {
      str(elem.dest)
    } else {
      none
    }
    if target == none { continue }

    labels.insert(target, true)
    order.push(target)
  }
  (labels: labels, order: order)
}

// everything Typst will let you write `@label` for
#let _queried = {
  selector(figure)
    .or(math.equation)
    .or(heading)
    .or(std.footnote)
    .or(std.image)
    .or(std.table)
}

#let _group-of(elem) = {
  let func = elem.func()
  if func == figure {
    let kind = figure-kind(elem)
    (if kind == "table" { "table" } else { "figure" }, kind)
  } else if func == math.equation {
    ("equation", "equation")
  } else if func == heading {
    ("heading", "heading")
  } else {
    ("footnote", "footnote")
  }
}

#let collected() = {
  let elements = ()
  let images = ()
  let tables = ()
  let is-paged = paged()
  let labels = (:)

  for (i, elem) in query(_queried).enumerate() {
    let loc = if is-paged { elem.location() } else { none }
    let pg = if loc == none { none } else { loc.page() }
    let pg-label = if pg == none { none } else {
      let key = str(pg)
      if key not in labels {
        let scheme = loc.page-numbering()
        labels.insert(
          key,
          if scheme == none { str(pg) } else { numbering(scheme, ..counter(page).at(loc)) },
        )
      }
      labels.at(key)
    }

    let common = (
      order: i,
      target: label-of(elem),
      page: pg,
      page-label: pg-label,
      location: loc,
      element: elem,
    )

    let func = elem.func()
    if func == std.image {
      // the file it came from is what sends an author to the right line, and
      // an image assembled out of bytes has none
      let src = elem.at("source", default: none)
      images.push(common + (
        noun: "image",
        source: if type(src) == str { src } else { none },
      ))
    } else if func == std.table {
      tables.push(common + (noun: "table"))
    } else {
      let (group, noun) = _group-of(elem)
      elements.push(common + (
        group: group,
        noun: noun,
        // (only a block equation can carry a number... and only a numbered can be
        // referenced)
        numbered: elem.numbering != none and (func != math.equation or elem.block),
      ))
    }
  }

  (elements: elements, images: images, tables: tables, count: elements.len() + images.len() + tables.len())
}

#let _caption-bodies(elements) = {
  elements
    .filter(e => e.group in ("figure", "table"))
    .map(e => e.element.caption)
    .filter(c => c != none)
    .map(c => c.body)
}

/// bib keys
#let cited-keys(elements) = {
  let cited = (:)
  for c in query(std.cite) {
    let key = str(c.key)
    cited.insert(key, cited.at(key, default: 0) + 1)
  }

  let in-captions = (:)
  for body in _caption-bodies(elements) {
    for (key, n) in citation-tally-of(body) {
      in-captions.insert(key, in-captions.at(key, default: 0) + n)
    }
  }

  let out = (:)
  for (key, total) in cited {
    if total > in-captions.at(key, default: 0) { out.insert(key, true) }
  }
  out
}

#let bibliographies() = query(std.bibliography)

#let prints-full-bibliography(bibs) = bibs.any(b => b.full == true)

#let bibliography-sources(bibs) = {
  bibs.map(b => b.sources).flatten().filter(s => type(s) == str).dedup()
}

#let label-exists(name) = query(label(name)).len() > 0

/// values of our own metadata markers
#let _markers(name, key) = {
  query(label(name))
    .filter(m => m.func() == metadata and type(m.value) == dictionary and key in m.value)
    .map(m => m.value)
}

/// what the author asked to keep quiet about, as (target, reason) pairs
#let ignores() = _markers("sanity-ignore", "target")

/// configuration left behind by the show rule, if the document uses one
#let stored-config() = {
  let markers = _markers("sanity-config", "checks")
  if markers.len() == 0 { none } else { markers.first() }
}
