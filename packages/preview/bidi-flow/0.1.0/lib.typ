// Walk the content tree and return the first Hebrew/Arabic or Latin character,
// or `none` if none is found.  Stops as soon as a match is found.
#let _first-strong(body) = {
  if type(body) != content { return none }
  let f = body.func()
  if f == math.equation or f == raw { return none }
  if body.has("text") {
    let m = body.text.match(regex("[\p{Hebrew}\p{Arabic}\p{Latin}]"))
    if m != none { return m.text }
    return none
  }
  if body.has("children") {
    for child in body.children {
      let ch = _first-strong(child)
      if ch != none { return ch }
    }
    return none
  }
  if body.has("body") {
    let inner = body.fields().at("body")
    if type(inner) == content { return _first-strong(inner) }
  }
  // styled() wraps strong/emph/link/… in Typst 0.14 — uses "child" not "body"
  if body.has("child") {
    let inner = body.fields().at("child")
    if type(inner) == content { return _first-strong(inner) }
  }
  none
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Detect the text direction of a content block using the "first strong
/// character" rule (same heuristic used by most editors and the Unicode
/// Bidi Algorithm).  Returns the Typst `direction` value `rtl` or `ltr`.
///
/// - body (content): The content to inspect.
/// -> direction
#let detect-dir(body) = {
  let ch = _first-strong(body)
  if ch == none { return ltr }
  if ch.match(regex("[\p{Hebrew}\p{Arabic}]")) != none { rtl } else { ltr }
}

#let _first-cell-body(children) = {
  for c in children {
    if c.func() == table.cell {
      return c.body
    }
  }
  none
}

/// Invisible zero-width directional seeds.  Insert inline to nudge
/// the bidi shaping context without adding visible text.
///   Usage: price is 100 #r ILS
#let r = text(size: 0pt)[י]   // RTL seed
#let l = text(size: 0pt)[i]   // LTR seed

/// Inline direction spans for mixed-direction fragments.
///   #rl[מילה באמצע משפט אנגלי]
///   #lr[word in the middle of a Hebrew sentence]
#let rl(body) = [#set text(dir: rtl); #body]
#let lr(body) = [#set text(dir: ltr); #body]

/// Scope-level direction override.  Use with `#show:` to force a direction
/// for the rest of the current scope.
///   #show: setrl
///   #show: setlr
#let setrl = body => [#set text(dir: rtl); #body]
#let setlr = body => [#set text(dir: ltr); #body]
///
/// Document-level show rule.  Apply once at the top of your entry file:
///   #show: bidi-flow
///
/// Automatically sets `text.dir` for every `par`, `heading`, `list`, `enum`,
/// and `table` based on the first strong (Hebrew/Arabic vs Latin) character.
/// RTL blocks get `dir: rtl`; everything else keeps Typst's default (`auto`).
#let bidi-flow = body => {
  show par: it => if detect-dir(it.body) == rtl [
    #set text(dir: rtl)
    #it
  ] else { it }

  show heading: it => if detect-dir(it.body) == rtl [
    #set text(dir: rtl)
    #it
  ] else { it }

  show list: it => if it.children.len() > 0 and detect-dir(it.children.at(0).body) == rtl [
    #set text(dir: rtl)
    #it
  ] else { it }

  show enum: it => if it.children.len() > 0 and detect-dir(it.children.at(0).body) == rtl [
    #set text(dir: rtl)
    #it
  ] else { it }

  show table: it => {
    let first-cell = _first-cell-body(it.children)
    if first-cell != none and detect-dir(first-cell) == rtl [
      #set text(dir: rtl)
      #it
    ] else {
      it
    }
  }

  body
}
