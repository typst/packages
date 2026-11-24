/// Phase D: decide the rendering strategy for each top-level piece of the
/// parsed item tree and, where needed, split division subtrees into peer
/// (top-level) segments at page/column breaks. Pure data → data.
///
/// A question subtree that contains no breaks and no fr-height elements is
/// rendered as ordinary nested blocks (instruction kind "nested") — full
/// fidelity, no flattening. Only subtrees containing a break or an fr height
/// are flattened into peer segments, because Typst cannot break pages inside
/// nested blocks and `fr` heights only resolve at the top level of the flow.
/// So are those with a `columns` inside, which holds only part of a division:
/// the rest of it, drawn outside the `columns`, is another segment.
///
/// Instruction kinds:
/// - (kind: "verbatim", item: idx)            — top-level chunk, rendered as-is
/// - (kind: "break", target, weak, to, styles, columns) — real page/column break,
///   inside `styles` (see `render`), which a page break in a `columns` is out of:
///   what follows it in them is drawn in another `columns`, the same as theirs
/// - (kind: "nested", root: idx)              — render subtree as nested blocks
/// - (kind: "frame", division: idx, labels: (idx, ..), rubrics: (idx, ..))
///                                            — a division given a `height`:
///   one block of that height, its subtree planned and rendered inside it
///   (see `frame_plan`). `labels` are ancestors whose number shares its
///   first line, and `rubrics` chunks it takes in, as `label_divisions` and
///   `rubrics` below.
/// - (kind: "segment", division: idx, first: bool, indent: length,
///    label_divisions: (idx, ..), items: (idx, ..), fr: fraction | none,
///    has_inner_break: bool, sticky: bool, hoisted: bool, rubrics: (idx, ..),
///    styles?, columns?)
///   `styles` are the rules it is drawn inside (see `_scope`), and `columns`
///   the `columns` it is drawn in; without them, those of its division.
///   `label_divisions` are the divisions whose number should be shown in the
///   gutter of this segment (a division whose body starts with a child
///   division shares its first line with that child). `rubrics` are chunks
///   of other segments that held nothing but rubrics, and were dropped:
///   their rubrics are placed in this one, still their division's.
/// - (kind: "rubrics", items: (idx, ..))      — such chunks with no segment
///   after them to take them in: their rubrics alone, in the flow.
/// - (kind: "rubric-end", division: idx)      — the rubric of a division drawn at
///   its `"end"`, after all it holds, inside its styles (see `_with_rubric_ends`)
///   `hoisted` marks a segment that wraps a single fr-height chunk pulled out
///   of its division's prose (see `plan_split`); `sticky` marks the segment
///   right before such a wrapper, which must not be separated from it.

#import "scan.typ": has_metadata, is_whitespace_content, takes_no_room
#import "config.typ": DEFAULT_INDENT
#import "tokenize.typ": stack_of

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

/// Whether something directly in division `it` is in a `columns` that `it` is
/// not all in.
#let _has_columns(items, it) = it.children.any(c => items_of(items).at(c).columns != it.columns)

/// Whether the subtree rooted at `idx` must be split into peer segments. A
/// division with a `height` inside it must be laid out as a peer of its own
/// (see `plan_split`); `top`, one whose height is what is being laid out, is
/// asked only about what it holds (see `frame_plan`).
#let needs_split(items, idx, top: false) = {
  let it = items_of(items).at(idx)
  if it.kind == "break" or not top and has_height(it) { return true }
  if it.kind == "chunk" {
    return it.has_inner_break or it.fr != none
  }
  _has_columns(items, it) or it.children.any(c => needs_split(items, c))
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

/// The rules what is drawn of division `owner` is inside, when it is `it`, a
/// chunk in the division, as `metadata`: the division's, and if `it` is in a `columns` of its own, those down to that `columns`, which `render`
/// keeps open across all it holds. The rest of `it`'s are its own.
#let _scope(items, owner, it) = {
  let d = items_of(items).at(owner)
  if it.columns == d.columns { d.styles } else { metadata(stack_of(it.styles).slice(0, it.columns.depth)) }
}

/// The rules break `b` is drawn inside: its own, for a `#set pagebreak(..)` to
/// apply, even one inside the `columns` it is in. A page break is out of all those
/// `columns`, as Typst cannot break the page in them, so they alone are left out:
/// what it was in is drawn again after it (see `render`), a `columns` as a new one
/// with the same arguments.
#let _break_styles(b) = {
  if b.target == "page" and b.columns != none { metadata(stack_of(b.styles).filter(s => "again" not in s)) } else { b.styles }
}

/// The instruction drawing break `b` (an item).
#let _break_instruction(b) = (
  kind: "break",
  target: b.target,
  weak: b.weak,
  to: b.to,
  styles: _break_styles(b),
  columns: b.columns,
)

/// The item instruction `instr` draws, or whose division it draws some of: its
/// index, or `none`.
#let _instruction_item(instr) = {
  if instr.kind == "verbatim" { instr.item } else if instr.kind == "nested" { instr.root } else {
    instr.at("division", default: none)
  }
}

/// The `columns` instruction `instr` is drawn in, if any.
#let instruction_columns(items, instr) = {
  let item = _instruction_item(instr)
  instr.at("columns", default: if item != none { items_of(items).at(item).columns })
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
      ..if current.items.len() > 0 {
        let chunk = items_of(items).at(current.items.first())
        (styles: _scope(items, current.division, chunk), columns: chunk.columns)
      },
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
      // A segment is all in a `columns` or all out of it: this is where one
      // starts or ends, unless it ends here anyway, for a chunk hoisted out.
      if not hoist and current.items.len() > 0 and items_of(items).at(current.items.first()).columns != chunk.columns {
        (instructions, pending_labels, pending_rubrics) = flush(instructions, pending_labels, pending_rubrics, current)
        current = new_segment(stack.at(-1), false)
      }
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
      instructions.push(_break_instruction(items_of(items).at(ev.item)))
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

/// The styles instruction `instr` is drawn with (see `render`): a segment's or a
/// break's own, or else those of the item or division it draws; `none` for one
/// drawn with whatever styles are around it.
#let instruction_styles(items, instr) = {
  let item = _instruction_item(instr)
  let styles = instr.at("styles", default: if item != none { items_of(items).at(item).styles })
  if styles != none { stack_of(styles) }
}

/// Whether instruction `instr` is given an `fr` height, in the flow it is in.
#let _instruction_fr(items, instr) = {
  if instr.kind == "segment" { return instr.fr != none }
  let item = _instruction_item(instr)
  if instr.kind == "verbatim" { items_of(items).at(item).fr != none } else if instr.kind == "frame" {
    type(items_of(items).at(item).fields.height) == fraction
  } else { false }
}

/// Whether instruction `instr` takes no room, and so stays where it is on a full
/// page (see `takes_no_room`).
#let instruction_takes_no_room(items, instr) = {
  if instr.kind == "rubrics" { return true }
  // A sticky one goes with the `fr` height after it (see `plan_split`).
  if _instruction_fr(items, instr) or instr.at("sticky", default: false) { return false }
  let bodies = if instr.kind == "verbatim" { (instr.item,) } else if instr.kind == "segment" and instr.label_divisions.len() == 0 {
    instr.items
  } else { return false }
  bodies.all(i => takes_no_room(items_of(items).at(i).body))
}

/// Whether `columns` `c` is `a`, or inside it.
#let columns_within(c, a) = {
  while c != none {
    if c.id == a.id { return true }
    c = c.parent
  }
  false
}

/// `instructions` with the rubric at the `"end"` of each division they split into
/// segments, or give a `height` (one marked `rubric_end`, see `process_questions`),
/// after the instruction that ends all it holds: `(kind: "rubric-end", division:
/// idx)`, innermost first. Only the divisions these instructions draw are counted:
/// those of their segments, and of their frames, with those whose number shares a
/// frame's first line; strictly within `root` when it is given (the division a
/// frame's instructions are inside, whose rubric is drawn after the frame, out of
/// its height, as it takes room of its own). A `nested` instruction draws those
/// of its divisions itself (see `render_nested`).
#let _with_rubric_ends(items, instructions, root: none) = {
  let within(d) = {
    if root == none { return true }
    let a = items_of(items).at(d).parent
    while a != none {
      if a == root { return true }
      a = items_of(items).at(a).parent
    }
    false
  }
  let drawn = (:)
  for instr in instructions {
    // A frame draws the rubrics of the divisions inside it; its own, and
    // those whose number shares its first line, are drawn after it.
    let ds = if instr.kind == "segment" {
      (instr.division, ..instr.label_divisions)
    } else if instr.kind == "frame" { (instr.division, ..instr.labels) } else { () }
    for d in ds {
      if items_of(items).at(d).at("rubric_end", default: false) and within(d) { drawn.insert(str(d), true) }
    }
  }
  if drawn.len() == 0 { return instructions }
  let last = (:)
  // Those last drawn by the instruction before: a column break at the end of a
  // `columns` their division is not in comes before their rubric, which is
  // outside it, for it not to draw the `columns` again. One in a `columns` around
  // their division's own goes after it, as it starts another column of them.
  // Only one in the `columns` that instruction is in: one at the start of a
  // `columns` after it is not in their division.
  let (latest, latest_columns) = ((), none)
  for (n, instr) in instructions.enumerate() {
    if instr.kind == "break" and instr.target == "col" and instr.columns != none {
      latest = if not columns_within(latest_columns, instr.columns) { () } else {
        latest.filter(d => not columns_within(items_of(items).at(d).columns, instr.columns))
      }
      for d in latest { last.insert(str(d), n) }
      continue
    }
    latest = ()
    if instr.kind not in ("segment", "frame") { continue }
    latest_columns = instruction_columns(items, instr)
    let d = instr.division
    while d != none {
      if str(d) in drawn {
        last.insert(str(d), n)
        latest.push(d)
      }
      d = items_of(items).at(d).parent
    }
  }
  let at = (:)
  for (d, n) in last {
    at.insert(str(n), at.at(str(n), default: ()) + (int(d),))
  }
  let out = ()
  for (n, instr) in instructions.enumerate() {
    out.push(instr)
    for d in at.at(str(n), default: ()).sorted(key: d => -items_of(items).at(d).level) {
      out.push((kind: "rubric-end", division: d))
    }
  }
  out
}

/// The key of `columns` `c` on the run of a page it is drawn in, `run` page breaks
/// into the instructions (see `_full_pieces`).
#let _piece(c, run) = str(c.id) + "." + str(run)

/// The `columns` that hold an `fr` height, directly or in a `columns` in them, as
/// keys (see `_piece`): each such takes all that is left of its page. Those a page
/// break splits are drawn as one `columns` to each page, and each counts alone.
#let _full_pieces(items, instructions) = {
  let (full, run) = ((:), 0)
  for instr in instructions {
    if instr.kind == "break" and instr.target == "page" { run += 1 } else if _instruction_fr(items, instr) {
      let c = instruction_columns(items, instr)
      while c != none {
        full.insert(_piece(c, run), true)
        c = c.parent
      }
    }
  }
  full
}

/// `instructions` with a weak column break where an `fr` height would otherwise
/// get no room: a `columns` holding one takes all that is left of the page, so
/// an `fr` height next to it must go on another page, or column. Only an `fr`
/// height needs telling, as anything else that takes room and does not fit moves
/// on by itself: text sticky to an `fr` height, which takes it along, or a rubric
/// at the `"end"` drawn outside those `columns`, which an `fr` height after it
/// follows.
#let _separate_fr(items, instructions) = {
  let full = _full_pieces(items, instructions)
  if full.len() == 0 { return instructions }
  let out = ()
  // The `columns` holding one just drawn, with the rules around it; whether an
  // `fr` height outside any such has been drawn on this page, which text after
  // it, unlike text after those `columns`, does not move on from; how many page
  // breaks there have been.
  let (last, around, shared, run) = (none, (), false, 0)
  for instr in instructions {
    let c = instruction_columns(items, instr)
    if instr.kind == "break" {
      if instr.target == "page" { run += 1 }
      if instr.target == "page" or last == none or not columns_within(c, last) { (last, shared) = (none, false) }
    } else if not instruction_takes_no_room(items, instr) {
      let in_full = c != none and _piece(c, run) in full
      let fr = not in_full and _instruction_fr(items, instr)
      let leaving = last != none and not columns_within(c, last)
      let outside = if in_full { instruction_styles(items, instr).slice(0, c.depth - 1) }
      if leaving and (in_full or fr) or in_full and shared {
        // Out of `last`, into the flow it and this are both in: a `columns` around
        // both, or else that of the outermost around `last`.
        let around_both = last
        while around_both != none and not columns_within(c, around_both) { around_both = around_both.parent }
        let styles = if not leaving { outside } else {
          around.slice(0, if around_both != none { around_both.depth } else { last.outer - 1 })
        }
        out.push((kind: "break", target: "col", weak: true, to: none, styles: metadata(styles), columns: none))
      }
      if in_full { (last, around, shared) = (c, outside, false) } else {
        if leaving { last = none }
        if fr { shared = true }
      }
    }
    out.push(instr)
  }
  out
}

/// Plan the whole document: one instruction list covering every top-level
/// item, with the rubrics at the `"end"` it draws (see `_with_rubric_ends`).
/// `fr-unit`: how `fr` heights are laid out (see `exam_options`); only as
/// shares of the page do they fill it, and need keeping apart (see
/// `_separate_fr`).
#let plan(items, fr-unit: none) = {
  let items = hold(items)
  let instructions = ()
  for (i, it) in items_of(items).enumerate() {
    if it.parent != none { continue }
    if it.kind == "chunk" {
      // Space after a page break that ended a `columns`: not reason enough to
      // draw another.
      let last = instructions.at(-1, default: none)
      let ended = last != none and last.kind == "break" and last.target == "page" and last.columns != none
      if ended and it.columns != none and is_whitespace_content(it.body) and not has_metadata(it.body) { continue }
      instructions.push((kind: "verbatim", item: i))
    } else if it.kind == "break" {
      instructions.push(_break_instruction(it))
    } else if has_height(it) {
      instructions.push((kind: "frame", division: i, labels: (), rubrics: ()))
    } else if needs_split(items, i) {
      instructions += plan_split(items, i)
    } else {
      instructions.push((kind: "nested", root: i))
    }
  }
  let instructions = _with_rubric_ends(items, instructions)
  if fr-unit == none { _separate_fr(items, instructions) } else { instructions }
}

/// The error for what division `idx`, given a `height`, holds (its plan is
/// `instructions`, see `frame_plan`) when it cannot all fit: an `fr` height in a
/// `columns` takes all the height the `columns` can get, and in one block, nothing
/// can move on from it, as it would on a page (see `_separate_fr`): not even a
/// rubric at the `"end"`. `none` if it is all well. Only for `fr` heights that
/// are shares of the block.
#let frame_fr_error(items, idx, instructions) = {
  let full = _full_pieces(items, instructions)
  if full.len() == 0 { return none }
  let d = items_of(items).at(idx)
  // The `columns` holding one just drawn, directly in the block; whether an `fr`
  // height has been, directly in it too.
  let (last, shared) = (none, false)
  for instr in instructions {
    if instr.kind == "break" or instruction_takes_no_room(items, instr) { continue }
    // The `columns` it is in that is directly in the block, if any.
    let top = none
    let c = instruction_columns(items, instr)
    while c != none and c != d.columns { (top, c) = (c, c.parent) }
    let in_full = top != none and _piece(top, 0) in full
    if last != none and top != last or in_full and shared {
      let left = if instr.kind == "rubric-end" {
        (
          "the rubric drawn at the `\"end\"`, after the `columns`, gets no room in the block. Give the height in "
            + "them a length, or draw the rubric in a margin."
        )
      } else {
        (
          "what comes after the `columns`, or an `fr` height before them, gets no room in the block. Move it "
            + "into the `columns`, or give the height in them a length."
        )
      }
      return (
        "examy: an `fr` height in a `columns` inside a `"
          + d.fields.name
          + "` with a `height` takes all the height left, so "
          + left
      )
    }
    if in_full { last = top } else if top == none and _instruction_fr(items, instr) { shared = true }
  }
  none
}

/// The plan of what goes inside a division given a `height` (see the
/// `frame` instruction): the division as nested blocks, when it is a
/// question with nothing inside it that needs splitting, and otherwise its
/// peer segments (at the indents they would have on the page), so that `fr`
/// answer boxes inside it share the block's height. `labels`, ancestors
/// whose number shares the frame's first line, go with what it starts with:
/// its first segment, or a frame it starts with (passed on down), or, if it
/// holds nothing, a segment of their own. `rubrics` (see the `frame`
/// instruction) go with them. The rubrics at the `"end"` of the divisions in it
/// are drawn in it (see `_with_rubric_ends`).
#let frame_plan(items, idx, labels: (), rubrics: ()) = {
  let it = items_of(items).at(idx)
  if it.parent == none and not needs_split(items, idx, top: true) {
    return ((kind: "nested", root: idx),)
  }
  let inner = plan_split(items, idx)
  if labels.len() == 0 and rubrics.len() == 0 { return _with_rubric_ends(items, inner, root: idx) }
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
  _with_rubric_ends(items, inner, root: idx)
}
