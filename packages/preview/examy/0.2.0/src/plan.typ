/// Phase D: decide the rendering strategy for each top-level piece of the
/// parsed item tree and, where needed, split division subtrees into peer
/// (top-level) segments at page/column breaks. Pure data → data.
///
/// A question subtree that contains no breaks and no fr-height elements is
/// rendered as ordinary nested blocks (instruction kind "nested") — full
/// fidelity, no flattening. Only subtrees containing a break or an fr height
/// are flattened into peer segments, because Typst cannot break pages inside
/// nested blocks and `fr` heights only resolve at the top level of the flow.
///
/// Instruction kinds:
/// - (kind: "verbatim", item: idx)            — top-level chunk, rendered as-is
/// - (kind: "break", target, weak)            — real page/column break
/// - (kind: "nested", root: idx)              — render subtree as nested blocks
/// - (kind: "segment", division: idx, first: bool, indent: length,
///    label_divisions: (idx, ..), items: (idx, ..), fr: fraction | none,
///    has_inner_break: bool, tail: idx | none)
///   `label_divisions` are the divisions whose number should be shown in the
///   gutter of this segment (a division whose body starts with a child
///   division shares its first line with that child). `tail` is a division
///   whose solution should be rendered at the end of this segment.

#import "scan.typ": is_whitespace_content

/// Sum of `indent`s of the division `idx` and all its ancestors.
#let cumulative_indent(items, idx) = {
  let total = 0pt + 0em
  let cur = idx
  while cur != none {
    let it = items.at(cur)
    if it.kind == "division" { total += it.fields.indent }
    cur = it.parent
  }
  total
}

/// Whether the subtree rooted at `idx` must be split into peer segments.
#let needs_split(items, idx) = {
  let it = items.at(idx)
  if it.kind == "break" { return true }
  if it.kind == "chunk" {
    return it.has_inner_break or it.fr != none
  }
  it.children.any(c => needs_split(items, c))
}

/// Depth-first event list for a subtree: open/close for divisions,
/// chunk/break for leaves.
#let _events(items, idx) = {
  let it = items.at(idx)
  if it.kind == "division" {
    (
      ((kind: "open", item: idx),)
        + it.children.map(c => _events(items, c)).flatten()
        + ((kind: "close", item: idx),)
    )
  } else if it.kind == "chunk" {
    ((kind: "chunk", item: idx),)
  } else {
    ((kind: "break", item: idx),)
  }
}

/// Whether a pending segment contains only whitespace chunks.
#let _segment_is_whitespace(items, seg) = {
  seg.items.all(i => is_whitespace_content(items.at(i).body))
}

/// Split the subtree rooted at `root` into peer-segment instructions.
#let plan_split(items, root) = {
  let instructions = ()
  let stack = () // open division indices
  let pending_labels = () // divisions whose label still needs a home
  let current = none

  // Emit `current` as a segment instruction (or defer/drop it).
  let flush(instructions, pending_labels, current, force: false) = {
    if current == none { return (instructions, pending_labels) }
    let whitespace = _segment_is_whitespace(items, current)
    let keep_for_content = not whitespace or current.fr != none or current.tail != none
    if current.first and whitespace and not keep_for_content and not force {
      // A first segment with nothing in it: let its label ride on the next
      // segment so e.g. "1." and "(a)" share a line.
      return (instructions, pending_labels + (current.division,))
    }
    if not current.first and not keep_for_content {
      // Whitespace-only continuation: drop entirely.
      return (instructions, pending_labels)
    }
    let label_divisions = pending_labels + (if current.first { (current.division,) } else { () })
    instructions.push((
      kind: "segment",
      division: current.division,
      first: current.first,
      indent: cumulative_indent(items, current.division),
      label_divisions: label_divisions,
      items: current.items,
      fr: current.fr,
      has_inner_break: current.has_inner_break,
      tail: current.tail,
    ))
    (instructions, ())
  }

  let new_segment(division, first) = (
    division: division,
    first: first,
    items: (),
    fr: none,
    has_inner_break: false,
    tail: none,
  )

  for ev in _events(items, root) {
    if ev.kind == "open" {
      (instructions, pending_labels) = flush(instructions, pending_labels, current)
      stack.push(ev.item)
      current = new_segment(ev.item, true)
    } else if ev.kind == "close" {
      if items.at(ev.item).fields.solution != none {
        current.tail = ev.item
      }
      // Force: if this division's first segment is empty and nothing follows
      // inside it, it must still become a block so its label shows.
      let force = current.first and current.division == ev.item and pending_labels.len() == 0
      (instructions, pending_labels) = flush(instructions, pending_labels, current, force: force)
      let _ = stack.pop()
      current = if stack.len() > 0 { new_segment(stack.at(-1), false) } else { none }
    } else if ev.kind == "chunk" {
      let chunk = items.at(ev.item)
      current.items.push(ev.item)
      if chunk.fr != none {
        current.fr = if current.fr == none { chunk.fr } else { current.fr + chunk.fr }
      }
      if chunk.has_inner_break { current.has_inner_break = true }
    } else {
      // break
      (instructions, pending_labels) = flush(instructions, pending_labels, current, force: true)
      let b = items.at(ev.item)
      instructions.push((kind: "break", target: b.target, weak: b.weak))
      current = new_segment(stack.at(-1), false)
    }
  }
  // Anything still pending (e.g. trailing empty divisions) must be emitted.
  if pending_labels.len() > 0 {
    instructions.push((
      kind: "segment",
      division: pending_labels.at(-1),
      first: true,
      indent: cumulative_indent(items, pending_labels.at(-1)),
      label_divisions: pending_labels,
      items: (),
      fr: none,
      has_inner_break: false,
      tail: none,
    ))
  }
  instructions
}

/// Plan the whole document: one instruction list covering every top-level
/// item.
#let plan(items) = {
  let instructions = ()
  for (i, it) in items.enumerate() {
    if it.parent != none { continue }
    if it.kind == "chunk" {
      instructions.push((kind: "verbatim", item: i))
    } else if it.kind == "break" {
      instructions.push((kind: "break", target: it.target, weak: it.weak))
    } else if needs_split(items, i) {
      instructions += plan_split(items, i)
    } else {
      instructions.push((kind: "nested", root: i))
    }
  }
  instructions
}
