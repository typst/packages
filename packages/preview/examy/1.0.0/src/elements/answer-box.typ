#import "../prelude.typ": *
#import "../config.typ": BOX_FILL, BOX_STROKE, _RELATIVE, config
#import "../widen.typ": exam_content, par_events, widen_par_solutions
#import "solution.typ": solution as solution_element
#import "../scan.typ": (
  ANSWER_BOX_EID, SEQUENCE_FUNC, STYLED_FUNC, _find, _inside, elembic_rule, extract_height,
  has_metadata, is_whitespace_content, unwrap,
)
#import "../signature.typ": declare_function
#import "../tokenize.typ": _elembic_show
#import "../markers.typ": height_hint
#import "../constants.typ": BATCH

/// The box's own inset: the space between its outline and its content.
#let _INSET = 5pt

/// The `config` options that give an answer box's fields when neither its
/// call nor a set rule on `answer-box` does, by option: the field each gives.
#let CONFIG_FIELDS = (
  answer-box-height: "height",
  answer-box-width: "width",
  answer-box-default-height: "default-height",
  answer-box-default-width: "default-width",
  answer-box-stroke: "stroke",
  answer-box-fill: "fill",
)

/// Those options with nothing configured.
#let CONFIG_DEFAULTS = {
  let fields = e.data(config).at("user-fields")
  CONFIG_FIELDS.keys().map(k => (k, fields.at(k).default)).to-dict()
}

/// A label nothing has (see `resolve_boxes`).
#let _NEVER = <examy-answer-box-never>

/// `type`, or `auto` for `config`'s: a value given over `auto` replaces it,
/// as `auto` given over a value does, and one given over another is folded
/// into it as `type` folds them (a `stroke`'s sides).
#let _smart(type) = e.types.wrap(
  e.types.union(auto, type),
  fold: prev => if prev == none { none } else {
    (outer, inner) => if outer == auto or inner == auto { inner } else if prev == auto {
      outer + inner
    } else {
      prev(outer, inner)
    }
  },
)

/// The deprecated names of fields, by their names now: snake_case, as in
/// 0.4.0, before the rest of examy was kebab-case.
#let _OLD_NAMES = ("default-height": "default_height", "default-width": "default_width")


/// `args`, the fields a call gives a box, with those given by their old
/// names (see `_OLD_NAMES`) under their names now, unless also given by
/// those: the box's constructor does this (see `answer_box`), so that a
/// call's old name wins over a set rule's name now, as any call's field
/// does. A set rule keeps the old name, the field of its own it is (see
/// `_configured`).
#let _renamed(args) = {
  for (name, old) in _OLD_NAMES {
    if old in args {
      let value = args.remove(old)
      if name not in args { args.insert(name, value) }
    }
  }
  args
}

/// `it`, the fields of a box, with those left to `config` taken from `cfg`,
/// the options of `CONFIG_FIELDS` in force. A field left `auto` under its
/// name now takes what its old name was given, if anything (by a set rule:
/// a call's is renamed, see `_renamed`). `config`'s `auto` height is a
/// height of `none`: fitted to what the box holds.
#let _configured(it, cfg) = {
  for (name, old) in _OLD_NAMES {
    if it.at(name) == auto { it.insert(name, it.at(old)) }
  }
  for (option, field) in CONFIG_FIELDS {
    if it.at(field) == auto { it.insert(field, cfg.at(option)) }
  }
  if it.height == auto { it.height = none }
  it
}

/// Whether a box's fields leave any of them to `config`.
#let _needs_config(it) = CONFIG_FIELDS.values().any(field => it.at(field) == auto)

/// The options of `CONFIG_FIELDS` in force, for use inside `e.get(get => ..)`.
#let config_options(get) = {
  let cfg = get(config)
  CONFIG_FIELDS.keys().map(k => (k, cfg.at(k))).to-dict()
}

#let _SPEC = declare_function(
  "answer-box",
  doc: "A box for students to write their answers in.",
  fields: (
    e.field(
      "body",
      e.types.union(content, str),
      doc: "The content of the box (e.g. a prompt or a `#solution[..]`). Can be blank (e.g., `#answer-box[]`)",
      required: true,
    ),
    e.field(
      "solution",
      e.types.option(content),
      doc: "A solution shown at the end of the box (e.g. `#answer-box(solution: [42])[]`). This is equivalent to writing `#solution[..]` as the last item of content in `body`.",
      default: none,
    ),
    e.field(
      "width",
      e.types.union(auto, .._RELATIVE, fraction),
      doc: "The width of the box. Set to a fraction (e.g. `1fr`) to fill the rest of the line. Setting to `auto` uses `config`'s `answer-box-width`.",
      default: auto,
      meta: (config: "answer-box-width"),
    ),
    e.field(
      "height",
      e.types.union(auto, .._RELATIVE, fraction, none),
      doc: "The height of the box. Setting to `auto` uses `config`'s `answer-box-height`. Can be any length unit including fractional units (e.g. `1fr`), along with a special value:

      `none`: if non-empty, fits the box's content, ignoring `#solution[..]`s, whatever `config`'s `answer-box-height` is. This value ensures an exam and answer key have the same layout.

      An empty box with height `none` gets a height of `default-height`.",
      default: auto,
      meta: (config: "answer-box-height"),
    ),
    // `.33em` is half the cap height of a typical serif face: the box is
    // centered on the center line of a capital letter, which is what
    // `bubble` centers on too, so the two line up side by side. `bubble`
    // measures that line from the font instead of approximating it, but it
    // can afford a `context` to do so and this cannot — one here would make
    // the box opaque to the exam pipeline's content scans (see the note on
    // block spacing below). tests/unit/bubble.typ holds the two to within
    // .01em of each other.
    e.field(
      "baseline",
      e.types.union(.._RELATIVE),
      doc: "The vertical position of a box placed inline in a sentence.",
      default: 50% - .33em,
      meta: (default-shown: "50% - .33em"),
    ),
    e.field(
      "default-height",
      e.types.smart(length),
      doc: "The height of the box when it is empty and its height is otherwise unspecified. Setting to `auto` uses `config`'s `answer-box-default-height`.",
      default: auto,
      meta: (config: "answer-box-default-height"),
    ),
    e.field(
      "default-width",
      e.types.smart(length),
      doc: "The width of the box when its width is `auto`, unless its height is a fractional unit (e.g. `2fr`). Setting to `auto` uses `config`'s `answer-box-default-width`.",
      default: auto,
      meta: (config: "answer-box-default-width"),
    ),
    e.field(
      "stroke",
      _smart(BOX_STROKE),
      doc: "The outline stroke of the box, specified like a [`box`'s `stroke`](https://typst.app/docs/reference/layout/box/#parameters-stroke) (e.g. `(bottom: .5pt)` for a single line to write on). Setting to `auto` uses `config`'s `answer-box-stroke`.",
      default: auto,
      meta: (config: "answer-box-stroke"),
    ),
    e.field(
      "fill",
      e.types.union(auto, BOX_FILL),
      doc: "The background color of the box, specified like a [`box`'s `fill`](https://typst.app/docs/reference/layout/box/#parameters-fill) (e.g. `luma(245)`). Setting to `auto` uses `config`'s `answer-box-fill`.",
      default: auto,
      meta: (config: "answer-box-fill"),
    ),
    e.field(
      "radius",
      e.types.union(.._RELATIVE, dictionary),
      doc: "Same as a [`box`'s `radius`](https://typst.app/docs/reference/layout/box/#parameters-radius).",
      default: 0pt,
    ),
    e.field(
      "outset",
      e.types.union(.._RELATIVE, dictionary),
      doc: "Same as a [`box`'s `outset`](https://typst.app/docs/reference/layout/box/#parameters-outset).",
      default: 0pt,
    ),
    e.field(
      "clip",
      bool,
      doc: "Same as a [`box`'s `clip`](https://typst.app/docs/reference/layout/box/#parameters-clip).",
      default: false,
    ),
    // The names `default-height` and `default-width` had in 0.4.0. Kept so
    // that documents written for it still compile and keep their boxes.
    e.field(
      "default_height",
      e.types.smart(length),
      doc: "Deprecated: alias of `default-height`. Use `default-height` instead.",
      default: auto,
      internal: true,
    ),
    e.field(
      "default_width",
      e.types.smart(length),
      doc: "Deprecated: alias of `default-width`. Use `default-width` instead.",
      default: auto,
      internal: true,
    ),
  ),
)

/// Draw an answer box from all of its fields (see `answer_box`).
#let _draw(it) = {
  let stroke = it.stroke
  // The `solution:` argument is a `#solution[..]` after the body, in a
  // paragraph of its own (alone in an empty box): drawn as one written
  // there, and handled as one everywhere below. Joined in markup, as it
  // would be written: `+` would merge the solution's own pieces into the
  // body's, where it would no longer be told a solution.
  // A body of only metadata (a `rubric`, a label) is kept, beside the
  // solution, as it shows nothing.
  let body = if it.solution == none { it.body } else if (
    is_whitespace_content([#it.body]) and not has_metadata(it.body)
  ) {
    solution_element(it.solution)
  } else {
    [#it.body#parbreak()#solution_element(it.solution)]
  }

  // Since Typst 0.15, the `show` chain below is applied eagerly, so the
  // resulting block/box (and its height) is directly visible to the exam
  // pipeline's content scans — no height hint needed (emitting one would
  // double-count the fr height).
  let is_block = type(it.height) == fraction
  let height = it.height
  // With a height of `none`, solutions take no height, so the answer key
  // lays out exactly like the exam: the box is sized by what the exam shows,
  // and nothing after it moves. Any height of its own opts out, and the box
  // holds its solutions as usual.
  let no_height = height == none
  // What the body holds, walked once for both the sizing below and the
  // widening of its solutions.
  let events = par_events(body, split: no_height)
  // The height of a box cannot be a fraction, so we change it to 100% if it
  // is. With no height given, a box with something in it — a prompt, a list
  // of choices — grows to fit it, while a blank one (empty, or holding only
  // its solutions) takes `default-height`, so the student has room to write.
  // A solution wrapped in another element (`align`, `strong`, ...) is opaque
  // to `par_events`, and so counts as content: the box fits it.
  // One holding only a `context` expression may be either, which is decided
  // when it is laid out (see the strut below).
  let shows = if height == none { exam_content(body, events: events) } else { none }
  let box_height = if is_block {
    100%
  } else if height == none {
    if shows == "no" { it.at("default-height") } else { auto }
  } else {
    height
  }

  let width = if is_block and (it.width == auto or type(it.width) == fraction) {
    // The default width for block elements is 100%, and a fractional width,
    // which only a box in a line can take, is the full width of a block too.
    100%
  } else {
    it.width
  }
  if width == auto {
    width = it.at("default-width")
  }

  // A centering baseline only makes sense for a small box sitting inline in
  // a sentence. For block-mode boxes and full-width boxes on their own line
  // there is none: since Typst 0.14/0.15 the line's ascent honors the
  // baseline shift literally, so `50% - .33em` on a tall box pushes it half
  // its height down the page.
  let is_standalone = is_block or type(width) in (ratio, relative)

  // If our height is given as a fraction, we must be a block element
  show: it_ => {
    if is_block {
      block(
        width: width,
        height: height,
        // Match the gap a fixed-height (inline) answer box gets from line
        // leading, instead of the much larger default block spacing —
        // otherwise `height: 1fr` boxes sit noticeably lower below their
        // question text than `height: 2in` ones. 0.65em is Typst's default
        // `par.leading`. (Not read via `context` because that would make the
        // box opaque to the exam pipeline's content scans.)
        above: 0.65em,
        it_,
      )
    } else {
      it_
    }
  }
  // The baseline shift goes on an *outer* wrapper rather than on the drawn
  // box itself: a box inherits the baseline of its contents' last line, so a
  // box holding anything at all (a prompt, a solution) would be positioned
  // by that line instead of by its own bottom edge, and the shift would then
  // drop the whole box below the surrounding text. A `stack` discards the
  // baseline of what it holds, so the wrapper's baseline is reliably its
  // bottom edge — which is what `50% - .33em` is measured from. Wrapping the
  // finished box (instead of its contents) also leaves the contents' own
  // region alone, so `place(bottom)` and `height: 1fr` inside still see the
  // full box. The wrapper repeats the box's height so that it still reads as
  // a sized box to the exam pipeline's scans (`starts_inline` keeps a gutter
  // label off the baseline of a tall box only when it can see its height).
  // A fractional width (`1fr`) is the room left in the line, which only a
  // box in the line itself is given: the wrapper takes it, and the box fills
  // the wrapper.
  let fills = type(width) == fraction
  show: it_ => if is_standalone { it_ } else {
    box(
      width: if fills { width } else { auto },
      height: box_height,
      baseline: it.baseline,
      stack(dir: ttb, it_),
    )
  }
  show: box.with(
    stroke: stroke,
    width: if fills { 100% } else { width },
    height: box_height,
    inset: _INSET,
    fill: it.fill,
    radius: it.radius,
    outset: it.outset,
    clip: it.clip,
  )
  // A body holding only a `context` cannot be told blank or not until it is
  // laid out: `#context [A prompt.]` shows something on the exam, while
  // `#e.get(get => if show-solutions(get) [42])` shows nothing there and
  // something on the key. So it is laid out here, as the exam shows it (see
  // `config`'s `_exam-view`, which wins over the command line too), and
  // measured. When that comes out empty, the box is blank on the exam, and
  // takes `default-height` at the least: a strut of that height beside the
  // body, in a column of no width. Measuring the exam's layout, the exam and
  // the key decide alike.
  show: it_ => if shows != "maybe" { it_ } else {
    let strut = context {
      let exam = measure({
        show: e.set_(config, _exam-view: true)
        body
      })
      if exam.height == 0pt { box(height: it.at("default-height") - 2 * _INSET) }
    }
    grid(
      columns: (0pt, 100%),
      strut, it_,
    )
  }

  // Set either way, so that a box nested in another decides for its own
  // solutions.
  show: e.set_(solution_element, _no-height: no_height)
  // A solution standing alone in a paragraph fills the box, so the highlight
  // reads as the box's answer rather than a stray label; one used
  // mid-sentence stays inline and leaves its line intact. Where solutions
  // take no height, a run of them with nothing visible between them is drawn
  // as one, so they do not land on each other.
  widen_par_solutions(body, events: events, group: no_height)
}

/// Display a box where students can write answers: an elembic element, so
/// that set rules give its defaults. Outside an exam it draws itself, reading
/// `config` for the fields nothing else gives; in one, the exam draws it (see
/// `resolve_boxes`).
#let answer_box = e.element.declare(
  "answer-box",
  prefix: PREFIX,
  doc: _SPEC.doc,
  construct: constructor => (..args) => constructor(..args.pos(), .._renamed(args.named())),
  display: it => if _needs_config(it) {
    e.get(get => _draw(_configured(it, config_options(get))))
  } else {
    _draw(it)
  },
  fields: _SPEC.fields.values(),
)

#let _EID = e.data(answer_box).eid
#assert(_EID == ANSWER_BOX_EID, message: "examy: scan.typ's eid for answer-box is not its own")

/// The label elembic gives each answer box it draws, which `e.selector(answer-box)`
/// is: the exam gives it to the boxes it draws too, so that a native show rule
/// on it (`#show e.selector(answer-box): set text(..)`), or a `query`, finds
/// them.
#let _SHOWN = e.data(answer_box).sel

/// The fields of an `answer-box` with no set rule in force: its defaults.
#let DEFAULT_FIELDS = (
  e
    .data(answer_box)
    .at("user-fields")
    .values()
    .filter(f => not f.required)
    .map(f => (f.name, f.default))
    .to-dict()
)

/// The fields that elembic folds rather than replaces (`stroke`, `radius`,
/// `outset`), by name: `(folder, default)`, as `e.data` keeps them.
#let _FOLDS = e.data(answer_box).fields.foldable-fields

/// `fields` with `args` given over them, as elembic gives a set rule's or a
/// call's: each replaces what was there, but for a foldable field (see
/// `_FOLDS`), which is folded into it, so that `stroke: (top: 1pt)` over
/// `(bottom: 1pt)` keeps both.
#let _given(fields, args) = {
  for (name, value) in args {
    let fold = _FOLDS.at(name, default: none)
    fields.insert(name, if fold == none or name not in fields { value } else if fold.folder
      == auto {
      fields.at(name) + value
    } else {
      (fold.folder)(fields.at(name), value)
    })
  }
  fields
}

/// The fields given to an `answer-box` call, if `c` is one, else `none`. An
/// instance is a sequence of exactly two, its body and its tag: one of more
/// that ends in a tag is other content with a box joined to its end (see
/// `_tag_args`), not the box.
#let box_args(c) = {
  if type(c) != content or c.func() != SEQUENCE_FUNC or c.children.len() != 2 { return none }
  if c.children.last().at("label", default: none) != <__elembic_element_tag> { return none }
  let d = e.data(c)
  if d.at("eid", default: none) == _EID { d.fields } else { none }
}

/// The fields given to an `answer-box` call, if `c` is the tag that ends
/// its instance, else `none`. An instance is a sequence of two, its body and
/// this tag; joined into other content (`a + box`), the two are spliced
/// into the sequence they join, side by side, so the tag is what tells the
/// instance there.
#let _tag_args(c) = {
  if (
    type(c) != content
      or c.func() != metadata
      or c.at("label", default: none) != <__elembic_element_tag>
  ) { return none }
  let v = c.value
  if type(v) == dictionary and v.at("eid", default: none) == _EID { v.fields } else { none }
}

/// The eid of `config`, whose rules on `CONFIG_FIELDS` the exam follows too.
#let _CONFIG_EID = e.data(config).eid

/// Those of `args`, the fields a rule on `config` sets, that are
/// `CONFIG_FIELDS`.
#let _box_options(args) = args.pairs().filter(((k, _)) => k in CONFIG_FIELDS).to-dict()

/// What the rules before an exam did to its answer boxes, from elembic's
/// record of the rules in force where it starts (`data`, as
/// `e.internal.debug-get` passes it; see `exam`): `(names, error)`.
/// `names` are those of the rules that set `answer-box` fields or the
/// options of `CONFIG_FIELDS`, which a `revoke` in the exam would undo.
/// `error` is the kind of a rule on `answer-box` that the exam cannot
/// follow, if there is one: elembic applies a `show_`, `cond-set`,
/// `filtered`, or `select` rule to a box as it draws it, and the exam draws
/// its boxes itself.
#let rules_before(data) = {
  let ab = data.elements.at(_EID, default: none)
  let cfg = data.elements.at(_CONFIG_EID, default: none)
  let names = if ab == none { () } else { ab.names.keys() }
  if cfg != none {
    // `data-chain` has `none` for a rule with no names before a named one.
    for (args, d) in cfg.chain.zip(cfg.data-chain) {
      if d != none and type(args) == dictionary and _box_options(args) != (:) { names += d.names }
    }
  }
  // Whether any of the rules `entries` (each `(index, names)`, its place in
  // the chain and its names) is still in force: not undone by a later
  // `reset`, or a later `revoke` naming it.
  let active(entries) = entries.any(d => {
    not ab.revoke-chain.any(r => (
      r.index > d.index and (r.kind == "reset" or r.at("revoking", default: none) in d.names)
    ))
  })
  let error = if ab == none { none } else if active(ab.show-rules.data) {
    "e.show_"
  } else if active(
    ab.cond-sets.data,
  ) { "e.cond-set" } else if active(ab.filters.data) { "e.filtered" } else if active(
    ab.at("selects", default: (:)).at("data", default: ()),
  ) { "e.select" }
  (names: names.dedup(), error: error)
}

/// No rules before the exam (see `rules_before`).
#let NO_RULES_BEFORE = (names: (), error: none)

/// What an elembic rule (its data, see `elembic_rule`) met inside an exam,
/// around answer boxes, does to them: `(fields, cfg, names, error)`,
/// `fields`, `cfg` (the options of `CONFIG_FIELDS`) and `names` (those of
/// the set rules in force on either, for `revoke`) updated by its `set_`
/// and `reset` rules, and an `error` for a rule the exam cannot follow, which it would
/// otherwise ignore, drawing the boxes wrong. `before` are the names of the
/// rules before the exam that set `answer-box` fields or those options (see
/// `rules_before`), which a `revoke` might name too.
#let _apply_rule(rule, fields, cfg, names, before) = {
  // The rules to go through, in order, `apply`s opened up.
  let stack = (rule,)
  while stack.len() > 0 {
    let r = stack.pop()
    if type(r) != dictionary { continue }
    let kind = r.at("kind", default: none)
    let eid = r.at("element", default: (:)).at("eid", default: none)
    let options = if eid == _CONFIG_EID { _box_options(r.at("args", default: (:))) } else { (:) }
    if kind == "apply" {
      stack += r.at("rules", default: ()).rev()
    } else if kind == "set" and eid == _EID {
      fields = _given(fields, r.args)
      names += r.at("names", default: ())
    } else if kind == "set" and options != (:) {
      cfg += options
      names += r.at("names", default: ())
    } else if kind == "reset" {
      // Undoes every rule before it on the elements it names (all, with
      // none named), as it does for boxes elembic draws.
      if r.eids == () or _EID in r.eids { fields = DEFAULT_FIELDS }
      if r.eids == () or _CONFIG_EID in r.eids { cfg = CONFIG_DEFAULTS }
    } else if kind == "cond-set" and (eid == _EID or options != (:)) {
      return (fields, cfg, names, "e.cond-set")
    } else if (
      kind == "filtered"
        and {
          // Its rule, for the elements inside those it matches, touches boxes.
          let (inner, inner_cfg, _, error) = _apply_rule(r.rule, (:), (:), (), ())
          inner != (:) or inner_cfg != (:) or error != none
        }
    ) {
      return (fields, cfg, names, "e.filtered")
    } else if kind == "revoke" and (r.revoking in names or r.revoking in before) {
      return (fields, cfg, names, "e.revoke")
    } else if (
      kind == "show"
        and {
          let filter = r.at("filter", default: none)
          type(filter) == dictionary and _EID in filter.at("elements", default: (:))
        }
    ) {
      return (fields, cfg, names, "e.show_")
    }
  }
  (fields, cfg, names, none)
}

/// The answer boxes inside `x`, an element the exam does not rebuild (see
/// `resolve_boxes`), which draw themselves: each as `(args, fields, cfg,
/// sized)`, its call's arguments and the fields and `CONFIG_FIELDS` options
/// in force where it is, those `at` (a frame's) with the set rules on the way
/// to it applied; and whether it is inside an element of a height of its own
/// (a `block(height: 3cm)`), against which an `fr` height of the box
/// resolves, as `scan` has it. Walked with a stack, not by recursing (see
/// `_find`), in batches (see `BATCH`).
#let _boxes_inside(x, at) = {
  let out = ()
  let stack = ((x, at.fields, at.cfg, false),)
  while stack.len() > 0 {
    // In batches (see `BATCH`).
    let round = 0
    while stack.len() > 0 and round < BATCH {
      round += 1
      let (y, fields, cfg, sized) = stack.pop()
      if type(y) == array {
        for z in y.rev() { stack.push((z, fields, cfg, sized)) }
        continue
      }
      let args = box_args(y)
      if args == none { args = _tag_args(y) }
      if args != none {
        out.push((args, fields, cfg, sized))
        continue
      }
      let rule = elembic_rule(y)
      if rule != none {
        // Only its set rules matter here: elembic applies the rest itself, as
        // these boxes draw themselves.
        let (fields, cfg, ..) = _apply_rule(rule.rule, fields, cfg, (), ())
        stack.push((rule.doc, fields, cfg, sized))
        continue
      }
      let h = extract_height(y)
      let sized = sized or h not in (none, auto)
      for z in _inside(y).rev() { stack.push((z, fields, cfg, sized)) }
    }
  }
  out
}

/// The error for a rule the exam cannot follow around answer boxes (see
/// `_apply_rule`): inside the exam, or, `before`, on `answer-box` before it
/// (see `rules_before`).
#let _rule_error(name, before: false) = (
  "examy: an `"
    + name
    + (
      if before { "` rule on `answer-box` before an exam" } else {
        "` rule inside an exam, around answer boxes,"
      }
    )
    + " may change them, which examy "
    + "cannot follow: the exam draws its answer boxes itself, applying the `e.set_`, `e.apply`, and "
    + "`e.reset` rules on them (and on `config`'s `answer-box-..` options) only. Give the boxes their fields "
    + "on the call (`#answer-box(height: ..)[..]`), or scope a set rule around them instead."
)

/// `c`, its answer boxes drawn (see `_draw`) from `fields`, the
/// `answer-box` fields in force where it starts, and `cfg`, the options of
/// `CONFIG_FIELDS` in force there, with the set rules met on the way and
/// each call's own arguments applied: what the box would draw itself, worked
/// out once for all of them, in the exam's own `e.get`, so that the exam
/// reads every box as the `box` or `block` it is. Looks through sequences,
/// styled content, and elembic rules, rebuilding them (with a stack, not by
/// recursing, for content nested deep, and in batches, for content long, see
/// `BATCH`); a box inside anything else is left to draw itself, with a hint
/// of its `fr` height for `scan`. A rule around boxes that does more than set
/// their fields is an error (see `_apply_rule`).
///
/// Rules before the exam are in `fields` and `cfg` (they are read with
/// `get`), and the set rules' fields folded as elembic folds them (see
/// `_given`). `before` is what else those rules did (see `rules_before`):
/// elembic applies a `show_`, `cond-set`, or `filtered` rule on
/// `answer-box` to each box as it draws it, and so not to the boxes of an
/// exam, which it does not draw, so one is an error; and the names of the
/// set rules, which a `revoke` in the exam would undo.
#let resolve_boxes(c, fields, cfg, before: NO_RULES_BEFORE) = {
  let is_box(y) = box_args(y) != none or _tag_args(y) != none
  // Content holding no answer box is left as it is, wrappers and all.
  if _find(c, is_box, first: true).len() == 0 { return c }
  assert(before.error == none, message: if before.error == none { "" } else {
    _rule_error(before.error, before: true)
  })
  // A box from `args`, its call's, with the rules in force `at` (a frame's
  // `fields`, `cfg`, and `names`), and the label `lbl` its call was given,
  // if any.
  let draw(args, at, lbl) = {
    let all = _given(at.fields, args)
    // Its body is drawn with the rules in force here, whose names a `revoke`
    // in it might name too.
    all.body = resolve_boxes(all.body, at.fields, at.cfg, before: (
      names: before.names + at.names,
      error: none,
    ))
    // On the `box` or `block` it draws, which the exam keeps whole, so that
    // the label stays.
    let drawn = [#_draw(_configured(all, at.cfg))#_SHOWN]
    if lbl == none { return drawn }
    // A label of its own goes around it, for a `query` or a link to find:
    // on `styled` content, with a show rule that matches nothing, as the
    // exam joins what it lays out, which splices a sequence into the one
    // beside it and drops the sequence's label.
    [#{
        show _NEVER: it => it
        drawn
      }#lbl]
  }
  // A frame for each container being rebuilt: what is left of it, last
  // first (`todo`), what it is rebuilt from so far (`done`), the rules in
  // force in it, how to rebuild it (`wrap`), and itself (`orig`). `changed`
  // is whether anything in it was drawn or hinted, so that it is rebuilt,
  // and `boxes` whether it holds a box, so that its rule's `error` (see
  // `_apply_rule`) counts. Each piece of content is looked at once, at its
  // own level, and one with nothing changed in it kept as it is.
  let frame(todo, at, wrap, orig, error: none) = (
    todo: todo,
    done: (),
    fields: at.fields,
    cfg: at.cfg,
    names: at.names,
    wrap: wrap,
    orig: orig,
    error: error,
    changed: false,
    boxes: false,
  )
  let frames = (frame((c,), (fields: fields, cfg: cfg, names: ()), parts => parts.first(), c),)
  while true {
    // In batches (see `BATCH`).
    let round = 0
    while round < BATCH {
      round += 1
      if frames.last().todo.len() == 0 {
        let f = frames.pop()
        assert(not f.boxes or f.error == none, message: if f.error == none { "" } else {
          _rule_error(f.error)
        })
        let built = if f.changed { (f.wrap)(f.done) } else { f.orig }
        if frames.len() == 0 { return built }
        frames.last().done.push(built)
        if f.changed { frames.last().changed = true }
        if f.boxes { frames.last().boxes = true }
        continue
      }
      let x = frames.last().todo.pop()
      // The rules in force in this frame, without its `todo` and `done`, so
      // that taking them copies neither.
      let at = (fields: frames.last().fields, cfg: frames.last().cfg, names: frames.last().names)
      // A box spliced into this sequence: its body is the part before.
      let spliced = _tag_args(x)
      let (args, lbl) = if spliced != none and frames.last().done.len() > 0 {
        let _ = frames.last().done.pop()
        (spliced, none)
      } else { (box_args(x), if type(x) == content { x.at("label", default: none) }) }
      if args != none {
        frames.last().done.push(draw(args, at, lbl))
        frames.last().changed = true
        frames.last().boxes = true
        continue
      }
      let rule = elembic_rule(x)
      if rule != none {
        let (fields, cfg, names, error) = _apply_rule(
          rule.rule,
          at.fields,
          at.cfg,
          at.names,
          before.names,
        )
        let wrap = parts => _elembic_show(rule.rule)(parts.first())
        frames.push(frame(
          (rule.doc,),
          (fields: fields, cfg: cfg, names: names),
          wrap,
          x,
          error: error,
        ))
      } else if type(x) == content and x.func() == SEQUENCE_FUNC {
        // Rebuilt as a sequence of these very children: joining them would
        // splice sequences among them (an elembic rule's, a box's) into it.
        // A rule already spliced into its end is taken apart from what comes
        // before it (see `unwrap`), and so applies to its own content alone.
        frames.push(frame(unwrap(x).rev(), at, parts => SEQUENCE_FUNC(parts), x))
      } else if type(x) == content and x.func() == STYLED_FUNC {
        // Its styles only, not all of `x`, in the closure.
        let styles = x.styles
        frames.push(frame((x.child,), at, parts => STYLED_FUNC(parts.first(), styles), x))
      } else {
        // Boxes inside an element the walk does not rebuild (`align`, a list,
        // ...) draw themselves, and `scan` reads only what their calls give:
        // the `fr` height a rule or `config` gives one is told it by a hint,
        // unless it resolves inside an element of a height of its own.
        let inside = _boxes_inside(x, at)
        if inside == () {
          frames.last().done.push(x)
          continue
        }
        let hints = inside
          .filter(((args, _, _, sized)) => args.at("height", default: auto) == auto and not sized)
          .map(((args, fields, cfg, _)) => _configured(_given(fields, args), cfg).height)
          .filter(h => type(h) == fraction)
          .map(height_hint)
        frames.last().boxes = true
        if hints == () {
          frames.last().done.push(x)
        } else {
          frames.last().done.push(SEQUENCE_FUNC((..hints, x)))
          frames.last().changed = true
        }
      }
    }
  }
}

/// An `answer-box` call drawn as the exam draws it, with no set rule in
/// force (see `resolve_boxes`): for the tests.
#let drawn(c) = resolve_boxes(c, DEFAULT_FIELDS, CONFIG_DEFAULTS)

/// API documentation for this module's exports, consumed by docs/api.typ
/// (keyed by export name).
#let DOCS = ("answer-box": (kind: "element"))
