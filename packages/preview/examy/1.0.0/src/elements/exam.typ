#import "../prelude.typ": *
#import "answer-box.typ": answer_box, config_options, resolve_boxes, rules_before
#import "../tokenize.typ": tokenize
#import "../parse.typ": parse
#import "../plan.typ": hold, plan
#import "../render.typ": localize, mark_rubrics, opts_of, render, rubric_info
#import "../points.typ": (
  EXAMS_ENDED, EXAMS_STARTED, assign_badges, compute_points_data, exam_index, pages_record, pages_start, points_data_state,
)
#import "../refs.typ": own_exam_refs
#import "../config.typ": config, exam_options, exam_wide_names
#import "./solution.typ": show_rubrics, show_solutions
#import "../scan.typ": _find, rubric_markers
#import "../markers.typ": exam_marker, marker_value
#import "../rubric.typ": exam_end, exam_start
#import "../export.typ": rubric_export
#import "../signature.typ": declare_function, define, parse_args

/// The exam title block (in the spirit of LaTeX's `\maketitle`): the
/// institution, term, duration, and exam name, laid out as the head of a
/// cover page. Each value is taken from `config` unless overridden here
/// (pass `none` to suppress a configured value). Renders nothing if no
/// value is set at all.
///
/// ```typst
/// #show: e.set_(config, institution: [..], exam-name: [..],
///   term: [..], duration: duration(minutes: 110))
/// #maketitle()
/// // or, overriding the configured term:
/// #maketitle(term: [Summer 2026])
/// ```
#let _MAKETITLE = declare_function(
  "maketitle",
  doc: "Displays the exam's title block (like LaTeX's `\\maketitle`), using `config`'s `institution`, `exam-name`, `term`, and `duration`. Displays nothing if all four are `none`.

  Note: use a [`set` rule](https://typst.app/docs/reference/styling/#set-rules) to change the font settings (e.g. `#{ set text(font: \"DejaVu Sans Mono\"); maketitle() }`).",
  fields: (
    e.field(
      "institution",
      e.types.union(auto, content, none),
      doc: "The institution name. Setting to `auto` uses `config`'s `institution`; `none` hides it.",
      default: auto,
      meta: (config: "institution"),
    ),
    e.field(
      "exam-name",
      e.types.union(auto, content, none),
      doc: "The name of the exam (e.g. Midterm 1). Setting to `auto` uses `config`'s `exam-name`; `none` hides it.",
      default: auto,
      meta: (config: "exam-name"),
    ),
    e.field(
      "term",
      e.types.union(auto, content, none),
      doc: "The term of the exam (e.g. Fall 2026). Setting to `auto` uses `config`'s `term`; `none` hides it.",
      default: auto,
      meta: (config: "term"),
    ),
    e.field(
      "duration",
      e.types.union(auto, none, duration, content),
      doc: "The length of the exam. [`Duration`](https://typst.app/docs/reference/foundations/duration/)s are shown in minutes (e.g. `duration(hours: 1, minutes: 50)` shows as \"110 Minutes\"). Pass content for complete control over what is shown (e.g., pass `[1 h 50 min]`). Setting to `auto` uses `config`'s `duration`; `none` hides it.",
      default: auto,
      meta: (config: "duration"),
    ),
  ),
)

/// What `maketitle` shows for a `duration`: a Typst `duration` in minutes,
/// content (or a string) as it is written.
#let duration_shown(d) = if type(d) == duration [#d.minutes() Minutes] else [#d]

#let maketitle = define(_MAKETITLE, it => e.get(get => {
  let c = get(config)
  // Each value is `config`'s unless given here.
  let pick(key) = if it.at(key) == auto { c.at(key) } else { it.at(key) }
  let institution = pick("institution")
  let exam_name = pick("exam-name")
  let term = pick("term")
  let duration = pick("duration")
  if (institution, exam_name, term, duration).all(t => t == none) {
    return none
  }
  grid(
    columns: (1fr, 1fr),
    row-gutter: 1em,
    {
      set align(center)
      institution
    },
    {
      set align(center)
      term
      if duration != none {
        [\ ]
        text(size: .9em, duration_shown(duration))
      }
    },

    {
      set align(center)
      text(weight: "bold", size: 1.2em)[#exam_name]
    },
  )
}))

/// The default rows for a name block.
#let DEFAULT_NAME_FIELDS = ((prefix: [Name:]), (prefix: [Student ID:]))

/// Render one entry of a name block's `fields` as grid cells. A dictionary entry
/// `(prefix: .., suffix: ..)` (both optional) becomes a fill-in row:
/// the prefix, then an underline extending to the end of the line, with the
/// suffix sitting on the line at its right end. Any other entry is content
/// rendered verbatim, spanning the full block width.
#let _name_field_row(entry) = {
  if type(entry) != dictionary {
    return (grid.cell(colspan: 2, entry),)
  }
  let prefix = entry.at("prefix", default: none)
  let suffix = entry.at("suffix", default: none)
  (
    align(right + bottom, box(inset: (bottom: .35em), prefix)),
    align(bottom, box(
      width: 100%,
      stroke: (bottom: 1pt),
      inset: (bottom: .35em, x: .2em),
      {
        h(1fr)
        // An invisible character keeps empty lines the same height as ones
        // with a suffix.
        if suffix == none { hide[X] } else { suffix }
      },
    )),
  )
}

/// A block of fill-in rows (name, student ID, ...) for an exam cover or
/// quiz header. Place it on a cover page, at the top of a quiz, or anywhere
/// else in the document.
///
/// `fields` entries are either a `(prefix: .., suffix: ..)` dictionary
/// (both keys optional), rendered as the prefix, an underline extending to
/// the end of the line, and the suffix sitting on the line at its right
/// end — or arbitrary content, rendered verbatim as its own row.
#let _NAME_BLOCK = declare_function(
  "name-block",
  doc: "A block of lines for students to fill in their name and other details.

  Note: it uses the document's font. To change it, use a [`set` rule](https://typst.app/docs/reference/styling/#set-rules) (e.g. `#{ set text(font: \"DejaVu Sans Mono\"); name-block() }`).",
  fields: (
    e.field(
      "title",
      e.types.option(content),
      doc: "A heading shown centered above the block.",
      default: none,
    ),
    e.field(
      "fields",
      e.types.array(e.types.union(dictionary, content)),
      doc: "The rows of the block. A dictionary `(prefix: .., suffix: ..)` (both optional) draws the prefix, a line to write on, and the suffix. Any other content is shown as is, as a row of its own.",
      default: DEFAULT_NAME_FIELDS,
      meta: (default-shown: "((prefix: [Name:]), (prefix: [Student ID:]))"),
    ),
  ),
)

#let name_block = define(_NAME_BLOCK, it => {
  let (title, fields) = (it.title, it.fields)
  if title != none and title != "" {
    set align(center)
    set text(size: .9em)
    title
    v(-.7em)
  }

  grid(
    columns: (auto, 1fr),
    row-gutter: 1em,
    column-gutter: .3em,
    ..fields.map(_name_field_row).flatten()
  )
})

/// Run the questions content through the full pipeline:
/// tokenize → parse → badges → plan → render (+ record point totals).
/// `opts` are the layout options resolved from `config` (see
/// `exam_options`).
#let process_questions(questions, opts) = {
  // What each division takes for itself (see `localize`), which its badge
  // is decided by.
  let items = localize(parse(tokenize(questions, wide_names: opts.at("wide-names", default: ()))), opts)
  let items = assign_badges(items, show-totals: opts.points-show-totals, position: opts.points-position)
  // Where its rubrics are, if it has any: an exam with none emits nothing
  // for them (see `mark_rubrics`).
  let (items, present) = mark_rubrics(items)
  let opts = opts
  opts.rubric.present = present
  opts.rubric.drawn = present and opts.rubric.shown
  opts.rubric.traced = opts.rubric.drawn and opts.rubric.trace
  // Where its divisions' rubrics are drawn, each division's own position
  // counted (see `opts_of`).
  if opts.rubric.drawn {
    opts.rubric.positions = items
      .filter(it => it.kind == "division" and it.at("rubric", default: false))
      .map(it => opts_of(it, opts).rubric.position)
      .dedup()
  }
  let data = compute_points_data(items, numbering: opts.numbering, full: opts.numbering-full)
  // Each exam keeps its own data, and marks where it starts and ends, so
  // that a reader can tell which exam it is about (see `exam_points_data`).
  EXAMS_STARTED.step()
  points_data_state.update(all => all + (data,))
  if present { exam_start }
  // Around what it draws, for the points on each page (see `pages_record`).
  pages_start
  let held = hold(items)
  render(held, plan(held), opts: opts)
  pages_record
  // Its rubrics recorded, and as data for the command line (see export.typ).
  if present {
    let divisions = range(items.len())
      .filter(i => items.at(i).kind == "division" and items.at(i).at("rubric", default: false))
      .map(i => (id: i, address: items.at(i).address, field: items.at(i).fields.rubric, info: rubric_info(items.at(i), opts)))
    rubric_export(divisions)
    exam_end
  }
  EXAMS_ENDED.step()
}

/// The questions with the `solutions-only` helper, if they are a function
/// of it, laid out (see `process_questions`). Reads `config` where it is.
///
/// It reads elembic's record of the rules in force (`e.internal.debug-get`,
/// in the elembic pinned in prelude.typ), not only their values (`e.get`),
/// for the rules on its answer boxes (see `rules_before`).
#let _exam_body(questions) = e.internal.debug-get(data => {
  let get = data.ctx.get
  // The answer boxes' fields here, `config`'s options for them, and the
  // rules on them here, from which the exam draws them (see `resolve_boxes`).
  let boxes = (get(answer_box), config_options(get))
  let before = rules_before(data)
  // The rules before the exam on the options it reads once, which a `revoke`
  // in it may not undo (see `exam_wide_rule_error`).
  let wide_names = exam_wide_names(data)
  let opts = exam_options(get)
  opts.rubric.shown = show_rubrics(get)
  opts.insert("wide-names", wide_names)
  if type(questions) == function {
    // A function of a helper that shows its argument only on the key.
    let solutions_only(content, otherwise: none) = {
      if show_solutions(get) == true {
        content
      } else if type(content) == content and (otherwise == none or type(otherwise) == content) {
        // Like a hidden `solution`, it leaves the rubrics in what it
        // hides where it stands.
        rubric_markers(content).join() + otherwise
      } else {
        otherwise
      }
    }
    process_questions(resolve_boxes(questions(solutions_only), ..boxes, before: before), opts)
  } else {
    process_questions(resolve_boxes(questions, ..boxes, before: before), opts)
  }
})

/// `config`'s options, by name, that `exam` takes: all but the internal
/// ones, whose names start with `_`. The deprecated ones, internal too so
/// as to be left out of the reference, are taken under their old names.
#let _OPTIONS = {
  let fields = e.data(config).at("user-fields")
  let out = (:)
  for (name, f) in fields { if not (f.internal and name.starts-with("_")) { out.insert(name, f) } }
  out
}

#let _EXAM = declare_function(
  "exam",
  doc: "Define an exam with questions/parts/subparts. This is the main entry point for examy, and is usually invoked as a [show rule](https://typst.app/docs/reference/styling/#show-rules) (e.g. `#show: exam` or `#show: exam.with(..)`).
  
  This function automatically invokes `e.prepare()`, which elembic needs to make cross references work.",
  fields: (
    e.field(
      "questions",
      e.types.union(content, function),
      doc: "Content of the exam built out of Typst content and `#question[..]` blocks.
      
      Alternatively, a function `(solutions-only) => [..]` that returns the content. `solutions-only(x, otherwise: y)` gives `x` if solutions are shown and `y` otherwise. Unlike `#solution[..]`, which returns a Typst `context`, `solutions-only()` returns what it is given and so can be used anywhere.",
      required: true,
      named: false,
    ),
  ),
  rest: (
    name: "options",
    doc: "Any of `config`'s options (e.g. `#show: exam.with(show-solutions: false)`).",
    fields: _OPTIONS,
  ),
)

/// What `exam`'s arguments are checked against: its questions, and its
/// `rest`, `config`'s options.
#let _EXAM_ARGS = declare_function(
  "exam",
  fields: (_EXAM.fields.questions, .._EXAM.rest.fields.values()),
  positional-error: n => "exam: takes one positional argument, the questions, got " + str(n),
  takes: "its questions and `config`'s options",
)

/// `exam`'s arguments parsed: `(true, (questions, options))`, `options`
/// the `config` options given, or `(false, message)`. Pure.
#let parse_exam_args(args) = {
  let pos = args.pos()
  let named = args.named()
  // The questions, also accepted by name (see `_EXAM`).
  if "questions" in named {
    if pos.len() > 0 {
      return (false, "exam: the questions are given twice; write `exam[..]` or `exam(questions: [..])`, not both")
    }
    pos.push(named.remove("questions"))
  }
  if pos.len() == 0 {
    return (false, "exam: missing the questions, e.g. `#exam[#question[..]]` or `#show: exam`")
  }
  let (ok, values) = parse_args(_EXAM_ARGS, arguments(..pos, ..named))
  if not ok { return (false, values) }
  let options = (:)
  for name in named.keys() { options.insert(name, values.at(name)) }
  (true, (questions: values.questions, options: options))
}

/// Lay out an exam (see DOCS): `exam[..]`, `exam(questions: [..])`, or as
/// a show rule, `#show: exam.with(..)`. Every named argument but
/// `questions` is a `config` option, set for this exam only.
///
/// An exam around another one (`#show: exam.with(..)` above an
/// `#exam(questions: ..)`, say) steps aside: it only sets its options for
/// what it holds, and the exam inside lays out the questions. Questions of
/// its own beside it would be in neither, and are an error.
#let exam(..args) = {
  let (ok, result) = parse_exam_args(args)
  assert(ok, message: if ok { "" } else { result })
  let (questions, options) = result
  // Looked for with an early exit, not by a full `scan`: `tokenize` walks
  // the questions once more anyway, if this exam lays them out.
  let kind_in(x, kinds) = {
    let m = marker_value(x)
    m != none and m.kind in kinds
  }
  let inner = type(questions) == content and _find(questions, x => kind_in(x, ("exam",)), first: true).len() > 0
  if inner and _find(questions, x => kind_in(x, ("begin", "end")), first: true).len() > 0 {
    panic(
      "examy: an `exam` holds both questions of its own and another `exam`; "
        + "put all the questions in one of them (with `#show: exam`, the rest "
        + "of the document is the exam, so an `#exam(..)` below it is inside it)",
    )
  }
  // Where an exam is, for one around it to find (see above).
  exam_marker
  // What the exam's references need, whether or not the document has it;
  // and a label its questions share with another exam's, as in a bundle of
  // the exam and its key, refers to its own.
  show: e.prepare()
  show ref: own_exam_refs(exam_index)
  show: if options.len() > 0 { e.set_(config, ..options) } else { it => it }
  if inner { questions } else { _exam_body(questions) }
}

/// API documentation for this module's exports, consumed by docs/api.typ
/// (keyed by export name).
#let DOCS = (exam: _EXAM, maketitle: _MAKETITLE, "name-block": _NAME_BLOCK)
