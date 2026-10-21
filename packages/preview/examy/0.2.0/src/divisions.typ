/// Public constructors for questions, parts, and subparts.
///
/// These are deliberately plain functions (not elembic elements): they must
/// emit their markers *eagerly* so the exam pipeline can find them by content
/// introspection, before any layout happens.

#import "markers.typ": begin_marker, end_marker

#let _division(
  body,
  points: none,
  intent: none,
  solution: none,
  rubric: none,
  number: auto,
  indent: 1.5em,
  label: none,
  name: "division",
) = {
  assert(
    type(body) in (content, str),
    message: "examy: the body of a " + name + " must be content, found " + repr(type(body)),
  )
  assert(
    points == none or type(points) in (int, float),
    message: "examy: `points` must be a number or none, found " + repr(points),
  )
  assert(
    intent in (none, "practice", "bonus"),
    message: "examy: `intent` must be none, \"practice\", or \"bonus\", found " + repr(intent),
  )
  assert(
    number == auto or number == none or type(number) in (int, str, content),
    message: "examy: `number` must be auto, none, an integer, or content, found " + repr(number),
  )
  assert(
    label == none or type(label) == std.label,
    message: "examy: `label` must be a label (e.g. `<my-label>`) or none, found " + repr(label),
  )
  assert(
    type(indent) == length,
    message: "examy: `indent` must be a length, found " + repr(indent),
  )

  begin_marker((
    points: points,
    intent: intent,
    solution: solution,
    rubric: rubric,
    number: number,
    indent: indent,
    label: label,
    name: name,
  ))
  [#body]
  end_marker()
}

/// Declare a question. Nesting `part`/`subpart` inside the body creates
/// sub-divisions; the nesting depth (not the constructor name) determines
/// the numbering style.
#let question = _division.with(name: "question")

/// Declare a part of a question.
#let part = _division.with(name: "part")

/// Declare a subpart of a part.
#let subpart = _division.with(name: "subpart")

/// API documentation for this module's exports, consumed by
/// docs/generate-api.typ (keyed by export name). Plain functions cannot be
/// introspected the way elembic elements can, so this lives here, next to
/// `_division`'s signature — update both together.
#let _DIVISION_ARGS = (
    (
      name: "body",
      type: "content",
      required: true,
      doc: "The body of the question.",
    ),
    (
      name: "points",
      type: "int | float | none",
      default: "none",
      doc: "The number of points: shows a \"(2 points)\" badge and feeds the points table.",
    ),
    (
      name: "intent",
      type: "\"practice\" | \"bonus\" | none",
      default: "none",
      doc: "Practice and bonus points are excluded from the regular totals; bonus points are tallied separately.",
    ),
    (
      name: "solution",
      type: "content | none",
      default: "none",
      doc: "A solution, rendered at the end of the division when solutions are enabled.",
    ),
    (
      name: "rubric",
      type: "content | none",
      default: "none",
      doc: "A grading rubric (accepted, but not yet rendered).",
    ),
    (
      name: "number",
      type: "auto | int | content | none",
      default: "auto",
      doc: "`auto` numbers sequentially; an integer is the number as displayed (later divisions continue from it); content is shown verbatim; `none` omits the number.",
    ),
    (
      name: "indent",
      type: "length",
      default: "1.5em",
      doc: "Indentation of the body relative to the parent.",
    ),
    (
      name: "label",
      type: "label | none",
      default: "none",
      doc: "Attach a label so the division can be referenced with `@name`.",
    ),
)

/// A shared description for `question`/`part`/`subpart`: they take
/// identical arguments and differ only in numbering style (chosen by
/// nesting depth, not which function is called), so the API reference
/// documents them as one group (see `group` below) instead of repeating
/// the same argument list three times.
#let _DIVISION_DESC = "Declare a question, part, or subpart — numbered `1.`, `(a)`, or `i.` respectively. The three functions take identical arguments; the numbering style is chosen by nesting depth, not by which function is called."

#let DOCS = (
  question: (group: "division", desc: _DIVISION_DESC, args: _DIVISION_ARGS),
  part: (group: "division", desc: _DIVISION_DESC, args: _DIVISION_ARGS),
  subpart: (group: "division", desc: _DIVISION_DESC, args: _DIVISION_ARGS),
)
