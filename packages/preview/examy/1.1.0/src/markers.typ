/// Stream markers: `question`/`part`/`subpart` emit these `metadata` values
/// inline (begin ... body ... end) instead of doing any layout. The exam
/// pipeline later tokenizes the stream and reconstructs the structure.

#import "constants.typ": DEBUG_PANIC

/// Version tag for the marker format; bump when the format changes.
#let MARKER_V = 1
#let MARKER_KEY = "_examy_marker"

/// Default fields carried by a `begin` marker.
#let DIVISION_FIELD_DEFAULTS = (
  points: none,
  intent: none,
  rubric: none,
  number: auto,
  height: auto,
  indent: auto,
  label: none,
  // Name of the constructor ("question"/"part"/...); used only for diagnostics.
  name: "division",
)

/// The label a division's begin and end markers are placed with: an exam
/// reads them as tokens, so only those of divisions no exam laid out are
/// in the document, for a division's check to find (see `outside_check`).
#let DIVISION_LABEL = label("_examy_division")

/// Marker for the start of a division. `fields` are the user-supplied
/// division fields (points, number, label, ...).
#let begin_marker(fields) = [#metadata((
  "_examy_marker": MARKER_V,
  kind: "begin",
  fields: DIVISION_FIELD_DEFAULTS + fields,
))#DIVISION_LABEL]

/// Marker for the end of a division.
#let end_marker() = [#metadata(("_examy_marker": MARKER_V, kind: "end"))#DIVISION_LABEL]

/// Hint emitted by elements (like `answer-box`) whose rendered height cannot
/// be determined by content introspection (e.g. because it is produced by a
/// lazy `show` rule). The scanner uses these to propagate `fr` heights.
#let height_hint(height) = metadata((
  "_examy_marker": MARKER_V,
  kind: "height",
  height: height,
))

/// Marker that an `exam` leaves beside what it lays out, which is otherwise
/// out of sight (in a `context`): for an exam around it to find it (see
/// `exam`).
#let exam_marker = metadata(("_examy_marker": MARKER_V, kind: "exam"))

/// The label of the check a division carries (see `outside_check`).
#let OUTSIDE_LABEL = label("_examy_outside")

/// The first `n` characters (clusters) of the text in `c`, with math as
/// `$…$` and whitespace collapsed, and `…` if there is more: for a message
/// to name what it is about. Walked with a stack, not by recursing, for
/// content nested deeper than Typst lets functions recurse.
#let excerpt(c, n) = {
  let out = ""
  let stack = (c,)
  // A cluster takes at most 4 bytes, but for the rare one joined by others.
  while stack.len() > 0 and out.len() <= 4 * n {
    let c = stack.pop()
    if type(c) == str { out += c; continue }
    if type(c) != content { continue }
    let f = c.func()
    if f == math.equation { out += "$…$"; continue }
    if f == [ ].func() or f == linebreak or f == parbreak { out += " "; continue }
    if c.has("text") and type(c.text) == str { out += c.text; continue }
    if c.has("children") { for x in c.children.rev() { stack.push(x) } } else if c.has("body") {
      stack.push(c.body)
    } else if c.has("child") { stack.push(c.child) }
  }
  let s = out.trim().replace(regex("\\s+"), " ")
  let cs = s.clusters()
  if cs.len() > n or stack.len() > 0 { cs.slice(0, calc.min(n, cs.len())).join() + "…" } else { s }
}

/// What is wrong with a division that its check draws (see `outside_check`).
#let _OUTSIDE_PROBLEM = (
  "was not laid out by an exam, so it is drawn as plain text, unnumbered. It is outside any exam, "
    + "or inside one but in content the exam cannot see into (built inside a `context`, or by a "
    + "show rule). Write it in the exam's content, e.g. after `#show: exam` at the top of the document."
)

/// The check a division carries beside its begin marker: dropped by the
/// exam that reads the markers (see `tokenize`), so it is only drawn when no
/// exam laid the division out. That is a division outside any exam, or in
/// content its exam cannot see into (built inside a `context`, or by a show
/// rule), which is drawn as plain text, unnumbered. Drawn, the check shows a
/// warning there, in red, and leaves `metadata` labelled `<examy-warning>`
/// for a script to find; with `--input _debug_panic=panic` (see
/// `DEBUG_PANIC`), it fails the compile instead, naming the division by its
/// page and first words.
///
/// A division inside another one that no exam laid out draws nothing: the
/// one around it warns for both.
#let outside_check(name, body) = {
  [#context {
    // How many divisions no exam laid out this check is in, its own
    // included: their begin markers before it, less their end markers.
    let depth = query(selector(DIVISION_LABEL).before(here())).map(m => if m.value.kind == "begin" { 1 } else { -1 }).sum()
    if depth > 1 { return }
    // Only worked out here, where an exam has not dropped the check.
    let words = excerpt(body, 40)
    if DEBUG_PANIC == "panic" {
      panic("examy: a `" + name + "` on page " + str(here().page()) + " (\"" + words + "\") " + _OUTSIDE_PROBLEM)
    }
    [#metadata((kind: "not-laid-out", name: name, page: here().page(), words: words))<examy-warning>]
    block(
      width: 100%,
      stroke: .6pt + red,
      inset: (x: .5em, y: .35em),
      radius: 2pt,
      // The message, its `code` as code.
      text(fill: red, size: .85em, {
        [*examy:* this #raw(name) ]
        _OUTSIDE_PROBLEM.split("`").enumerate().map(((i, p)) => if calc.odd(i) { raw(p) } else { p }).join()
      }),
    )
  }#OUTSIDE_LABEL]
}

/// Whether `c` is a division's check (see `outside_check`).
#let is_outside_check(c) = type(c) == content and c.at("label", default: none) == OUTSIDE_LABEL

/// Return the marker dictionary if `c` is examy marker metadata, else `none`.
#let marker_value(c) = {
  if type(c) != content { return none }
  if c.func() != metadata { return none }
  let v = c.at("value", default: none)
  if type(v) == dictionary and v.at(MARKER_KEY, default: none) == MARKER_V {
    v
  } else {
    none
  }
}

/// The key of the data a `rubric` carries in its marker, and the label the
/// marker is placed with (see rubric.typ). A rubric is not a division
/// marker: it travels through the pipeline as part of a chunk, and is
/// invisible wherever it is placed.
#let RUBRIC_KEY = "_examy_rubric"
#let RUBRIC_LABEL = label("_examy_rubric")

/// A rubric marker: `metadata` holding the rubric's data, so that the same
/// call can be read where it is written (a division's `rubric:` field) and
/// found where it is placed (in the body, by a query).
#let rubric_marker(data) = [#metadata(((RUBRIC_KEY): MARKER_V, ..data))#RUBRIC_LABEL]

/// The data of a rubric marker, if `c` is one, else `none`.
#let rubric_value(c) = {
  if type(c) != content or c.func() != metadata { return none }
  let v = c.at("value", default: none)
  if type(v) == dictionary and v.at(RUBRIC_KEY, default: none) == MARKER_V { v } else { none }
}

