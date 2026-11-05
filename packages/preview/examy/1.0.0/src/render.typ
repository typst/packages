/// Phase E: turn plan instructions into actual layout.

#import "prelude.typ": *
#import "scan.typ": (
  _find, glue_rubrics, has_any_rubric, is_plain_text, is_whitespace_content, leading, rubric_markers, split_first_par,
)
#import "tokenize.typ": apply_styles, stack_of
#import "plan.typ": cumulative_indent, frame_plan, hold, indent_of, items_of
#import "config.typ": DEFAULT_EXAM_OPTIONS, default_points_format
#import "points.typ": conflict_warning, division_marker, points_marker
#import "refs.typ": (
  display_number, division_anchor, enum_numbering, level_numberings, reference_body, update_current_address,
)
#import "rubric.typ": _margin, owner_update, rubric_area, rubric_end_area, rubric_head, rubric_leaders, stacked_badges

/// Half-em gap between a gutter label and the body text.
#let LABEL_GAP = .5em

/// The gap between a points badge in the margin and the text.
#let MARGIN_GAP = 1em

/// The least space between two gutter labels on one line (see
/// `_label_push`). With the default indent, a question's "1." and the "(a)"
/// of a part on its first line are about .46em apart, and stay where they
/// are (as for any part up to "(g)"; a wider one starting a question, such
/// as "(m)", moves right by a little, and the part's first line with it).
#let LABEL_SEP = .35em

/// The label of the metadata giving how far an exam's badges in the left
/// margin move (see `exam_badge_shift`), which they read where they are drawn
/// (see `_margin_badges`).
#let BADGE_SHIFT = label("_examy_badge_shift")

/// The label of the metadata giving the widths of a question's gutter labels
/// and badges in the left margin, measured where the exam draws it (see
/// `_shift_parts`, and `render`).
#let QUESTION_WIDTHS = label("_examy_question_widths")

/// How far left the badges in the left margin move (see `_margin_badges`),
/// so that each keeps `LABEL_SEP` from the gutter labels of the exam, which
/// run out past the text's edge into the margin when its indent is smaller
/// than they are (as it is with none): all alike, so that they stay in line.
/// None with an indent that leaves room for every label. `labels` are every
/// gutter label of the exam (see `exam_badge_shift`).
///
/// The labels are measured once for each question, where the exam draws it
/// (see `render`), not in each badge's context: measuring every label for
/// each badge takes time growing with the square of the exam's length. But a
/// badge and the
/// labels are drawn at the text size where they are, which a `set text`
/// inside the exam changes. So each label's width is kept in `em` (see
/// `_label_of`), and how far it runs left as a length of an absolute part
/// and an `em` part, which a badge resolves at its own size: the shift is
/// the least of them (see `_badge_shift_at`). Only those that can be less
/// than none at some size are kept, each once: few however long the exam, as
/// the labels of a level are alike. `none` when there are none: then no
/// badge moves, nor is measured.
#let _badge_shift(labels) = {
  let lefts = labels
    .map(l => l.x - LABEL_GAP - l.width - LABEL_SEP + MARGIN_GAP)
    .filter(x => x.abs < 0pt or x.em < 0)
    .dedup()
  if lefts == () { none } else { lefts }
}

/// The shift that `_badge_shift` gave (`lefts`), for a badge where it is
/// drawn (in context), `widest` the widest badge of the exam in the left
/// margin, in `em` (see `exam_badge_shift`).
///
/// Only as far as that badge stays on the page, its text at the margin of
/// the page it is on: a label that runs out farther (`"Problem 1."` in a
/// narrow margin) is not cleared, its badge drawn over it, rather than every
/// badge of the exam moved off the page. A badge too wide for the margin
/// where it is not moved at all (at a large text size) is off the page
/// already: it goes as far as its end stays on it.
#let _badge_shift_at(lefts, widest) = {
  let (gap, margin) = (MARGIN_GAP.to-absolute(), _margin("margin-left"))
  // The farthest left a badge can go: its left edge on the page's, or else
  // its right edge.
  let limit = widest.to-absolute() + gap - margin
  let limit = if limit > 0pt { gap - margin } else { limit }
  calc.min(0pt, ..lefts.map(x => x.to-absolute()).filter(x => x >= limit))
}

/// The width of the box a gutter label or a badge in the margin is set
/// in, against its edge nearest the text: wider than any of them, so that
/// one wider than the space it is given runs out over the margin instead of
/// wrapping onto a second line.
#let _OVERFLOW = 20cm

/// The badge a division shows (see `assign_badges`).
#let _badge(d) = d.badge

/// The items with each division's options resolved: its `indent`, `opts`'
/// where it gives none; and in `own`, the options the `config` rules inside
/// the exam around it (its `_scoped` field, see `tokenize`) give it, or the
/// division it is in, which `opts_of` lays it out with. It takes a rule's
/// over its parent's when the rule was set nearer, inside the parent. A
/// division under no such rule, in one under none, has no `own`. With a
/// `numbering` in `own`, `numberings` holds that of each level of its
/// address, `auto` for the exam's (see `level_numberings`). A rule's
/// `indent` is that of every division in its scope not given one.
#let localize(items, opts) = {
  for (i, it) in items.enumerate() {
    if it.kind != "division" { continue }
    let f = it.fields
    let scoped = f.at("_scoped", default: (:))
    if f.indent == auto { items.at(i).fields.indent = scoped.at("indent", default: opts.indent) }
    let parent = if it.parent != none { items.at(it.parent) }
    let own = if parent == none { (:) } else { parent.at("own", default: (:)) }
    // The rules around the parent are around it too: only those inside the
    // parent, which set something else, are nearer than the parent's own.
    let around = if parent == none { (:) } else { parent.fields.at("_scoped", default: (:)) }
    for (key, value) in scoped {
      if key == "indent" or (key in around and around.at(key) == value) { continue }
      // `auto` formats are the default ones, as the exam reads them.
      if value == auto and key == "points-format" { value = default_points_format }
      if value == auto and key == "bonus-points-format" { value = p => default_points_format(p, bonus: true) }
      own.insert(key, value)
    }
    if "numbering" in own {
      // Its parent's, if it has them: `own` starts as the parent's.
      let above = own.at("numberings", default: (auto,) * (it.level - 1))
      own.insert("numberings", above + (own.numbering,))
    }
    if own.len() > 0 { items.at(i).insert("own", own) }
  }
  items
}

/// `opts`, the exam's, as division `d` is laid out with: with the options
/// it, or a division it is in, gives of its own (see `localize`) in place
/// of the exam's. Always given the exam's, not another division's.
#let opts_of(d, opts) = {
  let own = d.at("own", default: none)
  // A rubric item of its own given `trace: true` (see `mark_rubrics`) is
  // traced whatever its rubrics are.
  let asked = opts.rubric.drawn and d.at("rubric_trace", default: false)
  if own == none {
    if asked { opts.rubric.traced = true }
    return opts
  }
  if "numbering" in own { opts.numbering = own.numbering }
  for key in ("points-format", "bonus-points-format", "points-position", "points-show-totals") {
    if key in own { opts.insert(key, own.at(key)) }
  }
  let r = opts.rubric
  r.position = own.at("rubric-position", default: r.position)
  r.width = own.at("rubric-width", default: r.width)
  // `auto` traces them in the margins and not at the `"end"`, of its own
  // position too.
  let trace = own.at("rubric-trace", default: r.trace-given)
  r.trace = if trace == auto { r.position != "end" } else { trace }
  r.traced = r.drawn and r.trace or asked
  opts.rubric = r
  opts
}

/// Where a division's badge is drawn: `none` when it has none, otherwise
/// its `points-position` (see `opts_of`), except that a conflict warning is
/// always drawn at the start, in the flow, where it is seen.
#let _badge_position(d, opts) = {
  let badge = _badge(d)
  if badge == none { none } else if badge.kind == "conflict" { "start" } else { opts_of(d, opts).points-position }
}

/// The points badge of a division, as drawn by `points-format` (or
/// `bonus-points-format`, for bonus points), or the conflict warning in its
/// place.
///
/// The badge is boxed so it acts as a single atomic inline unit: it never
/// breaks across lines, and its inner space is not stretched by paragraph
/// justification. Without the box, a body that starts with a full-width
/// inline element (e.g. `answer-box(width: 100%)`) pushes that element onto
/// the next line, which makes the badge's line a non-final — and therefore
/// justified — line, spreading "(1 point)" across the full measure.
#let _badge_body(d, opts) = {
  let badge = _badge(d)
  if badge == none { return none }
  if badge.kind == "conflict" { return conflict_warning(badge) }
  let opts = opts_of(d, opts)
  let format = if badge.bonus { opts.bonus-points-format } else { opts.points-format }
  box(format(badge.points))
}

/// The margin the badges of `d_idxs` (divisions sharing a first line,
/// outermost first) are drawn in: the innermost's that has its badge in one,
/// as each division may have a `points-position` of its own (see `opts_of`);
/// `none` if none has.
#let _margin_side(items, d_idxs, opts) = {
  let sides = d_idxs.map(i => _badge_position(items_of(items).at(i), opts)).filter(p => p in ("margin-left", "margin-right"))
  sides.at(-1, default: none)
}

/// The badges of `d_idxs` that go in the margin, as they are drawn there
/// (see `_margin_badges`), or `none`. Several share a first line when a
/// question starts with a part (`d_idxs` lists them outermost first). There,
/// an outer division's total (see `points-show-totals`) is left out when a
/// division inside it shows a badge, which would read as the outer one's
/// points; the rest are set side by side, the outermost first, rather than
/// drawn over each other.
#let _margin_badge_body(items, d_idxs, opts) = {
  let shown = d_idxs.filter(i => _badge_position(items_of(items).at(i), opts) in ("margin-left", "margin-right"))
  let innermost = shown.at(-1, default: none)
  let badges = shown
    .filter(i => i == innermost or not _badge(items_of(items).at(i)).total)
    .map(i => _badge_body(items_of(items).at(i), opts))
  if badges.len() == 0 { return none }
  stack(dir: ltr, spacing: .5em, ..badges)
}

/// Whether points badges in the margin on `side` are stacked with the
/// rubrics drawn in the same margin (see `stacked_badges`): when any
/// division of the exam draws its rubric there, whatever the position of the
/// badge's own.
#let _badges_stacked(opts, side) = opts.rubric.drawn and side in opts.rubric.positions

/// The badges of `d_idxs` that go in the margin (see `_margin_badge_body`),
/// placed in the margin level with the top of the block they are drawn in,
/// whose content starts `indent` right of the text's left edge; or, in the
/// margin rubrics are drawn in, stacked with them.
#let _margin_badges(items, d_idxs, indent, opts, dy: 0pt) = {
  let body = _margin_badge_body(items, d_idxs, opts)
  if body == none { return none }
  let side = _margin_side(items, d_idxs, opts)
  // Set against the text in a box wider than any badge, so that it neither
  // wraps nor needs measuring (a `context` here would break the paragraph
  // the badge is placed in).
  let body = box(width: _OVERFLOW, align(if side == "margin-right" { left } else { right }, body))
  let stacked = _badges_stacked(opts, side)
  // Anchored to the block, not to the line: since Typst 0.15 a `place`
  // with no alignment inside a paragraph anchors at the line's baseline.
  let placed(dy) = if side == "margin-right" {
    place(top + right, dx: MARGIN_GAP + _OVERFLOW, dy: dy, body)
  } else {
    // Clear of gutter labels that run out into the margin (see
    // `_badge_shift`), as far as the exam (`at`, see `render`) says it found
    // the last time it was laid out: read here, where it is used, so that
    // when it changes, only the badges are laid out again.
    let at = opts.at("badge-shift-at", default: none)
    let body = if at == none { body } else {
      context {
        let found = query(BADGE_SHIFT).find(m => m.value.at == at)
        let shift = if found != none { found.value.shift }
        if shift == none { body } else { move(dx: _badge_shift_at(shift.lefts, shift.widest), body) }
      }
    }
    place(top + left, dx: -indent - MARGIN_GAP - _OVERFLOW, dy: dy, body)
  }
  if stacked { stacked_badges(body, side, placed, dy: dy) } else { placed(dy) }
}

/// A badge drawn at the `"end"`: flush right after the text before it, on
/// the same line when there is room for it. After a block, such as an `fr`
/// answer box, it takes a line of its own, which in a segment of fixed
/// (`fr`) height the box gives up to it.
///
/// When the line is too full for it, as after a full-width box in the line,
/// it wraps, still flush right: the line may break only before the space
/// that pushes it right (at the zero-width space), never between the two
/// (the word joiner), and the empty box keeps that space from being dropped
/// as the start of the new line.
#let _end_badge(d, opts) = {
  if _badge_position(d, opts) != "end" { return none }
  [#h(.5em, weak: true)#sym.zws#box()#h(1fr)#sym.wj#_badge_body(d, opts)]
}

/// Division `d_idx`'s number as its gutter label shows it; `none` for an
/// unnumbered one.
#let _label_number(items, d_idx, opts) = {
  let d = items_of(items).at(d_idx)
  display_number(
    d.address,
    numbering: opts_of(d, opts).numbering,
    full: opts.numbering-full,
    levels: level_numberings(d, opts.numbering),
  )
}

/// Whether a division's address is counted at every level, so that its
/// full number (see `numbering-full`) holds those of the divisions it is in.
#let _counted(d) = d.address.all(n => type(n) == int)

/// Whether, with `numbering-full`, division `idx`'s number is left out of
/// the gutter: a division in it, numbered in full, shares its first line
/// and shows its number already ("1.a." for "1." and "(a)"). `line` lists
/// the divisions on that line, outermost first.
#let _covered(items, idx, line, opts) = {
  if not opts.numbering-full { return false }
  let i = line.position(d => d == idx)
  i != none and line.slice(i + 1).any(d => _counted(items_of(items).at(d)))
}

/// The top-level division that division `idx` is in, or `idx` itself.
#let _top(items, idx) = {
  let cur = idx
  while items_of(items).at(cur).parent != none { cur = items_of(items).at(cur).parent }
  cur
}

/// Division `top` and the divisions in it, in order.
#let _divisions_of(items, top) = {
  let out = ()
  let todo = (top,)
  while todo.len() > 0 {
    let d = todo.pop()
    out.push(d)
    for c in items_of(items).at(d).children.rev() { if items_of(items).at(c).kind == "division" { todo.push(c) } }
  }
  out
}

/// The width of `body`, drawn by division `drawer`, in `em` of the text
/// size there. Measured in the context the exam draws `drawer`'s question
/// in (see `render`), which has every rule of the exam's around the
/// question: `opts.measured-at` says which question that is, and how many of
/// its styles that context has (`depth`); without it, the exam's own context,
/// which has none. The styles of `drawer` past those are applied again, but
/// not its elembic rules (see `apply_styles`), which are for examy's
/// elements, not the text of a label or a badge. (The exam's rules around a
/// question cannot all be applied inside `measure`: they may hold a
/// `#set page(..)`.)
#let _width_at(items, body, drawer, opts) = {
  let size = text.size
  let top = _top(items, drawer)
  let at = opts.at("measured-at", default: none)
  let stack = stack_of(items_of(items).at(drawer).styles)
  let depth = if at != none and at.value.top == top { at.value.depth } else { stack_of(items_of(items).at(top).styles).len() }
  let styles = stack.slice(calc.min(depth, stack.len())).filter(s => type(s.apply) != function)
  measure(apply_styles({ set text(size: size); body }, styles)).width / size * 1em
}

/// The gutter label of division `d`, on its first line (`line`, its
/// divisions outermost first; see `_first_line`), as it is drawn:
/// `(division, number, x, width)`, `x` where its division's text starts,
/// which its label ends `LABEL_GAP` short of, and `width` the label's, in
/// `em` (see `_width_at`), so that it holds at the text size the label is
/// drawn at, in the font of the line's innermost division, whose block all
/// its labels are drawn in (see `_gutter_labels`). `none` for a division
/// whose number is left out (see `_covered`), or that has none.
///
/// Measured in the context the exam draws the question in (see `render`),
/// around all of it, rather than in a `context` where the label is drawn: one
/// in a line moves its inline math by a hair (see `rubric_area`), and in each
/// badge, measuring every label for each would take time growing with the
/// square of the exam's length.
#let _label_of(items, d, line, opts) = {
  if _covered(items, d, line, opts) { return none }
  let number = _label_number(items, d, opts)
  if number == none { return none }
  let width = _width_at(items, number, line.last(), opts)
  (division: d, number: number, x: cumulative_indent(items, d), width: width)
}

/// The gutter labels on a line that several share (`line`, see
/// `_label_of`).
#let _line_labels(items, line, opts) = line.map(d => _label_of(items, d, line, opts)).filter(l => l != none)

/// How lengths worked out from the labels on a line (`labels`, see
/// `_line_labels`) are compared: as they are when all are in `em`, which
/// holds at any text size (as with the default indent); otherwise resolved
/// at the size where the exam draws the question (in that context, see
/// `render`).
#let _resolver(labels) = if labels.all(l => l.x.abs == 0pt) { x => x } else { x => x.to-absolute() }

/// How far right of where it would end the `k`th of the labels on a line
/// (`labels`, see `_line_labels`) is moved, so that it starts `LABEL_SEP`
/// after the end of the label before it, as that one has moved: none when
/// the indent between them leaves room for it. The first label of a line
/// never moves, so that the labels of the outermost level stay in line, and
/// a label moves only on a line it shares: the next part, "(b)", is in line
/// with the others of its level. Needs no context with an indent in `em`
/// (see `_resolver`).
#let _label_push(labels, k) = {
  let resolve = _resolver(labels)
  let (end, push) = (none, 0pt)
  for l in labels.slice(0, k + 1) {
    let start = resolve(l.x - LABEL_GAP - l.width)
    push = if end == none { 0pt } else { calc.max(0pt, resolve(end + LABEL_SEP - start)) }
    end = start + push + resolve(l.width)
  }
  push
}

/// How far right the text of a line moves to clear the labels on it
/// (`labels`, see `_line_labels`): to start `LABEL_GAP` after the end of the
/// last, as that one has moved (see `_label_push`). `x` is where the text
/// starts, that of the line's innermost division, which has no label of its
/// own when it is unnumbered: then the last label is that of a division it
/// is in. None when the labels leave room for it.
#let _text_push(labels, x) = {
  if labels == () { return 0pt }
  let resolve = _resolver(labels + ((x: x),))
  let last = labels.last()
  calc.max(0pt, resolve(last.x + _label_push(labels, labels.len() - 1) - x))
}

/// Whether the labels of a line (`labels`, see `_line_labels`) that starts
/// with a block (not `inline`) are drawn on a line of their own above it:
/// when its text, starting at `x`, moves (see `_text_push`). Then the badges
/// in the margin are drawn there with them, at its top, not moved down to
/// the first line of a box it starts with (`dy`).
#let _labels_above(labels, inline, x) = not inline and _text_push(labels, x) > 0pt

/// The gutter label for a division, placed to the left of the body.
/// `indent` is the cumulative indent of the block the label is placed inside
/// (placement is relative to that block's content origin) and `width` is
/// the division's own cumulative indent, where its text starts.
///
/// When the body starts with inline content, pass `inline: true`: the label
/// is emitted as a zero-width inline box that participates in the first
/// line's layout, so it stays on the baseline even when the line is taller
/// than usual (e.g. a boxed solution on the first line). When the body
/// starts with a block-level element (or is empty), the label is `place`d at
/// the block top instead, which is where the block's first content sits.
/// (The zero-width trick assumes LTR text.)
///
/// `labels` are the gutter labels of its line when it shares it with others
/// (see `_line_labels`), and otherwise `()`. One after the first is moved
/// right, if it must be, clear of the label before it (see `_label_push`).
#let _gutter_label(items, d_idx, indent, width, opts, inline: false, dy: 0pt, labels: ()) = {
  let disp = _label_number(items, d_idx, opts)
  if disp == none { return none }
  // Right-aligned in a box ending `LABEL_GAP` short of the text, and wider
  // than the gutter, so that a label too long for it (`"Problem 1."`) runs
  // out to the left rather than wrapping.
  let dx = -indent + width - LABEL_GAP - _OVERFLOW
  let label = box(width: _OVERFLOW, align(right, disp))
  // Anchor to the block region explicitly: since Typst 0.15 an
  // alignment-less `place` inside a paragraph anchors at the line's
  // baseline, which for a line containing a tall inline box is its bottom.
  // `dy` moves it down to the first line of a box the body starts with.
  let k = labels.position(l => l.division == d_idx)
  let push = if k == none or k == 0 { 0pt } else { _label_push(labels, k) }
  // Moved, not set after more space: in its box of no width, that would
  // wrap it onto a line of its own.
  if inline { box(width: 0pt, move(dx: push, h(dx) + label)) } else { place(top + left, dx: dx + push, dy: dy, label) }
}

/// The gutter labels of a line (`line`, its divisions outermost first; see
/// `_first_line`), all drawn in the block of its innermost division, whose
/// text starts at `indent` (that block's cumulative indent), so that they are
/// all on the line's baseline when it starts `inline` (see `_gutter_label`).
/// `labels` as for `_gutter_label`. A division whose number one in it shows
/// has none (see `_covered`).
///
/// When the labels move the line's text right (see `_text_push`), they move
/// it as far: inline, by a box as wide after them; beside a block, which they
/// cannot move, they are drawn inline instead, on a line of their own above
/// the block, kept on the same page as the block (see `_labels_above`).
#let _gutter_labels(items, line, indent, opts, inline: false, dy: 0pt, labels: ()) = {
  let push = _text_push(labels, indent)
  let drawn = for d in line {
    if not _covered(items, d, line, opts) {
      _gutter_label(items, d, indent, cumulative_indent(items, d), opts, inline: inline or push > 0pt, dy: dy, labels: labels)
    }
  }
  if push == 0pt { drawn } else if inline { drawn + box(width: push) } else {
    // Spaced from the block as the paragraph it is would be.
    context block(sticky: true, below: par.spacing, drawn + box(width: push))
  }
}

/// Whether a body (a list of item indices, in order) starts with a child
/// division. Invisible chunks are skipped.
#let _body_starts_with_division(items, idxs) = {
  for i in idxs {
    let it = items_of(items).at(i)
    if it.kind == "chunk" and is_whitespace_content(it.body) { continue }
    return it.kind == "division"
  }
  false
}

/// Whether division `idx` shares its first line with a part its body starts
/// with: unless a badge in the flow (at the `"start"`, or the `"end"` of no
/// text) takes that line first.
#let _shares_first_line(items, idx, opts) = {
  let it = items_of(items).at(idx)
  _body_starts_with_division(items, it.children) and _badge_position(it, opts) not in ("start", "end")
}

/// Division `idx` and those it shares its first line with, outermost first
/// (see `_shares_first_line`).
#let _first_line(items, idx, opts) = {
  let line = (idx,)
  let cur = idx
  while _shares_first_line(items, cur, opts) {
    cur = items_of(items).at(cur).children.find(i => items_of(items).at(i).kind == "division")
    line.push(cur)
  }
  line
}

/// How the first line of a run of chunks (item indices, in order) sits, for
/// a gutter label: `inline`, whether the label rides that line's baseline;
/// and otherwise `dy`, how far below the top of the run the line starts (see
/// `leading`). Invisible chunks are skipped; anything but a chunk ends the
/// run.
#let _chunks_lead(items, idxs) = {
  for i in idxs {
    let it = items_of(items).at(i)
    if it.kind != "chunk" { break }
    let r = leading(it.body)
    if r != none { return (inline: r.inline, dy: if r.inline { 0pt } else { r.inset }) }
  }
  (inline: false, dy: 0pt)
}

/// `_chunks_lead` for the body of division `idx`. A body that shares its
/// first line with a part it starts with has its label drawn with the
/// part's (see `_gutter_labels`), and its badges and rubrics in the margin
/// level with them; one whose badge takes that line has its label at the
/// top.
#let _label_lead(items, idx, opts) = {
  let children = items_of(items).at(idx).children
  if not _body_starts_with_division(items, children) { return _chunks_lead(items, children) }
  if not _shares_first_line(items, idx, opts) { return (inline: false, dy: 0pt) }
  let first = children.find(i => items_of(items).at(i).kind == "division")
  (inline: false, dy: _label_lead(items, first, opts).dy)
}

/// Anchor, points marker, and (at the `"start"`) points badge emitted at
/// the start of a division's body. `inline` is whether the body starts with
/// inline content, a paragraph the head can join.
#let _division_head(items, d_idx, opts, inline: true) = {
  let d = items_of(items).at(d_idx)
  let anchor = division_anchor(
    label_name: d.fields.label,
    full_address: d.address,
    numbering: opts_of(d, opts).numbering,
    levels: level_numberings(d, opts.numbering),
    full: opts.numbering-full,
    label: d.fields.label,
  )
  if d.fields.label == none {
    // Realizes to pure invisible tags; safe to leave bare in the flow.
    anchor
  } else if inline or _badge_position(d, opts) == "start" {
    // A *labeled* elembic element realizes inside a block-level wrapper,
    // which would break the division's first line; an inline box keeps it in
    // the paragraph (references still resolve to it).
    box(anchor)
  } else {
    // With no paragraph to join (the body starts with a part or a block),
    // a box would make one, an empty line of its own: placed, it takes no
    // room.
    place(anchor)
  }
  // Where `num-points-page` finds the division's points, and where the
  // points table links its label to.
  if d.fields.points != none { points_marker(d.fields.points, d.fields.intent) }
  division_marker(d.id)
  if _badge_position(d, opts) == "start" { _badge_body(d, opts) + h(.5em) }
}

/// Mark the chunks that hold rubrics, anywhere inside them (`rubric:
/// true`, and `owner`: the id of their division, or `none`), and the
/// divisions that have a rubric (`rubric: true`): in their `rubric:` field,
/// or in their own text (then also `rubric_text: true`). Returns the items
/// and whether any are marked. What is not marked is rendered as if there
/// were no rubrics.
#let mark_rubrics(items) = {
  let any = false
  for (i, it) in items.enumerate() {
    if it.kind == "chunk" and has_any_rubric(it.body) {
      items.at(i).insert("rubric", true)
      items.at(i).insert("owner", if it.parent != none { items.at(it.parent).id })
      if it.parent != none {
        items.at(it.parent).insert("rubric", true)
        items.at(it.parent).insert("rubric_text", true)
        // An item given `trace: true` is traced whatever the division's
        // rubrics are (see `opts_of`).
        if rubric_markers(it.body, kept: true).any(m => m.value.at("trace", default: auto) == true) {
          items.at(it.parent).insert("rubric_trace", true)
        }
      }
      any = true
    } else if it.kind == "division" and it.fields.rubric != none {
      items.at(i).insert("rubric", true)
      any = true
    }
  }
  (items, any)
}

// Every call is memoized, its arguments hashed, and `items` takes long to
// hash: what follows is called only where there are rubrics, which the
// callers check first (`opts.rubric.drawn`, `opts.rubric.traced`, and the
// marks of `mark_rubrics`), so that an exam with none, or whose rubrics are
// not shown, pays (almost) nothing for them.

/// `body` marked as division `id`'s, for the rubrics in it (see `OWNER`):
/// no division's again after it.
#let _owned(id, body) = owner_update(id) + body + owner_update(none)

/// The `metadata` of chunks `chunks` (items) that a segment takes in (see
/// plan.typ), alone: their rubrics, their division's, and any other
/// `metadata` (with its label), all invisible.
#let _carried_rubrics(chunks) = for c in chunks {
  _owned(c.at("owner", default: none), _find(c.body, x => type(x) == content and x.func() == metadata).join())
}

/// Join a run of chunks (items) back into content, re-applying recorded
/// styles. Consecutive chunks with the same style stack are joined first so
/// spacing is preserved, then wrapped once. `base` styles (already applied
/// by an enclosing block) are skipped. `opts` are those of the division they
/// are in (see `opts_of`).
#let _render_chunk_list(chunks, opts, base: 0) = {
  let groups = ()
  // The division of those holding rubrics (all are its), if any do.
  let marked = false
  let owner = none
  for c in chunks {
    if c.at("rubric", default: false) { (marked, owner) = (true, c.owner) }
    let styles = stack_of(c.styles)
    let styles = styles.slice(calc.min(base, styles.len()))
    if groups.len() > 0 and groups.at(-1).styles.map(s => s.id) == styles.map(s => s.id) {
      groups.at(-1).bodies.push(c.body)
    } else {
      groups.push((styles: styles, bodies: (c.body,)))
    }
  }
  if not marked { return groups.map(g => apply_styles(g.bodies.join(), g.styles)).join() }
  // The rubrics in them are their division's. A rubric whose leader is
  // drawn stays with the text beside it (see `glue_rubrics`).
  let glue = if opts.rubric.traced { glue_rubrics } else { c => c }
  _owned(owner, groups.map(g => apply_styles(glue(g.bodies.join()), g.styles)).join())
}

/// `_render_chunk_list` for the chunks at item indices `idxs`.
#let render_chunks(items, idxs, opts, base: 0) = _render_chunk_list(idxs.map(i => items_of(items).at(i)), opts, base: base)

/// A run of chunks (items) cut where the first paragraph they hold ends (see
/// `split_first_par`): `(before, after)`, two runs of chunks, the chunk it
/// ends in cut in two. Of a chunk marked as holding rubrics (see
/// `mark_rubrics`), only a half that holds one stays marked.
#let _split_first_par(chunks) = {
  for (i, c) in chunks.enumerate() {
    let (b, a) = split_first_par(c.body)
    if a != none {
      let half(body) = if c.at("rubric", default: false) and not has_any_rubric(body) {
        (..c, body: body, rubric: false)
      } else { (..c, body: body) }
      let before = chunks.slice(0, i) + if b != none { (half(b),) } else { () }
      return (before, (half(a),) + chunks.slice(i + 1))
    }
  }
  (chunks, ())
}

/// `head`, the labels of a line that several share, then the chunks (items)
/// after it, `chunks`, of the innermost of them, and `end_badge`, the
/// innermost's badge at the `"end"` (or `none`). `hang` is `(labels, x)`
/// (see `_hang_of`).
///
/// When the line's text, starting at `x`, moved right to clear its labels
/// (see `_text_push`), the first paragraph, from the labels on,
/// is drawn with its lines after the first starting where the line's first
/// label starts: with no indent, "1. (a) The part's text" wraps back under
/// the "1.". Never left of the text's edge, though: where the "1." is in the
/// margin (as with no indent at all), they start at the edge, as the
/// paragraphs after it do. The chunks are cut where that paragraph ends (see
/// `split_first_par`), and the badge ends it when it is all of them. The
/// paragraph ends with a paragraph break: text alone in its block is not a
/// paragraph, and does not take a `hanging-indent`. (Not made a `par(..)` of
/// its own, which would drop a block in it that `split_first_par` cannot
/// see, one a `context` or a show rule makes; here, that block ends the
/// paragraph.)
///
/// When it did not move (as with the default indent), or the line's labels
/// are all in the margin, all is drawn as it would be, and the chunks are
/// not cut. So it is too when that paragraph holds more than text (see
/// `is_plain_text`): a box in it, an inline `solution` say, is as wide as
/// the paragraph, not as its lines after the first, which are wider, and
/// the text after the box would run on beside it. `opts` and `base` as for
/// `_render_chunk_list`.
#let _draw_hung(hang, head, chunks, end_badge, opts, base: 0) = {
  let (labels, x) = hang
  let first = labels.first()
  // From the edge of the division's text back to where the first label
  // starts, but no farther than the edge of the exam's text.
  let resolve = _resolver(labels + ((x: x),))
  let indent = calc.min(resolve(x), resolve(x - first.x + LABEL_GAP + first.width))
  let plain() = head + _render_chunk_list(chunks, opts, base: base) + end_badge
  if _text_push(labels, x) == 0pt or indent <= 0pt { return plain() }
  let (before, after) = _split_first_par(chunks)
  if not before.all(c => is_plain_text(c.body)) { return plain() }
  {
    set par(hanging-indent: -indent)
    head
    _render_chunk_list(before, opts, base: base)
    if after == () { end_badge }
    parbreak()
  }
  _render_chunk_list(after, opts, base: base)
  if after != () { end_badge }
}

/// Whether the first paragraph of the innermost division of a line that
/// several share, its text starting at `x`, may be drawn hung (see
/// `_draw_hung`), and with what: `(labels, x)`, or `none`. Only when its
/// labels (`labels`, see `_line_labels`) ride the line (`inline`); then they
/// may move its text.
#let _hang_of(labels, x, inline) = if inline and labels.len() > 1 { (labels, x) }

/// What division `d`'s rubric is headed by, and its points (or its parts'),
/// for the export (see `rubric_area`).
#let rubric_info(d, opts) = {
  let levels = level_numberings(d, opts.numbering)
  let opts = opts_of(d, opts)
  let weight = if d.fields.points != none { d.fields.points } else if d.total_points > 0 { d.total_points }
  (
    heading: (
      title: [#opts.strings.question #reference_body(d.address, (), numbering: opts.numbering, full: opts.numbering-full, levels: levels)],
      points: if weight == none { none } else if d.fields.points != none and d.fields.intent == "bonus" {
        (opts.bonus-points-format)(weight)
      } else {
        (opts.points-format)(weight)
      },
    ),
    points: weight,
  )
}

/// Whether division `d` (an item) has a rubric drawn (see `mark_rubrics`).
#let _drawn(d, opts) = opts.rubric.drawn and d.at("rubric", default: false)

/// Division `d`'s rubric in the margin, at the start of its block (see
/// `rubric_area`). Only for a division with a rubric drawn there.
#let _rubric_margin(d, opts, indent, dy) = {
  rubric_area(d.id, d.address, d.fields.rubric, rubric_info(d, opts), opts_of(d, opts), indent: indent, dy: dy)
}

/// Division `d`'s rubric at its `"end"` (see `rubric_end_area`). Only for a
/// division with a rubric drawn there.
#let _rubric_end(d, opts) = rubric_end_area(d.id, d.address, d.fields.rubric, rubric_info(d, opts), opts)

/// Render a division subtree as ordinary nested blocks (used when the
/// subtree contains no page breaks or fr heights). `carry` are ancestors
/// that share this division's first line, and whose badges in the margin
/// this division draws with its own. `end` is whether it draws its rubric at
/// the `"end"`: not when it is given a `height`, which `render` draws after
/// it (see `_rubric_ends`).
#let render_nested(items, idx, opts, base_styles: 0, carry: (), end: true) = {
  let it = items_of(items).at(idx)
  let indent = indent_of(it)
  // Its own options; the exam's go to the divisions in it (see `opts_of`).
  let o = opts_of(it, opts)
  let it_styles = stack_of(it.styles)
  let own_styles = it_styles.slice(calc.min(base_styles, it_styles.len()))

  // Whether the gutter label rides the first line, and otherwise how far down
  // to move it, and a badge in the margin, to that line.
  let (inline: inline_label, dy: dy) = _label_lead(items, idx, opts)
  // A body sharing its first line with a part it starts with has its badge
  // in the margin drawn by the part, with the part's own.
  let shares_line = _shares_first_line(items, idx, opts)
  // Whether it has rubrics written in its own text, whose leaders it draws.
  let traced = o.rubric.traced and it.at("rubric_text", default: false)
  let margin = o.rubric.position != "end" and _drawn(it, opts)
  // The divisions on its first line, outermost first, and their labels when
  // they share it; where the innermost's text starts.
  let line = carry + _first_line(items, idx, opts)
  let labels = if line.len() > 1 { _line_labels(items, line, opts) } else { () }
  let x = cumulative_indent(items, line.last())
  // On a line of their own above a box it starts with, all are drawn level
  // with it, not with the box's first line.
  let dy = if _labels_above(labels, inline_label, x) { 0pt } else { dy }
  let body = {
    // First, before the paragraph it is level with: a `place` aligned to the
    // block in the middle of a paragraph would break it in two.
    if _badges_stacked(opts, _margin_side(items, line, opts)) {
      // Stacked with the rubrics, the badges of a first line come before
      // them all: drawn by the outermost division whose number is on it,
      // for those of the divisions it shares it with.
      if carry.len() == 0 { _margin_badges(items, line, cumulative_indent(items, idx), opts, dy: dy) }
    } else if not shares_line {
      _margin_badges(items, line, cumulative_indent(items, idx), opts, dy: dy)
    }
    if traced { rubric_head(it.id) }
    if margin { _rubric_margin(it, opts, cumulative_indent(items, idx), dy) }
    // The labels of its first line, drawn by the innermost division on it,
    // on that line, its own last.
    let head = {
      if not shares_line { _gutter_labels(items, line, x, opts, inline: inline_label, dy: dy, labels: labels) }
      _division_head(items, idx, opts, inline: inline_label)
    }
    let carry = if shares_line { carry + (idx,) } else { () }
    let children = it.children
    // A badge at the `"end"` follows the division's own text, before its
    // first part.
    let end_badge = _end_badge(it, opts)
    // The innermost on a line shared with labels that may move it: its first
    // paragraph, which the line starts, drawn whole with its head (see
    // `_draw_hung`), from the chunks its body starts with, and then its
    // badge at the `"end"`, which follows its text before its first part.
    let hang = if not shares_line { _hang_of(labels, x, inline_label) }
    if hang == none { head } else {
      let n = children.position(c => items_of(items).at(c).kind != "chunk")
      let lead = if n == none { children } else { children.slice(0, n) }
      children = children.slice(lead.len())
      _draw_hung(hang, head, lead.map(i => items_of(items).at(i)), end_badge, o, base: it_styles.len())
      end_badge = none
    }
    // Children in document order: runs of chunks joined, child divisions
    // rendered recursively. Its text after a child division is its own
    // again, for the references in it (see `update_current_address`), which
    // the child's anchor made the child's.
    let chunk_run = ()
    let after_child = false
    for c_idx in children {
      let child = items_of(items).at(c_idx)
      if child.kind == "chunk" {
        chunk_run.push(c_idx)
      } else {
        if after_child and chunk_run.len() > 0 { update_current_address(it.address) }
        render_chunks(items, chunk_run, o, base: it_styles.len())
        end_badge
        end_badge = none
        chunk_run = ()
        render_nested(items, c_idx, opts, base_styles: it_styles.len(), carry: carry)
        carry = ()
        after_child = true
      }
    }
    if after_child and chunk_run.len() > 0 { update_current_address(it.address) }
    render_chunks(items, chunk_run, o, base: it_styles.len())
    end_badge
    if end and o.rubric.position == "end" and _drawn(it, opts) { _rubric_end(it, opts) }
    if traced { rubric_leaders(it.id, (it.id,), o.rubric.position, trace: o.rubric.trace) }
  }

  apply_styles(
    block(width: 100%, inset: (left: indent), {
      set enum(numbering: enum_numbering(o.numbering, it.level))
      body
    }),
    own_styles,
  )
}

/// The height an exam lays out `h`, a division's own `height`, at: a
/// fraction as `opts.fr-unit` says (see `exam_options`), anything else as it
/// is. (A segment of `fr` boxes is sized in `render_segment`.)
#let fr_height(h, opts) = {
  if type(h) != fraction or opts.fr-unit == none { h } else if opts.fr-unit == auto { auto } else {
    h / 1fr * opts.fr-unit
  }
}

/// Render one peer segment (produced by splitting a subtree at breaks).
/// `base` styles (already applied around it, see `render`) are skipped.
#let render_segment(items, seg, opts, ends: (:), n: none, base: 0) = {
  let owner = items_of(items).at(seg.division)
  // Its owner's options (see `opts_of`).
  let o = opts_of(owner, opts)
  let height = if seg.has_inner_break or seg.fr == none { auto } else { seg.fr }
  let owner_styles = stack_of(owner.styles)
  let own_styles = owner_styles.slice(calc.min(base, owner_styles.len()))
  // A hoisted segment is a bare wrapper sitting exactly where its one chunk
  // used to sit, so it takes over that chunk's `above` spacing instead of the
  // default gap between peer blocks (`answer-box` sets a tight one).
  let above = if seg.hoisted {
    items_of(items).at(seg.items.at(0)).body.at("above", default: auto)
  } else { auto }
  // The rubrics it takes in from segments dropped before it (see plan.typ),
  // and the divisions of those in it whose leaders it draws, with their
  // `opts.rubric`: each traced as its own division's are (see `opts_of`),
  // not as its owner's.
  let carried = seg.at("rubrics", default: ()).map(i => items_of(items).at(i))
  let traced = ()
  if o.rubric.traced and seg.items.any(i => items_of(items).at(i).at("rubric", default: false)) {
    traced.push((owner.id, o.rubric))
  }
  for c in carried.filter(c => c.at("rubric", default: false)) {
    let r = opts_of(items_of(items).at(c.parent), opts).rubric
    if r.traced and not traced.any(t => t.first() == c.owner) { traced.push((c.owner, r)) }
  }

  let body = {
    let (inline: inline_label, dy: dy) = _chunks_lead(items, seg.items)
    // Gutter labels: possibly several divisions share this segment's first
    // line (e.g. a question whose body starts with a part), drawn on a line
    // of their own above a box it starts with (see `render_nested`).
    let line = seg.label_divisions
    let labels = if line.len() > 1 { _line_labels(items, line, opts) } else { () }
    let dy = if _labels_above(labels, inline_label, seg.indent) { 0pt } else { dy }
    // First, before the paragraph it is level with (see `render_nested`).
    if seg.label_divisions.len() > 0 { _margin_badges(items, seg.label_divisions, seg.indent, opts, dy: dy) }
    if traced.len() > 0 { rubric_head(owner.id) }
    if opts.rubric.drawn {
      for d_idx in seg.label_divisions {
        let d = items_of(items).at(d_idx)
        if _drawn(d, opts) and opts_of(d, opts).rubric.position != "end" { _rubric_margin(d, opts, seg.indent, dy) }
      }
    }
    let head = {
      _gutter_labels(items, line, seg.indent, opts, inline: inline_label, dy: dy, labels: labels)
      if seg.label_divisions.len() > 0 {
        for d_idx in seg.label_divisions {
          _division_head(items, d_idx, opts, inline: inline_label)
        }
      } else {
        // Continuation: no label, but references inside still belong here.
        update_current_address(owner.address)
      }
      if carried.len() > 0 { _carried_rubrics(carried) }
    }
    let end_badge = if ends.at(str(seg.division), default: none) == n { _end_badge(owner, opts) }
    // On a line shared with labels that may move its own, the first
    // paragraph is drawn whole with them, and then the badge at the `"end"`
    // (see `_draw_hung`).
    let hang = _hang_of(labels, seg.indent, inline_label)
    let chunks = seg.items.map(i => items_of(items).at(i))
    if hang == none {
      head
      _render_chunk_list(chunks, o, base: owner_styles.len())
    } else {
      _draw_hung(hang, head, chunks, end_badge, o, base: owner_styles.len())
      end_badge = none
    }
    end_badge
    for (id, r) in traced { rubric_leaders(owner.id, (id,), r.position, trace: r.trace) }
  }

  let segment(height, above) = block(width: 100%, inset: (left: seg.indent), height: height, sticky: seg.sticky, above: above, {
    // A pagebreak buried inside an opaque chunk cannot break out of this
    // block; degrade it to a column break like the old implementation.
    show pagebreak: it => colbreak(weak: it.weak)
    set enum(numbering: enum_numbering(o.numbering, owner.level))
    body
  })
  let unit = opts.fr-unit
  apply_styles(
    if type(height) != fraction or unit == none {
      segment(height, above)
    } else if unit == auto {
      // Where a share of the page comes to nothing (see `exam_options`): as
      // tall as what it holds, its `fr` boxes nothing, so that what follows
      // them (a badge at the `"end"`) stays in the flow.
      segment(auto, above)
    } else {
      // Each `1fr` as `unit` (see `exam_options`): what the segment holds
      // besides its `fr` boxes, which come to nothing measured, and `unit`
      // times its `fr`s on top, which its `fr` boxes share, so that a box of
      // `height: 2fr` is `2 * unit` tall.
      block(width: 100%, sticky: seg.sticky, above: above, layout(size => {
        let rest = measure(segment(auto, auto), width: size.width).height
        segment(rest + height / 1fr * unit, auto)
      }))
    },
    own_styles,
  )
}

/// For each division with a badge at the `"end"`, the index of the segment
/// that ends its own text: the last of its own segments before the first of
/// one of its parts, as the badge follows all its own text before its first
/// part when it is drawn in one piece (`render_nested`). Keyed by the
/// division's index, as a string. (`plan` gives each such division a segment
/// of its own before its parts, even with no text in it, for the badge.)
#let _end_segments(items, instructions, opts) = {
  let ends = (:)
  let closed = (:)
  for (n, instr) in instructions.enumerate() {
    // A frame (a part with a `height`) closes its parent's text, as one of
    // its segments would.
    if instr.kind not in ("segment", "frame") { continue }
    let owner = instr.division
    let ancestor = items_of(items).at(owner).parent
    while ancestor != none {
      closed.insert(str(ancestor), true)
      ancestor = items_of(items).at(ancestor).parent
    }
    if instr.kind == "segment" and str(owner) not in closed and _badge_position(items_of(items).at(owner), opts) == "end" {
      ends.insert(str(owner), n)
    }
  }
  ends
}

/// For rubrics at the `"end"` of divisions split into segments, or given a
/// `height`: for each instruction (its index, as a string), the divisions
/// whose rubric follows it, as it ends all they hold, innermost first. Only
/// the divisions these instructions draw are counted: those of their
/// segments, and of their frames, with those whose number shares a frame's
/// first line; strictly within `root` when it is given (the division a
/// frame's instructions are inside, whose rubric is drawn after the frame,
/// out of its height, as it takes room of its own).
#let _rubric_ends(items, instructions, opts, root: none) = {
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
    // those whose number shares its first line, are drawn here, after it.
    let ds = if instr.kind == "segment" {
      (instr.division, ..instr.label_divisions)
    } else if instr.kind == "frame" { (instr.division, ..instr.labels) } else { () }
    for d in ds {
      let item = items_of(items).at(d)
      if within(d) and _drawn(item, opts) and opts_of(item, opts).rubric.position == "end" {
        drawn.insert(str(d), true)
      }
    }
  }
  let last = (:)
  for (n, instr) in instructions.enumerate() {
    if instr.kind not in ("segment", "frame") { continue }
    let d = instr.division
    while d != none {
      if str(d) in drawn { last.insert(str(d), n) }
      d = items_of(items).at(d).parent
    }
  }
  let at = (:)
  for (d, n) in last {
    at.insert(str(n), at.at(str(n), default: ()) + (int(d),))
  }
  for (n, ds) in at {
    at.insert(n, ds.sorted(key: d => -items_of(items).at(d).level))
  }
  at
}

/// The styles instruction `instr` is drawn with (see `render`): those of
/// the item or division it draws, or a top-level break's own; `none` for
/// one drawn with whatever styles are around it.
#let _instruction_styles(items, instr) = {
  let kind = instr.kind
  let styles = if kind == "verbatim" { items_of(items).at(instr.item).styles } else if kind == "nested" {
    items_of(items).at(instr.root).styles
  } else if kind in ("segment", "frame") { items_of(items).at(instr.division).styles } else if kind == "break" {
    instr.at("styles", default: none)
  }
  if styles != none { stack_of(styles) }
}

/// The divisions that may draw the badges in the margin of a line (`line`,
/// its divisions outermost first): its innermost, or, stacked with the
/// rubrics, its outermost (see `render_nested`), or its innermost again,
/// whose segment draws them all after a break (see `render_segment`).
#let _badge_drawers(line, opts) = if _badges_stacked(opts, "margin-left") { (line.first(), line.last()).dedup() } else { (line.last(),) }

/// The widths of question `top`'s gutter labels and of its badges in the
/// left margin, as `exam_badge_shift` takes them: `(labels, widths)`,
/// `labels` each label's `(x, width)` (see `_label_of`), and `widths` each
/// badge's, on one line (see `_margin_badge_body`), in `em`. Needs the
/// context the exam draws the question in (see `_width_at`).
#let _shift_parts(items, top, opts) = {
  let lines = _divisions_of(items, top).map(d => (d, _first_line(items, d, opts)))
  let labels = lines.map(((d, line)) => _label_of(items, d, line, opts)).filter(l => l != none).map(l => (x: l.x, width: l.width))
  // Each in the font of each division that may draw it.
  let widths = lines
    .map(((_, line)) => line)
    .filter(line => _margin_side(items, line, opts) == "margin-left")
    .map(line => _badge_drawers(line, opts).map(drawer => _width_at(items, _margin_badge_body(items, line, opts), drawer, opts)))
    .flatten()
  (labels: labels, widths: widths)
}

/// How far the badges an exam draws in the left margin move, clear of its
/// gutter labels (see `_badge_shift`): `(lefts, widest)`, `widest` the
/// widest of those badges, in `em`, as the labels' widths are. Each label is
/// where it is drawn unless a shared line moves it right (see
/// `_label_push`), which takes it farther from the margin. `none` when none
/// move: when the indent leaves room for every label. Needs the exam's
/// context.
///
/// A question drawn inside rules of the exam's is measured where the exam
/// draws it, and its widths given in `measured`, by its index (see
/// `render`); one not measured yet is left out. Any other is measured here,
/// in the exam's context, which is the one it is drawn in.
#let exam_badge_shift(items, opts, measured: (:)) = {
  let tops = range(items_of(items).len()).filter(i => items_of(items).at(i).kind == "division" and items_of(items).at(i).parent == none)
  let parts = tops.map(t => if str(t) in measured { measured.at(str(t)) } else if (
    stack_of(items_of(items).at(t).styles).len() > 0
  ) { (labels: (), widths: ()) } else {
    _shift_parts(items, t, opts)
  })
  let lefts = _badge_shift(parts.map(p => p.labels).flatten())
  if lefts == none { return none }
  (lefts: lefts, widest: calc.max(0em, ..parts.map(p => p.widths).flatten()))
}

/// Render a full instruction list. `opts` are the layout options resolved
/// from `config` (see `exam_options`). `root` is the division a frame's
/// instructions are inside (see `_rubric_ends`). `base` styles are already
/// applied around them.
///
/// Each style is applied once around the run of instructions it is the
/// same for, as Typst would apply the rule it comes from to its scope, not
/// to each instruction alone: a `#set page(..)` before some questions (with
/// `#show: exam`, inside the exam) starts one run of pages for them all, not
/// one per question. The runs are kept open on a stack, not by recursing,
/// as a document may have more rules than Typst lets functions recurse.
#let render(items, instructions, opts: DEFAULT_EXAM_OPTIONS, root: none, base: 0) = {
  let items = hold(items)
  // Where the exam is, at the top (a frame's instructions are rendered with
  // it), in its context (see `_exam_body`), when it draws badges in the left
  // margin: how far they move is worked out here (see `exam_badge_shift`),
  // from the widths of each question's labels, measured where the exam
  // draws it (see below), the last time it was laid out; and given to the
  // badges as metadata, which they read where they are drawn, not in the
  // options, so that what else the exam draws is laid out once, not again
  // when the widths come in.
  let at = none
  let shift = none
  if root == none and range(items_of(items).len()).any(i => (
    items_of(items).at(i).kind == "division" and _badge_position(items_of(items).at(i), opts) == "margin-left"
  )) {
    at = here()
    let measured = query(QUESTION_WIDTHS).filter(m => m.value.at == at).map(m => (str(m.value.top), m.value.parts))
    shift = [#metadata((at: at, shift: exam_badge_shift(items, opts, measured: measured.to-dict())))#BADGE_SHIFT]
    opts.insert("badge-shift-at", at)
  }
  let ends = _end_segments(items, instructions, opts)
  let rubric_ends = if opts.rubric.drawn and "end" in opts.rubric.positions {
    _rubric_ends(items, instructions, opts, root: root)
  } else { (:) }
  // For each instruction, whether it is text between divisions, or after
  // them, that follows one: it is no division's, for the references in it
  // (see `update_current_address`), which the division's anchor made the
  // division's. And whether the last of them draws a division, so that
  // what follows the exam is no division's either.
  let (resets, in_division) = ((), false)
  for instr in instructions {
    resets.push(instr.kind == "verbatim" and in_division)
    if instr.kind in ("nested", "segment", "frame") { in_division = true } else if instr.kind == "verbatim" {
      in_division = false
    }
  }
  // Instruction `n`, drawn inside styles `depth` deep.
  let one(n, depth, opts) = {
    let instr = instructions.at(n)
    if instr.kind == "verbatim" {
      // Between divisions: a rubric here is no division's (see `OWNER`).
      let it = items_of(items).at(instr.item)
      let styles = stack_of(it.styles)
      if resets.at(n) { update_current_address(()) }
      apply_styles(it.body, styles.slice(calc.min(depth, styles.len())))
    } else if instr.kind == "rubrics" {
      _carried_rubrics(instr.items.map(i => items_of(items).at(i)))
    } else if instr.kind == "break" {
      if instr.target == "page" {
        pagebreak(weak: instr.weak)
      } else {
        colbreak(weak: instr.weak)
      }
    } else if instr.kind == "nested" {
      render_nested(items, instr.root, opts, base_styles: depth, end: instr.root != root)
    } else if instr.kind == "segment" {
      render_segment(items, instr, opts, ends: ends, n: n, base: depth)
    } else if instr.kind == "frame" {
      // A division with a `height`: one block of that height, which cannot
      // break across pages (see `fixed_height_break_error`), with what it
      // holds planned and rendered inside it, so that `fr` answer boxes in
      // it share its height.
      let inner = frame_plan(items, instr.division, labels: instr.labels, rubrics: instr.at("rubrics", default: ()))
      let height = fr_height(items_of(items).at(instr.division).fields.height, opts)
      // In a block of fixed height, `fr` heights are shares of it again.
      let inner_opts = if height == auto { opts } else { (..opts, fr-unit: none) }
      block(width: 100%, height: height, breakable: false, render(
        items,
        inner,
        opts: inner_opts,
        root: instr.division,
        base: depth,
      ))
    } else {
      panic("examy: unknown render instruction: " + repr(instr.kind))
    }
    for d in rubric_ends.at(str(n), default: ()) {
      block(width: 100%, inset: (left: cumulative_indent(items, d)), _rubric_end(items_of(items).at(d), opts))
    }
  }
  // The styles open, outermost first, each with what is drawn in it so far;
  // the first, of none, holds what is drawn with only `base` styles.
  let open = ((style: none, parts: ()),)
  // The questions whose widths are measured (see below).
  let measured = (:)
  // Close the innermost open style: what it holds, styled, goes into the
  // one around it.
  let close(open) = {
    let o = open.pop()
    open.at(-1).parts.push(apply_styles(o.parts.join(), (o.style,)))
    open
  }
  for (n, instr) in instructions.enumerate() {
    let styles = _instruction_styles(items, instr)
    if styles != none {
      // Keep the open styles it starts with, close the others, and open
      // the rest of its own.
      let keep = 1
      while keep < open.len() and base + keep - 1 < styles.len() and styles.at(base + keep - 1).id == open.at(keep).style.id {
        keep += 1
      }
      while open.len() > keep { open = close(open) }
      for s in styles.slice(calc.min(base + keep - 1, styles.len())) { open.push((style: s, parts: ())) }
    }
    // At the top, a question inside rules of the exam's is drawn in a
    // `context` inside them, where its labels and badges are measured as
    // they are drawn, in the font the rules give, say, or in capitals (see
    // `_width_at`); around all of it, not in a line. The widths for the
    // badge shift are measured once, inside its own styles (see above).
    let depth = base + open.len() - 1
    let division = instr.at("root", default: instr.at("division", default: none))
    let top = if root == none and division != none { _top(items, division) }
    let top_depth = if top != none { stack_of(items_of(items).at(top).styles).len() } else { 0 }
    if top_depth == 0 {
      open.at(-1).parts.push(one(n, depth, opts))
      continue
    }
    if at != none and str(top) not in measured {
      measured.insert(str(top), true)
      let o = (..opts, measured-at: metadata((top: top, depth: top_depth)))
      open.at(top_depth - base).parts.push(context [#metadata((at: at, top: top, parts: _shift_parts(items, top, o)))#QUESTION_WIDTHS])
    }
    open.at(-1).parts.push(context one(n, depth, (..opts, measured-at: metadata((top: top, depth: depth)))))
  }
  while open.len() > 1 { open = close(open) }
  shift + open.first().parts.join()
  // A frame's instructions are inside its division, which goes on after them.
  if root == none and in_division { update_current_address(()) }
}
