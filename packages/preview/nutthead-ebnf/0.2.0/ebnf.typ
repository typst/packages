/// Plain color scheme
#let colors-plain = (
  lhs: none,
  nonterminal: none,
  terminal: none,
  operator: none,
  delim: none,
  comment: none,
)

/// Colorful color scheme (default)
#let colors-colorful = (
  lhs: rgb("#1a5fb4"),
  nonterminal: rgb("#613583"),
  terminal: rgb("#26a269"),
  operator: rgb("#a51d2d"),
  delim: rgb("#5e5c64"),
  comment: rgb("#5e5c64"),
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
  "comment",
)

#let _ebnf-state = state("ebnf", (
  mono-font: none,
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
  let styled-content = if state.mono-font != none {
    text(font: state.mono-font, content)
  } else { content }
  _styled(state.colors.at(role, default: none), styled-content)
}

#let _validate-font(mono-font) = {
  if mono-font != none and type(mono-font) != str {
    return (false, "mono-font must be string or none")
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
  if type(prod) != array or prod.len() != 3 {
    return (false, "production #" + str(n) + " invalid")
  }
  let alts = prod.at(2)
  if type(alts) != array or alts.len() == 0 {
    return (false, "production #" + str(n) + " has no alternatives")
  }
  for a in alts {
    if type(a) != array or a.len() != 2 {
      return (false, "production #" + str(n) + " has invalid alt()")
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
  let (lhs, delim, alts) = prod
  let delim = if delim == auto { "::=" } else { delim }

  let rows = ()

  // Add spacer row before production (except first)
  if idx > 0 {
    rows.push((grid.cell(colspan: 4, v(production-spacing)),))
  }

  // Add alternative rows
  for (i, (rhs, comment)) in alts.enumerate() {
    let has-comment = comment != none and comment != []
    let comment-col = if has-comment {
      _colorize("comment", [(\* #comment \*)])
    } else { [] }

    let row = if i == 0 {
      (_colorize("lhs", lhs), _colorize("delim", delim), rhs, comment-col)
    } else {
      ([], _colorize("delim", "|"), rhs, comment-col)
    }
    rows.push(row)
  }

  rows
}

/// Optional sequence: `[ definitions-list ]`
#let optional-sequence(content) = _wrap-op("[", "]", content)

/// Repeated sequence: `{ definitions-list }`
#let repeated-sequence(content) = _wrap-op("{", "}", content)

/// Grouped sequence: `( definitions-list )`
#let grouped-sequence(content) = _wrap-op("(", ")", content)

/// Terminal string: quoted literal text
#let terminal-string(content) = context {
  let state = _ebnf-state.get()
  set text(font: state.mono-font) if state.mono-font != none
  _styled(state.colors.at("terminal", default: none), content)
}

/// Meta-identifier: non-terminal reference (italic)
#let meta-identifier(content) = context {
  let state = _ebnf-state.get()
  set text(font: state.mono-font) if state.mono-font != none
  _styled(state.colors.at("nonterminal", default: none), emph(content))
}

/// Exception: `factor - exception` (excluding sequences)
#let exception(a, b) = context {
  let state = _ebnf-state.get()
  set text(font: state.mono-font) if state.mono-font != none
  [#a #_styled(state.colors.at("operator", default: none), "−") #b]
}

/// Single definition: `term , term , ...` (syntactic concatenation)
#let single-definition(..items) = context {
  let state = _ebnf-state.get()
  set text(font: state.mono-font) if state.mono-font != none
  let sep = [#_styled(state.colors.at("operator", default: none), ",") ]
  items.pos().join(sep)
}

/// Syntactic factor: `integer * primary` (repetition count)
#let syntactic-factor(count, content) = context {
  let state = _ebnf-state.get()
  set text(font: state.mono-font) if state.mono-font != none
  [#_styled(state.colors.at("operator", default: none), str(count) + " ∗") #content]
}

/// Special sequence: `? ... ?` (implementation-defined)
#let special-sequence(content) = _wrap-op("?", "?", content)

/// Comment: `(* ... *)` (inline documentation)
#let comment(content) = context {
  let state = _ebnf-state.get()
  _styled(state.colors.at("comment", default: none), [(\* #content \*)])
}

/// Empty sequence (epsilon): represents an empty production
#let empty-sequence = context {
  let state = _ebnf-state.get()
  set text(font: state.mono-font) if state.mono-font != none
  _styled(state.colors.at("operator", default: none), "ε")
}

/// Definitions list: alternative in a production with optional comment
#let definitions-list(var, comment) = (var, comment)

/// Syntax rule: production rule
#let syntax-rule(lhs, delim: auto, ..rhs) = {
  (lhs, delim, rhs.pos().flatten().chunks(2).map(c => (c.at(0), c.at(1, default: none))))
}

/// Syntax: renders an EBNF grammar as a formatted grid.
///
/// The grammar is displayed as a 4-column table with columns for:
/// left-hand side (LHS), delimiter, right-hand side (RHS), and comments.
/// Multiple alternatives for a production are shown on separate rows with `|` delimiters.
/// Comments are rendered as ISO 14977 `(* ... *)` notation in the 4th column.
///
/// - mono-font (string, none): Font for grammar symbols. If `none`, uses document default.
/// - colors (dictionary): Color scheme for syntax highlighting. Use `colors-plain` for no colors
///   or `colors-colorful` (default). Keys: `lhs`, `nonterminal`, `terminal`, `operator`, `delim`, `comment`.
/// - production-spacing (length): Extra vertical space between productions. Default: `0.5em`.
/// - column-gap (length): Horizontal spacing between grid columns. Default: `0.75em`.
/// - row-gap (length): Vertical spacing between grid rows. Default: `0.5em`.
/// - body (syntax-rule): One or more production rules created with `syntax-rule()`.
/// -> content
#let syntax(
  mono-font: none,
  colors: colors-colorful,
  production-spacing: _production-spacing,
  column-gap: _column-gap,
  row-gap: _row-gap,
  ..body,
) = {
  let (ok, err) = _validate-font(mono-font)
  if not ok { return _error(err) }

  let (ok, err) = _validate-colors(colors)
  if not ok { return _error(err) }

  let prods = body.pos()
  let (ok, err) = _validate-prods(prods)
  if not ok { return _error(err) }

  _ebnf-state.update((
    mono-font: mono-font,
    colors: colors,
  ))

  let cells = prods
    .enumerate()
    .map(((idx, prod)) => _prod-to-rows(idx, prod, production-spacing).flatten())
    .join()

  grid(columns: 4, align: (left, center, left, left), column-gutter: column-gap, row-gutter: row-gap, ..cells)
}
