// Unified error reporting for src/.
//
// Typst cannot catch a panic, so the message *builders* are pure functions
// returning strings (tests/unit/test-errors.typ asserts their wording) and the
// `fail-*` / `check` wrappers raise them via `panic` / `assert`.
//
// Message grammar:
//   "<scope>: <problem>; got <repr(value)>. <hint>"
//   - scope:   the public function or module ("compose", "geom-curve").
//   - problem: the expectation, without a trailing period.
//   - got:     appended only when a value is shown; always via repr().
//   - one trailing full stop.
//   - hint:    optional final sentence giving the fix.
//
// Never inline a panic string elsewhere in src/; route every validation here.

// Render an array of values as a quoted, comma-joined list: "a", "b", "c".
#let quote-each(values) = values.map(v => "\"" + str(v) + "\"").join(", ")

// A cm figure in a layout message, rounded to the sub-millimetre the reader can
// act on. Every layout failure quotes room the same way, so the rounding lives
// here rather than beside each `fail`.
#let cm-text(value) = str(calc.round(value, digits: 2))

// Append a hint sentence when one is supplied.
#let _with-hint(text, hint) = if hint == none { text } else {
  text + " " + hint
}

// "<scope>: <problem>." plus optional hint. `problem` may already carry its own
// "; got ..." clause for bespoke messages.
#let error-text(scope, problem, hint: none) = {
  _with-hint(scope + ": " + problem + ".", hint)
}

// "<scope>: <name> must be one of "a", "b"; got <repr(value)>."
#let enum-text(scope, name, value, valid, hint: none) = {
  error-text(
    scope,
    name + " must be one of " + quote-each(valid) + "; got " + repr(value),
    hint: hint,
  )
}

// "<scope>: <name> must be <expected>; got <repr(value)>."
// `expected` is a noun phrase, e.g. "a positive integer", "a length or `auto`".
#let type-text(scope, name, value, expected, hint: none) = {
  error-text(
    scope,
    name + " must be " + expected + "; got " + repr(value),
    hint: hint,
  )
}

// "<scope>: <name> must be in (lo, hi); got <repr(value)>."
// lo-open/hi-open pick the bracket: open -> "(" / ")", closed -> "[" / "]".
#let range-text(
  scope,
  name,
  value,
  lo,
  hi,
  lo-open: true,
  hi-open: true,
  hint: none,
) = {
  let open = if lo-open { "(" } else { "[" }
  let close = if hi-open { ")" } else { "]" }
  let interval = open + repr(lo) + ", " + repr(hi) + close
  error-text(
    scope,
    name + " must be in " + interval + "; got " + repr(value),
    hint: hint,
  )
}

// "<scope>: <label> maps to unknown column <repr(col)>; available columns:
// "a", "b"." `label` is the aesthetic name for a mapping, or the facet role
// ("variable", "rows", "columns") for a facet.
#let unknown-column-text(scope, label, col, available, hint: none) = {
  error-text(
    scope,
    label
      + " maps to unknown column "
      + repr(col)
      + "; available columns: "
      + quote-each(available),
    hint: hint,
  )
}

// Panic / assert wrappers ----------------------------------------------------

#let fail(scope, problem, hint: none) = {
  panic(error-text(scope, problem, hint: hint))
}

#let fail-enum(scope, name, value, valid, hint: none) = {
  panic(enum-text(scope, name, value, valid, hint: hint))
}

#let fail-type(scope, name, value, expected, hint: none) = {
  panic(type-text(scope, name, value, expected, hint: hint))
}

#let fail-range(
  scope,
  name,
  value,
  lo,
  hi,
  lo-open: true,
  hi-open: true,
  hint: none,
) = {
  panic(range-text(
    scope,
    name,
    value,
    lo,
    hi,
    lo-open: lo-open,
    hi-open: hi-open,
    hint: hint,
  ))
}

#let check(cond, scope, problem, hint: none) = {
  assert(cond, message: error-text(scope, problem, hint: hint))
}

#let fail-unknown-column(scope, label, col, available, hint: none) = {
  panic(unknown-column-text(scope, label, col, available, hint: hint))
}

// Panic unless `align` is a Typst alignment (the house type for every text /
// legend alignment). `none` is allowed: it means "inherit the default". Guards
// against passing a string like "left" (which silently never matches the
// alignment comparisons downstream). `name` names the field in the message,
// for a caller that takes more than one alignment.
#let assert-halign(scope, align, name: "align") = {
  if align != none and type(align) != alignment {
    fail-type(
      scope,
      name,
      align,
      "a Typst alignment `left`, `center`, or `right`",
      hint: "Use the alignment value `left`, not the string \"left\".",
    )
  }
}

// Panic unless `value` is a Typst length or `none` (inherit the theme
// default). Guards against passing a raw number or string where a glyph
// diameter is expected.
#let assert-length(scope, name, value) = {
  if value != none and type(value) != length {
    fail-type(
      scope,
      name,
      value,
      "a length such as `0.3cm`, or `none`",
      hint: "Use `0.3cm` for an absolute size; `none` keeps the theme default.",
    )
  }
}

// Panic unless `value` is a length of at least 0. A caller that also takes
// `none` or `auto` tests for it first and names it in `also`.
#let assert-nonnegative-length(scope, name, value, also: none) = {
  if type(value) != length or value.abs < 0pt or value.em < 0 {
    fail-type(
      scope,
      name,
      value,
      "a length of at least `0pt`"
        + if also != none { ", or " + also } else { "" },
    )
  }
}

// Panic unless `value` is an absolute length, a ratio (a `%` value relative to
// the parent surface), or `none` (inherit), and is not below zero. `given` is
// the value as the caller wrote it, for the message.
#let _assert-extent(scope, name, value, given, expected, hint) = {
  if value != none and type(value) not in (length, ratio) {
    fail-type(scope, name, given, expected, hint: hint)
  }
  let zero = if type(value) == length { 0pt } else { 0% }
  if type(value) in (length, ratio) and value < zero {
    fail-type(
      scope,
      name,
      given,
      "a length or ratio of at least 0",
      hint: hint,
    )
  }
}

// Panic unless `size` is a length or ratio of at least 0, or `none` (inherit).
// Guards against passing a raw number or string where a typed size is expected.
#let assert-text-size(scope, size) = _assert-extent(
  scope,
  "size",
  size,
  size,
  "a length (e.g., `12pt`), a ratio (e.g., `80%`), or `none`",
  "Use `12pt` for an absolute size or `80%` to scale the parent size.",
)

// Panic unless `stroke` is a length or ratio of at least 0, or `none`
// (inherit). `given` is the value before `split-stroke-shorthand` reduced a
// native `stroke(...)`, so the message shows what the user wrote. A dictionary
// here means that `stroke(...)` carried a dash, cap, join or miter limit.
#let assert-stroke(scope, stroke, given: auto) = {
  let shown = if given == auto { stroke } else { given }
  if type(stroke) == dictionary {
    fail-type(
      scope,
      "stroke",
      shown,
      "a length (e.g., `1pt`), a ratio (e.g., `80%`), or `none`",
      hint: "Dash, cap and join are not supported; this stroke sets "
        + stroke.keys().filter(k => k != "thickness").join(", ")
        + ". Set a thickness and a separate `colour`.",
    )
  }
  _assert-extent(
    scope,
    "stroke",
    stroke,
    shown,
    "a length (e.g., `1pt`), a ratio (e.g., `80%`), or `none`",
    "Use `1pt` for an absolute thickness or `80%` to scale the parent stroke.",
  )
}

// Panic unless `value` is a length or ratio of at least 0, or `none` (inherit).
#let assert-tick-length(scope, value) = _assert-extent(
  scope,
  "length",
  value,
  value,
  "a length (e.g., `0.1cm`), a ratio (e.g., `50%`), or `none`",
  "Use `0.1cm` for an absolute tick length or `50%` to scale the parent length.",
)

// Panic unless `value` is `none` (inherit) or a colour, gradient or tiling.
#let assert-paint(scope, name, value) = {
  if value != none and type(value) not in (color, gradient, tiling) {
    fail-type(
      scope,
      name,
      value,
      "a colour, a gradient, a tiling, or `none`",
      hint: "Pass an `rgb(...)` value, not a string.",
    )
  }
}

// Panic unless `value` is a colour. Used where the value is mixed with another
// colour, which a gradient or a tiling cannot be.
#let assert-colour(scope, name, value, none-ok: true) = {
  if value == none and none-ok { return }
  if type(value) != color {
    fail-type(
      scope,
      name,
      value,
      if none-ok { "a colour, or `none`" } else { "a colour" },
      hint: "Pass an `rgb(...)` value, not a string.",
    )
  }
}

// Panic unless `angle` is `none` (inherit) or a Typst angle.
#let assert-angle(scope, angle) = {
  if angle != none and type(angle) != std.angle {
    fail-type(
      scope,
      "angle",
      angle,
      "an angle such as `45deg`, or `none`",
      hint: "Use `45deg`, not the number `45`.",
    )
  }
}

// Panic unless `weight` is `none` (inherit), a whole number, or a weight name.
#let assert-weight(scope, weight) = {
  if weight != none and type(weight) not in (int, str) {
    fail-type(
      scope,
      "weight",
      weight,
      "a whole number such as `700`, a name such as `\"bold\"`, or `none`",
    )
  }
}

// Panic unless `font` is `none` (keep the document font), a family name, an
// array of family names, or a font dictionary.
#let assert-font(scope, font) = {
  if font != none and type(font) not in (str, array, dictionary) {
    fail-type(
      scope,
      "font",
      font,
      "a font family name, an array of names, or `none`",
    )
  }
}

// Panic unless `value` is `none` or a `margin(...)` record. Anything else is
// not a margin, and the theme could only discard it.
#let assert-margin(scope, name, value) = {
  if (
    value != none
      and (
        type(value) != dictionary or value.at("kind", default: none) != "margin"
      )
  ) {
    fail-type(
      scope,
      name,
      value,
      "a `margin(...)` record, or `none`",
      hint: "Build it with `margin(top: 0.4cm, ...)`; a bare length is not a margin.",
    )
  }
}

// Panic unless `alpha` is `none`, `auto`, or a number in [0, 1]. Guards the
// documented opacity range at construction, where it would otherwise clamp in
// silence or fail on a comparison at render.
#let assert-alpha(scope, alpha) = {
  if alpha == none or alpha == auto { return }
  if type(alpha) not in (int, float) {
    fail-type(scope, "alpha", alpha, "a number in [0, 1], `auto`, or `none`")
  }
  if alpha < 0 or alpha > 1 {
    fail-range(scope, "alpha", alpha, 0, 1, lo-open: false, hi-open: false)
  }
}

#let LINETYPES = (
  "solid",
  "dotted",
  "densely-dotted",
  "loosely-dotted",
  "dashed",
  "densely-dashed",
  "loosely-dashed",
  "dash-dotted",
  "densely-dash-dotted",
  "loosely-dash-dotted",
)

// Panic unless `linetype` is `none`, `auto`, a Typst dash keyword, or a Typst
// dash pattern (an array or a dictionary).
#let assert-linetype(scope, linetype) = {
  if linetype == none or linetype == auto { return }
  if type(linetype) in (array, dictionary) { return }
  if linetype not in LINETYPES {
    fail-enum(
      scope,
      "linetype",
      linetype,
      LINETYPES,
      hint: "Use `auto` to honour the linetype scale.",
    )
  }
}

// Panic unless `value` is a number. With `positive`, it must be greater than
// zero; with `min`, it must be at least `min`.
#let assert-number(scope, name, value, min: none, positive: false) = {
  let expected = if positive { "a positive number" } else if min == none {
    "a number"
  } else { "a number of at least " + repr(min) }
  if type(value) not in (int, float) {
    fail-type(scope, name, value, expected)
  }
  if positive and value <= 0 or min != none and value < min {
    fail-type(scope, name, value, expected)
  }
}

#let CONTENT-ANCHORS = (
  "center",
  "mid",
  "mid-east",
  "mid-west",
  "base",
  "base-east",
  "base-west",
  "text",
  "north",
  "north-east",
  "north-west",
  "south",
  "south-east",
  "south-west",
  "east",
  "west",
)

// Panic unless `anchor` names an anchor of a CeTZ content element.
#let assert-anchor(scope, anchor) = {
  if anchor not in CONTENT-ANCHORS {
    fail-enum(scope, "anchor", anchor, CONTENT-ANCHORS)
  }
}

// Panic unless `value` is a number in (0, 1], the share of a slot that a mark
// fills.
#let assert-fraction(scope, name, value) = {
  if type(value) not in (int, float) {
    fail-type(scope, name, value, "a number in (0, 1]")
  }
  if value <= 0 or value > 1 {
    fail-range(scope, name, value, 0, 1, hi-open: false)
  }
}
