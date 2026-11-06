#import "core.typ": finding

#let id = "uncited-entry"

#let _bibtex-escape = regex("\\\\[\\{\\}%]")

#let _bibtex-token = regex(
  "@(\\w+)\\s*([\\{\\(])\\s*(?:([^,\\s\\{\\}\\(\\)]+)\\s*,)?|[\\{\\}%\\n]",
)

#let _bibtex-other = ("string", "comment", "preamble", "xdata")
#let _bibtex-inherit = regex("(?i)\\b(?:crossref|xdata)\\s*=\\s*[\\{\"]([^\\}\"]*)[\\}\"]")
#let _hayagriva-key = regex("(?m)^[^\\s#][^:]*:")
#let _comment = regex("(?m)[%#].*$")

// enough of a value to recognise it
#let _excerpt(text) = {
  let head = text.trim().split("\n").first()
  let shown = head.clusters()
  if shown.len() > 60 { repr(shown.slice(0, 60).join()) + " .." } else { repr(head) }
}

/// keys of the entries BibTeX data declares (or none when the text holds no
/// BibTeX at all)
#let _bibtex-keys(text) = {
  let keys = ()
  let depth = 0
  let commented = false
  let is-bibtex = false

  for m in text.matches(_bibtex-token) {
    let (kind, opener, key) = (m.captures.at(0), m.captures.at(1), m.captures.at(2))

    if kind == none {
      if m.text == "\n" {
        commented = false
      } else if not commented {
        if m.text == "%" {
          commented = depth == 0
        } else if m.text == "{" {
          depth += 1
        } else if depth > 0 {
          depth -= 1
        }
      }
      continue
    }

    if commented {
      if m.text.contains("\n") { commented = false }
      continue
    }

    let top = depth == 0
    if opener == "{" { depth += 1 }
    if not top { continue }

    let other = lower(kind) in _bibtex-other
    is-bibtex = is-bibtex or other or key != none
    if key != none and not other { keys.push(key) }
  }

  if is-bibtex { keys } else { none }
}

#let _bibtex-inherited(text) = {
  let out = ()
  for m in text.matches(_bibtex-inherit) {
    out += m.captures.first().split(",").map(k => k.trim())
  }
  out
}

#let _keys-of(source) = {
  let text = if type(source) == bytes { str(source) } else { source }
  if text.trim() == "" { return () }

  let bib = text.replace(_bibtex-escape, "")
  let keys = _bibtex-keys(bib)
  if keys != none {
    let inherited = _bibtex-inherited(bib)
    return keys.filter(key => key not in inherited)
  }

  // Hayagriva
  if text.contains(_hayagriva-key) {
    let data = yaml(bytes(text))
    return if type(data) == dictionary { data.keys() } else { () }
  }

  // neither format found anything
  assert(
    text.replace(_comment, "").trim() == "",
    message: "sanity: bibliography takes what read() returns for a .bib or .yml file, not "
      + _excerpt(text),
  )
  ()
}

#let entry-keys(sources) = {
  if sources == none { return none }

  let each = if type(sources) == array { sources } else { (sources,) }
  if each.len() == 0 { return none }

  // deduplicated as they arrive, since the order they arrive in is the order
  // the report follows
  let seen = (:)
  let keys = ()
  for source in each {
    for key in _keys-of(source) {
      if key in seen { continue }
      seen.insert(key, true)
      keys.push(key)
    }
  }
  keys
}

#let run(keys, cited, cfg) = {
  if keys == none or not cfg.checks.at(id, default: false) { return () }

  keys
    .filter(key => key not in cited)
    .map(key => finding(
      id,
      cfg.severities.at(id),
      "bibliography entry \"" + key + "\" is never cited",
      target: key,
    ))
}

#let not-checked-id = "bibliography-not-checked"

/// a package cannot open the document .bib file, so without the data
/// `uncited-entry` cannot run
#let not-checked(sources, cfg) = {
  if not cfg.checks.at(not-checked-id, default: false) { return () }

  let read-calls = sources.map(s => "read(\"" + s + "\")")
  let argument = if read-calls.len() == 0 {
    "read(..)"
  } else if read-calls.len() == 1 {
    read-calls.first()
  } else {
    "(" + read-calls.join(", ") + ")"
  }

  (finding(
    not-checked-id,
    cfg.severities.at(not-checked-id),
    "bibliography entries are not checked; add bibliography: "
      + argument
      + " to the show rule, or run sanity from the command line",
  ),)
}
