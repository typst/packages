// Speaker-note extraction for one physical incremental frame.
#import "../incremental/core.typ": status
#import "../incremental/command.typ": (
  is-command-on,
  is-temporal,
  replace-index,
  reveal-slots,
  slot-status,
)
#import "command.typ": is-note
#import "../grid/traversal.typ": fold-grid
#import "../incremental/pause.typ": has-pause, is-pause, pause-schedule
#import "../incremental/analysis.typ": max-step
#import "../shared.typ": typst-sequence

// Does this value hold a speaker note on any step at all?
//
// `notes-at` answers "which notes are visible on step N", which the frame loop
// needs, but running it per frame makes a deck without notes pay for a full
// content walk on every page. This predicate is the step-independent question,
// asked once per slide so the per-frame walks can be skipped entirely. It
// short-circuits and allocates nothing.
//
// Structure matters more than order here: a Mosaic temporal wrapper is itself a
// `metadata` element, so foreign metadata can only be rejected after the
// temporal check, exactly as in `notes-at` below.
#let has-note(value) = {
  if is-note(value) { return true }
  if is-command-on(value) { return has-note(value.body) }
  if type(value) == array { return value.any(has-note) }
  if type(value) == dictionary { return value.values().any(has-note) }
  if type(value) != content { return false }
  if value.func() == metadata {
    return is-temporal(value) and has-note(value.value)
  }
  value.fields().values().any(has-note)
}

// Every note the grid's fixed cell content holds, on any step. Fixed content
// lives on the grid node rather than in the id -> content map, so a slide's
// note check has to look in both places.
#let fixed-grid-has-note(node) = fold-grid(
  node,
  cell => cell.content != none and has-note(cell.content),
  (node, child) => child,
  (node, children) => children.any(value => value),
)

#let notes-at(value, step) = {
  let visit(value) = {
    if is-note(value) {
      return (value.value.body,)
    }
    if is-pause(value) {
      return ()
    }
    if is-command-on(value) {
      let state = status(value.range, value.before, value.after, step)
      if state == "visible" {
        return visit(value.body)
      }
      return ()
    }
    if type(value) == array {
      return value.map(visit).sum(default: ())
    }
    if type(value) == dictionary {
      return value.values().map(visit).sum(default: ())
    }
    if type(value) != content {
      return ()
    }
    if is-temporal(value) {
      let timed = value.value
      if timed.kind == "temporal-on" {
        let state = status(timed.range, timed.before, timed.after, step)
        if state == "visible" {
          return visit(timed.body)
        }
        return ()
      }
      if timed.kind == "temporal-reveal" {
        let result = ()
        for slot in reveal-slots(timed.items).slots {
          if slot-status(timed, slot, step) == "visible" {
            result += visit(slot.body)
          }
        }
        return result
      }
      if timed.kind == "temporal-replace" {
        let index = replace-index(timed, step)
        if index == none {
          return ()
        }
        return visit(timed.bodies.at(index))
      }
      if timed.kind == "temporal-drawing" {
        return visit(timed.args)
      }
    }
    if value.func() == typst-sequence {
      if has-pause(value.children) {
        let result = ()
        for segment in pause-schedule(value.children, max-step) {
          let local-step = step - segment.start + 1
          if local-step > 0 {
            result += notes-at(segment.children, local-step)
          }
        }
        return result
      }
    }
    if value.func() == metadata {
      return ()
    }
    value.fields().values().map(visit).sum(default: ())
  }
  visit(value)
}

#let fixed-grid-notes-at(node, step) = fold-grid(
  node,
  cell => if cell.content == none { () } else { notes-at(cell.content, step) },
  (node, child) => if (
    status(node.range, node.before, node.after, step) == "visible"
  ) { child } else { () },
  (node, children) => children.sum(default: ()),
)
