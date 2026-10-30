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
/// - (kind: "break", target, weak, styles?)   — real page/column break; a
///   top-level one keeps its styles (see `render`)
/// - (kind: "nested", root: idx)              — render subtree as nested blocks
/// - (kind: "frame", division: idx, labels: (idx, ..), rubrics: (idx, ..))
///                                            — a division given a `height`:
///   one block of that height, its subtree planned and rendered inside it
///   (see `frame_plan`). `labels` are ancestors whose number shares its
///   first line, and `rubrics` chunks it takes in, as `label_divisions` and
///   `rubrics` below.
/// - (kind: "segment", division: idx, first: bool, indent: length,
///    label_divisions: (idx, ..), items: (idx, ..), fr: fraction | none,
///    has_inner_break: bool, sticky: bool, hoisted: bool, rubrics: (idx, ..))
///   `label_divisions` are the divisions whose number should be shown in the
///   gutter of this segment (a division whose body starts with a child
///   division shares its first line with that child). `rubrics` are chunks
///   of other segments that held nothing but rubrics, and were dropped:
///   their rubrics are placed in this one, still their division's.
/// - (kind: "rubrics", items: (idx, ..))      — such chunks with no segment
///   after them to take them in: their rubrics alone, in the flow.
///   `hoisted` marks a segment that wraps a single fr-height chunk pulled out
///   of its division's prose (see `plan_split`); `sticky` marks the segment
///   right before such a wrapper, which must not be separated from it.

#import "scan.typ": has_metadata, is_whitespace_content
#import "config.typ": DEFAULT_INDENT

/// The items (see parse.typ) as the functions here take them: in `metadata`,
/// as content, whose hash Typst works out once and keeps. Typst memoizes
/// every call, hashing its arguments, and the items are passed to a call or
/// more for each of them: as an array, hashed anew each time, laying out an
/// exam would take time growing with the square of its length. Each
/// function reads them with `items_of`, and passes them on as it was given
/// them; `plan` and `render` take an array too, and hold it (see `hold`).
#let hold(items) = if type(items) == content { items } else { metadata(items) }

/// The items as an array, whether held (see `hold`) or not.
#let items_of(items) = if type(items) == content { items.value } else { items }

/// Division `d`'s `indent`: its own, or `config`'s, as the exam resolves it
/// (see `localize` in render.typ); the default where nothing resolved it.
#let indent_of(d) = if d.fields.indent == auto { DEFAULT_INDENT } else { d.fields.indent }

/// Sum of `indent`s of the division `idx` and all its ancestors.
#let cumulative_indent(items, idx) = {
  let total = 0pt + 0em
  let cur = idx
  while cur != none {
    let it = items_of(items).at(cur)
    if it.kind == "division" { total += indent_of(it) }
    cur = it.parent
  }
  total
}

/// Whether a division is given a `height`, and so is laid out as one block.
#let has_height(it) = it.kind == "division" and it.fields.height != auto

/// Whether the subtree rooted at `idx` must be split into peer segments. A
/// division with a `height` inside it must be laid out as a peer of its own
/// (see `plan_split`); it is never asked about itself, but about its
/// children (see `frame_plan`).
#let needs_split(items, idx) = {
  let it = items_of(items).at(idx)
  if it.kind == "break" or has_height(it) { return true }
  if it.kind == "chunk" {
    return it.has_inner_break or it.fr != none
  }
  it.children.any(c => needs_split(items, c))
}

/// Depth-first event list for a subtree: open/close for divisions,
/// chunk/break for leaves, and frame for a division inside it given a
/// `height`, which is laid out whole.
#let _events(items, idx, top: true) = {
  let it = items_of(items).at(idx)
  if not top and has_height(it) {
    ((kind: "frame", item: idx),)
  } else if it.kind == "division" {
    (
      ((kind: "open", item: idx),)
        + it.children.map(c => _events(items, c, top: false)).flatten()
        + ((kind: "close", item: idx),)
    )
  } else if it.kind == "chunk" {
    ((kind: "chunk", item: idx),)
  } else {
    ((kind: "break", item: idx),)
  }
}

/// Whether a pending segment contains only whitespace chunks: if so, those
/// of them that hold `metadata` (a rubric, a labelled marker, ...), else
/// `none`. `metadata` is invisible, and a segment of nothing else is dropped
/// all the same, as it would take room, but the `metadata` must still be
/// placed, to be found: the next segment takes it in (see `rubrics` above).
#let _segment_blank(items, seg) = {
  let rubrics = ()
  for i in seg.items {
    let body = items_of(items).at(i).body
    if not is_whitespace_content(body) { return none }
    if has_metadata(body) { rubrics.push(i) }
  }
  rubrics
}

/// Split the subtree rooted at `root` into peer-segment instructions.
#let plan_split(items, root) = {
  let instructions = ()
  let stack = () // open division indices
  // Divisions whose label still needs a home, and chunks of rubrics that do.
  let pending_labels = ()
  let pending_rubrics = ()
  let current = none

  // Emit `current` as a segment instruction (or defer/drop it).
  let flush(instructions, pending_labels, pending_rubrics, current, force: false, sticky: false) = {
    if current == none { return (instructions, pending_labels, pending_rubrics) }
    let blank = _segment_blank(items, current)
    let whitespace = blank != none
    let keep_for_content = not whitespace or current.fr != none
    let dropped = if whitespace { blank } else { () }
    if current.first and whitespace and not keep_for_content and not force {
      // A first segment with nothing in it: let its label ride on the next
      // segment so e.g. "1." and "(a)" share a line.
      return (instructions, pending_labels + (current.division,), pending_rubrics + dropped)
    }
    if not current.first and not keep_for_content {
      // Whitespace-only continuation: drop entirely.
      return (instructions, pending_labels, pending_rubrics + dropped)
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
      sticky: sticky,
      hoisted: current.hoisted,
      rubrics: pending_rubrics,
    ))
    (instructions, (), ())
  }

  let new_segment(division, first, hoisted: false) = (
    division: division,
    first: first,
    items: (),
    fr: none,
    has_inner_break: false,
    hoisted: hoisted,
  )

  for ev in _events(items, root) {
    if ev.kind == "open" {
      // A division with no text of its own before its first part keeps its
      // label for the part's first line, unless a badge at the `"end"` of
      // that (no) text needs a line of its own there, as it gets when drawn
      // in one piece.
      let force = current != none and current.first and items_of(items).at(current.division).badge_at_end
      (instructions, pending_labels, pending_rubrics) = flush(instructions, pending_labels, pending_rubrics, current, force: force)
      stack.push(ev.item)
      current = new_segment(ev.item, true)
    } else if ev.kind == "close" {
      // Force: if this division's first segment is empty and nothing follows
      // inside it, it must still become a block so its label shows.
      let force = current.first and current.division == ev.item and pending_labels.len() == 0
      (instructions, pending_labels, pending_rubrics) = flush(instructions, pending_labels, pending_rubrics, current, force: force)
      let _ = stack.pop()
      current = if stack.len() > 0 { new_segment(stack.at(-1), false) } else { none }
    } else if ev.kind == "chunk" {
      let chunk = items_of(items).at(ev.item)
      // An fr height only resolves against the page at the top level of the
      // flow, so a chunk sharing its segment with the division's prose would
      // negotiate against that prose's height instead of against the other fr
      // peers on the page — two `1fr` answer boxes under prompts of different
      // lengths came out different sizes. Give it its own peer segment, and
      // mark the prose sticky so the two still cannot be split apart. A chunk
      // with a break inside keeps `auto` height anyway (see `render_segment`),
      // so there is nothing to negotiate.
      let hoist = chunk.fr != none and not chunk.has_inner_break
      if hoist {
        // A points badge in the flow takes a line, so letting one ride into
        // the hoisted segment would spend the box's own fr share on it. Keep
        // the head in a segment of its own instead. A bare gutter label, or a
        // badge in the margin, is `place`d and costs no height, so it can
        // still ride along.
        let badged = (pending_labels + (current.division,)).any(d => (
          items_of(items).at(d).badge_takes_line
        ))
        (instructions, pending_labels, pending_rubrics) = flush(
          instructions,
          pending_labels,
          pending_rubrics,
          current,
          force: badged,
          sticky: true,
        )
        current = new_segment(stack.at(-1), false, hoisted: true)
      }
      current.items.push(ev.item)
      if chunk.fr != none {
        current.fr = if current.fr == none { chunk.fr } else { current.fr + chunk.fr }
      }
      if chunk.has_inner_break { current.has_inner_break = true }
      if hoist {
        (instructions, pending_labels, pending_rubrics) = flush(instructions, pending_labels, pending_rubrics, current)
        current = new_segment(stack.at(-1), false)
      }
    } else if ev.kind == "frame" {
      // A division with a `height`: a peer of its own, laid out whole. Its
      // parent's text before it ends here; a parent with no text before it
      // has its number on the frame's first line, as with any part.
      let force = current.first and items_of(items).at(current.division).badge_at_end
      (instructions, pending_labels, pending_rubrics) = flush(instructions, pending_labels, pending_rubrics, current, force: force)
      instructions.push((kind: "frame", division: ev.item, labels: pending_labels, rubrics: pending_rubrics))
      pending_labels = ()
      pending_rubrics = ()
      current = new_segment(stack.at(-1), false)
    } else {
      // break
      (instructions, pending_labels, pending_rubrics) = flush(instructions, pending_labels, pending_rubrics, current, force: true)
      let b = items_of(items).at(ev.item)
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
      sticky: false,
      hoisted: false,
      rubrics: pending_rubrics,
    ))
  } else if pending_rubrics.len() > 0 {
    instructions.push((kind: "rubrics", items: pending_rubrics))
  }
  instructions
}

/// Plan the whole document: one instruction list covering every top-level
/// item.
#let plan(items) = {
  let items = hold(items)
  let instructions = ()
  for (i, it) in items_of(items).enumerate() {
    if it.parent != none { continue }
    if it.kind == "chunk" {
      instructions.push((kind: "verbatim", item: i))
    } else if it.kind == "break" {
      instructions.push((kind: "break", target: it.target, weak: it.weak, styles: it.styles))
    } else if has_height(it) {
      instructions.push((kind: "frame", division: i, labels: (), rubrics: ()))
    } else if needs_split(items, i) {
      instructions += plan_split(items, i)
    } else {
      instructions.push((kind: "nested", root: i))
    }
  }
  instructions
}

/// The plan of what goes inside a division given a `height` (see the
/// `frame` instruction): the division as nested blocks, when it is a
/// question with nothing inside it that needs splitting, and otherwise its
/// peer segments (at the indents they would have on the page), so that `fr`
/// answer boxes inside it share the block's height. `labels`, ancestors
/// whose number shares the frame's first line, go with what it starts with:
/// its first segment, or a frame it starts with (passed on down), or, if it
/// holds nothing, a segment of their own. `rubrics` (see the `frame`
/// instruction) go with them.
#let frame_plan(items, idx, labels: (), rubrics: ()) = {
  let it = items_of(items).at(idx)
  if it.parent == none and not it.children.any(c => needs_split(items, c)) {
    return ((kind: "nested", root: idx),)
  }
  let inner = plan_split(items, idx)
  if labels.len() == 0 and rubrics.len() == 0 { return inner }
  let first = inner.at(0, default: none)
  if first != none and first.kind == "segment" {
    inner.at(0).label_divisions = labels + first.label_divisions
    inner.at(0).rubrics = rubrics + first.rubrics
  } else if first != none and first.kind == "frame" {
    inner.at(0).labels = labels + first.labels
    inner.at(0).rubrics = rubrics + first.rubrics
  } else if labels.len() == 0 {
    inner.insert(0, (kind: "rubrics", items: rubrics))
  } else {
    inner.insert(0, (
      kind: "segment",
      division: labels.at(-1),
      first: true,
      indent: cumulative_indent(items, labels.at(-1)),
      label_divisions: labels,
      items: (),
      fr: none,
      has_inner_break: false,
      sticky: false,
      hoisted: false,
      rubrics: rubrics,
    ))
  }
  inner
}
