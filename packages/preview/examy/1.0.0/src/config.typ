#import "prelude.typ": *

/// API documentation for `config` below, consumed by docs/api.typ
/// (keyed by export name). The properties are introspected from the
/// element declaration; `config` is never called like a function (its
/// properties are set with `e.set_`), so no call signature is shown.
#let DOCS = (
  config: (
    kind: "element",
    show-signature: false,
    desc: "Global configuration of package options. Give options to the exam, e.g. `#show: exam.with(show-solutions: true)`, or set them with `#show: e.set_(config, show-solutions: true)`.",
  ),
)

/// The outline thickness of a bubble (`choice`, `bubble`, `square-bubble`,
/// `choices`) when `bubble-stroke` is not configured. Relative to the font
/// size, so a bubble keeps its proportions in a footnote and in a heading
/// alike; heavier than `answer-box`'s hairline box, because at a bubble's size
/// a thin ring reads as a faint circle rather than as something a student is
/// meant to fill in.
#let DEFAULT_BUBBLE_STROKE = .1em

/// The font a bubble's label (see `choices`' `enumerate`) is set in when
/// `bubble-label-font` is not configured: the monospaced face bundled with
/// Typst, so it is there wherever the document is compiled. Its letters and
/// digits are all of a width, so labels read alike from one bubble to the
/// next, and as a sans face they stand apart from the text of the choice
/// beside them.
#let DEFAULT_BUBBLE_LABEL_FONT = "DejaVu Sans Mono"

/// The space a bubble keeps around itself when `bubble-outset` is not
/// configured: a gap after it, parting it from whatever follows (see
/// `choice`'s `outset`).
#let DEFAULT_BUBBLE_OUTSET = (right: .4em)

/// How far the body of a question, part, or subpart is indented from the one
/// it is in, when `indent` is not configured.
#let DEFAULT_INDENT = 1.5em

/// A relative length, checked but kept as given: a plain length stays a
/// length (see signature.typ), as `answer-box` expects: its
/// `is_standalone` tells a box of a fixed width from one of a ratio by type.
#let _RELATIVE = (length, ratio, e.types.exact(relative))

/// What an answer box's outline and background take, as `box`'s `stroke`
/// and `fill` do: `answer-box`'s fields and the options that give them.
#let BOX_STROKE = e.types.union(
  none,
  length,
  color,
  gradient,
  tiling,
  e.types.exact(stroke),
  dictionary,
)
#let BOX_FILL = e.types.union(none, color, gradient, tiling)

/// What a bubble's outline takes, as a shape's `stroke` does: a thickness, a
/// paint, both (`.1em + blue`), or a dictionary of a stroke's fields. Not
/// `none`: a bubble is its outline (`0pt` draws none).
#let BUBBLE_STROKE = e.types.union(length, color, gradient, tiling, e.types.exact(stroke), dictionary)

/// How questions, parts, and subparts are numbered when `numbering` is not
/// configured: one numbering pattern per nesting level. Deeper levels fall
/// back to `"1."`.
#let DEFAULT_NUMBERING = ("1.", "(a)", "i.")

/// The words examy prints itself, when `strings` does not replace them.
#let DEFAULT_STRINGS = (
  question: [Question],
  page: [Page],
  points: [Points],
  bonus: [Bonus],
  score: [Score],
  total: [Total],
)

/// The points badge when `points-format` is not configured: "(1 point)",
/// "(2 points)"; with `bonus`, the badge when `bonus-points-format` is not
/// configured: "(1 bonus point)", "(2 bonus points)".
#let default_points_format(points, bonus: false) = {
  let word = if points == 1 [point] else [points]
  if bonus [(#points bonus #word)] else [(#points #word)]
}

/// The options that draw words, which `strings` takes too, though it is
/// not documented, as an author easily puts them there: `strings:
/// (points: [Punkte], points-format: p => ..)`. The option of the same name
/// wins over it (see `exam_options`).
#let _STRINGS_FORMATS = ("points-format", "bonus-points-format")

/// `strings`' type: a dictionary of content, as documented, which takes the
/// functions of `_STRINGS_FORMATS` too, named and failing as it would
/// without them.
#let _STRINGS_TYPE = {
  let base = e.types.dict(content)
  let formats(d) = d.keys().filter(k => k in _STRINGS_FORMATS and type(d.at(k)) == function)
  let words(d) = {
    for k in formats(d) { let _ = d.remove(k) }
    d
  }
  e.types.wrap(
    base,
    check: _ => d => e.types.cast(words(d), base).first(),
    cast: _ => d => (
      e.types.cast(words(d), base).last() + formats(d).map(k => (k, d.at(k))).to-dict()
    ),
    // Still a dictionary, folded as before: a rule's keys over the last's.
    output: prev => prev,
    fold: prev => prev,
    error: _ => d => e.types.cast(words(d), base).last(),
  )
}

#let config = e.element.declare(
  "config",
  prefix: PREFIX,
  doc: "Examy's options. Set them with `#show: exam.with(..)` or `#show: e.set_(config, ..)`, and read them with `e.get(get => get(config).exam-name)`.",
  display: it => panic(
    "Config should not be displayed directly; instead use `e.set_` to set properties on it.",
  ),
  fields: (
    e.field(
      "show-solutions",
      bool,
      doc: "Whether to show solutions. The `--input show-solutions=..` command-line option overrides this setting.",
      default: true,
    ),
    e.field(
      "institution",
      e.types.option(content),
      doc: "The institution name shown by `#maketitle()`",
    ),
    e.field(
      "exam-name",
      e.types.option(content),
      doc: "The name of the exam (e.g. Midterm 1) shown by `#maketitle()`",
    ),
    e.field(
      "term",
      e.types.option(content),
      doc: "The term of the exam (e.g. Fall 2026) shown by `#maketitle()`",
    ),
    e.field(
      "duration",
      e.types.option(e.types.union(duration, content)),
      doc: "The length of the exam shown by `#maketitle()`. [`Duration`](https://typst.app/docs/reference/foundations/duration/)s are shown in minutes (e.g. `duration(hours: 1, minutes: 50)` shows as \"110 Minutes\"). Pass content for complete control over what is shown (e.g., pass `[1 h 50 min]`)",
    ),
    e.field(
      "show-rubrics",
      e.types.union(auto, bool),
      doc: "Whether to show rubrics (see `#rubric[..]`). Setting to `auto` shows rubrics whenever solutions are shown. The `--input show-rubrics=..` command-line option overrides this setting.",
      default: false,
    ),
    e.field(
      "rubric-position",
      e.types.union("margin-left", "margin-right", "end"),
      doc: "Determines where rubrics are displayed.

      `\"margin-left\"` or `\"margin-right\"`: in the page margin, next to the question/part/subpart they belong to (see `rubric-width`).

      `\"end\"`: after the question/part/subpart, taking up space on the page, so an exam with visible rubrics is laid out differently from one without.",
      default: "margin-right",
    ),
    e.field(
      "rubric-trace",
      e.types.union(auto, bool),
      doc: "Whether to draw a dotted line from each rubric item written in a question's text to the rubric. Setting to `auto` draws lines only for rubrics in the margin. A rubric item's own `trace` overrides this.",
      default: auto,
    ),
    e.field(
      "rubric-width",
      e.types.union(auto, length),
      doc: "The width of rubrics in the margin. Setting to `auto` fills the margin.",
      default: auto,
    ),
    e.field(
      "solution-color",
      e.types.union(auto, color),
      doc: "The primary color for solutions; i.e., the color of the text of a solution or the outline and check mark of a filled-in bubble. Setting to `auto` derives it from `solution-background-color`",
      default: auto,
    ),
    e.field(
      "solution-background-color",
      e.types.union(auto, color),
      doc: "The background color for a solution. Setting to `auto` derives it from `solution-color` by lightening",
      default: auto,
    ),
    e.field(
      "bubble-stroke",
      BUBBLE_STROKE,
      doc: "The outline of bubbles drawn by `#choice[..]`, `#bubble()`, `#square-bubble()`, and `#choices[..]`, specified like a [`circle`'s `stroke`](https://typst.app/docs/reference/visualize/circle/#parameters-stroke): a thickness (e.g. `.15em`), a color (e.g. `blue`), or both (e.g. `.15em + blue`). A thickness left out is `.1em`, and a color left out is black. On the answer key, a correct bubble's outline takes the solution color.",
      default: DEFAULT_BUBBLE_STROKE,
    ),
    e.field(
      "bubble-label-font",
      e.types.union(str, array),
      doc: "The font of the labels inside bubbles (see `choices-enumerate`).",
      default: DEFAULT_BUBBLE_LABEL_FONT,
      // Set as a whole: the default folding of arrays would append to it.
      folds: false,
    ),
    e.field(
      "bubble-size",
      e.types.union(auto, length),
      doc: "The diameter of bubbles drawn by `#choice[..]`, `#bubble()`, `#square-bubble()`, and `#choices[..]`. Setting to `auto` uses `1em` (which scales with the surrounding text).",
      default: auto,
    ),
    e.field(
      "bubble-outset",
      e.types.union(length, dictionary),
      doc: "The space around each bubble, specified like `#choice[..]`'s `outset`: a length (the gap after the bubble) or a dictionary of sides (`left`, `right`, `top`, `bottom`, `x`, `y`, `rest`).",
      default: DEFAULT_BUBBLE_OUTSET,
    ),
    e.field(
      "choices-enumerate",
      e.types.union(bool, str, function, array),
      doc: "Determines how `#choices[..]` labels its bubbles. Setting to `false` results in no labels; `true` results in A, B, C, …. A numbering pattern, function, or array of labels can be used (e.g., `\"a\"` or `(\"x\", \"y\", \"z\")`).",
      default: false,
      // Set as a whole: the default folding of arrays would append to it.
      folds: false,
    ),
    e.field(
      "choices-inline",
      bool,
      doc: "Show `#choices[..]` inline in a paragraph. If you would like a grid of choices, consider using `choices-columns` instead.",
      default: false,
    ),
    e.field(
      "choices-columns",
      e.types.option(int),
      doc: "Split `#choices[..]` into the specified number of columns. Setting to `none` results in a single column (i.e., each choice on its own line). Cannot be combined with `choices-inline`.",
      default: none,
    ),
    e.field(
      "choices-gap",
      e.types.union(auto, length, fraction),
      doc: "The space between items in a `#choices[..]` block. Setting to `auto` uses the usual line spacing for choices on separate lines, and `1.5em` for choices side by side. A fraction (e.g. `1fr`) spreads side-by-side choices across the line.",
      default: auto,
    ),
    e.field(
      "answer-box-height",
      e.types.union(auto, .._RELATIVE, fraction),
      doc: "The default height of an `#answer-box[..]`. Setting to `auto` sizes a non-empty box to fit its contents, excluding `#solution[..]`s, and gives an empty box `answer-box-default-height`.",
      default: auto,
    ),
    e.field(
      "answer-box-width",
      e.types.union(auto, .._RELATIVE, fraction),
      doc: "The default width of an `#answer-box[..]`. Setting to `auto` makes a box `answer-box-default-width` wide, or full width if its height is fractional (e.g. `1fr`).",
      default: auto,
    ),
    e.field(
      "answer-box-stroke",
      BOX_STROKE,
      doc: "The outline stroke of an `#answer-box[..]`, specified like a [`box`'s `stroke`](https://typst.app/docs/reference/layout/box/#parameters-stroke) (e.g. `(bottom: .5pt)` for a single line to write on).",
      default: .5pt,
    ),
    e.field(
      "answer-box-fill",
      BOX_FILL,
      doc: "The background fill of an `#answer-box[..]`, specified like a [`box`'s `fill`](https://typst.app/docs/reference/layout/box/#parameters-fill) (e.g. `luma(245)`).",
      default: none,
    ),
    e.field(
      "answer-box-default-height",
      length,
      doc: "The height of an empty `#answer-box[..]` with an otherwise unspecified height.",
      default: 2cm,
    ),
    e.field(
      "answer-box-default-width",
      length,
      doc: "The width of an `#answer-box[..]` with a width of `auto`, unless its height is a fractional unit (e.g. `2fr`).",
      default: 2cm,
    ),
    e.field(
      "numbering",
      e.types.union(str, function, e.types.array(e.types.union(str, function))),
      doc: "Determines how questions, parts, and subparts are numbered. This option behaves like [`enum`'s `numbering`](https://typst.app/docs/reference/model/enum/#parameters-numbering), taking a numbering pattern (e.g. `\"1.a.i.\"`) or a function that generates a label. In addition, `numbering` also accepts an array of numbering patterns (e.g. `(\"Problem 1.\", \"(a)\", \"i.\")`), with the left-most pattern applying to the highest level (almost always the `#question[..]`).

      A `config` rule inside an exam (e.g. `#show: e.set_(config, numbering: (\"Bonus 1.\", \"(i)\"))`) sets the numbering of the questions/parts/subparts after it in its scope. Its left-most pattern still applies to questions, even when the rule is inside a question.",
      default: DEFAULT_NUMBERING,
      // Set as a whole: the default folding of arrays would append to it.
      folds: false,
    ),
    e.field(
      "indent",
      length,
      doc: "How far each question/part/subpart is indented from the question/part it is in (a question, from the left edge of the text).",
      default: DEFAULT_INDENT,
    ),
    e.field(
      "numbering-full",
      bool,
      doc: "Similar to [`enum`'s `full`](https://typst.app/docs/reference/model/enum/#parameters-full), if set, ensures that questions/parts/subparts get globally unique identifiers (e.g., part (a) of question 1 is labelled \"1 (a)\" by default, or \"1.a.\" with `numbering: \"1.a.i.\"`). This also affects `@name` references to questions.",
      default: false,
    ),
    e.field(
      "strings",
      _STRINGS_TYPE,
      doc: "Words that can be localized to different languages. These include `question`, `page`, `points`, `bonus`, `score`, and `total`. Any subset of these may be set.
      
      Note: the words in points badges are set by `points-format` and `bonus-points-format`",
      default: DEFAULT_STRINGS,
    ),
    e.field(
      "points-format",
      e.types.union(auto, function),
      doc: "A function `(points) => [content]` that determines how points are visibly displayed. Defaults to a function that renders `(X points)`. Other examples include `p => [[#p]]` or `p => [(#p Punkte)]`.",
      default: auto,
    ),
    e.field(
      "bonus-points-format",
      e.types.union(auto, function),
      doc: "A function `(bonus-points) => [content]` that determines how bonus points are visibly displayed. Defaults to a function that renders `(X bonus points)`.",
      default: auto,
    ),
    e.field(
      "points-position",
      e.types.union("start", "margin-left", "margin-right", "end"),
      doc: "Determines where the points are visibly displayed.
      
      `\"start\"`: before the question text.
      
      `\"margin-left\"` or `\"margin-right\"`: in the page margin.
      
      `\"end\"`: right-aligned, after the question text",
      default: "start",
    ),
    e.field(
      "points-show-totals",
      bool,
      doc: "When set to `true`, a question/part/subpart whose parts/subparts have points shows a total even when it is not given points itself: the sum of the points of its parts/subparts. One with no points of its own and none in its parts/subparts still shows none.
      
      For example, `#question[#part(points: 2)[]]` shows `1. (2 points)`, with `(a) (2 points)` on the line below.
      
      When set, a question that is assigned points while its parts/subparts are too shows a warning in red in place of its points.",
      default: false,
    ),
    e.field(
      "points-table-direction",
      e.types.union("horizontal", "vertical"),
      doc: "Determines the layout of `#points-table()`: `\"horizontal\"` (a column per question) or `\"vertical\"` (a row per question).",
      default: "horizontal",
    ),
    e.field(
      "points-table-granularity",
      e.types.union("question", "part", "subpart", "page"),
      doc: "How points are grouped into the cells of a `#points-table()`: one cell per `\"question\"` (the default), `\"part\"`, `\"subpart\"`, or `\"page\"`.",
      default: "question",
    ),
    e.field(
      "points-table-score",
      bool,
      doc: "Whether `#points-table()` includes an empty row for a grader to fill in.",
      default: false,
    ),
    e.field(
      "points-table-bonus",
      bool,
      doc: "Whether `#points-table()` includes a row for the bonus points (only visible if the exam has bonus points).",
      default: false,
    ),
    e.field(
      "points-table-max-columns",
      e.types.option(int),
      doc: "The maximum number of columns in a horizontal `#points-table()`. A wider table wraps to multiple rows. Use `none` for no limit.",
      default: none,
    ),
    // The name `solution-color` had in 0.3 and earlier, when it colored only the
    // text of a solution. Kept so that documents written for 0.3 still
    // compile and keep their color.
    e.field(
      "solution-text-color",
      e.types.union(auto, color),
      doc: "Deprecated: alias of `solution-color`. Use `solution-color` instead.",
      default: auto,
      internal: true,
    ),
    // The name `show-rubrics` had in 0.4.0. Kept so that documents written
    // for it still compile.
    e.field(
      "show-rubric",
      e.types.option(e.types.union(auto, bool)),
      doc: "Deprecated: alias of `show-rubrics`. Use `show-rubrics` instead.",
      default: none,
      internal: true,
    ),
    // Internal: set while `answer-box` lays out its body as the exam shows
    // it, to measure it. Overrides `show-solutions` and the command line
    // alike, so the measurement is of the exam even when compiling the key.
    e.field(
      "_exam-view",
      bool,
      doc: "Whether to lay out as the exam, whatever `show-solutions` and the command line say.",
      default: false,
      internal: true,
    ),
    // Internal: set by the documentation's examples, which are laid out in
    // blocks on a page of no fixed height, where `fr` heights would come to
    // nothing: in a block of no fixed height, a length; in one of a fixed
    // height, `1fr`, so that they share it.
    e.field(
      "_fr-unit",
      e.types.option(e.types.union(length, fraction)),
      doc: "The length an exam lays out each `1fr` of its own heights as (a segment's of `fr` answer boxes, a division's `height`), instead of a share of the page: a fraction for a share of the block the exam is in, even on a page of no fixed height; `none` for a share of the page, as usual.",
      default: none,
      internal: true,
    ),
  ),
)

/// The color solutions are drawn in when neither `solution-color` nor
/// `solution-background-color` is configured.
#let DEFAULT_SOLUTION_COLOR = blue.darken(20%)

/// How much lighter than the solution color its background is.
#let _BACKGROUND_LIGHTEN = 90%

/// Derive a solution color from a background: the inverse of lightening it.
///
/// Darkening alone will not do. A background is a pale wash with almost no
/// saturation left, and darkening a near-white color keeps its (nearly
/// neutral) proportions, so `bg.darken(..)` comes out gray whatever the hue
/// was. The color is instead rebuilt at a readable lightness from the wash's
/// own hue, with its chroma scaled back up — capped, so a background that is
/// already vivid does not land far outside the gamut. A neutral gray
/// background has no hue to restore, and stays neutral.
#let _color_from_background(background) = {
  let (_, chroma, hue, ..) = oklch(background).components()
  oklch(45%, calc.min(chroma * 8, 0.2), hue)
}

/// Resolve the configured pair into the two colors actually drawn with.
/// Either may be given on its own, and the other is then derived from it;
/// given both, both are used as-is. Pure, so it is testable without a
/// document.
#let resolve_solution_colors(solution-color, background) = {
  if solution-color == auto and background == auto {
    solution-color = DEFAULT_SOLUTION_COLOR
  }
  if solution-color == auto {
    solution-color = _color_from_background(background)
  }
  if background == auto {
    background = solution-color.lighten(_BACKGROUND_LIGHTEN)
  }
  (color: solution-color, background: background)
}

/// `config`'s `show-rubrics`, of the configuration `cfg`, or the deprecated
/// `show-rubric` when only it is set.
#let configured_show_rubrics(cfg) = if cfg.show-rubrics == false and cfg.show-rubric != none {
  cfg.show-rubric
} else { cfg.show-rubrics }

/// `resolve_solution_colors` for the configured values, for use inside
/// `e.get(get => ..)`. The deprecated `solution-text-color` stands in for
/// `solution-color` when only it is set. `color` and `background`, when not
/// `auto`, stand in for the configured ones, as a solution's own `color` and
/// `background-color` do.
#let solution_colors(get, color: auto, background: auto) = {
  let cfg = get(config)
  if color == auto {
    color = if cfg.solution-color != auto { cfg.solution-color } else { cfg.solution-text-color }
  }
  if background == auto { background = cfg.solution-background-color }
  resolve_solution_colors(color, background)
}

/// The options the exam pipeline lays out with, resolved from `config`, for
/// use inside `e.get(get => ..)`. Passed down to `render` as a plain
/// dictionary, so that rendering itself needs no context.
#let exam_options(get) = {
  let cfg = get(config)
  (
    numbering: cfg.numbering,
    numbering-full: cfg.numbering-full,
    // Folded onto its default by elembic: a partial `strings` keeps the rest.
    strings: cfg.strings,
    // The option, else one put in `strings` (see `_STRINGS_FORMATS`).
    points-format: if cfg.points-format != auto { cfg.points-format } else {
      cfg.strings.at("points-format", default: default_points_format)
    },
    bonus-points-format: if cfg.bonus-points-format != auto { cfg.bonus-points-format } else {
      cfg.strings.at("bonus-points-format", default: p => default_points_format(p, bonus: true))
    },
    points-position: cfg.points-position,
    points-show-totals: cfg.points-show-totals,
    // How the exam lays out its own `fr` heights (see `fr_height` in
    // render.typ): as a share of the page or of the block the exam is in
    // (`none`), as `_fr-unit` each, or, on a page of no fixed height, where a
    // share comes to nothing, as tall as what they hold (`auto`).
    fr-unit: if type(cfg._fr-unit) == fraction { none } else if cfg._fr-unit != none { cfg._fr-unit } else if (
      page.height == auto
    ) { auto } else { none },
    // `shown` is resolved by the exam, which knows whether solutions are shown
    // (see `show_rubrics`), and `present`, whether it has rubrics at all, and
    // so `drawn`, whether they are drawn, and `traced`, whether their leaders
    // are too, and `positions`, those its divisions' rubrics are drawn at
    // (see `process_questions`).
    rubric: (
      shown: configured_show_rubrics(cfg),
      present: false,
      drawn: false,
      traced: false,
      positions: (),
      position: cfg.rubric-position,
      trace: if cfg.rubric-trace == auto { cfg.rubric-position != "end" } else { cfg.rubric-trace },
      // As configured, for a division under a `config` rule setting its
      // `rubric-position` (see `opts_of` in render.typ).
      trace-given: cfg.rubric-trace,
      width: cfg.rubric-width,
    ),
    indent: cfg.indent,
  )
}

/// The options an exam reads once, where it starts (see `exam_options`,
/// and `show_rubrics`), for all its questions: set inside it, around some of
/// them, they would change nothing (see `exam_wide_options_set`). Keep in
/// step with `exam_options`.
#let EXAM_WIDE_OPTIONS = (
  "numbering",
  "numbering-full",
  "strings",
  "points-format",
  "bonus-points-format",
  "points-position",
  "points-show-totals",
  "_fr-unit",
  "show-rubrics",
  "show-rubric",
  "rubric-position",
  "rubric-trace",
  "rubric-width",
  "indent",
)

/// The options of `EXAM_WIDE_OPTIONS` that a `config` set rule inside an
/// exam may set: the exam applies them to the questions, parts, and subparts
/// in the rule's scope (see `scoped_options_set`, and `localize` in
/// render.typ). The others are read once for all of them.
#let SCOPED_OPTIONS = (
  "numbering",
  "points-format",
  "bonus-points-format",
  "points-position",
  "points-show-totals",
  "rubric-position",
  "rubric-trace",
  "rubric-width",
  "indent",
)

/// The `config` rules an elembic rule (its data, see `elembic_rule` in
/// scan.typ) is made of, in order: itself, or those an `apply` combines.
#let _config_rules(rule) = {
  let found = ()
  let stack = (rule,)
  while stack.len() > 0 {
    let r = stack.pop()
    if type(r) != dictionary { continue }
    let kind = r.at("kind", default: none)
    if kind == "apply" {
      stack += r.at("rules", default: ()).rev()
    } else if (
      kind in ("set", "cond-set")
        and r.at("element", default: (:)).at("eid", default: none) == e.eid(config)
    ) {
      found.push(r)
    }
  }
  found
}

/// Which of `EXAM_WIDE_OPTIONS` an elembic rule sets on `config` that it may
/// not inside an exam, in order: any but `SCOPED_OPTIONS` that a `set_` rule
/// sets, and any that a `cond-set` rule sets, as a condition on `config`
/// would hold for some questions and not others.
#let exam_wide_options_set(rule) = {
  let found = ()
  for r in _config_rules(rule) {
    let keys = r.at("args", default: (:)).keys().filter(k => k in EXAM_WIDE_OPTIONS)
    found += if r.kind == "set" { keys.filter(k => k not in SCOPED_OPTIONS) } else { keys }
  }
  found.dedup()
}

/// The values of `SCOPED_OPTIONS` that an elembic rule sets on `config`, by
/// name: a later rule's (in an `apply`) over an earlier one's.
#let scoped_options_set(rule) = {
  let found = (:)
  for r in _config_rules(rule) {
    if r.kind != "set" { continue }
    for (k, v) in r.at("args", default: (:)) {
      if k in SCOPED_OPTIONS { found.insert(k, v) }
    }
  }
  found
}

/// The names of the rules before an exam that set any of
/// `EXAM_WIDE_OPTIONS`, from elembic's record of the rules in force where it
/// starts (`data`, as `e.internal.debug-get` passes it; see `exam`): a
/// `revoke` of one inside the exam would undo what it read there, and so
/// change nothing (see `exam_wide_rule_error`).
#let exam_wide_names(data) = {
  let d = data.elements.at(e.data(config).eid, default: none)
  if d == none { return () }
  let names = ()
  // `data-chain` has `none` for a rule with no names before a named one.
  for (args, info) in d.chain.zip(d.data-chain) {
    if info != none and type(args) == dictionary and args.keys().any(k => k in EXAM_WIDE_OPTIONS) {
      names += info.names
    }
  }
  names.dedup()
}

/// `exam_options` with nothing configured, for rendering without a document
/// (the unit tests).
#let DEFAULT_EXAM_OPTIONS = (
  numbering: DEFAULT_NUMBERING,
  numbering-full: false,
  strings: DEFAULT_STRINGS,
  points-format: default_points_format,
  bonus-points-format: p => default_points_format(p, bonus: true),
  points-position: "start",
  points-show-totals: false,
  fr-unit: none,
  rubric: (
    shown: false,
    present: false,
    drawn: false,
    traced: false,
    positions: (),
    position: "margin-right",
    trace: true,
    trace-given: auto,
    width: auto,
  ),
  indent: DEFAULT_INDENT,
)
