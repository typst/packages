// Extract readable source text without realizing contextual content. Reusing a
// body in an outline can otherwise register nested notes or update counters twice.
#let _deixis-summary-text(body) = {
  if body == none { return "" }
  if type(body) == str { return body }
  if type(body) != content { return "" }
  let kind = body.func()
  let fields = body.fields()
  if kind in (text, raw) { return fields.at("text", default: "") }
  if kind in (linebreak, parbreak) or repr(kind) == "space" { return " " }
  if "children" in fields {
    return fields.children.map(_deixis-summary-text).join()
  }
  // Content wrappers expose body/child; metadata payloads, state updates, and
  // opaque context/layout functions are deliberately never evaluated or visited.
  if "body" in fields { return _deixis-summary-text(fields.body) }
  if "child" in fields { return _deixis-summary-text(fields.child) }
  ""
}

#let _deixis-note-summary(body) = {
  let plain = _deixis-summary-text(body).replace(regex("\\s+"), " ").trim()
  if plain == "" { return text(fill: luma(150), style: "italic", size: 0.9em)[No static summary] }
  let characters = plain.clusters()
  if characters.len() > 160 { plain = characters.slice(0, 157).join().trim() + "…" }
  text(plain)
}
