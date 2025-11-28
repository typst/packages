/// Plain color scheme
#let colors-plain = (
  lhs: none,
  nonterminal: none,
  terminal: none,
  operator: none,
  delim: none,
  annot: none,
)

/// Colorful color scheme (default)
#let colors-colorful = (
  lhs: rgb("#1a5fb4"),
  nonterminal: rgb("#613583"),
  terminal: rgb("#26a269"),
  operator: rgb("#a51d2d"),
  delim: rgb("#5e5c64"),
  annot: rgb("#986a44"),
)

// Layout constants
#let _error-text-size = 0.9em
#let _production-spacing = 0.5em
#let _column-gap = 0.75em
#let _row-gap = 0.5em

#let _color-keys = (
  "lhs",
  "nonterminal",
  "terminal",
  "operator",
  "delim",
  "annot",
)

#let _ebnf-state = state("ebnf", (
  mono-font: none,
  body-font: none,
  colors: colors-colorful,
))

#let _error(msg) = text(
  fill: red,
  weight: "bold",
  size: _error-text-size,
)[⚠ EBNF Error: #msg]

#let _styled(color, content) = if color != none {
  text(fill: color, content)
} else { content }

#let _wrap-op(left, right, content, suffix: none) = context {
  let state = _ebnf-state.get()
  let c = state.colors.at("operator", default: none)
  set text(font: state.mono-font) if state.mono-font != none
  if suffix != none {
    [#_styled(c, left)#content#_styled(c, right)#_styled(c, suffix)]
  } else { [#_styled(c, left)#content#_styled(c, right)] }
}

#let _colorize(role, content) = context {
  let state = _ebnf-state.get()
  let styled-content = if role == "annot" {
    if state.body-font != none { text(font: state.body-font, content) } else { content }
  } else {
    if state.mono-font != none { text(font: state.mono-font, content) } else { content }
  }
  _styled(state.colors.at(role, default: none), styled-content)
}

#let _validate-fonts(mono-font, body-font) = {
  for (name, val) in (("mono-font", mono-font), ("body-font", body-font)) {
    if val != none and type(val) != str {
      return (false, name + " must be string or none")
    }
  }
  (true, none)
}

#let _validate-colors(colors) = {
  if type(colors) != dictionary {
    return (false, "colors must be a dictionary")
  }
  let missing = _color-keys.filter(k => k not in colors)
  if missing.len() > 0 {
    return (false, "colors missing: " + missing.join(", "))
  }
  (true, none)
}

#let _validate-prod(prod, n) = {
  if type(prod) != array or prod.len() != 4 {
    return (false, "production #" + str(n) + " invalid")
  }
  let alts = prod.at(2)
  if type(alts) != array or alts.len() == 0 {
    return (false, "production #" + str(n) + " has no alternatives")
  }
  for alt in alts {
    if type(alt) != array or alt.len() != 2 {
      return (false, "production #" + str(n) + " has invalid Or()")
    }
  }
  (true, none)
}

#let _validate-prods(prods) = {
  if prods.len() == 0 {
    return (false, "no productions provided")
  }
  for (i, p) in prods.enumerate() {
    let (ok, err) = _validate-prod(p, i + 1)
    if not ok { return (false, err) }
  }
  (true, none)
}

#let _prod-to-rows(idx, prod, production-spacing) = {
  let (lhs, delim, alts, annot) = prod
  let delim = if delim == auto { "::=" } else { delim }

  // Determine annotation strategy
  let first-annot = alts.at(0).at(1)
  let multi-annot = alts.len() > 1 and alts.slice(1).any(a => a.at(1) != none)

  // Helper: create a full-width annotation row
  let annot-row(c) = (
    grid.cell(colspan: 4, if idx > 0 {
      [#v(production-spacing)#_colorize("annot", c)]
    } else { _colorize("annot", c) }),
  )

  let rows = ()

  // Add production-level annotation
  if annot != none { rows.push(annot-row(annot)) }

  // Add first alternative's annotation (only if single-annotation mode)
  if first-annot != none and not multi-annot {
    rows.push(annot-row(first-annot))
  }

  // Add alternative rows
  for (i, (rhs, rhs-annot)) in alts.enumerate() {
    let acol = if rhs-annot != none and multi-annot {
      _colorize("annot", rhs-annot)
    } else { [] }

    let row = if i == 0 {
      (_colorize("lhs", lhs), _colorize("delim", delim), rhs, acol)
    } else {
      ([], _colorize("delim", "|"), rhs, acol)
    }
    rows.push(row)
  }

  rows
}

/// Optional: `[content]`
#let Opt(content) = _wrap-op("[", "]", content)

/// Repetition (zero or more): `{content}`
#let Rep(content) = _wrap-op("{", "}", content)

/// Repetition (one or more): `{content}+`
#let Rep1(content) = _wrap-op("{", "}", content, suffix: "+")

/// Grouping: `(content)`
#let Grp(content) = _wrap-op("(", ")", content)

/// Terminal symbol
#let T(content) = context {
  let state = _ebnf-state.get()
  set text(font: state.mono-font) if state.mono-font != none
  _styled(state.colors.at("terminal", default: none), content)
}

/// Non-terminal reference (italic)
#let N(content) = context {
  let state = _ebnf-state.get()
  set text(font: state.mono-font) if state.mono-font != none
  _styled(state.colors.at("nonterminal", default: none), emph(content))
}

/// Non-terminal in angle brackets: `⟨content⟩`
#let NT(content) = context {
  let state = _ebnf-state.get()
  set text(font: state.mono-font) if state.mono-font != none
  _styled(state.colors.at("nonterminal", default: none), [⟨#emph(content)⟩])
}

/// Alternative in a production
#let Or(var, annot) = (var, annot)

/// Production rule
#let Prod(lhs, annot: none, delim: auto, ..rhs) = {
  (
    lhs,
    delim,
    rhs.pos().flatten().chunks(2).map(c => (c.at(0), c.at(1, default: none))),
    annot,
  )
}

/// Renders an EBNF grammar as a formatted grid.
///
/// The grammar is displayed as a 4-column table with columns for:
/// left-hand side (LHS), delimiter, right-hand side (RHS), and annotations.
/// Multiple alternatives for a production are shown on separate rows with `|` delimiters.
///
/// - mono-font (string, none): Font for grammar symbols. If `none`, uses document default.
/// - body-font (string, none): Font for annotation text. If `none`, uses document default.
/// - colors (dictionary): Color scheme for syntax highlighting. Use `colors-plain` for no colors
///   or `colors-colorful` (default). Keys: `lhs`, `nonterminal`, `terminal`, `operator`, `delim`, `annot`.
/// - production-spacing (length): Extra vertical space between productions. Default: `0.5em`.
/// - column-gap (length): Horizontal spacing between grid columns. Default: `0.75em`.
/// - row-gap (length): Vertical spacing between grid rows. Default: `0.5em`.
/// - body (Prod): One or more production rules created with `Prod()`.
/// -> content
#let ebnf(
  mono-font: none,
  body-font: none,
  colors: colors-colorful,
  production-spacing: _production-spacing,
  column-gap: _column-gap,
  row-gap: _row-gap,
  ..body,
) = {
  let (ok, err) = _validate-fonts(mono-font, body-font)
  if not ok { return _error(err) }

  let (ok, err) = _validate-colors(colors)
  if not ok { return _error(err) }

  let prods = body.pos()
  let (ok, err) = _validate-prods(prods)
  if not ok { return _error(err) }

  _ebnf-state.update((
    mono-font: mono-font,
    body-font: body-font,
    colors: colors,
  ))

  let cells = prods
    .enumerate()
    .map(((idx, prod)) => _prod-to-rows(idx, prod, production-spacing).flatten())
    .join()

  grid(columns: 4, align: (
      left,
      center,
      left,
      left,
    ), column-gutter: column-gap, row-gutter: row-gap, ..cells)
}
