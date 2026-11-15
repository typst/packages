// Helpers shared by the thesis layout.

/// Marker placed where the appendix begins, so the character counter stops there.
#let appendix-marker = "ucph-lehmann-appendix-start"

/// Elements that do not count towards the character total. UCPH rules vary
/// between faculties; this follows the common rule that figures, tables,
/// equations, the reference list and the appendix are excluded, while
/// headings, footnotes and body text are counted.
#let _skipped = (figure, table, math.equation, bibliography, outline, metadata, raw)

/// Count characters (including spaces) in a piece of content.
/// Returns `(count, done)`; `done` is true once the appendix marker is reached.
#let _count(it) = {
  if it == none { return (0, false) }
  if type(it) == str { return (it.clusters().len(), false) }
  if type(it) != content { return (0, false) }

  let f = it.func()
  if f == metadata and it.value == appendix-marker { return (0, true) }
  if f in _skipped { return (0, false) }
  if f == [ ].func() { return (1, false) }       // space
  if f == text { return (it.text.clusters().len(), false) }
  if f == smartquote { return (1, false) }
  if f == linebreak { return (1, false) }

  if it.has("children") {
    let n = 0
    for child in it.children {
      let (c, done) = _count(child)
      n += c
      if done { return (n, true) }
    }
    return (n, false)
  }
  let n = 0
  for key in ("body", "child", "title") {
    if it.has(key) {
      let (c, done) = _count(it.at(key))
      n += c
      if done { return (n, true) }
    }
  }
  (n, false)
}

/// Number of characters (including spaces) in the main text, stopping at the
/// appendix.
#let count-characters(body) = _count(body).first()

/// Accept a single value or an array, always return an array.
#let as-array(x) = if x == none { () } else if type(x) == array { x } else { (x,) }

/// People may be given as plain text or as `(name: .., id: ..)`.
#let person-name(p) = if type(p) == dictionary { p.name } else { p }
#let person-detail(p) = if type(p) == dictionary { p.at("id", default: none) } else { none }
