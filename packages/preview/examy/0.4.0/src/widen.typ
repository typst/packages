/// Make a `solution` that stands alone in a paragraph fill its container's
/// width instead of shrink-wrapping to its text. Used by `answer-box`, so
/// that `#answer-box[#solution[..]]` highlights the whole box while a
/// solution used mid-sentence ("we look at #solution[foo]") stays inline and
/// does not break up the line.
///
/// This works on the *authored* content, before realization. Deciding it
/// later is not possible: by the time a `show par` rule fires, the solutions
/// in that paragraph have already realized into boxes, so a set rule there is
/// inert — and a solution rendered at full width has by then been split into
/// a paragraph of its own, which makes paragraph membership useless as a
/// signal anyway.
///
/// A paragraph can run across `styled` and `sequence` nesting in either
/// direction (`Prompt. #set text(..) #solution[..]`, or
/// `#[#set text(..); #solution[..]] more text`), so the work is done in two
/// passes over the same tree: the first lists what each paragraph holds, in
/// document order; the second widens the solutions found to be alone.

#import "prelude.typ": *
#import "scan.typ": SEQUENCE_FUNC, STYLED_FUNC, is_whitespace_content
#import "elements/solution.typ": solution as solution_element

/// The `solution` element's elembic id, to recognize its instances by.
/// Matching on the id rather than the element's name avoids colliding with a
/// same-named element from another package.
#let _SOLUTION_EID = e.data(solution_element).eid

/// Whether `c` is a `solution` instance. Note that an element realizes to a
/// bare `sequence`, so it cannot be recognized by `func()`.
#let _is_solution(c) = {
  let d = e.data(c)
  (
    type(d) == dictionary
      and d.at("data-kind", default: none) == "element-instance"
      and d.at("eid", default: none) == _SOLUTION_EID
  )
}

/// Elements that are always block-level, and so end the paragraph before
/// them and start a fresh one after. Anything not listed counts as inline:
/// mistaking a block for inline content merely leaves a solution
/// shrink-wrapped, whereas the reverse widens a solution in the middle of a
/// sentence and breaks the line apart.
#let _BLOCK_FUNCS = (
  parbreak,
  block,
  table,
  grid,
  figure,
  list,
  enum,
  terms,
  heading,
  image,
  align,
  pad,
  stack,
  columns,
  colbreak,
  pagebreak,
  v,
  rect,
  square,
  circle,
  ellipse,
  polygon,
  line,
  outline,
  bibliography,
)

#let _ends_par(c) = {
  let f = c.func()
  if _BLOCK_FUNCS.contains(f) { return true }
  // Inline unless their `block` flag is set.
  if (math.equation, raw, quote).contains(f) { return c.at("block", default: false) }
  false
}

/// Pass 1: what `c` contributes to the paragraph flow, as an array of events
/// in document order: `"solution"`, `"break"` (a paragraph boundary), or
/// `"text"` (any other visible content). `styled` and `sequence` are looked
/// through; everything else is opaque, so a solution nested inside it (a
/// table cell, `strong`, ...) is not seen.
#let _events(c) = {
  if type(c) != content { return () }
  if _is_solution(c) { return ("solution",) }
  if _ends_par(c) { return ("break",) }
  let f = c.func()
  if f == STYLED_FUNC { return _events(c.child) }
  if f == SEQUENCE_FUNC { return c.children.map(_events).flatten() }
  if is_whitespace_content(c) { return () }
  ("text",)
}

/// For each solution event, in order, whether it is the only visible content
/// of its paragraph.
#let _alone_flags(events) = {
  let flags = ()
  let par = ()
  for ev in events + ("break",) {
    if ev != "break" {
      par.push(ev)
      continue
    }
    for p in par {
      if p == "solution" { flags.push(par.len() == 1) }
    }
    par = ()
  }
  flags
}

/// Ask a solution to fill the available width, via a set rule scoped to just
/// that solution. An explicit `width` — passed as an argument or set by a rule
/// at any scope — still wins, because `_fill-width` only applies when `width`
/// is left unset.
#let _widen(c) = {
  show: e.set_(solution_element, _fill-width: true)
  c
}

/// Pass 2: rebuild `c`, widening the solutions whose flag is set. Walks the
/// tree exactly as `_events` does; `i` is the index of the next solution.
/// Returns the new content and the next index.
#let _rewrite(c, flags, i) = {
  if type(c) != content { return (c, i) }
  if _is_solution(c) {
    return (if flags.at(i) { _widen(c) } else { c }, i + 1)
  }
  if _ends_par(c) { return (c, i) }
  let f = c.func()
  if f == STYLED_FUNC {
    let (child, next) = _rewrite(c.child, flags, i)
    return (STYLED_FUNC(child, c.styles), next)
  }
  if f == SEQUENCE_FUNC {
    let out = ()
    for child in c.children {
      let (new, next) = _rewrite(child, flags, i)
      out.push(new)
      i = next
    }
    return (out.join(), i)
  }
  (c, i)
}

/// Widen every `solution` in `body` that stands alone in its paragraph.
#let widen_par_solutions(body) = {
  let flags = _alone_flags(_events(body))
  if not flags.any(x => x) { return body }
  _rewrite(body, flags, 0).first()
}
