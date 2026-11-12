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
#import "scan.typ": SEQUENCE_FUNC, STYLED_FUNC, ends_par, is_multi_par, is_whitespace_content
#import "elements/solution.typ": solution as solution_element

/// The `solution` element's elembic id, to recognize its instances by.
/// Matching on the id rather than the element's name avoids colliding with a
/// same-named element from another package.
#let _SOLUTION_EID = e.data(solution_element).eid

/// The internal `context` element function, which `context` expressions and
/// elembic's `e.get` produce.
#let _CONTEXT_FUNC = (context none).func()

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

/// What a solution shows on the exam in its place: its `otherwise`, or `none`.
/// A solution with one is, to the exam, that content: visible, and in the
/// flow, where the answer key draws the solution over it (see `solution`).
#let _otherwise(c) = e.fields(c).at("otherwise", default: none)

/// Pass 1: what `c` contributes to the paragraph flow, as an array of events
/// in document order: `"solution"`, `"break"` (a paragraph boundary),
/// `"block"` (a block-level element, always between two breaks), `"context"`
/// (a `context` expression, or `e.get`, which may or may not show anything),
/// or `"text"` (any other visible content). `styled` and `sequence` are
/// looked through; everything else is opaque, so a solution nested inside it
/// (a table cell, `strong`, ...) is not seen. Exported so that a caller
/// needing both `widen_par_solutions` and `exam_content` walks the body only
/// once.
///
/// With `split`, a solution of several paragraphs is a paragraph of its own
/// even where it is written inline (`*Proof:*` and then `#solution[..]` on
/// the next line), so it is widened into a block like one set off by blank
/// lines. `answer-box` asks for this where its solutions take no height: an
/// inline solution is then highlighted line by line, which would leave a gap
/// between each of its lines.
/// It also makes a solution with an `otherwise` the content shown in its place
/// (see `solution`), visible on the exam and drawn over on the key, rather
/// than a solution: elsewhere, the key replaces it with the solution.
#let par_events(c, split: false) = {
  // Only ever at the top: a body given as a string rather than as content.
  if type(c) == str { return if c.trim() == "" { () } else { ("text",) } }
  if type(c) != content { return () }
  if _is_solution(c) {
    let otherwise = _otherwise(c)
    if split and otherwise != none { return if is_multi_par(otherwise) { ("break", "block", "break") } else { ("text",) } }
    let body = e.fields(c).at("body", default: none)
    return if split and is_multi_par(body) { ("break", "solution", "break") } else { ("solution",) }
  }
  if ends_par(c) {
    return if c.func() == parbreak { ("break",) } else { ("break", "block", "break") }
  }
  let f = c.func()
  if f == STYLED_FUNC { return par_events(c.child, split: split) }
  if f == SEQUENCE_FUNC { return c.children.map(x => par_events(x, split: split)).flatten() }
  if f == _CONTEXT_FUNC { return ("context",) }
  if is_whitespace_content(c) { return () }
  ("text",)
}

/// For each solution event, in order, whether it is the only visible content
/// of its paragraph. A `context` event counts as visible: mistaking it for
/// visible content merely leaves a solution shrink-wrapped.
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
/// is left unset. `last` is its `_last`, and `then` its `_then`.
#let _widen(c, last, then) = {
  show: e.set_(solution_element, _fill-width: true, _last: last, _then: then)
  c
}

/// A solution drawn after the first of its run, by that first one (see
/// `widen_par_solutions`): in the flow, filling the width as it would
/// have standing alone in its paragraph.
#let _in_run(c) = {
  show: e.set_(solution_element, _no-height: false, _fill-width: true, _last: false, _then: none)
  c
}

/// Pass 2: rebuild `c`, widening the solutions whose flag is set. Walks the
/// tree exactly as `par_events` does; `i` is the index of the next solution.
/// `flags` holds, for each solution, whether to widen it, whether it is last,
/// and what it draws after itself: `none`, the content of the rest of its
/// run, or `"drop"` when the first of its run draws it instead. `split` is
/// as `par_events` was given it. Returns the new content and the next index.
#let _rewrite(c, flags, i, split) = {
  if type(c) != content { return (c, i) }
  if split and _is_solution(c) and _otherwise(c) != none { return (c, i) }
  if _is_solution(c) {
    let (wide, last, then) = flags.at(i)
    let new = if then == "drop" { [] } else if wide { _widen(c, last, then) } else { c }
    return (new, i + 1)
  }
  if ends_par(c) { return (c, i) }
  let f = c.func()
  if f == STYLED_FUNC {
    let (child, next) = _rewrite(c.child, flags, i, split)
    return (STYLED_FUNC(child, c.styles), next)
  }
  if f == SEQUENCE_FUNC {
    let out = ()
    for child in c.children {
      let (new, next) = _rewrite(child, flags, i, split)
      out.push(new)
      i = next
    }
    return (out.join(), i)
  }
  (c, i)
}

/// The solutions in `c`, in the order `par_events` and `_rewrite` meet them.
#let _collect(c) = {
  if type(c) != content { return () }
  if _is_solution(c) { return if _otherwise(c) == none { (c,) } else { () } }
  if ends_par(c) { return () }
  let f = c.func()
  if f == STYLED_FUNC { return _collect(c.child) }
  if f == SEQUENCE_FUNC { return c.children.map(_collect).flatten() }
  ()
}

/// Whether an event is something the exam may show.
#let _is_visible(ev) = ev in ("text", "block", "context")

/// Widen every `solution` in `body` that stands alone in its paragraph.
/// `events` is `par_events(body)`, if already at hand. Returns the new body.
///
/// Each widened solution is also told whether it is last: visible content
/// before it, and none after. That matters to a solution that takes no
/// height (see `answer-box`), which is placed out of the flow. Placed between
/// two paragraphs, it lands below the spacing the flow puts between them;
/// placed after the last one, it gets no spacing, as the flow trims spacing
/// at its end, so it has to add that spacing itself.
///
/// With `group`, as where solutions take no height, a run of solutions alone
/// in their paragraphs with nothing visible between them is drawn as one.
/// Each would be placed out of the flow where its block begins, and as none
/// takes any height, they would all begin at the same place, each drawn over
/// the one before. So the first draws them all, stacked as the flow would
/// stack them, and the others draw nothing. (`answer-box`'s `solution:`
/// argument is a solution at the end of its body, and so joins a run there
/// as any other does.) A solution moved into the first of its run loses any
/// set rule between the two.
#let widen_par_solutions(body, events: auto, group: false) = {
  if events == auto { events = par_events(body, split: group) }
  let alone = _alone_flags(events)
  if not alone.any(x => x) { return body }
  // A solution is last when it comes after the last visible event.
  let from_end = events.rev().position(_is_visible)
  let solution_at = events.enumerate().filter(((_, ev)) => ev == "solution").map(((i, _)) => i)
  let lasts = solution_at.map(i => from_end != none and i > events.len() - 1 - from_end)
  let thens = (none,) * alone.len()
  if group {
    // The runs, as solution indices, and whether one ends the body.
    let runs = ()
    let open = false
    let k = 0
    for ev in events {
      if ev == "break" { continue }
      if ev == "solution" {
        if alone.at(k) { if open { runs.last().push(k) } else { runs.push((k,)) } }
        open = alone.at(k)
        k += 1
      } else {
        open = false
      }
    }
    let solutions = _collect(body)
    for run in runs {
      let rest = run.slice(1).map(j => _in_run(solutions.at(j)))
      if rest.len() == 0 { continue }
      thens.at(run.first()) = rest.map(x => parbreak() + x).join()
      for j in run.slice(1) { thens.at(j) = "drop" }
    }
  }
  _rewrite(body, alone.zip(lasts, thens), 0, group).first()
}

/// What `body` shows on the exam itself, that is, with its solutions, which
/// appear only on the answer key, left out: `"yes"` when it holds visible
/// content, `"no"` when it holds only whitespace and solutions, and
/// `"maybe"` when all it might show is a `context` expression (an `e.get`
/// that shows a solution only on the key, say), which cannot be told from
/// the source: `answer-box` lays it out to decide. An answer box sizes
/// itself by this — one holding, say, a
/// prompt or a list of choices grows to fit them, while one that is blank on
/// the exam (empty, or holding only its solutions) keeps a fixed height for
/// the student to write in, the same on the exam and the key. A solution
/// inside an opaque element (`align`, `strong`, ...) is not seen, so it
/// counts as `"yes"`: the box fits it, as does one with an `otherwise`, which
/// the exam shows. `events` is `par_events(body, split: true)`, if already at
/// hand.
#let exam_content(body, events: auto) = {
  if events == auto { events = par_events(body, split: true) }
  if events.any(ev => ev == "text" or ev == "block") { "yes" } else if "context" in events { "maybe" } else { "no" }
}
