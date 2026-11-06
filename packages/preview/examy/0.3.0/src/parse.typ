/// Phase C: parse the flat token stream into a flat array of *items* linked
/// into a tree by indices, then resolve numbering, addresses, and point
/// totals. Everything here is pure data → data (no layout, no context).
///
/// Item kinds:
/// - (kind: "division", level, fields, styles, parent, children, number,
///    address, total_points, total_bonus_points)
/// - (kind: "chunk", body, styles, has_inner_break, fr, parent)
/// - (kind: "break", target, weak, styles, parent)
///
/// `parent`/`children` are indices into the items array (`none` for top
/// level). `level` is 1 for questions, 2 for parts, 3 for subparts, ...
/// `number` is the resolved number: 0-based int for auto/int numbering,
/// content/str for custom numbers, or `none` for unnumbered divisions.
/// `address` is the full path of resolved numbers, root first.

/// Build the item tree from tokens (structure only; no numbering yet).
#let build_items(tokens) = {
  let items = ()
  let stack = () // indices of currently-open divisions
  for tok in tokens {
    if tok.kind == "begin" {
      let idx = items.len()
      let parent = stack.at(-1, default: none)
      items.push((
        kind: "division",
        level: stack.len() + 1,
        fields: tok.fields,
        styles: tok.styles,
        parent: parent,
        children: (),
        number: none,
        address: (),
      ))
      if parent != none { items.at(parent).children.push(idx) }
      stack.push(idx)
    } else if tok.kind == "end" {
      assert(
        stack.len() > 0,
        message: "examy: unbalanced division markers: found an `end` marker without a matching `begin`",
      )
      let _ = stack.pop()
    } else {
      let idx = items.len()
      let parent = stack.at(-1, default: none)
      items.push((..tok, parent: parent))
      if parent != none { items.at(parent).children.push(idx) }
    }
  }
  assert(
    stack.len() == 0,
    message: "examy: unbalanced division markers: "
      + str(stack.len())
      + " division(s) were never closed (this should be impossible when using `question[...]` etc.)",
  )
  items
}

/// Resolve division numbers and addresses.
///
/// Numbering rules per division, driven by its `number` field:
/// - `auto`: next value of this level's counter; entering a division resets
///   all deeper counters
/// - int: the 1-based number as displayed; later divisions continue from it
/// - content/str: displayed verbatim; counters untouched
/// - `none`: unnumbered; counters untouched
#let assign_numbers(items) = {
  let counters = () // counters.at(l) is the last used 0-based number at level l+1
  for (i, it) in items.enumerate() {
    if it.kind != "division" { continue }
    let level = it.level
    // Grow the counter array as needed; reset all counters deeper than us.
    while counters.len() < level { counters.push(-1) }
    counters = counters.enumerate().map(((l, v)) => if l >= level { -1 } else { v })

    let requested = it.fields.number
    let number = if requested == auto {
      counters.at(level - 1) += 1
      counters.at(level - 1)
    } else if type(requested) == int {
      // `number:` is the 1-based number as it will be displayed; internal
      // counters are 0-based.
      counters.at(level - 1) = requested - 1
      requested - 1
    } else {
      requested // content, str, or none: verbatim / unnumbered
    }

    let parent_address = if it.parent == none { () } else { items.at(it.parent).address }
    items.at(i).number = number
    items.at(i).address = parent_address + (number,)
  }
  items
}

/// Compute `total_points`/`total_bonus_points` for every division: its own
/// points plus those of all descendants. Points with `intent: "practice"` or
/// `intent: "bonus"` are excluded from the regular total; bonus points are
/// totalled separately.
#let assign_points(items) = {
  let totals = items.map(_ => 0)
  let bonus = items.map(_ => 0)
  // Children always come after their parent, so a reverse pass accumulates
  // fully-computed subtotals into parents.
  for (i, it) in items.enumerate().rev() {
    if it.kind != "division" { continue }
    let p = it.fields.points
    if p != none {
      if it.fields.intent == none { totals.at(i) += p }
      if it.fields.intent == "bonus" { bonus.at(i) += p }
    }
    if it.parent != none {
      totals.at(it.parent) += totals.at(i)
      bonus.at(it.parent) += bonus.at(i)
    }
  }
  items
    .enumerate()
    .map(((i, it)) => {
      if it.kind == "division" {
        (
          ..it,
          total_points: totals.at(i),
          total_bonus_points: if bonus.at(i) == 0 { none } else { bonus.at(i) },
        )
      } else {
        it
      }
    })
}

#import "scan.typ": is_whitespace_content, trim_leading_space

/// Normalize division bodies: drop leading whitespace-only chunks and strip
/// leading space/parbreak elements from the first real chunk. This makes the
/// rendered body start exactly at the first visible content, so gutter
/// labels can be glued to the first line without a stray space. (Dropped
/// chunks stay in the items array as orphans; they are simply never
/// rendered.)
#let trim_division_bodies(items) = {
  let items = items
  for (i, it) in items.enumerate() {
    if it.kind != "division" { continue }
    let children = it.children
    while children.len() > 0 {
      let c = items.at(children.at(0))
      if (
        c.kind == "chunk"
          and is_whitespace_content(c.body)
          and c.fr == none
          and not c.has_inner_break
      ) {
        children = children.slice(1)
      } else {
        break
      }
    }
    if children.len() > 0 {
      let ci = children.at(0)
      if items.at(ci).kind == "chunk" {
        items.at(ci).body = trim_leading_space(items.at(ci).body)
      }
    }
    items.at(i).children = children
  }
  items
}

/// Panic if two divisions share the same user label.
#let check_duplicate_labels(items) = {
  let seen = (:)
  for it in items {
    if it.kind != "division" or it.fields.label == none { continue }
    let key = str(it.fields.label)
    assert(
      key not in seen,
      message: "examy: duplicate label <" + key + "> on two different questions/parts",
    )
    seen.insert(key, true)
  }
  items
}

/// Full parse: tokens → items with numbering, addresses, and point totals.
#let parse(tokens) = {
  check_duplicate_labels(assign_points(assign_numbers(trim_division_bodies(
    build_items(tokens),
  ))))
}
