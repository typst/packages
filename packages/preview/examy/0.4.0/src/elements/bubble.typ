#import "../prelude.typ": *
#import "../config.typ": solution_colors
#import "solution.typ": show_solutions

/// The size of a bubble: the round one's diameter, and the basis every
/// other shape's size is derived from. Relative to the font size, so a
/// bubble scales with the text it labels.
#let _BUBBLE_SIZE = 1.0em

/// A square of the same side length as a circle's diameter covers 4/π as
/// much of the page, so it reads heavier beside the same text. Scaling by
/// √π/2 gives the two shapes equal area.
#let _SQUARE_SCALE = calc.sqrt(calc.pi) / 2

/// The square bubble's side: the equal-area side rounded to a hundredth of an
/// em, then made 5% larger, so a square bubble is a little smaller across
/// than a round one but reads slightly heavier than it.
#let _SQUARE_SIZE = calc.round(_BUBBLE_SIZE.em * _SQUARE_SCALE, digits: 2) * _BUBBLE_SIZE * 1.05

/// The outline thickness of a bubble. Relative to the font size, like
/// `size` is, so a bubble keeps its proportions in a footnote and in a
/// heading alike; heavier than `answer-box`'s hairline box, because at this
/// size a thin ring reads as a faint circle rather than as something a
/// student is meant to fill in.
#let _STROKE = .1em

/// The center line of a capital letter in the font in use: half its cap
/// height. A bubble is centered on this, so a bubble and a capital `X` are
/// centered on each other — capitals rather than lowercase, because a bubble
/// labels a choice that as often as not starts with one, or is a numeral,
/// and an x-height-centered bubble sits visibly low beside `ABC 1990`.
///
/// The cap height is measured, not guessed: a bare `measure` reports the
/// line box (the same height for `x` as for `M`), but `text` exposes the
/// font's own metrics through `top-edge`/`bottom-edge`, and measuring
/// between them gives the real thing — .658em in Libertinus, and whatever
/// is right in any other face. Needs context, which `_bubble` has.
#let cap_center() = (
  measure(
    text(top-edge: "cap-height", bottom-edge: "baseline")[X],
  ).height
    / 2
)

/// The space a bubble keeps around itself. The default parts the bubble from
/// whatever comes after it — its own content, an answer box, the next
/// choice — so that a gap does not have to be spelled out at the call site.
///
/// Note that this reserves layout space, which is what an author means by
/// "the space around a bubble"; Typst's own `outset` on a box expands only
/// what is *drawn*, leaving the space it occupies alone.
#let _OUTSET = (right: .4em)

/// No space on any side: what a side not named by `_OUTSET` defaults to.
#let _NO_SIDES = (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt)

/// The sides of an `outset` key may name, and the axis keys that stand in
/// for them.
#let _SIDE_KEYS = ("left", "right", "top", "bottom", "x", "y", "rest")

/// Resolve an `outset` into its four sides, each side not named keeping its
/// value in `base`.
///
/// What an author nearly always wants to change is the gap after the bubble,
/// so a bare length sets just that: the right side. (Spreading it over every
/// side, as Typst's own `inset` does, would also pad the bubble above and
/// below, and so open up the lines around it.) A dictionary names sides the
/// way an `inset` does — each side wins over `x`/`y`, which in turn win over
/// `rest` — but changes only the sides it names, so `(left: 1em)` adds space
/// before a bubble without losing the default gap after it.
#let resolve_sides(value, base: _NO_SIDES) = {
  let value = if type(value) == dictionary { value } else { (right: value) }
  let rest = value.at("rest", default: none)
  let x = value.at("x", default: rest)
  let y = value.at("y", default: rest)
  let side(name, axis) = {
    let v = value.at(name, default: axis)
    if v == none { base.at(name) } else { v }
  }
  (
    left: side("left", x),
    right: side("right", x),
    top: side("top", y),
    bottom: side("bottom", y),
  )
}

/// Check an `outset` argument, so a mistake is reported in the bubble's
/// terms rather than as a failure deep inside the box it is drawn in.
#let _check_outset(caller, value) = {
  let hint = (
    " — give a length for the gap after the bubble (`outset: .6em`), or a dictionary of sides (`outset: (left: .2em, right: .6em)`)"
  )
  if type(value) == dictionary {
    for (key, v) in value {
      assert(
        key in _SIDE_KEYS,
        message: caller + ": `outset` has no side `" + key + "`; the sides are " + _SIDE_KEYS.map(k => "`" + k + "`").join(", "),
      )
      assert(
        type(v) == length,
        message: caller + ": `outset` side `" + key + "` must be a length, got " + repr(v) + hint,
      )
    }
  } else {
    assert(type(value) == length, message: caller + ": `outset` must be a length or a dictionary, got " + repr(value) + hint)
  }
}

/// How far a bubble of `size` hangs below the baseline when centered on a
/// center line `center` above it: half of it, less that center line. A
/// baseline shift is measured from the box's bottom edge, so this *is* the
/// shift. It grows with the bubble — a bigger bubble drops further — and
/// goes negative for a bubble under twice the center line, which then clears
/// the baseline entirely.
#let bubble_drop(size, center) = size / 2 - center

/// Shape drawers for `choice` (see `_SHAPES`): a function of the bubble's size that
/// otherwise takes the same `stroke`/`fill` as any Typst shape. `circle` and
/// `square` each take a single measurement (`radius`/`size`) — a `width`
/// *and* a `height` are mutually exclusive on both — so the size cannot
/// simply be forwarded to an arbitrary shape function.
#let round_shape(size, ..style) = circle(radius: size / 2, ..style)
#let square_shape(size, ..style) = square(size: size, ..style)

/// The look of a bubble's shape: when filled in, the same pair a solution is
/// drawn with — an outline in the solution color around the solution
/// background — so a marked bubble and a highlighted solution read as the
/// same annotation; a plain outline when it is not. Pure, so the color
/// decision can be checked without rendering and measuring pixels.
#let bubble_style(filled, colors) = if filled {
  (stroke: _STROKE + colors.color, fill: colors.background)
} else {
  (stroke: _STROKE, fill: none)
}

/// How large the check mark in a filled-in bubble is, as a share of the
/// bubble's size: big enough to read at a glance, small enough to stay clear
/// of the outline.
#let _CHECK_SCALE = 0.75

/// The check mark drawn in a filled-in bubble, in the solution color.
///
/// The fill alone is a pale wash, which in a grayscale print is lighter than
/// an empty bubble's black outline; the check is what still marks the answer
/// there. It is the `sym.checkmark` glyph, so it takes the font's own design
/// (or a fallback font's, where the font has none). Its text edges are set
/// to the glyph's bounds, so the box it sits in is exactly its ink, and
/// centering that box centers the mark itself rather than its line.
#let check_mark(size, paint) = text(
  size: size * _CHECK_SCALE,
  fill: paint,
  sym.checkmark,
)

/// Whether a bubble marked `correct: ..` should be drawn filled in: only on
/// the answer key, so that a document whose solutions are off cannot leak
/// its answers through the bubbles.
#let is_filled(correct, get) = correct and show_solutions(get) != false

/// The two shapes a choice's bubble can take, by the name its `bubble:`
/// option gives: the shape drawer, and the size it is drawn at by default.
#let _SHAPES = (
  circle: (draw: round_shape, size: _BUBBLE_SIZE),
  square: (draw: square_shape, size: _SQUARE_SIZE),
)

/// The shape named by a `bubble:` option — `"circle"` or `"square"`, or
/// Typst's own `circle`/`square` function, which reads the same at the call
/// site (`bubble: square`) and is told apart by its name. `caller` names the
/// function in the error message.
#let shape_name(value, caller) = {
  let name = if type(value) == function { repr(value) } else { value }
  assert(
    type(name) == str and name in _SHAPES,
    message: caller
      + ": `bubble` must be \"circle\" (round, for \"select one\") or \"square\" (for \"select all that apply\"), got "
      // A function's repr is often just `(..) => ..`, which names nothing.
      + if type(value) == function { "a function" } else { repr(value) },
  )
  name
}

/// The named arguments `choice` takes.
#let _CHOICE_ARGS = ("bubble", "correct", "size", "outset")

/// Names an author might reach for to mark a choice as the answer.
#let _CORRECT_ALIASES = ("filled", "fill", "checked", "check", "marked", "answer", "solution", "selected", "right")

/// Names an author might reach for to pick the bubble's shape.
#let _SHAPE_ALIASES = ("shape", "style", "kind", "type")

/// Check the arguments of `choice`, so that a mistake is reported at the
/// call, in its own terms, rather than as a failure inside the shape it draws.
#let _check_choice_args(pos, named) = {
  assert(
    pos.len() <= 1,
    message: "choice: a bubble labels one choice, so it takes at most one content argument, got "
      + str(pos.len())
      + " — to lay out several choices, use `#choices`",
  )
  if pos.len() == 1 {
    assert(
      type(pos.first()) != bool,
      message: "choice: got `" + repr(pos.first()) + "` as the bubble's content; to mark the answer, write `correct: true`",
    )
  }
  for key in named.keys() {
    if key in _CORRECT_ALIASES {
      panic("choice: unknown argument `" + key + "`; to mark the answer, write `correct: true`")
    }
    if key in _SHAPE_ALIASES {
      panic("choice: unknown argument `" + key + "`; to pick the shape, write `bubble: \"circle\"` or `bubble: \"square\"`")
    }
    assert(
      key in _CHOICE_ARGS,
      message: "choice: unknown argument `" + key + "`; `choice` takes " + _CHOICE_ARGS.map(k => "`" + k + "`").join(", "),
    )
  }
  let correct = named.at("correct", default: false)
  assert(
    type(correct) == bool,
    message: "choice: `correct` must be `true` or `false`, got " + repr(correct),
  )
  let size = named.at("size", default: auto)
  assert(
    size == auto or type(size) == length,
    message: "choice: `size` must be a length, such as `1.2em` or `12pt`, got " + repr(size),
  )
  if "outset" in named { _check_outset("choice", named.outset) }
}

/// Whether `body` holds nothing to show: empty, or only spaces. A bubble
/// given such content (`#choice[]`) is drawn exactly as one given none.
#let _is_blank(body) = {
  if type(body) != content { return false }
  if body == [] or body.func() == [ ].func() { return true }
  body.func() == [].func() and body.children.all(_is_blank)
}

/// A bubble for students to fill in, optionally followed by `body`, the
/// choice it labels.
///
/// `correct` marks the bubble as (part of) the answer. It only has a visible
/// effect when solutions are shown: then the bubble is filled in and checked
/// and its content picks up the solution color, so the answer key reads like
/// a filled-in answer sheet. With solutions off, `correct` changes nothing —
/// the same source is both the exam and its key.
///
/// Takes its content as an *optional* positional argument, which a plain
/// parameter list cannot express, so `#choice[Paris]`, `#choice[]` and a
/// bare `#choice()` all work.
#let choice(..args) = {
  let named = args.named()
  _check_choice_args(args.pos(), named)
  let shape = _SHAPES.at(shape_name(named.at("bubble", default: "circle"), "choice"))
  let correct = named.at("correct", default: false)
  let size = named.at("size", default: auto)
  if size == auto { size = shape.size }
  let outset = named.at("outset", default: _OUTSET)
  // A string or a number is shown as written, like any other content.
  let body = args.pos().at(0, default: none)
  if _is_blank(body) { body = none }
  if body != none and type(body) != content { body = [#body] }

  e.get(get => {
    let filled = is_filled(correct, get)
    let colors = solution_colors(get)

    // A bubble sits inline in a sentence, so it is centered on the text's
    // own center line rather than on the baseline, and hangs below the
    // baseline by whatever is left over. (A shape holds no text of its own,
    // so the box's baseline is its bottom edge, which is what the shift is
    // measured from.)
    //
    // The outset is the wrapper's own padding, so it is space the bubble
    // occupies. That moves the box's bottom edge down by the bottom outset,
    // and the shift — measured from that edge — has to follow it to leave
    // the shape itself on the center line.
    //
    // A filled-in bubble's check mark is placed over the shape, centered in
    // the box's inset area — which is the shape — and takes no space, so it
    // neither resizes the bubble nor moves it on the line.
    let sides = resolve_sides(outset, base: resolve_sides(_OUTSET))
    box(
      baseline: bubble_drop(size, cap_center()) + sides.bottom,
      inset: sides,
      {
        (shape.draw)(size, ..bubble_style(filled, colors))
        if filled { place(center + horizon, check_mark(size, colors.color)) }
      },
    )

    if body != none {
      if filled { text(fill: colors.color, body) } else { body }
    }
  })
}

/// A round bubble: "select one".
#let bubble = choice.with(bubble: "circle")

/// A square bubble: "select all that apply", drawn a little smaller across
/// than the round one (see `_SQUARE_SIZE`).
#let square_bubble = choice.with(bubble: "square")

/// API documentation for this module's exports, consumed by
/// docs/generate-api.typ (keyed by export name). Kept next to the
/// definitions — update both together.
#let DOCS = (
  choice: (
    desc: "A bubble for students to fill in, followed by the choice it labels. On the answer key (when solutions are shown) a bubble marked `correct` is filled in and checked in the solution color, and its content is set in that color; otherwise it is drawn empty, so the same source gives both the exam and its key. For a list of choices, use `choices`.",
    args: (
      (
        name: "body",
        type: "content | none",
        named: false,
        default: "none",
        doc: "The choice the bubble labels, shown after it. Omit it, or leave it empty (`#choice[]`), for a bare bubble, e.g. one in a table or a grid of its own.",
      ),
      (
        name: "bubble",
        type: "\"circle\" | \"square\"",
        default: "\"circle\"",
        doc: "The shape of the bubble: round for \"select one\", square for \"select all that apply\". Typst's own `circle` and `square` work too.",
      ),
      (
        name: "correct",
        type: "bool",
        default: "false",
        doc: "Whether this choice is part of the answer, and so is filled in and checked when solutions are shown.",
      ),
      (
        name: "outset",
        type: "length | dictionary",
        default: repr(_OUTSET),
        doc: "The space the bubble keeps around itself. A length sets the gap after the bubble, between it and its content (`outset: .6em`); a dictionary sets any of `left`, `right`, `top`, `bottom`, `x`, `y` and `rest`, as the `inset` of a box does, and leaves the sides it does not name at their defaults. The default parts the bubble from whatever follows — its content, an answer box, the next choice — so a gap need not be written at the call site.",
      ),
      (
        name: "size",
        type: "auto | length",
        default: "auto",
        doc: "The diameter of a round bubble, or the side of a square one. `auto` is "
          + repr(_BUBBLE_SIZE)
          + " round and "
          + repr(_SQUARE_SIZE)
          + " square (a little smaller across than the circle, so the two read alike); relative to the font size, so a bubble scales with the surrounding text.",
      ),
    ),
  ),
  bubble: (
    desc: "`choice.with(bubble: \"circle\")`: a round bubble, for \"select one\". Takes the same arguments as `choice`.",
  ),
  "square-bubble": (
    desc: "`choice.with(bubble: \"square\")`: a square bubble, for \"select all that apply\". Takes the same arguments as `choice`.",
  ),
)
