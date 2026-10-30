/// Rubrics (DESIGN.md §14): `rubric`; each division's rubric, drawn in the
/// margin or after the division; the leaders traced from where a rubric is
/// written to its item; and `rubric-list`, every rubric on its own.
///
/// `rubric` returns a marker (see markers.typ) carrying its own data, so the
/// same call works in a division's `rubric:` field, where it is read, and in
/// its body, where it is placed: an invisible anchor, found by a query. The
/// renderer marks each run of a division's own content (see `OWNER`), so a
/// rubric in the body, however deep (a `solution`, an `answer-box`), belongs
/// to the division whose text it is in.

#import "prelude.typ": *
#import "markers.typ": RUBRIC_LABEL, rubric_marker, rubric_value
#import "scan.typ": SEQUENCE_FUNC, STYLED_FUNC, is_whitespace_content
#import "points.typ": EXAMS_ENDED, EXAMS_STARTED
#import "signature.typ": declare_function, define

// ---------------------------------------------------------------------------
// The authoring function
// ---------------------------------------------------------------------------

#let _RUBRIC = declare_function(
  "rubric",
  doc: "A rubric item, or a group of items, for grading a question/part/subpart. Rubrics can be written in the question's `rubric` argument or anywhere in its body. Rubrics are only shown when `config`'s `show-rubrics` is set and by default take up no space.

  A rubric containing other rubrics is a group: its first paragraph is the group's title, and the rubrics inside are its items. Other text is shown as a note.",
  fields: (
    e.field(
      "body",
      e.types.union(content, str),
      doc: "The criterion for the item, or a group's title and items.",
      required: true,
    ),
    e.field(
      "points",
      e.types.union(int, float, none),
      doc: "The points for this rubric item (positive or negative).",
      default: none,
    ),
    e.field(
      "annotation",
      e.types.union(none, content, str),
      doc: "A short note for the grader, shown at the top of the rubric (e.g. `annotation: [pick one]`).",
      default: none,
    ),
    e.field(
      "trace",
      e.types.union(auto, bool),
      doc: "Whether to draw a dotted line from where this rubric item is written to the rubric. Setting to `auto` uses `config`'s `rubric-trace`.

      An item inside a group is traced with its group: the line runs from where the group is written, and the group's `trace` decides whether it is drawn. The item's own `trace` is not used.

      Note: items written in a question/part/subpart's `rubric` argument are never traced.",
      default: auto,
      meta: (config: "rubric-trace"),
    ),
  ),
)

/// A rubric item or group (see DOCS).
#let rubric = define(_RUBRIC, it => rubric_marker((
  points: it.points,
  annotation: it.annotation,
  body: it.body,
  trace: it.trace,
)))

// ---------------------------------------------------------------------------
// The data: rubric content as a tree
// ---------------------------------------------------------------------------

/// Content flattened into a list of pieces: `(rubric: data)` for each
/// rubric, other content as it is. Styles set inside are not kept.
#let _pieces(c) = {
  if c == none { return () }
  if type(c) == str { return ([#c],) }
  if type(c) != content { return ([#c],) }
  let v = rubric_value(c)
  if v != none { return ((rubric: v),) }
  if c.func() == SEQUENCE_FUNC { return c.children.map(_pieces).flatten() }
  if c.func() == STYLED_FUNC { return _pieces(c.child) }
  (c,)
}

#let _is_blank(p) = type(p) == content and is_whitespace_content(p)

/// `pieces` without its leading and trailing blank ones.
#let _trim(pieces) = {
  let first = pieces.position(p => not _is_blank(p))
  if first == none { return () }
  let last = pieces.len() - pieces.rev().position(p => not _is_blank(p))
  pieces.slice(first, last)
}

/// Pieces as nodes: each rubric a node (made by `node`), and each run of
/// other content in between, unless blank, a note.
#let _nodes(pieces, node) = {
  let out = ()
  let run = ()
  for p in pieces + (none,) {
    if p == none or type(p) == dictionary {
      let body = _trim(run).join()
      if body != none { out.push((kind: "note", body: body)) }
      run = ()
      if p != none { out.push(node(p.rubric)) }
    } else {
      run.push(p)
    }
  }
  out
}

/// The node of one rubric's data: an item, or, when its body holds rubrics,
/// a group, titled by its first paragraph, with a note of what follows it
/// before the first item.
#let _node(v) = {
  let pieces = _pieces(v.body)
  let first = pieces.position(p => type(p) == dictionary)
  // `annotation` is missing from the data of a rubric made by hand.
  let annotation = v.at("annotation", default: none)
  if first == none { return (kind: "item", points: v.points, annotation: annotation, body: v.body) }
  let head = pieces.slice(0, first)
  let brk = head.position(p => type(p) == content and p.func() == parbreak)
  let title = _trim(head.slice(0, if brk == none { head.len() } else { brk })).join()
  let note = if brk == none { none } else { _trim(head.slice(brk)).join() }
  (
    kind: "group",
    title: title,
    note: note,
    annotation: annotation,
    children: _nodes(pieces.slice(first), _node),
  )
}

/// The rubric content `c` as a list of nodes, each one of
///   (kind: "item", points, annotation, body)
///   (kind: "group", title, note, annotation, children)
///   (kind: "note", body)
/// Pure.
#let rubric_tree(c) = _nodes(_pieces(c), _node)

// ---------------------------------------------------------------------------
// Drawing
// ---------------------------------------------------------------------------

/// The colors a rubric is drawn in. A group's look depends on how deep it
/// is, so that a group inside a group stands apart from it; its `text`, for
/// its note and its annotation, is about 7:1 on its fill.
#let COLORS = (
  ink: rgb("#3a2630"),
  muted: rgb("#7a4560"),
  trace: rgb("#c63d7a"),
  positive: rgb("#1f7a3a"),
  negative: rgb("#b3261e"),
  card: (fill: rgb("#fdf4f8"), stroke: rgb("#e8b4ca"), title: rgb("#7a2148"), rule: rgb("#f1cfdd")),
  item: (fill: white, stroke: rgb("#efcadb")),
  groups: (
    (fill: rgb("#f9e2ec"), edge: rgb("#d77aa2"), title: rgb("#6e1d41"), text: rgb("#6a3a50")),
    (fill: rgb("#f2e0f3"), edge: rgb("#b264ad"), title: rgb("#5b2358"), text: rgb("#5e3a5b")),
    (fill: rgb("#fde6df"), edge: rgb("#e0866d"), title: rgb("#7a3320"), text: rgb("#6e3b2c")),
  ),
)

/// An item's points, signed: "+2", "−1", "0".
#let _points(p) = {
  if p == none { return none }
  let color = if p > 0 { COLORS.positive } else if p < 0 { COLORS.negative } else { COLORS.muted }
  text(fill: color, if p > 0 [+#p] else if p < 0 [−#calc.abs(p)] else [0])
}

/// The label of a place a box's leader can end at: one of its two top
/// corners (`edge`, `"left"` or `"right"`), for the rubric of key `key` (see
/// `_row_marks`). One of its own, to be found without looking through every
/// box.
#let row_label(key, edge) = label("_examy_rubric_row_" + str(key) + "_" + edge)

/// Invisible marks at the top corners of a box, where the leader of the
/// rubric of key `key` ends. `inset` is the box's, to reach its border from
/// inside it.
#let _row_marks(key, inset, scale) = if key != none {
  place(top + left, dx: -inset.left, dy: -inset.top, [#metadata((key: key, edge: "left", scale: scale))#row_label(key, "left")])
  place(top + right, dx: inset.right, dy: -inset.top, [#metadata((key: key, edge: "right", scale: scale))#row_label(key, "right")])
}

/// A rubric's annotation, set small in `fill`; `none` if it has none.
#let _annotation(n, fill) = if n.annotation != none { text(size: .85em, fill: fill, [#n.annotation]) }

/// An item's points, criterion, and annotation, side by side.
#let _item_row(n) = grid(
  columns: (1.7em, 1fr, auto),
  column-gutter: 5pt,
  align: (right + top, left + top, right + top),
  _points(n.points), n.body, _annotation(n, COLORS.muted),
)

#let _ITEM_INSET = (left: 4pt, right: 4pt, top: 3pt, bottom: 3pt)
#let _GROUP_INSET = (left: 5pt, right: 4pt, top: 2.5pt, bottom: 2.5pt)

/// Nodes as boxes: an item in a box of its own, a group in a tinted box
/// holding its items, a note as it is. `keys` maps a node's index (a string) to the
/// key of the rubric it was written as in the body, for its leader; only
/// the top level's are traced. `scale` is how much the card is scaled (see
/// `_scale`), which its leaders are too.
#let draw_nodes(nodes, keys: (:), depth: 0, scale: 1) = {
  for (i, n) in nodes.enumerate() {
    let k = if depth == 0 { keys.at(str(i), default: none) } else { none }
    if n.kind == "note" {
      block(above: 4pt, below: 4pt, inset: (x: 2pt), text(fill: COLORS.muted, style: "italic", n.body))
    } else if n.kind == "item" {
      block(
        width: 100%,
        above: 2.5pt,
        below: 2.5pt,
        fill: COLORS.item.fill,
        stroke: .6pt + COLORS.item.stroke,
        radius: 3.5pt,
        inset: _ITEM_INSET,
        {
          _row_marks(k, _ITEM_INSET, scale)
          _item_row(n)
        },
      )
    } else {
      let style = COLORS.groups.at(calc.min(depth, COLORS.groups.len() - 1))
      block(
        width: 100%,
        above: 3pt,
        below: 3pt,
        fill: style.fill,
        stroke: (left: 2pt + style.edge, rest: .6pt + style.fill.darken(10%)),
        radius: 4pt,
        inset: _GROUP_INSET,
        {
          _row_marks(k, _GROUP_INSET, scale)
          grid(
            columns: (1fr, auto),
            column-gutter: 3pt,
            align: (left + horizon, right + horizon),
            text(weight: "bold", fill: style.title, n.title),
            _annotation(n, style.text),
          )
          if n.note != none {
            block(above: 2pt, below: 3pt, text(fill: style.text, style: "italic", n.note))
          }
          draw_nodes(n.children, depth: depth + 1)
        },
      )
    }
  }
}

/// The space inside a card, around its boxes.
#let CARD_INSET = 3.5pt

/// A division's rubric: a card headed by `heading` (`title` at the left,
/// `points` at the right), holding its nodes, set at `size` (relative to the
/// text around it).
#let draw_card(heading, nodes, keys: (:), size: .72em, scale: 1) = {
  set text(size: size, fill: COLORS.ink)
  set par(justify: false, leading: .45em, spacing: .7em, first-line-indent: 0pt)
  set align(left)
  block(
    width: 100%,
    fill: COLORS.card.fill,
    stroke: .6pt + COLORS.card.stroke,
    radius: 5pt,
    inset: CARD_INSET,
    {
      grid(
        columns: (1fr, auto),
        text(weight: "bold", fill: COLORS.card.title, heading.title),
        if heading.points != none { text(fill: COLORS.muted, heading.points) },
      )
      block(above: 2pt, below: 2.5pt, line(length: 100%, stroke: .5pt + COLORS.card.rule))
      draw_nodes(nodes, keys: keys, scale: scale)
    },
  )
}

// ---------------------------------------------------------------------------
// Which rubrics are a division's
// ---------------------------------------------------------------------------

/// The label of the marks around each run of a division's content that
/// holds rubrics: the first with the id of the division (see parse.typ), the
/// last with `none`. A rubric is the division's of the last mark before it.
///
/// Marks, not a `state`: whose a rubric is comes from one query of the marks
/// and the rubrics together (see `_owned_rubrics`). A `state` read at each
/// rubric would be a read per rubric that Typst checks again every time it
/// reuses a result that depends on them (`_exam_rubrics`, for every card),
/// so that an exam would take time in the square of its rubrics.
#let OWNER = label(PREFIX + "/rubric-owner")

/// Mark the content that follows as division `id`'s (`none`: no
/// division's), for the rubrics in it.
#let owner_update(id) = [#metadata(id)#OWNER]

/// The rubrics after `start` and before `end` (locations), in order, each
/// `(rubric, owner)`: its marker, and the id of its division, or `none`
/// (see `OWNER`). Needs context.
#let _owned_rubrics(start, end) = {
  let owner = query(selector(OWNER).before(start)).at(-1, default: none)
  let owner = if owner == none { none } else { owner.value }
  let out = ()
  for m in query(selector(RUBRIC_LABEL).or(OWNER).after(start).before(end)) {
    if m.label == OWNER { owner = m.value } else { out.push((m, owner)) }
  }
  out
}

/// The exam a location is in: its number, counted from 1. Needs context.
#let _exam_number(loc) = EXAMS_STARTED.at(loc).first()

/// The labels of the start and the end of an exam with rubrics: the rubrics
/// between them are its own (see `exam_bounds`).
#let EXAM_START = label("_examy_rubric_exam_start")
#let EXAM_END = label("_examy_rubric_exam_end")
#let exam_start = [#metadata(none)#EXAM_START]
#let exam_end = [#metadata(none)#EXAM_END]

/// The start and end of the exam at `here()`, as locations: `none` until
/// they are laid out. Needs context.
#let exam_bounds() = {
  let start = query(selector(EXAM_START).before(here())).at(-1, default: none)
  let end = query(selector(EXAM_END).after(here())).at(0, default: none)
  if start == none or end == none { return none }
  (start.location(), end.location())
}

/// The rubrics written in the exam between `start` and `end`, by the
/// division they belong to (keyed by its id, as a string): its nodes,
/// in order, and for each of them (by index, as a string) its key, its index
/// among every rubric placed in the document, which links its box to its
/// anchor. Worked out once for the exam: Typst reuses the result for every
/// call with the same bounds. Needs context.
#let _exam_rubrics(start, end) = {
  let offset = query(selector(RUBRIC_LABEL).before(start, inclusive: false)).len()
  let out = (:)
  for (i, (a, owner)) in _owned_rubrics(start, end).enumerate() {
    if owner == none { continue }
    let k = str(owner)
    let r = out.at(k, default: (nodes: (), keys: (:)))
    r.keys.insert(str(r.nodes.len()), offset + i)
    r.nodes.push(_node(rubric_value(a)))
    out.insert(k, r)
  }
  out
}

/// The rubric of the division `id`, its `rubric:` field `field`, in the exam
/// within `bounds` (see `exam_bounds`): the rubrics written in its body, in
/// order, then its field; and the keys of those written (see
/// `_exam_rubrics`). Needs context.
#let division_rubric(id, field, bounds) = {
  let written = if bounds == none { (nodes: (), keys: (:)) } else {
    _exam_rubrics(..bounds).at(str(id), default: (nodes: (), keys: (:)))
  }
  (nodes: written.nodes + rubric_tree(field), keys: written.keys)
}

// ---------------------------------------------------------------------------
// The areas
// ---------------------------------------------------------------------------

/// The label of each division's rubric record: its exam, address, heading,
/// points, and nodes, for `rubric-list` and the export, recorded at the end
/// of its exam (see export.typ).
#let RECORD = label("_examy_rubric_record")

/// The label of where each rubric is drawn, for stacking those in a margin.
#let AREA = label("_examy_rubric_area")

/// The label of the marker at the start of each block of division `id`'s
/// content, which its leaders are drawn from (see `rubric_leaders`): one of
/// its own, to be found without looking through every division's.
#let _head_label(id) = label("_examy_rubric_head_" + str(id))

/// The marker at the start of a block of division `id`'s content
/// (invisible).
#let rubric_head(id) = [#metadata(id)#_head_label(id)]

/// The gap between the text and a rubric in the margin, and between the
/// rubric and the page's edge; and the gap between rubrics stacked in a
/// margin.
#let GAP = .18in
#let OUTER = .18in
#let STACK_GAP = 5pt

/// The label of the probes that tell how much a rubric is scaled (see
/// `_scale`).
#let SCALE = label("_examy_rubric_scale")

/// Two invisible probes, 100pt apart: put them in what a `context` places,
/// for it to read with `_scale`.
#let _scale_probes = {
  place(top + left, [#metadata(0)#SCALE])
  place(top + left, dx: 100pt, [#metadata(1)#SCALE])
}

/// How much the content at `here()` is scaled (by `scale`, say, in a figure
/// shrunk to fit), as found from the next `_scale_probes`: 1 until they are
/// laid out. Positions are reported on the page, scaled, but placing is done
/// in the content's own lengths: a distance between two positions is divided
/// by this to place something across it. Needs context.
#let _scale() = {
  let probes = query(selector(SCALE).after(here()))
  if probes.len() < 2 { return 1 }
  let (a, b) = probes.slice(0, 2).map(m => m.location().position())
  if a.page != b.page or b.x == a.x { return 1 }
  (b.x - a.x) / 100pt
}

/// The width of the page's margin on `side` (`"margin-left"` or
/// `"margin-right"`), resolved. Needs context.
#let _margin(side) = {
  let m = page.margin
  let key = if side == "margin-right" { "right" } else { "left" }
  if type(m) == dictionary {
    let v = m.at(key, default: none)
    if v == none and ("inside" in m or "outside" in m) {
      // Bound on the left (the default), the inside is the left of an odd
      // page and the right of an even one.
      let binding = if page.binding == auto { left } else { page.binding }
      let odd = calc.odd(here().page())
      let inside_left = (binding == left) == odd
      v = m.at(if (key == "left") == inside_left { "inside" } else { "outside" }, default: none)
    }
    if v == none { v = m.at("x", default: m.at("rest", default: auto)) }
    m = v
  }
  // As Typst resolves them: on a page of `auto` width, a margin's ratio is of
  // nothing, and an `auto` margin is of the smaller side that is not `auto`
  // (A4's width if neither is).
  let width = if page.width == auto { 0pt } else { page.width }
  if m == auto {
    let sides = (page.width, page.height).filter(x => x != auto)
    return 2.5 / 21 * if sides.len() == 0 { 21cm } else { calc.min(..sides) }
  }
  if type(m) == ratio { return m * width }
  if type(m) == relative { return m.length.to-absolute() + m.ratio * width }
  m.to-absolute()
}

/// Division `division`'s rubric as drawn (see `division_rubric`), and the id
/// its area is known by, which names the division by its `address`: none
/// when it has no rubric. Needs context.
#let _drawn(division, address, field) = {
  let r = division_rubric(division, field, exam_bounds())
  if r.nodes.len() == 0 { return none }
  r + (id: (exam: _exam_number(here()), address: address))
}

/// Where an area in the margin on `side` whose natural top on the page is
/// `top_y` goes, in the exam numbered `exam`: there, or below the areas
/// before it on its page, page position `p`, if they reach down to it. `k`:
/// its scale (see `_scale`). Needs context.
#let _stacked(exam, p, side, top_y, k) = {
  // Each area records only its natural top and height, which do not depend
  // on the stacking, and every area redoes the stacking of those before it
  // on its page: recording where each was moved to would chain them, a
  // layout pass each, and a page of several would not converge. They are
  // recorded in the content's own lengths, and scaled here, so that this
  // does not wait for another area's scale to be known either.
  let bottom = none
  // Only this exam's: a bundle's documents share one introspection, so the
  // first page of another document would read as this page. Those before it
  // on its page come last before it: read back to the first that is not.
  let before = query(selector(AREA).before(here()))
  let n = before.rev().position(m => m.value.id.exam != exam or m.value.page != p.page)
  let same = if n == none { before } else { before.slice(before.len() - n) }
  for m in same.filter(m => m.value.side == side) {
    let natural_top = m.value.py + m.value.dy * k
    let top = if bottom == none { natural_top } else { calc.max(natural_top, bottom + STACK_GAP * k) }
    bottom = top + m.value.natural * k
  }
  if bottom == none { top_y } else { calc.max(top_y, bottom + STACK_GAP * k) }
}

/// The record of an area (see `AREA`): `id` its exam and its division's
/// address (`none` for badges), at page position `p`, drawn at `dy` below
/// it, `natural` tall, in its own lengths; at `top_y` on the page, moved to
/// `y` (see `_stacked`).
#let _area_record(id, p, side, dy, natural, top_y, y, k) = [#metadata((
  id: id,
  page: p.page,
  side: side,
  // Where its block starts, on the page, and how far below that, and how
  // tall, it is in its own lengths: for the stacking.
  py: p.y,
  dy: dy,
  natural: natural,
  // On the page: where it would be, where it is (moved down below the area
  // before it), and how tall; for the tests.
  y: top_y,
  top: y,
  h: natural * k,
))#AREA]

/// Points badges `body` in the margin on `side` where rubrics are drawn too:
/// stacked with them (see `rubric_area`), so that neither covers the other.
/// `placed(dy)` places them `dy` below the top of their block, where they
/// are drawn. Emitted at the start of the block, before the rubrics of its
/// first line, so that they come first.
#let stacked_badges(body, side, placed, dy: 0pt) = context {
  let p = here().position()
  let k = _scale()
  let top_y = p.y + dy * k
  let natural = measure(body).height
  let id = (exam: _exam_number(here()), address: none)
  let y = _stacked(id.exam, p, side, top_y, k)
  _area_record(id, p, side, dy, natural, top_y, y, k)
  placed((y - p.y) / k)
  _scale_probes
}

/// A division's rubric in the margin, emitted at the start of its block,
/// before its first paragraph: placed, it takes no room. (The `context` it
/// is worked out in moves the inline math of the line it starts by a hair,
/// so it is emitted only for a division with a rubric, and only when
/// rubrics are shown: see render.typ.) `indent` is how far right of the
/// text's left edge the block's content is, and `dy` how far below its top
/// the first line is. `division` is its id, and `address` its address.
/// `info`: `heading` and `points` (see `rubric_info`).
#let rubric_area(division, address, field, info, opts, indent: 0pt, dy: 0pt) = context {
  let r = _drawn(division, address, field)
  if r == none { return }
  let side = opts.rubric.position
  let width = if opts.rubric.width == auto { _margin(side) - GAP - OUTER } else { opts.rubric.width }
  let p = here().position()
  // Positions are on the page, lengths here are the content's (see `_scale`).
  let k = _scale()
  let body = draw_card(info.heading, r.nodes, keys: r.keys, scale: k)
  let top_y = p.y + dy * k
  let natural = measure(block(width: width, body)).height
  let h = natural * k
  let y = _stacked(r.id.exam, p, side, top_y, k)
  let on_right = side == "margin-right"
  // A box of its own height: placed, it would otherwise be laid out in what
  // is left of the region it is placed in, as short as the exam is when the
  // exam is set in a box of its own height, and its items squeezed into it.
  let card = box(width: width, height: natural, body)
  _area_record(r.id, p, side, dy, natural, top_y, y, k)
  if on_right {
    place(top + right, dx: GAP + width, dy: (y - p.y) / k, card)
  } else {
    place(top + left, dx: -indent - GAP - width, dy: (y - p.y) / k, card)
  }
  _scale_probes
}

/// A division's rubric at its `"end"`: a block in the flow, after its parts.
#let rubric_end_area(division, address, field, info, opts) = context {
  let r = _drawn(division, address, field)
  if r == none { return }
  let k = _scale()
  block(width: 100%, above: .8em, below: .8em, breakable: false, {
    place(top + right, [#metadata((id: r.id, page: here().page(), side: "end"))#AREA])
    _scale_probes
    draw_card(info.heading, r.nodes, keys: r.keys, size: .85em, scale: k)
  })
}

// ---------------------------------------------------------------------------
// The leaders
// ---------------------------------------------------------------------------

/// Whether rubric `value` (its data) is traced: by its own `trace`, else
/// by `trace`, its division's.
#let is_traced(value, trace) = {
  let own = value.at("trace", default: auto)
  own == true or own == auto and trace
}

/// The leaders of the rubrics written in a block of division `id`'s content
/// that belong to one of `owners`, by id (its own, and those it takes in
/// from segments dropped before it, see plan.typ), to their boxes in their
/// rubric: along the rest of the rubric's line, in the gap below it, to the
/// text's edge, then to the box (at the `"end"`, down beside the text).
/// Emitted at the end of the block, so that they are drawn over its content:
/// drawn with the rubric, before the content, a solution's background would
/// cover them. Takes no room. Only those traced (see `is_traced`).
///
/// They are drawn from the top of the block, where its `rubric_head` is,
/// rather than from where they are emitted: laid out in a `measure` (to size
/// what holds the exam, say), a `context` sees its own position in the
/// measured layout, but every other element's on the page, and leaders
/// drawn from their own position would not match those on the page. A
/// block that runs onto a later page has its top on another page, and there
/// they are drawn from where they are emitted.
#let rubric_leaders(id, owners, side, trace: true) = context {
  let here_loc = here()
  let head = query(selector(_head_label(id)).before(here_loc)).at(-1, default: none)
  if head == none { return }
  // The rubrics in the block, between its head and here.
  // Those traced: by their own `trace`, else by `trace`.
  let mine = _owned_rubrics(head.location(), here_loc)
    .filter(((a, owner)) => owner in owners and is_traced(a.value, trace))
    .map(((a, owner)) => a)
  if mine.len() == 0 { return }
  let from_head = head.location().page() == here_loc.page()
  let o = if from_head { head.location().position() } else { here().position() }
  let edge_name = if side == "margin-right" { "left" } else { "right" }
  let stroke = (paint: COLORS.trace.transparentize(15%), thickness: .6pt, dash: (1.6pt, 1.2pt), cap: "round")
  // Below the rubric's line, in the gap before the next: below its
  // descenders, about .22em deep, and above the next line's capitals, .65em
  // down with the default leading.
  let draw = for a in mine {
    // Its index among every rubric placed (see `_exam_rubrics`).
    let key = query(selector(RUBRIC_LABEL).before(a.location())).len() - 1
    let row = query(row_label(key, edge_name)).at(0, default: none)
    if row == none { continue }
    let ap = a.location().position()
    let rp = row.location().position()
    if ap.page != o.page or rp.page != o.page { continue }
    // Scaled as the rubric they lead to is (see `_scale`).
    let k = row.value.scale
    // The text's edge beside the rubric, from the box's edge: the card's
    // inset, and in a margin the gap between the card and the text.
    let edge = if side == "margin-right" {
      rp.x - (CARD_INSET + GAP) * k
    } else if side == "margin-left" {
      rp.x + (CARD_INSET + GAP) * k
    } else {
      rp.x + CARD_INSET * k
    }
    let ay = ap.y + .43em.to-absolute() * k
    // The middle of the box's first line.
    let ry = rp.y + k * if side == "end" { 9.5pt } else { 8.5pt }
    // On the page, then in the content's own lengths, from `o`.
    let pts = if side == "margin-right" {
      ((ap.x, ay), (edge + 4pt * k, ay), (rp.x - 5pt * k, ry), (rp.x, ry))
    } else if side == "margin-left" {
      ((ap.x, ay), (edge - 4pt * k, ay), (rp.x + 5pt * k, ry), (rp.x, ry))
    } else {
      ((ap.x, ay), (edge + 6pt * k, ay), (edge + 6pt * k, ry), (rp.x, ry))
    }
    let pts = pts.map(((x, y)) => ((x - o.x) / k, (y - o.y) / k))
    let (a, z) = (pts.first(), pts.last())
    place(top + left, curve(stroke: stroke, curve.move(a), ..pts.slice(1).map(p => curve.line(p))))
    place(top + left, dx: a.at(0) - 1.6pt, dy: a.at(1) - 1.6pt, circle(radius: 1.6pt, fill: COLORS.trace))
    place(top + left, dx: z.at(0) - 1.25pt, dy: z.at(1) - 3pt, rect(width: 2.5pt, height: 6pt, fill: COLORS.trace, radius: 1pt))
  }
  if from_head { place(top + left, draw) } else { place(dx: 0pt, dy: 0pt, draw) }
}

// ---------------------------------------------------------------------------
// The rubrics on their own
// ---------------------------------------------------------------------------

/// The records of the exam a reader at `here()` is about: the exam it is
/// in; else the next exam, as a list before the exam is about the exam that
/// follows; else the last one. Needs context.
#let exam_records() = {
  let started = EXAMS_STARTED.get().first()
  let ended = EXAMS_ENDED.get().first()
  let total = EXAMS_STARTED.final().first()
  let exam = if started > ended { started } else { calc.min(started + 1, total) }
  query(RECORD).map(m => m.value).filter(r => r.exam == exam)
}

#let _RUBRIC_LIST = declare_function(
  "rubric-list",
  doc: "Lists every rubric of the exam. This function ignores the value of the global `show-rubrics` option.",
)

/// Every rubric of the exam, each in its card, one after another (see
/// DOCS).
#let rubric_list = define(_RUBRIC_LIST, it => context {
  let records = exam_records()
  if records.len() == 0 {
    return text(fill: red, "WARNING: No rubrics found! Can't make a rubric list.")
  }
  for r in records {
    block(width: 100%, breakable: false, below: 1em, draw_card(r.heading, r.nodes, size: .9em))
  }
})

/// API documentation for this module's exports, consumed by docs/api.typ
/// (keyed by export name).
#let DOCS = (
  rubric: _RUBRIC,
  "rubric-list": _RUBRIC_LIST,
)
