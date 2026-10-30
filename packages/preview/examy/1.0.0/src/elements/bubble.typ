#import "../prelude.typ": *
#import "../config.typ": BUBBLE_STROKE, DEFAULT_BUBBLE_LABEL_FONT, DEFAULT_BUBBLE_OUTSET, DEFAULT_BUBBLE_STROKE, config, solution_colors
#import "solution.typ": show_solutions
#import "../scan.typ": is_multi_par
#import "../signature.typ": declare_function, define

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
/// what is *drawn*, leaving the space it occupies alone. `config`'s
/// `bubble-outset` changes it for every bubble.
#let _OUTSET = DEFAULT_BUBBLE_OUTSET

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

/// What is wrong with an `outset` argument, or `none` if nothing is, so a
/// mistake is reported in the bubble's terms rather than as a failure deep
/// inside the box it is drawn in. `name` is the option's (`config`'s is
/// `bubble-outset`), and `auto` is allowed where it means "as configured".
#let outset_error(caller, value, name: "outset", allow-auto: false) = {
  let hint = (
    " — give a length for the gap after the bubble (`"
      + name
      + ": .6em`), or a dictionary of sides (`"
      + name
      + ": (left: .2em, right: .6em)`)"
  )
  if allow-auto and value == auto { return none }
  if type(value) != dictionary {
    if type(value) == length { return none }
    return (
      caller
        + ": `"
        + name
        + "` must be a length or a dictionary"
        + if allow-auto { ", or `auto`" } else { "" }
        + ", got "
        + repr(value)
        + hint
    )
  }
  for (key, v) in value {
    if key not in _SIDE_KEYS {
      return (
        caller + ": `" + name + "` has no side `" + key + "`; the sides are " + _SIDE_KEYS.map(k => "`" + k + "`").join(", ")
      )
    }
    if type(v) != length {
      return caller + ": `" + name + "` side `" + key + "` must be a length, got " + repr(v) + hint
    }
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

/// A bubble's outline, as a dictionary of a stroke's fields: `own`, a
/// choice's `stroke` (`auto` for none), over `configured`, `config`'s
/// `bubble-stroke`, field by field, so that `stroke: blue` keeps the
/// configured thickness. A thickness neither gives is
/// `DEFAULT_BUBBLE_STROKE`; any other field neither gives is left out, for
/// the shape's own.
#let bubble_outline(own, configured) = {
  let fields(s) = if s == auto { (:) } else {
    let s = std.stroke(s)
    (paint: s.paint, thickness: s.thickness, cap: s.cap, join: s.join, dash: s.dash, miter-limit: s.miter-limit)
      .pairs()
      .filter(((_, v)) => v != auto)
      .to-dict()
  }
  (thickness: DEFAULT_BUBBLE_STROKE) + fields(configured) + fields(own)
}

/// The look of a bubble's shape: when filled in, the same pair a solution is
/// drawn with — an outline in the solution color around the solution
/// background — so a marked bubble and a highlighted solution read as the
/// same annotation; its plain outline when it is not. Pure, so the color
/// decision can be checked without rendering and measuring pixels.
/// `outline` is the outline's fields (see `bubble_outline`); filled in, its
/// paint is the solution color, whatever it is otherwise.
#let bubble_style(filled, colors, outline) = if filled {
  (stroke: std.stroke(outline + (paint: colors.color)), fill: colors.background)
} else {
  (stroke: std.stroke(outline), fill: none)
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
/// (or a fallback font's, where the font has none). It keeps the text's
/// default edges, so it is centered in the bubble by its line box rather
/// than by its ink.
#let check_mark(size, paint) = text(
  size: size * _CHECK_SCALE,
  fill: paint,
  sym.checkmark,
)

/// The outline thickness a bubble of `size` is drawn with when its `stroke`
/// (or `config`'s `bubble-stroke`) is `thickness`. `mark` is the longer side of the check mark
/// drawn in that bubble. All three are absolute lengths.
///
/// A shape's outline is drawn centered on its edge, so as it thickens it
/// reaches inward over the check mark and outward past the bubble's box, into
/// the gap after it and the lines above and below. It is capped at what
/// leaves the check mark clear of the outline's full thickness on either
/// side, which also keeps what spills outside the box under a tenth of the
/// bubble's size. Capped rather than refused because the limit follows the
/// bubble: the default `.1em` is over it for a bubble under about half an em,
/// which should still draw, with a thinner ring.
#let bubble_stroke(thickness, size, mark) = calc.min(thickness, (size - mark) / 2)

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

/// What is wrong with a `bubble:` option, or `none` if it names a shape (see
/// `shape_name`).
#let shape_error(value, caller) = {
  let name = if type(value) == function { repr(value) } else { value }
  if type(name) == str and name in _SHAPES { return none }
  (
    caller
      + ": `bubble` must be \"circle\" (round, for \"select one\") or \"square\" (for \"select all that apply\"), got "
      // A function's repr is often just `(..) => ..`, which names nothing.
      + if type(value) == function { "a function" } else { repr(value) }
  )
}

/// The shape named by a `bubble:` option — `"circle"` or `"square"`, or
/// Typst's own `circle`/`square` function, which reads the same at the call
/// site (`bubble: square`) and is told apart by its name. `caller` names the
/// function in the error message.
#let shape_name(value, caller) = {
  let message = shape_error(value, caller)
  if message != none { assert(false, message: message) }
  if type(value) == function { repr(value) } else { value }
}

/// Names an author might reach for to mark a choice as the answer.
#let _CORRECT_ALIASES = ("filled", "fill", "checked", "check", "marked", "answer", "solution", "selected", "right")

/// Names an author might reach for to pick the bubble's shape.
#let _SHAPE_ALIASES = ("shape", "style", "kind", "type")

/// Whether `body` holds nothing to show: empty, or only spaces. A bubble
/// given such content (`#choice[]`) is drawn exactly as one given none.
#let _is_blank(body) = {
  if type(body) != content { return false }
  if body == [] or body.func() == [ ].func() { return true }
  body.func() == [].func() and body.children.all(_is_blank)
}

/// What `enumerate: true` numbers the choices with.
#let DEFAULT_ENUMERATE = "A"

/// The counting symbols a numbering pattern counts with, one of which it must
/// hold: `numbering` rejects a pattern without one.
#let _COUNTING_SYMBOLS = "1aAiIαΑ一壹あいアイא가ㄱ*١۱१১ক①⓵"

/// Check an `enumerate` option: `true`, `false`, what `enum`'s `numbering`
/// takes — a pattern such as `"a"` or `"(i)"`, or a function of the number —
/// or an array of the labels themselves, one per choice in turn.
/// `caller` names the function in the error message and `name` the option,
/// and `auto` is allowed where it means "as configured".
/// Returns the message saying what is wrong, or `none` if nothing is.
#let enumerate_error(value, caller, name: "enumerate", allow-auto: false) = {
  if not (type(value) in (bool, str, function, array) or (allow-auto and value == auto)) {
    return (
      caller
        + ": `"
        + name
        + "` must be `true`, `false`, a numbering pattern such as \"a\" or \"(i)\", a numbering function, or an array of labels"
        + if allow-auto { ", or `auto` to follow `config`'s `choices-enumerate`" } else { "" }
        + "; got "
        + repr(value)
    )
  }
  if type(value) == str and not value.clusters().any(c => _COUNTING_SYMBOLS.contains(c)) {
    return (
      caller
        + ": `"
        + name
        + "` pattern "
        + repr(value)
        + " has nothing to count with; it needs a counting symbol such as 1, a, A, i or I, as in \"a\" or \"(i)\""
    )
  }
  if type(value) == array {
    let stray = value.position(l => type(l) not in (str, content, symbol))
    if stray != none {
      return (
        caller
          + ": `"
          + name
          + "` labels must be strings or content, but label "
          + str(stray + 1)
          + " is "
          + repr(value.at(stray))
      )
    }
  }
}

/// The error when an array of labels, from `enumerate` as `caller` and
/// `name` name it, is too short for `count` choices; `none` if it is long
/// enough or is no array.
#let enumerate_count_error(value, count, caller, name: "enumerate") = {
  if type(value) != array or value.len() >= count { return none }
  (
    caller
      + ": `"
      + name
      + "` gives "
      + str(value.len())
      + " label"
      + if value.len() != 1 { "s" } else { "" }
      + ", but there are "
      + str(count)
      + " choices; give one label per choice"
  )
}

/// `enumerate_error`, failing the call if anything is wrong.
#let check_enumerate(..args) = {
  let message = enumerate_error(..args)
  if message != none { assert(false, message: message) }
}

/// The label inside the bubble of the choice at `index` (counting from 0),
/// as `enumerate` numbers it, or `none` when `enumerate` is `false`.
#let choice_label(enumerate, index) = {
  if enumerate == false { return none }
  if type(enumerate) == array { return [#enumerate.at(index)] }
  let pattern = if enumerate == true { DEFAULT_ENUMERATE } else { enumerate }
  [#numbering(pattern, index + 1)]
}

/// How large a choice's label is set, as a share of its bubble's size: a
/// single letter or digit at this size sits well inside the outline.
#let _LABEL_SCALE = 0.68

/// How far a label may reach from the bubble's center toward the ring
/// around it (see `ring_geometry`), as a share of the radius inside the ring.
/// A longer label (`12`) is set smaller until it fits, down to `_LABEL_MIN`.
#let _LABEL_ROOM = 0.85

/// The smallest a label is set, as a share of its bubble's size: 5.5pt in a
/// bubble beside 10pt text. A label too long to fit at this size is set at it
/// anyway (see `label_mark`), as legibility matters more than clearance.
#let _LABEL_MIN = 0.55

/// The ring drawn inside a correct labelled bubble on the answer key: how
/// far inside the outline it sits, and how thick it is, as shares of the
/// bubble's size. Thinner than the outline, so the two read as a ring within
/// a ring rather than as one heavy one.
#let _RING_GAP = 0.06
#let _RING_THICKNESS = 0.045

/// The size of the ring inside a bubble of `size` drawn with an outline
/// `thickness` thick (its diameter, or its side), measured to the middle of
/// its stroke, as a shape's size is; and the room left inside it, across.
/// Both absolute lengths.
#let ring_geometry(size, thickness) = {
  let ring_thickness = size * _RING_THICKNESS
  let ring = size - thickness - 2 * size * _RING_GAP - ring_thickness
  (size: ring, thickness: ring_thickness, room: ring - ring_thickness)
}

/// A choice's label, set to fit inside `room` across, in `font` (`choices`'
/// `label-font`, or `config`'s `bubble-label-font`) and `paint` (`auto` for
/// the text's own color).
///
/// Its text edges are the glyphs' own bounds, so the box it sits in is
/// exactly its ink, and the label is centered in the bubble by that box: a
/// lowercase `a` as well as a capital `A`, which centered on a capital's
/// height would sit low. It is set small enough that its corners clear the
/// inside of a circle `room` across — the tightest fit, and so the size a
/// square bubble's label is set at too, so the two read alike.
///
/// A label that would have to be set smaller than `_LABEL_MIN` to fit (`(a)`,
/// whose brackets are much taller than its letter, or `(iii)`) is set larger,
/// up to that size, reaching past `room` toward the ring: but never past
/// `limit` across, the inside of the bubble's outline, where the outline
/// would cover it. Needs context, to measure the label.
#let label_mark(size, room, label, paint, font: DEFAULT_BUBBLE_LABEL_FONT, limit: auto) = {
  let set_label(s) = text(
    size: s,
    font: font,
    top-edge: "bounds",
    bottom-edge: "bounds",
    ..if paint != auto { (fill: paint) },
    label,
  )
  let s = (size * _LABEL_SCALE).to-absolute()
  let m = measure(set_label(s))
  // How far the label's corners reach from the bubble's center, per point of
  // its size: its extent scales with its size, so one ratio fits it.
  let reach = calc.sqrt(calc.pow(m.width.pt() / 2, 2) + calc.pow(m.height.pt() / 2, 2)) / s.pt()
  // An empty label (a numbering function giving `[]` for some choice) has
  // nothing to fit.
  if reach == 0 { return set_label(s) }
  let fit(across) = across.to-absolute().pt() / 2 / reach * 1pt
  s = calc.min(s, fit(room) * _LABEL_ROOM)
  let least = (size * _LABEL_MIN).to-absolute()
  if s >= least or limit == auto { return set_label(s) }
  set_label(calc.max(s, calc.min(least, fit(limit))))
}

/// Draw a choice: a bubble of the shape named `bubble-shape`, followed by `body`.
/// `choice` checks its arguments and calls this; `choices` calls it directly,
/// to give each bubble its label.
///
/// `correct` marks the bubble as (part of) the answer. It only has a visible
/// effect when solutions are shown: then the bubble is filled in and checked
/// and its content picks up the solution color, so the answer key reads like
/// a filled-in answer sheet. With solutions off, `correct` changes nothing —
/// the same source is both the exam and its key.
///
/// `enumerate` and `index` label the bubble: `enumerate` as `choices` takes
/// it, with `auto` already resolved (`choices` reads `config` once for the
/// whole list), and `index` the choice's place in its list.
///
/// `size`, `outset`, `stroke`, `label-font`, `color` and `background` are
/// the caller's own, `auto` for `config`'s (`bubble-size`, `bubble-outset`,
/// `bubble-stroke`, `bubble-label-font`, `solution-color` and
/// `solution-background-color`); `caller` names the function an error about
/// them names.
///
/// A choice is one unit, whose bubble stays on its first line and whose
/// further lines hang under its body rather than under the bubble.
///
/// As a block (`inline: false`, each choice of `choices` one per line or in
/// columns), the bubble is the marker of a one-item list holding `body`. The
/// list adds no indent of its own: the bubble carries the gap between itself
/// and its body in its own outset, so the marker is already as wide as a
/// bubble plus that gap.
///
/// Inline (a choice in a sentence, or in `choices(inline: true)`), the unit
/// is a box, which keeps it whole within a line of text and lets an answer
/// box see it as content of a line rather than as a `context` that may or
/// may not show anything. In the box, the bubble and body are one paragraph,
/// hanging its lines after the first by the bubble's width: a box holding a
/// block (such as the list) has no baseline of its own, so it would sit on
/// its bottom edge — the bubble's, which hangs below the text's baseline —
/// and lift the choice off the line around it. A body of several paragraphs
/// cannot be one paragraph, so it takes the list; it starts a line of its
/// own anyway.
#let draw_choice(
  body,
  bubble-shape: "circle",
  correct: false,
  size: auto,
  outset: auto,
  stroke: auto,
  label-font: auto,
  color: auto,
  background: auto,
  enumerate: false,
  index: none,
  inline: true,
  caller: "choice",
) = {
  let bubble_shape = _SHAPES.at(bubble-shape)

  show: it => if inline { box(it) } else { it }
  e.get(get => {
    let cfg = get(config)
    // `bubble-size` is the round bubble's; a square one keeps its proportion
    // to it (see `_SQUARE_SIZE`).
    let size = if size != auto { size } else if cfg.bubble-size != auto {
      cfg.bubble-size * (bubble_shape.size / _BUBBLE_SIZE)
    } else { bubble_shape.size }
    let filled = is_filled(correct, get)
    let colors = solution_colors(get, color: color, background: background)
    let label = if index == none { none } else { choice_label(enumerate, index) }

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
    // What is drawn inside the bubble — a filled-in bubble's check mark, a
    // label — is placed over the shape, centered in the box's inset area
    // (which is the shape), and takes no space, so it neither resizes the
    // bubble nor moves it on the line.
    let message = outset_error("config", cfg.bubble-outset, name: "bubble-outset")
    if message != none { assert(false, message: message) }
    let sides = resolve_sides(cfg.bubble-outset, base: resolve_sides(_OUTSET))
    if outset != auto { sides = resolve_sides(outset, base: sides) }
    // Its thickness capped on every bubble, filled in or not, so that the
    // exam and the answer key draw the same ring.
    let outline = bubble_outline(stroke, cfg.bubble-stroke)
    let thickness = outline.thickness
    let source = if stroke != auto and std.stroke(stroke).thickness != auto { caller + ": `stroke`" } else {
      "config: `bubble-stroke`"
    }
    assert(
      thickness.to-absolute() >= 0pt,
      message: source + " must not be negative, got " + repr(thickness),
    )
    thickness = thickness.to-absolute()
    // The check mark is no larger than its font size (about .84 of it, in
    // the fonts bundled with Typst), so an outline within the room that
    // leaves cannot reach it, and the mark need not be measured.
    if thickness > (size * (1 - _CHECK_SCALE) / 2).to-absolute() {
      let mark = measure(check_mark(size, colors.color))
      thickness = bubble_stroke(thickness, size.to-absolute(), calc.max(mark.width, mark.height))
    }
    // A labelled bubble is filled in like any other — outlined in the solution
    // color over the solution background — with its label, in the solution
    // color, where the check mark would go: the two would sit on each other.
    let mark = box(
      baseline: bubble_drop(size, cap_center()) + sides.bottom,
      inset: sides,
      {
        (bubble_shape.draw)(size, ..bubble_style(filled, colors, outline + (thickness: thickness)))
        if label != none {
          // Ringed only once filled in, so on the exam every label reads
          // alike and the answers do not stand out. The label fits inside
          // the ring on the exam too, so it is the same size on both.
          let ring = ring_geometry(size.to-absolute(), thickness)
          if filled {
            place(center + horizon, (bubble_shape.draw)(ring.size, stroke: ring.thickness + colors.color, fill: none))
          }
          place(center + horizon, label_mark(
            size,
            ring.room,
            label,
            if filled { colors.color } else { auto },
            font: if label-font != auto { label-font } else { cfg.bubble-label-font },
            // The inside of the outline, less the gap the ring keeps from it.
            limit: size.to-absolute() * (1 - 2 * _RING_GAP) - thickness,
          ))
        } else if filled {
          place(center + horizon, check_mark(size, colors.color))
        }
      },
    )

    if body == none { return mark }
    let multi_par = is_multi_par(body)
    let body = if filled { text(fill: colors.color, body) } else { body }
    if inline and not multi_par {
      return par(hanging-indent: measure(mark).width, first-line-indent: 0pt, mark + body)
    }
    list(marker: mark, indent: 0pt, body-indent: 0pt, body)
  })
}

#let _CHOICE = declare_function(
  "choice",
  doc: "A single bubble (round or square) followed by the choice it labels. For a list of choices, use `#choices[..]`.
  
  When solutions are shown, a `correct: true` bubble is filled in to indicate it is a correct choice.",
  fields: (
    e.field(
      "body",
      e.types.union(none, content, str, int, float),
      doc: "The text of the choice, shown after the bubble. Leave it out (e.g. `#choice[]`) for a bubble on its own.",
      named: false,
      default: none,
      meta: (
        check: v => if type(v) == bool {
          "choice: got `" + repr(v) + "` as the bubble's content; to mark the answer, write `correct: true`"
        },
      ),
    ),
    e.field(
      "bubble",
      e.types.union(e.types.literal("circle"), e.types.literal("square"), function),
      doc: "The shape of the bubble: `\"circle\"` for \"select one\", `\"square\"` for \"select all that apply\".",
      default: "circle",
      // Typst's own `circle` and `square` are taken too, and examy's
      // `bubble` and `square-bubble` (see `choice`), but not documented.
      meta: (check: v => shape_error(v, "choice"), type-shown: "\"circle\" | \"square\""),
    ),
    e.field(
      "correct",
      bool,
      doc: "Whether this choice is correct; has an effect only when solutions are shown.",
      default: false,
      meta: (hint: "write `true` or `false`"),
    ),
    e.field(
      "outset",
      e.types.union(auto, length, dictionary),
      doc: "The space around the bubble, specified like a [`box`'s `inset`](https://typst.app/docs/reference/layout/box/#parameters-inset). Sides given replace those of `config`'s `bubble-outset`; the others are kept. Setting to `auto` uses `config`'s `bubble-outset`.",
      default: auto,
      meta: (config: "bubble-outset", check: v => outset_error("choice", v, allow-auto: true)),
    ),
    e.field(
      "size",
      e.types.smart(length),
      doc: "The diameter of a bubble. Setting to `auto` uses `config`'s `bubble-size`.",
      default: auto,
      meta: (config: "bubble-size", hint: "such as `1.2em` or `12pt`"),
    ),
    e.field(
      "stroke",
      e.types.smart(BUBBLE_STROKE),
      doc: "The outline of the bubble, specified like `config`'s `bubble-stroke` (e.g. `.15em`, `blue`, or `.15em + blue`). What it leaves out, its thickness or its color, is `config`'s. Setting to `auto` uses `config`'s `bubble-stroke`.",
      default: auto,
      meta: (config: "bubble-stroke"),
    ),
    e.field(
      "solution-color",
      e.types.union(auto, color),
      doc: "The primary color for a correct bubble; i.e., the color of its outline, check mark, and text when filled in. Setting to `auto` uses `config`'s `solution-color`.",
      default: auto,
      meta: (config: "solution-color"),
    ),
    e.field(
      "solution-background-color",
      e.types.union(auto, color),
      doc: "The background color for a correct bubble when filled in. Setting to `auto` uses `config`'s `solution-background-color`.",
      default: auto,
      meta: (config: "solution-background-color"),
    ),
  ),
  aliases: (
    _CORRECT_ALIASES.map(k => (k, "to mark the answer, write `correct: true`"))
      + _SHAPE_ALIASES.map(k => (k, "to pick the shape, write `bubble: \"circle\"` or `bubble: \"square\"`"))
  ).to-dict(),
  positional-error: n => (
    "choice: a bubble labels one choice, so it takes at most one content argument, got "
      + str(n)
      + " — to lay out several choices, use `#choices`"
  ),
)

/// A bubble for students to fill in, optionally followed by `body`, the
/// choice it labels; see `draw_choice` for how it is drawn. `body` is an
/// *optional* positional argument, so `#choice[Paris]`, `#choice[]` and a
/// bare `#choice()` all work.
#let _choice = define(_CHOICE, it => {
  // A string or a number is shown as written, like any other content.
  let body = it.body
  if _is_blank(body) { body = none }
  if body != none and type(body) != content { body = [#body] }
  draw_choice(
    body,
    bubble-shape: shape_name(it.bubble, "choice"),
    correct: it.correct,
    size: it.size,
    outset: it.outset,
    stroke: it.stroke,
    color: it.solution-color,
    background: it.solution-background-color,
  )
})

/// `_choice`, taking for its `bubble:` examy's own `bubble` and
/// `square-bubble` as well, as `choices` does: every spelling of a shape
/// works wherever one is taken. Only the strings are documented. They are
/// recognized here, where they can be named, as two functions bound alike
/// are equal.
#let choice(..args) = {
  let named = args.named()
  let bubble_shape = named.at("bubble", default: none)
  if type(bubble_shape) == function {
    if bubble_shape == choice.with(bubble: "circle") { named.bubble = "circle" }
    if bubble_shape == choice.with(bubble: "square") { named.bubble = "square" }
  }
  _choice(..args.pos(), ..named)
}

/// A round bubble: "select one".
#let bubble = choice.with(bubble: "circle")

/// A square bubble: "select all that apply", drawn a little smaller across
/// than the round one (see `_SQUARE_SIZE`).
#let square_bubble = choice.with(bubble: "square")

/// API documentation for this module's exports, consumed by docs/api.typ
/// (keyed by export name).
#let DOCS = (
  choice: _CHOICE,
  bubble: (alias-of: "choice", with: (bubble: "circle"), desc: "A round bubble (for \"select one\" multiple choice)."),
  "square-bubble": (alias-of: "choice", with: (bubble: "square"), desc: "A square bubble, used for \"select all that apply\"."),
)
