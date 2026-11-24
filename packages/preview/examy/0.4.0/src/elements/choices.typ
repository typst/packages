#import "../prelude.typ": *
#import "../config.typ": solution_colors
#import "bubble.typ": bubble, choice, is_filled, shape_name, square_bubble

/// The default space between two choices side by side, inline or in columns
/// (see `gap`). One per line, the default is the text's own line spacing.
#let _SIDE_BY_SIDE_GAP = 1.5em

/// The named arguments `choices` takes.
#let _CHOICES_ARGS = ("correct", "bubble", "inline", "columns", "gap")

/// Names an author might reach for in place of `correct`.
#let _CORRECT_ALIASES = ("answer", "answers", "solution", "solutions", "correct-answer", "key", "right")

/// The shape named by a `bubble:` option: whatever `choice` takes for its
/// own `bubble:` (see `shape_name`), or one of examy's own bubble functions,
/// which an author may well pass here.
#let choices_shape(value) = {
  if value == bubble { return "circle" }
  if value == square_bubble { return "square" }
  shape_name(value, "choices")
}

/// The plain text in `c`, gathered from whatever it is nested in.
#let _plain_text(c) = {
  if c.has("text") and type(c.text) == str {
    c.text
  } else if c.func() == [ ].func() {
    " "
  } else if c.has("children") {
    c.children.map(_plain_text).join(default: "")
  } else if c.has("body") and type(c.body) == content {
    _plain_text(c.body)
  } else if c.has("child") {
    _plain_text(c.child)
  } else {
    ""
  }
}

/// A short, readable excerpt of `c` for an error message: its text where it
/// has any, else the name of the element it is.
#let _excerpt(c) = {
  let s = _plain_text(c).trim()
  if s == "" { return "`" + repr(c.func()) + "`" }
  let cs = s.clusters()
  "`" + if cs.len() > 30 { cs.slice(0, 30).join() + "…" } else { s } + "`"
}

/// Why `c`, found among the choices, is not one: the message for an author
/// who wrote it there, naming the likely mistake where one is recognizable.
#let _not_a_choice(c) = {
  let how = "Start each choice on its own line with `- ` (or `+ ` for a correct one)."
  let f = c.func()
  let why = if f == strong {
    "found bold text " + _excerpt(c) + ". A line starting with `*` is bold text in Typst, not a list item. " + how
  } else if f == terms.item {
    "found a term-list item (`/ term: ..`), which is not a choice. " + how
  } else if f == [#set text(red)].func() {
    "found a `#set` or `#show` rule among the choices. Move it out of `#choices[..]`, before it or into a block around it."
  } else if f in (text, emph, math.equation, smartquote, raw, ref, link) {
    "found " + _excerpt(c) + " outside any choice. " + how + " Text that introduces the choices goes before `#choices`."
  } else {
    "found " + _excerpt(c) + ", which is not a choice. " + how
  }
  "choices: " + why
}

/// The children of `body`, with nested sequences (as a `for` loop or a
/// `#[..]` block produces) spread out into their own children.
#let _flat_children(body) = {
  if body.func() != [].func() { return (body,) }
  body.children.map(_flat_children).flatten()
}

/// The choices in `body`, in order, each as `(body: content, marked: bool)`.
///
/// An array is taken as the choices themselves, none of them marked; its
/// entries are made content, so a bare string or number works as well. A
/// content block is expected to hold a list: each `- ..` item is a choice,
/// and each `+ ..` item a choice marked correct. Typst parses the two as
/// `list.item` and `enum.item`, which sit side by side in the block's
/// children (they are only grouped into lists later, at layout), so they can
/// be read off in order however they are interleaved.
#let parse_choices(body) = {
  if type(body) == array {
    return body.map(b => (body: [#b], marked: false))
  }
  assert(
    type(body) == content,
    message: "choices: expected the choices as a list, one `- ..` item per choice (`+ ..` for a correct one), or as an array such as `(\"a\", \"b\")`; got "
      + str(type(body))
      + " "
      + repr(body),
  )
  _flat_children(body)
    .filter(c => c.func() not in ([ ].func(), parbreak))
    .map(c => {
      if c.func() == list.item {
        (body: c.body, marked: false)
      } else if c.func() == enum.item {
        // `1.` is an enum item too; taking it as a correct answer would be a
        // surprise, so it is refused rather than read as a `+`.
        if c.has("number") {
          panic(
            "choices: mark a correct choice with `+`, not a numbered item (`"
              + str(c.number)
              + ".`); start the other choices with `- `",
          )
        }
        (body: c.body, marked: true)
      } else {
        panic(_not_a_choice(c))
      }
    })
}

/// The indices named by a `correct:` option, checked against the `count`
/// choices there are and made non-negative: `none` names none, an integer
/// one, an array several. Indices count the way Typst's own arrays do: from
/// 0 at the first choice, or from -1 at the last.
#let correct_indices(correct, count) = {
  let indices = if correct == none { () } else if type(correct) == array { correct } else { (correct,) }
  indices.map(i => {
    assert(
      type(i) == int,
      message: "choices: `correct` names choices by their index (`correct: 1` for the second, `correct: (0, 2)` for several), got "
        + repr(i)
        + if type(i) in (str, content) { " — to mark a choice by its content, start it with `+` instead of `-`" } else { "" },
    )
    assert(
      -count <= i and i < count,
      message: "choices: `correct` names choices by index, 0 to "
        + str(count - 1)
        + " counting from the first or -1 to -"
        + str(count)
        + " from the last, but there "
        + if count == 1 { "is 1 choice" } else { "are " + str(count) + " choices" }
        + ", so "
        + repr(i)
        + " names none of them",
    )
    if i < 0 { i + count } else { i }
  })
}

/// The choices in `body`, each as `(body: content, correct: bool)`: correct
/// if it is a `+` item *or* named by `correct`, so the two ways of marking
/// an answer can be mixed.
#let resolve_choices(body, correct: none) = {
  let choices = parse_choices(body)
  let indices = correct_indices(correct, choices.len())
  choices.enumerate().map(((i, c)) => (body: c.body, correct: c.marked or i in indices))
}

/// One choice on a line of its own. The bubble is the marker of a one-item
/// list, rather than inline before the body as in `choice[..]`, so a choice
/// that wraps hangs its second line under its body and not under the bubble,
/// and a tall bubble does not push that second line further down.
///
/// The list adds no indent of its own: a bubble carries the space between
/// itself and what it labels in its own outset, so the marker is already as
/// wide as a bubble plus that gap.
#let _block_choice(shape, body, correct) = e.get(get => {
  let body = if is_filled(correct, get) { text(fill: solution_colors(get).color, body) } else { body }
  list(marker: choice(bubble: shape, correct: correct), indent: 0pt, body-indent: 0pt, body)
})

/// Check the arguments of `choices` that Typst's own parameter list cannot:
/// `extra` holds any positional or named argument it does not take.
#let _check_choices_args(extra, inline, columns, gap) = {
  let pos = extra.pos()
  assert(
    pos.len() == 0,
    message: "choices: the choices go in one argument — a list, one `- ..` item per choice, or an array such as `(\"a\", \"b\")` — but got "
      + str(pos.len() + 1)
      + " separate arguments",
  )
  for key in extra.named().keys() {
    if key in _CORRECT_ALIASES {
      panic(
        "choices: unknown argument `"
          + key
          + "`; mark a correct choice with `+` in place of `-`, or name it by index with `correct:`",
      )
    }
    panic(
      "choices: unknown argument `" + key + "`; `choices` takes " + _CHOICES_ARGS.map(k => "`" + k + "`").join(", "),
    )
  }
  assert(type(inline) == bool, message: "choices: `inline` must be `true` or `false`, got " + repr(inline))
  assert(
    columns == none or (type(columns) == int and columns >= 1),
    message: "choices: `columns` must be a number of columns, such as `columns: 2`, got " + repr(columns),
  )
  assert(
    not (inline and columns != none),
    message: "choices: `inline` and `columns` are two different layouts; use one or the other",
  )
  assert(
    gap == auto or type(gap) in (length, fraction),
    message: "choices: `gap` must be a length, such as `1em`, got " + repr(gap),
  )
  assert(
    type(gap) != fraction or inline or columns != none,
    message: "choices: a fractional `gap` spreads choices across a line, so it needs `inline: true` or `columns`; one choice per line, give a length such as `1em`",
  )
}

/// A multiple-choice answer: a bubble for each choice, filled in and
/// checked on the answer key for the correct ones.
///
/// Laid out one choice per line by default, `gap` apart — as close as the
/// lines of a paragraph unless `gap` says otherwise. `columns: n` sets them
/// in `n` equal columns instead, filled across each row in turn, so they
/// read in the order they were written; each choice is drawn as on a line of
/// its own, so a long one wraps within its column. `inline: true` runs them
/// together side by side in a paragraph of their own, each kept whole unless
/// it is longer than a line. In both, `gap` is the space between two choices
/// side by side; inline it is weak, so a choice that wraps to the start of a
/// line is not indented by it.
#let choices(
  body,
  ..extra,
  correct: none,
  bubble: "circle",
  inline: false,
  columns: none,
  gap: auto,
) = {
  _check_choices_args(extra, inline, columns, gap)
  let shape = choices_shape(bubble)
  let resolved = resolve_choices(body, correct: correct)
  let side_gap = if gap == auto { _SIDE_BY_SIDE_GAP } else { gap }
  if inline {
    // A paragraph of its own, like the other layouts, so that choices written
    // on the line after a question start below it rather than running on
    // from its text.
    block(resolved.map(c => box(choice(c.body, bubble: shape, correct: c.correct))).join(h(side_gap, weak: true)))
  } else if columns != none {
    // Rows are spaced like the choices of the one-per-line layout.
    context grid(
      columns: (1fr,) * columns,
      column-gutter: side_gap,
      row-gutter: par.leading,
      ..resolved.map(c => _block_choice(shape, c.body, c.correct)),
    )
  } else {
    // Each choice is a list of its own (see `_block_choice`), and Typst
    // spaces two lists in a row by the paragraph spacing, so setting that
    // spaces the choices. It also spaces the paragraphs of a choice that has
    // several, which keeps them as apart as the choices are; unlike setting
    // the block spacing, it leaves alone the space around an equation or
    // other block inside a choice.
    block(context {
      set par(spacing: if gap == auto { par.leading } else { gap })
      resolved.map(c => _block_choice(shape, c.body, c.correct)).join()
    })
  }
}

/// API documentation for this module's exports, consumed by
/// docs/generate-api.typ (keyed by export name). Kept next to the
/// definitions — update both together.
#let DOCS = (
  choices: (
    desc: "A multiple-choice answer: a bubble for each choice, filled in and checked on the answer key (when solutions are shown) for the correct ones, whose content is then set in the solution color. Mark a correct choice with `+` in place of `-`, or by its index with `correct`.",
    args: (
      (
        name: "body",
        type: "content | array",
        required: true,
        named: false,
        doc: "The choices: a list, one `- ..` item per choice (`+ ..` for a correct one), each starting its own line; or an array of the choices' content.",
      ),
      (
        name: "correct",
        type: "int | array | none",
        default: "none",
        doc: "The index of the correct choice, or an array of indices for several, counted as Typst counts an array's: from 0 at the first choice, or from -1 at the last. Adds to any choices marked with `+`.",
      ),
      (
        name: "bubble",
        type: "\"circle\" | \"square\"",
        default: "\"circle\"",
        doc: "The shape of the bubbles: round for \"select one\", square for \"select all that apply\". Typst's own `circle` and `square` work too, as do `bubble` and `square-bubble`.",
      ),
      (
        name: "inline",
        type: "bool",
        default: "false",
        doc: "Run the choices together, side by side in a paragraph of their own, rather than one per line; suits short choices. A choice is not split across lines unless it is longer than a whole line. Cannot be combined with `columns`.",
      ),
      (
        name: "columns",
        type: "int | none",
        default: "none",
        doc: "Set the choices in this many equal columns, filled across each row in turn, rather than one per line. Cannot be combined with `inline`.",
      ),
      (
        name: "gap",
        type: "auto | length | fraction",
        default: "auto",
        doc: "The space between two choices. One per line, it is the space between one choice and the next below it, and `auto` sets them as close as the lines of a paragraph. Side by side, inline or in `columns`, it is the space between them, and `auto` is "
          + repr(_SIDE_BY_SIDE_GAP)
          + "; there, a fraction (`1fr`) spreads the choices across the line.",
      ),
    ),
  ),
)
