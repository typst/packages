/// Read-only recursive scans over content. Used by the tokenizer to decide
/// whether a piece of content must be unwrapped (it contains division
/// markers) and by the planner to detect page-breaking/fr-height elements.

#import "markers.typ": marker_value

/// The internal `sequence` and `styled` element functions.
#let SEQUENCE_FUNC = [#none#none].func()
#let STYLED_FUNC = {
  set text(fill: red)
  [x]
}.func()

/// Whether `c` is a `pagebreak()` or `colbreak()` element.
#let is_break(c) = {
  type(c) == content and (c.func() == pagebreak or c.func() == colbreak)
}

/// Extract the explicitly-set height of elements that can carry one
/// (including examy height hints). Returns `none` if no height is set.
#let extract_height(c) = {
  if type(c) != content { return none }
  let f = c.func()
  if f == v { return c.at("amount", default: none) }
  if f == box or f == block or f == image { return c.at("height", default: none) }
  let m = marker_value(c)
  if m != none and m.kind == "height" { return m.height }
  none
}

#let EMPTY_SCAN = (has_marker: false, has_break: false, fr: none, marker_names: ())

#let _merge_scans(a, b) = (
  has_marker: a.has_marker or b.has_marker,
  has_break: a.has_break or b.has_break,
  fr: if a.fr == none { b.fr } else if b.fr == none { a.fr } else { a.fr + b.fr },
  marker_names: a.marker_names + b.marker_names,
)

/// Recursively scan `c` (content, array, or anything else) and report:
/// - `has_marker`: a division begin/end marker occurs somewhere inside
/// - `has_break`: a pagebreak/colbreak occurs somewhere inside
/// - `fr`: the summed `fraction` heights of children (heights inside
///   explicitly-sized containers do not propagate past their container)
/// - `marker_names`: constructor names of found markers (for diagnostics)
#let scan(c) = {
  if type(c) == array {
    return c.fold(EMPTY_SCAN, (acc, x) => _merge_scans(acc, scan(x)))
  }
  if type(c) != content { return EMPTY_SCAN }

  let m = marker_value(c)
  if m != none {
    if m.kind == "begin" {
      return EMPTY_SCAN + (has_marker: true, marker_names: (m.fields.name,))
    }
    if m.kind == "end" {
      return EMPTY_SCAN + (has_marker: true)
    }
    if m.kind == "height" {
      let h = m.height
      return EMPTY_SCAN + (fr: if type(h) == fraction { h } else { none })
    }
    return EMPTY_SCAN
  }
  if is_break(c) { return EMPTY_SCAN + (has_break: true) }

  // Scan all content-valued fields (children, child, body, caption, ...).
  let inner = EMPTY_SCAN
  for (name, value) in c.fields() {
    if type(value) == content or type(value) == array {
      inner = _merge_scans(inner, scan(value))
    }
  }

  let h = extract_height(c)
  if h != none and h != auto {
    // Explicitly sized: inner fr heights resolve inside this container and
    // must not propagate; markers/breaks inside are still reported.
    return (
      has_marker: inner.has_marker,
      has_break: inner.has_break,
      fr: if type(h) == fraction { h } else { none },
      marker_names: inner.marker_names,
    )
  }
  inner
}

/// Element functions whose content participates in inline (paragraph)
/// layout. Used to decide whether a gutter label can ride the first line.
#let _INLINE_FUNCS = (
  text,
  box,
  h,
  linebreak,
  strong,
  emph,
  link,
  ref,
  sub,
  super,
  underline,
  overline,
  strike,
  highlight,
  smallcaps,
  footnote,
)

/// Tri-state: does `c` *begin* with inline-level content?
/// - `true`: the first visible leaf is inline (text, an inline box, ...)
/// - `false`: it is block-level (a block, enum, figure, ...), a parbreak,
///   or something unknown (unknown defaults to block-level — the safe case)
/// - `none`: `c` is invisible/transparent (spaces, metadata); keep looking
#let starts_inline(c) = {
  if type(c) == str {
    return if c.trim() == "" { none } else { true }
  }
  if type(c) != content { return true }
  let f = c.func()
  if f == parbreak { return false }
  if ([ ].func(), metadata).contains(f) { return none }
  if f == SEQUENCE_FUNC {
    for child in c.children {
      let r = starts_inline(child)
      if r != none { return r }
    }
    return none
  }
  if f == STYLED_FUNC { return starts_inline(c.at("child")) }
  // Equations, raw, and quotes are inline unless their `block` flag is set.
  if (math.equation, raw, quote).contains(f) {
    return not c.at("block", default: false)
  }
  // A box with an explicit height (e.g. a fixed-height answer box) fills its
  // line well past the text baseline; a gutter label must not ride that
  // baseline. Only content-sized boxes count as text-like.
  if f == box {
    return c.at("height", default: auto) == auto
  }
  if _INLINE_FUNCS.contains(f) { return true }
  false
}

/// Strip leading space/parbreak elements from content (looking through
/// sequences and styled wrappers). Used so a division body written on its
/// own markup line does not render a visible space after an inline gutter
/// label.
#let trim_leading_space(c) = {
  if type(c) != content { return c }
  let f = c.func()
  if ([ ].func(), parbreak().func()).contains(f) { return none }
  if f == SEQUENCE_FUNC {
    let kids = c.children
    let i = 0
    while i < kids.len() {
      let trimmed = trim_leading_space(kids.at(i))
      if trimmed == none {
        i += 1
      } else if trimmed != kids.at(i) {
        return (trimmed, ..kids.slice(i + 1)).join()
      } else {
        break
      }
    }
    return kids.slice(i).join()
  }
  if f == STYLED_FUNC {
    let trimmed = trim_leading_space(c.at("child"))
    if trimmed == none { return none }
    return STYLED_FUNC(trimmed, c.at("styles"))
  }
  c
}

/// Whether content consists only of whitespace (spaces, parbreaks, metadata).
#let is_whitespace_content(it) = {
  if it == none { return true }
  if type(it) == str { return it.trim() == "" }
  if type(it) != content { return false }
  if ([ ].func(), parbreak().func(), metadata).contains(it.func()) {
    return true
  }
  if it.has("text") { return it.at("text").trim() == "" }
  if it.has("children") {
    return it.at("children").all(is_whitespace_content)
  }
  false
}
