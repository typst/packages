/// Point totals, the scoring table, and the points on each page. The exam
/// element computes the per-division data once from the parsed item tree
/// and stores it in a state; the functions here read the final value, so
/// they work anywhere in the document (even before the exam). Points by page
/// come from markers the exam leaves where each division's points are drawn.

#import "prelude.typ": *
#import "config.typ": DEFAULT_NUMBERING, config
#import "refs.typ": level_numberings, reference_body
#import "signature.typ": declare_function, define

/// The per-division point data of every exam in the document, one array per
/// exam, in order (see `compute_points_data`). A document can hold several exams (a bundle export of
/// the exam and its key, or a page of examples), so each reader picks its
/// own exam (see `exam_points_data`).
#let points_data_state = state(PREFIX + "/points-data", ())

/// How many exams have started, and how many ended, before a location.
#let EXAMS_STARTED = counter(PREFIX + "/exams-started")
#let EXAMS_ENDED = counter(PREFIX + "/exams-ended")

/// The exam a reader at `loc` is about, by its index among the document's
/// (from 0): the exam it is in; else the next exam, as a points table on a
/// cover page is about the exam that follows; else the last one, as a total
/// at the end of a document is. `none` if there is no exam. Needs context.
#let exam_index(loc) = {
  let count = EXAMS_STARTED.final().first()
  if count == 0 { return none }
  let started = EXAMS_STARTED.at(loc).first()
  let ended = EXAMS_ENDED.at(loc).first()
  if started > ended { started - 1 } else { calc.min(started, count - 1) }
}

/// The point data of the exam a reader at `here()` is about (see
/// `exam_index`). Needs context.
/// `(index, rows)`: the index of that exam among the document's (from 0),
/// and its rows, one per division; `none` if there is no exam.
#let _exam_rows() = {
  let i = exam_index(here())
  if i == none { none } else { (i, points_data_state.final().at(i)) }
}

/// The point data of the exam a reader at `here()` is about (see
/// `_exam_rows`): a row per question. Needs context.
#let exam_points_data() = {
  let found = _exam_rows()
  if found == none { none } else { found.last().filter(r => r.level == 1) }
}

/// The label of the marker each division with points leaves at its start
/// (see `points_marker`).
#let POINTS_MARKER = label(PREFIX + "/points")

/// The marker a division with points leaves where it starts, which
/// `num-points-page` and the table by page count. Invisible.
#let points_marker(points, intent) = [#metadata((points: points, intent: intent))#POINTS_MARKER]

/// The label of the marker every division leaves at its start, with its id
/// (see parse.typ), for the points table to link to (see `division_marker`).
#let DIVISION_MARKER = label(PREFIX + "/division")

/// The marker a division leaves where it starts. Invisible.
#let division_marker(id) = [#metadata(id)#DIVISION_MARKER]

/// How a division is labelled in the points table: exactly as a reference
/// to it reads from outside its exam ("2 (a)"; "2(a)" with `full`), an
/// unnumbered division and those in it included ("??", "?? (a)").
#let _division_label(d, numbering, full) = reference_body(
  d.address,
  (),
  numbering: numbering,
  full: full,
  levels: level_numberings(d, numbering),
)

/// The point data of an exam, from its parsed items: a row per division, in
/// order, with its `id`, `level`, `address`, `number`, and `label` (see
/// `_division_label`); its own regular, bonus and practice points, `own`,
/// `own-bonus` and `own-practice`; and its `total_points` and `total_bonus_points`, its own
/// with all of its parts' (see `assign_points`).
#let compute_points_data(items, numbering: DEFAULT_NUMBERING, full: false) = {
  items
    .filter(it => it.kind == "division")
    .map(d => {
      let p = if d.fields.points == none { 0 } else { d.fields.points }
      (
        id: d.id,
        level: d.level,
        address: d.address,
        number: d.number,
        // A division numbered by its own `numbering` (see `localize`) is
        // labelled so too.
        label: _division_label(d, numbering, full),
        own: if d.fields.intent == none { p } else { 0 },
        own-bonus: if d.fields.intent == "bonus" { p } else { 0 },
        own-practice: if d.fields.intent == "practice" { p } else { 0 },
        total_points: d.total_points,
        total_bonus_points: d.total_bonus_points,
      )
    })
}

/// The columns of a points table of `rows` (see `compute_points_data`) by
/// `level` (1 for questions, 2 for parts, 3 for subparts): `(label, points,
/// bonus, id, address)` each, in order. Pure.
///
/// A division at `level` has a column of its points and all of its parts',
/// if they come to anything; one above `level`, a column of its own points,
/// if it has any, its parts' being in columns of their own. A question none
/// of whose divisions has a column has one of its own, so that every
/// question is in the table. Each point is in exactly one column, so the
/// total is the same at every level.
#let table_columns(rows, level) = {
  let column(r, points, bonus) = (
    label: r.label,
    points: points,
    bonus: if bonus == none or bonus == 0 { none } else { bonus },
    id: r.id,
    address: r.address,
  )
  let out = ()
  // The columns of the current question's divisions, and the question.
  let held = ()
  let question = none
  for r in rows + ((level: 1, end: true),) {
    if r.level == 1 {
      if question != none {
        out += if held == () {
          (column(question, question.total_points, question.total_bonus_points),)
        } else { held }
      }
      if r.at("end", default: false) { break }
      question = r
      held = ()
    }
    if r.level == level {
      if r.total_points > 0 or r.total_bonus_points != none {
        held.push(column(r, r.total_points, r.total_bonus_points))
      }
    } else if r.level < level and (r.own > 0 or r.own-bonus > 0) {
      held.push(column(r, r.own, r.own-bonus))
    }
  }
  out
}

/// The singular and plural names of the divisions at a level, for the
/// warning a points conflict shows.
#let _LEVEL_NAMES = ("question", "part", "subpart")

/// Decide the points badge of every division, given `config`'s
/// `points-show-totals` and `points-position`, unless the division has its
/// own (its `own`, see `localize` in render.typ). Pure. Each division gets
/// - `badge`: `none`; `(kind: "points", points: n, total: bool, bonus:
///   bool)`, the number to show, whether it is the total of the division's
///   parts, and whether they are bonus points (drawn by
///   `bonus-points-format`); or
///   `(kind: "conflict", own: n, parts: m)` when, showing totals, a division
///   has points of its own as well as regular points on its parts, so that
///   neither is its total;
/// - `badge_takes_line`: whether the badge is drawn in the flow of the
///   division's first segment, so that `plan` keeps it out of a segment
///   holding an `fr` box, where it would spend the box's share of the page.
///   A badge in the margin takes no room, and one at the `"end"` follows the
///   division's text (taking a line after an `fr` box, in its segment, which
///   the box shares with it); a conflict warning is always drawn at the
///   start, in the flow.
/// - `badge_at_end`: whether the badge is drawn at the `"end"`, after the
///   division's own text, so that `plan` gives a division with none before
///   its first part a segment of its own, for the badge's line.
#let assign_badges(items, show-totals: false, position: "start") = {
  items.map(it => {
    if it.kind != "division" { return it }
    let own_opts = it.at("own", default: (:))
    let show-totals = own_opts.at("points-show-totals", default: show-totals)
    let position = own_opts.at("points-position", default: position)
    let own = it.fields.points
    let bonus = it.fields.intent == "bonus"
    let badge = if not show-totals {
      if own == none { none } else { (kind: "points", points: own, total: false, bonus: bonus) }
    } else {
      let own_regular = if own != none and it.fields.intent == none { own } else { 0 }
      let parts = it.total_points - own_regular
      if own != none and parts > 0 {
        (kind: "conflict", own: own, parts: parts, level: it.level)
      } else if own != none {
        (kind: "points", points: own, total: false, bonus: bonus)
      } else if parts > 0 {
        (kind: "points", points: parts, total: true, bonus: false)
      } else {
        none
      }
    }
    (
      ..it,
      badge: badge,
      badge_takes_line: badge != none and (badge.kind == "conflict" or position == "start"),
      badge_at_end: badge != none and badge.kind == "points" and position == "end",
    )
  })
}

/// The warning drawn in place of a badge in conflict (see `assign_badges`).
#let conflict_warning(badge) = {
  let name = _LEVEL_NAMES.at(badge.level - 1, default: "subpart")
  let parts = _LEVEL_NAMES.at(badge.level, default: "subpart") + "s"
  text(fill: red)[examy: this #name has points of its own (#badge.own) and points on its #parts
    (#badge.parts); with `points-show-totals`, give points to one or the other.]
}

// Each count is a number, and needs context: `#context num-points()` shows
// it, and `num-points()` in a context block computes with it.

/// The `intent` of the points a count counts, named as a question's
/// `intent` names them.
#let _intent_field() = e.field(
  "intent",
  e.types.union(e.types.literal("practice"), e.types.literal("bonus"), none),
  doc: "Which points to count, by their `intent` (see `#question[..]`): `none` for regular points, `\"bonus\"` for bonus points, or `\"practice\"` for practice points.",
  default: none,
)

/// An `intent` as a key of a dictionary: `none` as `"none"`.
#let _intent_key(intent) = if intent == none { "none" } else { intent }

/// The key of the points of `intent` in a row of `compute_points_data`.
#let _OWN = ("none": "own", bonus: "own-bonus", practice: "own-practice")
#let _own_key(intent) = _OWN.at(_intent_key(intent))

#let _NUM_QUESTIONS = declare_function(
  "num-questions",
  doc: "The number of questions in the exam. Must be used inside of a [context](https://typst.app/docs/reference/context/) block, e.g. `#context num-questions()`.",
)

/// The number of questions (see DOCS). Needs context.
#let num_questions = define(_NUM_QUESTIONS, it => {
  let data = exam_points_data()
  if data == none { 0 } else { data.len() }
})

#let _NUM_POINTS = declare_function(
  "num-points",
  doc: "The total number of points in the exam: by default its regular points, not counting bonus and practice points. Must be used inside of a [context](https://typst.app/docs/reference/context/) block, e.g. `#context num-points()` to show it, or `#context calc.ceil(num-points() * .6)` to compute with it.",
  fields: (_intent_field(),),
)

/// The total number of points of an intent (see DOCS). Needs context.
#let num_points = define(_NUM_POINTS, it => {
  let found = _exam_rows()
  if found == none { 0 } else { found.last().map(r => r.at(_own_key(it.intent))).sum(default: 0) }
})

/// The document of a bundle that `loc` is in, by its index among them (from
/// 1); 0 outside a bundle. The documents of a bundle share one
/// introspection, but number their pages each from 1, so a page number
/// alone does not tell which document's page it is. Needs context.
#let _document_index(loc) = query(selector(document).before(loc)).len()

/// The labels of the mark an exam leaves where its questions start, and of
/// the record of their points by page it leaves where they end (see
/// `pages_record`).
#let PAGES_START = label(PREFIX + "/pages-start")
#let PAGES = label(PREFIX + "/pages")

/// The mark an exam leaves where its questions start (see `pages_record`).
/// Invisible.
#let pages_start = [#metadata(none)#PAGES_START]

/// The record an exam leaves where its questions end: the points of the
/// divisions that start on each page (see `points_marker`), which exam it is
/// (counted from 1, see `EXAMS_STARTED`), and which document of a bundle it
/// is in (see `_document_index`). Invisible. Worked
/// out here, once for the exam, so that a reader of them, such as a page
/// footer, read on every page, queries only these records, one per exam: a
/// query of every marker, in every footer, takes time growing with the
/// square of the exam's length, as Typst checks a reused query by running
/// it again.
///
/// `pages`: for each page with points, keyed by its number (as a string),
/// `(page, location, points)`, `location` that of its first marker, and
/// `points` its points by intent (`none`, `"bonus"`, `"practice"`, as
/// strings; see `_intent_key`).
#let pages_record = context {
  let start = query(selector(PAGES_START).before(here())).at(-1, default: none)
  if start == none { return }
  let pages = (:)
  for m in query(selector(POINTS_MARKER).after(start.location()).before(here())) {
    let page = m.location().page()
    let key = str(page)
    if key not in pages {
      pages.insert(key, (page: page, location: m.location(), points: ("none": 0, bonus: 0, practice: 0)))
    }
    pages.at(key).points.at(_intent_key(m.value.intent)) += m.value.points
  }
  [#metadata((doc: _document_index(here()), exam: EXAMS_STARTED.get().first(), pages: pages))#PAGES]
}

/// The points of document `doc` (see `_document_index`) by page, as
/// `pages_record` gives them: of exam `exam` alone (counted from 1), or with
/// `none`, of all its exams together, a page's first location that of its
/// first exam. Needs context.
#let _pages_of(doc, exam: none) = {
  let pages = (:)
  for r in query(PAGES) {
    if r.value.doc != doc or exam != none and r.value.exam != exam { continue }
    for (key, p) in r.value.pages {
      if key not in pages {
        pages.insert(key, p)
        continue
      }
      for (intent, n) in p.points { pages.at(key).points.at(intent) += n }
    }
  }
  pages
}

/// The points of the exam a reader at `here()` is about (see `exam_index`),
/// by page: an array of `(page: n, location, points, bonus)`, one per page
/// with points, in page order, where `location` is that of the page's first
/// division with points. Another exam's points on the same pages are not
/// counted. Needs context.
#let exam_pages() = {
  let i = exam_index(here())
  if i == none { return () }
  _pages_of(_document_index(here()), exam: i + 1)
    .values()
    .map(p => (page: p.page, location: p.location, points: p.points.at("none"), bonus: p.points.bonus))
    .sorted(key: p => p.page)
}

#let _NUM_POINTS_PAGE = declare_function(
  "num-points-page",
  doc: "The number of points on a page (of the questions/parts/subparts that start on it): by default its regular points, on the current page. Must be used inside of a [context](https://typst.app/docs/reference/context/) block, e.g. in a page footer, `#set page(footer: context [#num-points-page() points])`.",
  fields: (
    e.field(
      "page",
      e.types.smart(int),
      doc: "The physical page number (counted from 1). Setting to `auto` uses the current page.",
      default: auto,
    ),
    _intent_field(),
  ),
)

/// The number of points of an intent on a page (see DOCS). Needs context.
#let num_points_page = define(_NUM_POINTS_PAGE, it => {
  let page = if it.page == auto { here().page() } else { it.page }
  let found = _pages_of(_document_index(here())).at(str(page), default: none)
  if found == none { 0 } else { found.points.at(_intent_key(it.intent)) }
})

#let _PAGE_SCORE_BOX = declare_function(
  "page-score-box",
  doc: "A box for the grader to write the page's score in (e.g. \"Score: ____ / 7\"). Meant for a page footer (e.g. `#set page(footer: align(right, page-score-box()))`). Shows nothing on a page without points. The word \"Score\" can be localized with `config`'s `strings`.",
)

/// A score box for the current page (see DOCS).
#let page_score_box = define(_PAGE_SCORE_BOX, it => e.get(get => {
  let points = num_points_page()
  if points == 0 { return }
  let strings = get(config).strings
  box(stroke: .5pt, inset: (x: .6em, y: .4em))[
    #strings.score: #box(width: 2.5em, stroke: (bottom: .5pt), outset: (bottom: .15em)) / #points
  ]
}))

/// The page number as the page shows it, for the table by page.
#let _page_label(loc) = {
  let pattern = loc.page-numbering()
  numbering(if pattern == none { "1" } else { pattern }, ..counter(page).at(loc))
}

/// The cell a number of points is shown in; nothing for none.
#let _cell(points) = if points == none or points == 0 { [] } else { [#points] }

/// Lay out the points table: `entries` are `(label, points, bonus)`, one per
/// question or page, and `o` the table's options, resolved (see
/// `points_table`).
#let _points_table(entries, heading, o) = {
  let strings = o.strings
  let total = (
    label: strings.total,
    points: entries.map(x => x.points).sum(default: 0),
    bonus: entries.map(x => if x.bonus == none { 0 } else { x.bonus }).sum(default: 0),
  )
  let with_bonus = o.bonus and total.bonus > 0
  // The series the table shows, in order: each a heading and a cell per entry.
  let series = (
    (heading: heading, cell: x => x.label),
    (heading: strings.points, cell: x => [#x.points]),
    ..if with_bonus { ((heading: strings.bonus, cell: x => _cell(x.bonus)),) },
    ..if o.score { ((heading: strings.score, cell: x => [], score: true),) },
  )
  let table_of(entries) = if o.direction == "vertical" {
    table(
      // The score column is wide enough to write in.
      columns: if o.score { (auto,) * (series.len() - 1) + (4em,) } else { series.len() },
      align: center,
      stroke: .2pt,
      inset: .6em,
      ..series.map(s => s.heading),
      ..entries.map(x => series.map(s => (s.cell)(x))).flatten(),
    )
  } else {
    table(
      align: (right, ..(center,) * entries.len()),
      columns: entries.len() + 1,
      stroke: .2pt,
      inset: .6em,
      // The score row is tall enough to write in.
      ..if o.score { (rows: (auto,) * (series.len() - 1) + (2.5em,)) },
      ..series.map(s => ([#s.heading:], ..entries.map(s.cell))).flatten(),
    )
  }
  let entries = entries + (total,)
  let per = o.max-columns
  if per == none or o.direction == "vertical" {
    table_of(entries)
  } else {
    assert(
      per > 0,
      message: "examy: points-table: `max-columns` must be positive, found " + str(per),
    )
    entries.chunks(per).map(table_of).join()
  }
}

#let _POINTS_TABLE = declare_function(
  "points-table",
  doc: "A table of the points per question, with a total.",
  fields: (
    e.field(
      "direction",
      e.types.union(auto, "horizontal", "vertical"),
      doc: "Determines the layout of the table: `\"horizontal\"` (a column per question) or `\"vertical\"` (a row per question). Setting to `auto` uses `config`'s `points-table-direction`.",
      default: auto,
      meta: (config: "points-table-direction"),
    ),
    e.field(
      "granularity",
      e.types.union(auto, "question", "part", "subpart", "page"),
      doc: "How points are grouped into table cells: one cell per `\"question\"` (`config`'s default), `\"part\"`, `\"subpart\"`, or `\"page\"`. Setting to `auto` uses `config`'s `points-table-granularity`.",
      default: auto,
      meta: (config: "points-table-granularity"),
    ),
    e.field(
      "score",
      e.types.union(auto, bool),
      doc: "Whether the table includes an empty row for a grader to fill in. Setting to `auto` uses `config`'s `points-table-score`.",
      default: auto,
      meta: (config: "points-table-score"),
    ),
    e.field(
      "bonus",
      e.types.union(auto, bool),
      doc: "Whether the table includes a row for the bonus points (only visible if the exam has bonus points). Setting to `auto` uses `config`'s `points-table-bonus`.",
      default: auto,
      meta: (config: "points-table-bonus"),
    ),
    e.field(
      "max-columns",
      e.types.union(auto, int, none),
      doc: "The maximum number of columns in a horizontal table. A wider table wraps to multiple rows. Use `none` for no limit. Setting to `auto` uses `config`'s `points-table-max-columns`.",
      default: auto,
      meta: (config: "points-table-max-columns"),
    ),
  ),
)

/// A scoring table showing the point value of each question (or page) (see
/// DOCS).
#let points_table = define(_POINTS_TABLE, it => e.get(get => {
  let cfg = get(config)
  // Each option as given, else `config`'s.
  let pick(key) = if it.at(key) == auto { cfg.at("points-table-" + key) } else { it.at(key) }
  let o = (
    strings: cfg.strings,
    direction: pick("direction"),
    granularity: pick("granularity"),
    score: pick("score"),
    bonus: pick("bonus"),
    max-columns: pick("max-columns"),
  )
  let strings = o.strings
  let (entries, heading) = if o.granularity == "page" {
    (
      exam_pages()
        .filter(p => p.points > 0 or p.bonus > 0)
        .map(p => (label: _page_label(p.location), points: p.points, bonus: p.bonus)),
      strings.page,
    )
  } else {
    let found = _exam_rows()
    (
      if found == none { () } else {
        let (i, rows) = found
        let level = ("question", "part", "subpart").position(x => x == o.granularity) + 1
        // Where each division of that exam starts, by its id, to link its
        // label to: the markers after its start, before the next's.
        let starts = (:)
        for m in query(DIVISION_MARKER) {
          if EXAMS_STARTED.at(m.location()).first() == i + 1 {
            starts.insert(str(m.value), m.location())
          }
        }
        table_columns(rows, level).map(c => {
          let at = starts.at(str(c.id), default: none)
          (..c, label: if at == none { c.label } else { link(at, c.label) })
        })
      },
      strings.question,
    )
  }
  if entries.len() == 0 {
    let missing = if o.granularity == "page" { "points" } else { "questions" }
    return text(fill: red, "WARNING: No " + missing + " found! Can't make a points table.")
  }
  _points_table(entries, heading, o)
}))

/// API documentation for this module's exports, consumed by
/// docs/api.typ (keyed by export name).
#let DOCS = (
  "points-table": _POINTS_TABLE,
  "num-questions": _NUM_QUESTIONS,
  "num-points": _NUM_POINTS,
  "num-points-page": _NUM_POINTS_PAGE,
  "page-score-box": _PAGE_SCORE_BOX,
)
