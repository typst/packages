/// Numbering display and reference resolution.
///
/// Every numbered division gets an invisible *anchor* that carries its full
/// address (e.g. question 2, part a → `(1, 0)`) and updates the
/// "current address" state. A reference (`@label`) compares the target's
/// address with the address at the reference site and displays the shortest
/// distinguishing suffix: `@q1p1` from inside question 2 shows "1 (a)", but
/// from inside question 1 part 2 it shows just "(a)".

#import "types.typ": *

/// Numbering patterns per level: questions, parts, subparts.
#let LABELLING = ("1.", "(a)", "i.")

/// The number as displayed in the document gutter (trailing dot kept).
/// `level` is 1-based; `number` is a 0-based int, content, or none.
#let display_number(level, number) = {
  if number == none { return none }
  if type(number) == int {
    numbering(LABELLING.at(level - 1, default: "1."), number + 1)
  } else {
    [#number]
  }
}

/// One address component as displayed in a reference (trailing "." stripped,
/// so a question+part reference reads "1 (a)", not "1. (a)").
/// `level_index` is 0-based.
#let format_component(level_index, number) = {
  if type(number) == int {
    let s = numbering(LABELLING.at(level_index, default: "1."), number + 1)
    if type(s) == str and s.ends-with(".") { s = s.slice(0, -1) }
    [#s]
  } else if number == none {
    [??]
  } else {
    [#number]
  }
}

/// Pure resolution rule: given the target's full address and the address of
/// the reference site (both root-first arrays), return the
/// `(level_index, number)` pairs to display. The common prefix is dropped,
/// but at least the last component is always shown.
#let relative_components(target, current) = {
  let i = 0
  while i < target.len() - 1 and i < current.len() and target.at(i) == current.at(i) {
    i += 1
  }
  target.enumerate().slice(i)
}

/// Render the reference body for a target address as seen from `current`.
#let reference_body(target, current) = {
  relative_components(target, current)
    .map(((lvl, n)) => format_component(lvl, n))
    .join(sym.space.thin)
}

/// State holding the address of the most recently started division (or
/// continuation segment) — the "where am I" for relative references.
#let _current_address = state(PREFIX + "/current-address", ())

/// Emit a (invisible) state update marking that subsequent content belongs
/// to the division at `address`.
#let update_current_address(address) = _current_address.update(address)

/// Invisible anchor placed at the start of a numbered division. Carries the
/// user's label so `@label` references resolve to a smart relative number.
#let division_anchor = e.element.declare(
  "division-anchor",
  prefix: PREFIX,
  doc: "Invisible anchor marking a division's position and address; the target of `@label` references.",
  display: it => {
    _current_address.update(it.full_address)
  },
  reference: (
    custom: it => {
      let target = it.full_address
      context {
        let current = _current_address.get()
        let body = reference_body(target, current)
        if it.label_name != none {
          link(it.label_name, body)
        } else {
          body
        }
      }
    },
  ),
  fields: (
    e.field(
      "label_name",
      e.types.option(label),
      doc: "The division's user label (repeated here so references can link to it)",
    ),
    e.field(
      "full_address",
      e.types.array(e.types.any),
      doc: "The full address of the division, root first, e.g. (1, 0) for question 2 part a. 0-based ints for numbered levels; content for custom numbers.",
    ),
  ),
)
