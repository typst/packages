/// Public constructors for questions, parts, and subparts.
///
/// These are deliberately plain functions (not elembic elements): they must
/// emit their markers *eagerly* so the exam pipeline can find them by content
/// introspection, before any layout happens. Their arguments are declared
/// with `e.field` all the same (see signature.typ), which both checks them
/// and documents them.

#import "prelude.typ": e
#import "markers.typ": begin_marker, end_marker, outside_check
#import "constants.typ": DEBUG_PANIC
#import "signature.typ": declare_function, define
#import "config.typ": _RELATIVE

/// The arguments of a question, part, or subpart, which take identical ones.
#let _DIVISION_FIELDS = (
  e.field(
    "body",
    e.types.union(content, str),
    doc: "The text of the question/part/subpart. Can contain nested question/part/subparts",
    required: true,
  ),
  e.field(
    "points",
    e.types.union(int, float, none),
    doc: "The number of points shown for this question/part/subpart (e.g. `points: 2` shows \"(2 points)\"). Points are also shown in `#points-table()` and related functions.",
    default: none,
  ),
  e.field(
    "intent",
    e.types.union(e.types.literal("practice"), e.types.literal("bonus"), none),
    doc: "Setting to `\"bonus\"` counts the points as bonus points, which are totaled separately. Setting to `\"practice\"` leaves the points out of the exam's totals and its points table; `num-points(intent: \"practice\")` counts them.",
    default: none,
  ),
  e.field(
    "rubric",
    e.types.option(content),
    doc: "Rubric items for the question/part/subpart (see `#rubric[..]`). Rubric items written here are shown after any `#rubric[..]` items in `body`.",
    default: none,
  ),
  e.field(
    "number",
    e.types.union(auto, int, str, content, none),
    doc: "By default, questions/parts/subparts automatically increment their number. Providing a `number` overrides this behaviour. A numerical value will cause numbering to skip to that value; a non-numerical value or general content will pause the counter and show that content. To omit a number completely, set `number: none`.",
    default: auto,
  ),
  e.field(
    "height",
    e.types.union(auto, .._RELATIVE, fraction),
    doc: "The height of the question/part/subpart, including its parts. A length (e.g. `5cm`, or `50%` of the page), or a fraction (e.g. `1fr`), makes it a single block of that height, which cannot break across pages.

    Note: prefer `#answer-box[..]` (e.g. `#answer-box(width: 100%, height: 3cm)[]`) over setting a question's height if your goal is to give students a space to write in.",
    default: auto,
  ),
  e.field(
    "indent",
    e.types.smart(length),
    doc: "How far this question/part/subpart is indented from the question/part it is in (a question, from the left edge of the text). Setting to `auto` uses `config`'s `indent`.",
    default: auto,
    meta: (config: "indent"),
  ),
  e.field(
    "label",
    e.types.option(label),
    doc: "A label for referencing the question/part/subpart with `@name` (e.g. `label: <derivative>`).",
    default: none,
    meta: (hint: "write it in angle brackets, e.g. `label: <my-label>`"),
  ),
)

/// The three take identical arguments and differ only in numbering style
/// (chosen by nesting depth, not by which function is called), so the API
/// reference documents them as one group instead of repeating the same
/// argument list three times.
#let _DIVISION_DOC = "Declare a question, part, or subpart, numbered \"1.\", \"(a)\", and \"i.\" respectively. `#question[..]`, `#part[..]`, and `#subpart[..]` are aliases of the same function, taking the same arguments. The numbering style is chosen by nesting depth, not by function, so `#question[#part[..]]` and `#question[#question[..]]` will render identically."

/// Names an author might reach for that the divisions do not take.
#let _ALIASES = (
  solution: "write the solution in the body, as `#solution[..]`, where it should be drawn",
)

#let _spec(name) = declare_function(
  name,
  doc: _DIVISION_DOC,
  fields: _DIVISION_FIELDS,
  aliases: _ALIASES,
  group: "division",
)

#let _division(spec) = define(spec, it => {
  begin_marker((
    points: it.points,
    intent: it.intent,
    rubric: it.rubric,
    number: it.number,
    height: it.height,
    indent: it.indent,
    label: it.label,
    name: spec.name,
  ))
  // A warning, drawn if no exam lays the division out (see `outside_check`);
  // left out with `--input _debug_panic=none`.
  if DEBUG_PANIC != "none" { outside_check(spec.name, it.body) }
  [#it.body]
  end_marker()
})

#let _QUESTION = _spec("question")
#let _PART = _spec("part")
#let _SUBPART = _spec("subpart")

/// Declare a question. Nesting `part`/`subpart` inside the body creates
/// sub-divisions; the nesting depth (not the constructor name) determines
/// the numbering style.
#let question = _division(_QUESTION)

/// Declare a part of a question.
#let part = _division(_PART)

/// Declare a subpart of a part.
#let subpart = _division(_SUBPART)

/// API documentation for this module's exports, consumed by docs/api.typ
/// (keyed by export name).
#let DOCS = (question: _QUESTION, part: _PART, subpart: _SUBPART)
