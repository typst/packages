// clanker-slop-nicematrix: the mathematical side of LaTeX's nicematrix for
// Typst, with the paths and flood fills of pavemat, in a single file.
//
//   #import "@preview/clanker-slop-nicematrix:0.1.0": *
//   $ nicemat(1, dots.c, 1; dots.v, dots.down, dots.v; 1, dots.c, 1) $
//
// Public API (every other name starts with `_` and is internal):
//   nicemat, nicearray                        the matrices            (§12)
//   ldots, cdots, vdots, ddots, iddots        leaders                 (§3)
//   cell, diagbox, hline, vline               cells and rules         (§3)
//   hbrace, vbrace, submatrix, region         braces and decorations  (§3)
//   dotline, connect, pave, flood             lines, arrows, paths    (§3)
//   nicemat-group                             shared column widths    (§11)
//   nicemat-setup                             inline equations        (§13)
//   nicemat-cell, nicemat-connect             named matrices          (§14)
//
// Sections, in the order Typst needs them (a name must be defined before the
// functions using it):
//   1 Utilities             6 Drawing              11 Groups
//   2 Measuring math        7 Leaders              12 nicemat
//   3 Markers               8 Rules and corners    13 Setup
//   4 Parsing               9 Decorations          14 Named matrices
//   5 Layout               10 Paths and flood fills
//
// License: MIT (see LICENSE). Section 10 is adapted from pavemat
// (https://github.com/QuadnucYard/pavemat, MIT, © 2024–2025 QuadnucYard).
// Documentation: https://github.com/coder56765/clanker-slop-nicematrix

// ===========================================================================
// 1. Utilities
// ===========================================================================
//
// Small helpers shared by the whole package: coercions of values coming
// from math-mode calls, coordinate parsing, delimiter pairing and strokes.

/// Best-effort plain text of a value. Math-mode arguments arrive as content
/// (`span: 3` gives `[3]`, `(0, 1)` gives an `lr` element), so most coercions
/// go through this.
#let _plain-text(it) = {
  let t = type(it)
  if it == none { return "" }
  if t == str { return it }
  if t == symbol { return str(it) }
  if t == int or t == float { return str(it) }
  if t != content { return "" }
  if it.has("text") { return _plain-text(it.text) }
  if it.has("children") { return (("",) + it.children.map(_plain-text)).join("") }
  if it.has("body") { return _plain-text(it.body) }
  if it.has("child") { return _plain-text(it.child) }
  if it.func() == [ ].func() { return " " }
  ""
}

/// Normalizes the minus signs and spaces of a number typed in math mode.
#let _clean-number(s) = s.replace("−", "-").replace(" ", "").trim()

/// Coerces an int, a float, a string or math content (`[3]`) to an integer.
#let _to-int(v, name: "value") = {
  let t = type(v)
  if t == int { return v }
  if t == float { return int(v) }
  let s = _clean-number(_plain-text(v))
  if s.match(regex("^-?\d+$")) == none {
    panic("nicematrix: expected an integer for `" + name + "`, got " + repr(v))
  }
  int(s)
}

/// Coerces a length-like value; content such as `[2pt]` is not supported in
/// math mode, so we only accept real lengths here (with a helpful message).
#let _to-length(v, name: "value") = {
  let t = type(v)
  if t == length or t == relative or t == ratio { return v }
  if t == int or t == float { return v * 1pt }
  panic("nicematrix: expected a length for `" + name + "` (write `#2pt` in math mode), got " + repr(v))
}

/// Coerces a boolean; math mode gives content for bare `true`.
#let _to-bool(v, name: "value") = {
  if type(v) == bool { return v }
  let s = _plain-text(v).trim()
  if s == "true" { return true }
  if s == "false" { return false }
  panic("nicematrix: expected a boolean for `" + name + "` (write `#true` in math mode), got " + repr(v))
}

/// Coerces an angle; plain numbers (also math content such as `30` or
/// `−30`) are degrees.
#let _to-angle(v, name: "value") = {
  let t = type(v)
  if t == angle { return v }
  if t == int or t == float { return v * 1deg }
  let s = _clean-number(_plain-text(v)).replace("deg", "").replace("°", "")
  if s.match(regex("^-?\d+(\.\d+)?$")) == none {
    panic("nicematrix: expected an angle for `" + name + "` (such as `30` or `#30deg`), got " + repr(v))
  }
  float(s) * 1deg
}

/// Coerces an integer or a list of integers: an array, or math content such
/// as `(1, −1)` or `2`.
#let _to-int-list(v, name: "value") = {
  if type(v) == array { return v.map(x => _to-int(x, name: name)) }
  if type(v) in (int, float) { return (_to-int(v, name: name),) }
  let s = _clean-number(_plain-text(v)).replace("(", "").replace(")", "")
  s.split(",").filter(p => p != "").map(p => _to-int(p, name: name))
}

/// Parses a cell coordinate `(row, col)`.
///
/// Accepts an array `(1, 2)`, math content `(1, 2)` (an `lr` element), a
/// string `"1-2"`, `"1,2"` or `"(1, 2)"`, or a dictionary `(row: 1, col: 2)`.
/// Negative numbers are kept as is (they count from the end).
#let _to-coord(v, name: "coordinate") = {
  let t = type(v)
  if t == array {
    if v.len() != 2 { panic("nicematrix: `" + name + "` needs two numbers, got " + repr(v)) }
    return v.map(x => _to-int(x, name: name))
  }
  if t == dictionary {
    let r = v.at("row", default: v.at("i", default: none))
    let c = v.at("col", default: v.at("j", default: none))
    if r == none or c == none { panic("nicematrix: `" + name + "` dictionary needs `row` and `col`") }
    return (_to-int(r, name: name), _to-int(c, name: name))
  }
  let s = _clean-number(_plain-text(v)).replace("(", "").replace(")", "")
  let parts = if s.contains(",") { s.split(",") } else if s.contains(";") { s.split(";") } else {
    // "1-2" style (only without negative numbers)
    let m = s.match(regex("^(\d+)-(\d+)$"))
    if m == none { () } else { m.captures }
  }
  if parts.len() != 2 {
    panic("nicematrix: cannot read `" + name + "` from " + repr(v) + " (use `(row, col)`)")
  }
  parts.map(p => _to-int(p, name: name))
}

/// Resolves a possibly negative index against `n` (count from the end).
#let _norm-index(k, n) = if k < 0 { n + k } else { k }

/// Resolves a length, relative length or ratio to an absolute length. Must be
/// called in a context. Ratios have no sensible base here and count as zero.
#let _abs-len(v) = {
  let t = type(v)
  if t == length { v.to-absolute() }
  else if t == relative { v.length.to-absolute() }
  else if t == ratio { 0pt }
  else if t == int or t == float { v * 1pt }
  else if v == none { 0pt }
  else { panic("nicematrix: expected a length, got " + repr(v)) }
}

/// Returns element `k` of a per-gap specification: either a single value or
/// an array whose last entry is repeated.
#let _pick(spec, k) = {
  if type(spec) != array { return spec }
  if spec.len() == 0 { return none }
  spec.at(calc.min(k, spec.len() - 1))
}

/// Normalizes a length or a dictionary with `left/right/top/bottom/x/y/rest`
/// keys into a dictionary with the four _sides.
#let _sides(v, default: 0pt) = {
  if type(v) != dictionary {
    let x = if v == auto or v == none { default } else { v }
    return (left: x, right: x, top: x, bottom: x)
  }
  let rest = v.at("rest", default: default)
  let x = v.at("x", default: rest)
  let y = v.at("y", default: rest)
  (
    left: v.at("left", default: x),
    right: v.at("right", default: x),
    top: v.at("top", default: y),
    bottom: v.at("bottom", default: y),
  )
}

/// Closing delimiter matching an opening one (the same pairing Typst uses).
#let _closing = (
  "(": ")", "[": "]", "{": "}", "⟨": "⟩", "⟦": "⟧", "⌈": "⌉", "⌊": "⌋",
  "|": "|", "‖": "‖", "⦇": "⦈", "⦃": "⦄", "⟮": "⟯", "⟬": "⟭",
  "⦅": "⦆", "⌜": "⌝", "⌞": "⌟", "⟅": "⟆", "/": "\\", "\\": "/",
)

/// Splits a `delim` specification (`"("`, a symbol, an array or `none`)
/// into a `(left, right)` pair; each side may be `none`.
#let _delim-pair(d) = {
  if d == none { return (none, none) }
  if type(d) == array {
    if d.len() != 2 { panic("nicematrix: `delim` array needs two entries, got " + repr(d)) }
    return (d.at(0), d.at(1))
  }
  let s = str(d)
  let r = _closing.at(s, default: s)
  (d, if type(d) == str { r } else if r == s { d } else { r })
}

/// Merges a user stroke specification into a default dictionary stroke.
/// `auto` keeps the default, `none` disables, a color/length/dictionary/
/// stroke is layered on top of the default.
#let _merge-stroke(default, user) = {
  if user == auto { return default }
  if user == none { return none }
  let base = if type(default) == dictionary { default } else { (:) }
  let t = type(user)
  if t == color or t == gradient or t == tiling { return base + (paint: user) }
  if t == length { return base + (thickness: user) }
  // The rules default to square caps (like the `augment` of `mat`), which
  // would merge the dots of a dotted pattern into a solid line: those get
  // Typst's default butt caps back unless a cap is given.
  let round-dots(d, user-cap) = {
    let dotted = d.at("dash", default: none) in ("dotted", "densely-dotted", "loosely-dotted")
    if dotted and user-cap == auto and d.at("cap", default: auto) == "square" { d + (cap: "butt") } else { d }
  }
  if t == dictionary { return round-dots(base + user, user.at("cap", default: auto)) }
  if t == stroke {
    let d = base
    let fields = (
      paint: user.paint, thickness: user.thickness, cap: user.cap,
      join: user.join, dash: user.dash, miter-limit: user.miter-limit,
    )
    for (key, v) in fields {
      if v != auto { d.insert(key, v) }
    }
    return round-dots(d, user.cap)
  }
  panic("nicematrix: invalid stroke " + repr(user))
}

/// Like `_merge-stroke`, but also accepts a dictionary of _sides (`top`,
/// `bottom`, `left`, `right`, `x`, `y`, `rest`) as `rect` does; `true`
/// means the default stroke.
#let _side-stroke(default, user) = {
  if user == true { return default }
  let _sides = ("top", "bottom", "left", "right", "x", "y", "rest")
  if type(user) == dictionary and user.keys().any(k => k in _sides) {
    return user.pairs().map(((k, v)) => (k, if v == none { none } else { _merge-stroke(default, if v == true { auto } else { v }) })).to-dict()
  }
  _merge-stroke(default, user)
}

/// Thickness of a (dictionary) stroke, for offsets of double rules.
#let _stroke-thickness(s) = {
  if s == none { return 0pt }
  let st = stroke(s)
  if st.thickness == auto { 1pt } else { st.thickness.to-absolute() }
}

/// Text-mode representation of horizontal alignment components.
#let _h-align(a, fallback: center) = {
  if a == auto or a == none { return fallback }
  let x = if type(a) == alignment and a.x != none { a.x } else if type(a) == alignment and a.y == none { a } else { fallback }
  if x == start { if text.dir == rtl { right } else { left } }
  else if x == end { if text.dir == rtl { left } else { right } }
  else { x }
}

#let _v-align(a, fallback: horizon) = {
  if type(a) == alignment and a.y != none { a.y } else if type(a) == alignment and a.x == none { a } else { fallback }
}

/// Offset of an object of width `w` aligned inside a slot of width `total`.
#let _align-offset(a, total, w) = {
  if a == left { 0pt } else if a == right { total - w } else { (total - w) / 2 }
}

// ===========================================================================
// 2. Measuring math
// ===========================================================================
//
// Measuring and placing math content with exact ascents and descents.
//
// Inline equations report adjusted edges (they take `text.top-edge` /
// `bottom-edge` into account and subtract a "slack" derived from the
// leading), so we never rely on their natural size. Instead we give the
// equation huge fixed edges on one side and the _ink bounds on the other,
// which yields the exact ascent or descent of the math frame. For placing,
// both edges are huge and fixed, so the baseline is at a known offset.
// All functions here must be called in a context.

#let _BIG = 5000pt

/// The math style a `nicemat` is in, as a level: 0 display, 1 text (an
/// inline equation), 2 script, 3 script-script. `nicemat-setup` marks inline
/// equations with level 1, and the cells of a matrix at level `k ≥ 1` carry
/// the level of their style. The level is stored in the supplement of
/// equations, which is never shown for inline ones.
#let _level-flag(k) = metadata((nicematrix-math-level: k))
#let _inline-flag = _level-flag(1)

/// The level of the current context (0 when not marked). Must be called in
/// a context.
#let _math-level() = {
  let s = math.equation.supplement
  if type(s) == content and s.func() == metadata and type(s.value) == dictionary and "nicematrix-math-level" in s.value {
    s.value.nicematrix-math-level
  } else { 0 }
}

/// `body` in the math style of a level.
#let _style-at(level, body, cramped: true) = {
  if level <= 1 { math.inline(body, cramped: cramped) }
  else if level == 2 { math.script(body, cramped: cramped) }
  else { math.sscript(body, cramped: cramped) }
}

/// The styles of a matrix at `level`: its own (`matrix`) and that of its
/// cells (`cells`: one level smaller, like the cells of `mat`). `flag`:
/// whether the cells must carry their level.
///
/// Note: inside script styles, `text.size` keeps the size of the equation
/// (only `em` is scaled), so explicit styles in new equations are exact.
#let _math-style(level) = {
  let cells = if level == 0 { 1 } else { calc.min(level + 1, 3) }
  (matrix: level, cells: cells, flag: level >= 1)
}

/// The equation used for a cell: text style (like LaTeX's matrices, and like
/// Typst's `mat` in a display equation) or script style with `small`.
/// The text edges are restored inside so that text in cells is unaffected by
/// the edges we set outside.
/// With `style` (from `_math-style`), the cells take the style of the cells
/// of a matrix at that level, and carry that level.
#let _cell-eq(body, small: false, style: none) = {
  let (te, be) = (text.top-edge, text.bottom-edge)
  if style != none {
    return math.equation(block: false, {
      set text(top-edge: te, bottom-edge: be)
      if style.flag {
        set math.equation(supplement: _level-flag(style.cells))
        _style-at(style.cells, body)
      } else {
        _style-at(style.cells, body)
      }
    })
  }
  math.equation(block: false, {
    set text(top-edge: te, bottom-edge: be)
    if small { math.script(body, cramped: true) } else { math.inline(body, cramped: true) }
  })
}

/// An equation with `body` in the style of the matrix itself.
#let _matrix-eq(body, style: none) = {
  if style == none or style.matrix <= 1 { return math.equation(body) }
  math.equation(_style-at(style.matrix, body, cramped: false))
}

/// Plain math equation (no style change) with restored edges.
#let _eq(body) = _cell-eq(body, small: false)

/// Width, ascent and descent of an inline equation (or any inline content).
#let _ink(e) = (
  w: measure(box(e)).width,
  a: measure(box(text(top-edge: "bounds", bottom-edge: -_BIG, e))).height - _BIG,
  d: measure(box(text(top-edge: _BIG, bottom-edge: "bounds", e))).height - _BIG,
)

/// Content to `place` at `dy = baseline - _BIG`: its baseline lands on the
/// requested line.
#let _placeable(e) = box(text(top-edge: _BIG, bottom-edge: -_BIG, e))

/// Font metrics used by the layout.
/// With `style`, the paren strut and the axis of the cells follow the style
/// of the cells, and the axis of the matrix its own style.
#let _math-metrics(small: false, style: none) = {
  let at(level, body) = if style == none {
    math.equation(if level == 2 { math.script(body) } else { body })
  } else {
    math.equation(_style-at(level, body, cramped: false))
  }
  let (lm, lc) = if style == none { (1, if small { 2 } else { 1 }) } else { (style.matrix, style.cells) }
  let paren = _ink(at(lc, [(]))
  // The math axis, exactly as Typst uses it for matrices: a `vec` centres
  // its body on the axis.
  let probe(level) = _ink(at(level, math.vec(delim: none, box(height: 100pt, baseline: 50pt)))).a - 50pt
  (
    paren-a: paren.a,
    paren-d: paren.d,
    axis: probe(lm),
    cell-axis: probe(lc),
    em: 1em.to-absolute(),
  )
}

/// A stretched delimiter (one side) sized like the delimiters of `mat` for a
/// body of height `h`. Returns the equation and its metrics; the glyph is
/// centred on the math axis, so place its baseline at `centre + axis`.
/// Delimiters that `vec` (and `mat`) accept; any other character (an arrow,
/// …) is stretched with `math.stretch`, as nicematrix accepts any extensible
/// delimiter.
#let _vec-delims = (
  "(", ")", "[", "]", "{", "}", "|", "‖", "⟨", "⟩", "⌊", "⌋", "⌈", "⌉", "⟦", "⟧",
  "⟮", "⟯", "⦇", "⦈", "⦃", "⦄", "⟬", "⟭", "⦅", "⦆", "⌜", "⌝", "⌞", "⌟", "⟅", "⟆",
  "/", "\\", "⎰", "⎱", "⟪", "⟫", "⧼", "⧽",
)

#let _delim-glyph(d, h, side: left, fill: auto, tr: none, br: none, style: none) = {
  let v = if str(d) in _vec-delims {
    let pair = if side == left { (d, none) } else { (none, d) }
    // The body box must be at least as tall as the paren strut `vec` pads to.
    math.vec(delim: pair, box(width: 0pt, height: h, baseline: h * 0.25))
  } else {
    // Same target height as `mat`: 110% of the body, centred on the axis.
    math.stretch(symbol(str(d)), size: h * 1.1)
  }
  if tr != none or br != none { v = math.attach(v, tr: tr, br: br) }
  let e = _matrix-eq(v, style: style)
  if fill != auto and fill != none { e = text(fill: fill, e) }
  let m = _ink(e)
  (body: e, w: m.w, a: m.a, d: m.d)
}

// ===========================================================================
// 3. Markers (public: the leaders, cell, diagbox, rules, braces, decorations)
// ===========================================================================
//
// Markers are the small "commands" users put among the cells of a
// `nicemat`: leaders, spanning cells, rules, braces and decorations.
//
// Each marker is a `metadata` element carrying a dictionary with a
// `nicematrix` key naming its kind, followed by a fallback: what the marker
// shows outside a `nicemat` (the dots of a leader, the body of a cell, …).
// Being content, a marker survives inside the cells of a regular `mat` (so
// `show math.mat: nicemat` sees it).

#let _marker(kind, fallback: none, ..fields) = {
  if fields.pos().len() > 0 {
    panic("nicematrix: `" + kind + "` takes named arguments only, got " + repr(fields.pos()))
  }
  let m = metadata((nicematrix: kind, ..fields.named()))
  if fallback == none { m } else { [#m#fallback] }
}

/// Markers covering a rectangle of cells: two corners `from, to`, or whole
/// rows and columns with `row:` / `rows: (first, last)` / `col:` /
/// `cols: (first, last)` (the other direction defaults to the main block).
#let _ranged(kind, args) = {
  let pos = args.pos()
  if pos.len() == 2 { return _marker(kind, from: pos.at(0), to: pos.at(1), ..args.named()) }
  if pos.len() == 0 { return _marker(kind, ..args.named()) }
  panic("nicematrix: `" + kind + "` takes two corners `from, to`, or `row:`, `rows:`, `col:`, `cols:`; got "
    + str(pos.len()) + " positional arguments")
}

// --- Dotted leaders ---------------------------------------------------------

/// Horizontal leader on the baseline (like `\Ldots`, `\Hdotsfor`).
///
/// Named options: `span` (cover several columns, like `\Hdotsfor`),
/// `above`, `below`, `middle` (labels), `fill`, `stroke`, `radius`,
/// `spacing`, `shorten`, `shorten-start`, `shorten-end`, `nullify`,
/// `horizontal-labels`, `marks`.
#let ldots(..args) = _marker("leader", dir: "l", fallback: sym.dots.h, ..args)

/// Horizontal leader on the math axis (like `\Cdots`).
#let cdots(..args) = _marker("leader", dir: "c", fallback: sym.dots.c, ..args)

/// Vertical leader (like `\Vdots`; with `span`, like `\Vdotsfor`).
#let vdots(..args) = _marker("leader", dir: "v", fallback: sym.dots.v, ..args)

/// Diagonal leader going down to the right (like `\Ddots`).
/// `first: #true` makes this the reference for the parallel diagonals.
#let ddots(..args) = _marker("leader", dir: "d", fallback: sym.dots.down, ..args)

/// Diagonal leader going up to the right (like `\Iddots`).
#let iddots(..args) = _marker("leader", dir: "i", fallback: sym.dots.up, ..args)

// --- Cells and rules -------------------------------------------------------

/// A cell with options, possibly spanning several rows and columns (like
/// `\Block`). Covered positions are skipped automatically, as with
/// `table.cell`.
///
/// Options: `rowspan`, `colspan`, `fill`, `stroke`, `radius`, `outset`,
/// `align`, `transparent` (let rules cross the block), `empty` (force the
/// cell to count as empty or not, like `\NotEmpty`).
#let cell(body, ..args) = _marker("cell", fallback: body, body: body, ..args)

/// A horizontal rule. On its own row (`1, 2; hline(); 3, 4`) it separates the
/// neighbouring rows; inside a row it is drawn below that row.
/// Options: `start`, `end` (columns), `stroke`, `y` (explicit position).
#let hline(..args) = _marker("hline", ..args)

/// A vertical rule, drawn after the cell it follows (`1, vline(), 2`).
/// Options: `start`, `end` (rows), `stroke`, `x` (explicit position).
#let vline(..args) = _marker("vline", ..args)

/// A cell slashed diagonally, with `lower` in the bottom-left corner and
/// `upper` in the top-right one (like `\diagbox`). It can also be the body of
/// a spanning `cell`. Option: `stroke`.
#let diagbox(lower, upper, ..args) = _marker("diagbox", fallback: [#lower/#upper], lower: lower, upper: upper, ..args)

// --- Braces ----------------------------------------------------------------

#let _brace(kind, args) = {
  let pos = args.pos()
  let named = args.named()
  let ranged = ("row", "rows", "col", "cols").any(k => k in named)
  if ranged and pos.len() <= 1 {
    _marker("span-brace", dir: kind, label: pos.at(0, default: none), ..named)
  } else if pos.len() == 1 {
    _marker("brace", fallback: pos.at(0), dir: kind, label: pos.at(0), ..named)
  } else if pos.len() == 3 {
    _marker("span-brace", dir: kind, from: pos.at(0), to: pos.at(1), label: pos.at(2), ..named)
  } else if pos.len() == 0 {
    _marker("brace", dir: kind, label: none, ..named)
  } else {
    panic("nicematrix: `" + kind + "brace` takes a label (inside a row), `from, to, label`, or a label with `rows:` / `cols:`")
  }
}

/// A horizontal brace.
///
/// - `hbrace(label, span: n)` inside the first or last (exterior) row spans
///   `n` columns (like `\Hbrace`).
/// - `hbrace(from, to, label, side: top)` anywhere draws a brace above (or
///   below with `side: bottom`) the cells from `from` to `to` (like
///   `\OverBrace` / `\UnderBrace`).
/// - `hbrace(label, cols: (first, last))` (or `col:`, `rows:`, `row:`) does
///   the same for whole columns of the main block.
///
/// Options: `fill`, `shorten`, `shift`.
#let hbrace(..args) = _brace("h", args)

/// A vertical brace; see `hbrace`. The coordinate form takes
/// `side: right` (default) or `side: left`.
#let vbrace(..args) = _brace("v", args)

// --- Decorations -----------------------------------------------------------

/// Delimiters around a part of the matrix (like `\SubMatrix`).
///
/// Options: `delim` (default `"("`), `sup`, `sub`, `hlines`, `vlines`,
/// `stroke`, `slim`, `xshift`, `left-xshift`, `right-xshift`,
/// `extra-height`, `fill`, `reserve` (make room for the delimiters,
/// default true), `bound` (stop leaders at the sub-matrix, default true).
///
/// The rectangle is `from, to`, or whole rows and columns: `row: 1`,
/// `rows: (0, 2)`, `col: 3`, `cols: (1, 2)`.
#let submatrix(..args) = _ranged("submatrix", args)

/// A background shape over a rectangle of cells (like `\rectanglecolor`, or
/// the TikZ "highlight" recipe of nicematrix).
/// Options: `fill`, `stroke`, `radius`, `outset`, `fit` (`"cells"` or
/// `"content"`), `above` (draw over the cells instead of below).
/// The rectangle is `from, to`, or whole rows and columns as for `submatrix`.
#let region(..args) = _ranged("region", args)

/// A leader between two arbitrary cells (like `\line` in `\CodeAfter`).
/// Takes the same options as the leaders, and `bend` (an angle, or a number
/// of degrees): the line leaves and reaches the cells turned by that angle,
/// like TikZ's `bend left` (negative values bend to the right).
#let dotline(from, to, ..args) = _marker("dotline", from: from, to: to, ..args)

/// An arrow between two cells: a `dotline` drawn as a solid line with an
/// arrow head (`marks: "->"`). All options of `dotline` apply; `stroke: auto`
/// gives dots again.
#let connect(from, to, ..args) = _marker("dotline", from: from, to: to, connect: true, ..args)

/// A path along the grid lines (as in pavemat): a string of directions `W`
/// (up), `A` (left), `S` (down), `D` (right); lower-case letters move without
/// drawing; `(key: value, …)` changes the stroke of what follows, up to `]`.
/// Options: `from` (a grid point `(i, j)` counted within the matrix like the
/// rules, or a corner `top + left`, …), `stroke`, `chars` (other letters, e.g.
/// `(up: "U", down: "D", left: "L", right: "R")`).
#let pave(path, ..args) = _marker("pave", path: path, ..args)

/// Fills the cells connected to `from` without crossing a `pave` path (drawn
/// or hidden), like the fills of pavemat. Option: `fill`.
#let flood(from, ..args) = _marker("flood", from: from, ..args)

// --- Detection -------------------------------------------------------------

#let _is-space(c) = type(c) == content and (c.func() == [ ].func() or c == [])

/// The marker dictionary carried by `v`, or `none`.
#let _marker-of(v) = {
  if type(v) == dictionary and "nicematrix" in v { return v }
  if type(v) != content { return none }
  if v.func() == metadata {
    let val = v.value
    if type(val) == dictionary and "nicematrix" in val { return val }
    return none
  }
  if v.has("children") {
    let ch = v.children
    // A marker with its fallback: `[#metadata(..)#fallback]`.
    if ch.len() == 2 and type(ch.at(0)) == content and ch.at(0).func() == metadata {
      let m = _marker-of(ch.at(0))
      if m != none { return m }
    }
    let rest = ch.filter(c => not _is-space(c))
    if rest.len() == 1 { return _marker-of(rest.first()) }
  }
  none
}

#let _dot-chars = ("…": "l", "⋯": "c", "⋮": "v", "⋱": "d", "⋰": "i")
#let _leader-fns = ((ldots, "l"), (cdots, "c"), (vdots, "v"), (ddots, "d"), (iddots, "i"))

/// If `v` is a plain dots symbol (`dots.c`, `...`, `dots.v`, …) or a bare
/// leader function (`cdots` without parentheses), returns the leader
/// direction; otherwise `none`.
#let _auto-leader(v) = {
  if type(v) == function {
    for (f, d) in _leader-fns { if v == f { return d } }
    return none
  }
  if type(v) not in (symbol, str, content) { return none }
  let s = _plain-text(v).trim()
  _dot-chars.at(s, default: none)
}

// ===========================================================================
// 4. Parsing
// ===========================================================================
//
// Turns the arguments of `nicemat` into a grid of cell records.
//
// A record is a dictionary:
// - `i`, `j`: row and column of the top-left position (0-based, as written),
// - `rowspan`, `colspan`,
// - `kind`: `"cell"`, `"leader"`, `"brace"`, `"diagbox"` or `"pad"` (a
//   missing cell),
// - `body`: the content (cells), `label` (braces),
// - `dir`: `"l" | "c" | "v" | "d" | "i"` (leaders), `"h" | "v"` (braces),
// - `opts`: the remaining named options of the marker,
// - `explicit`: whether it came from `cell(..)`.

#let _line-kinds = ("hline", "vline")
#let _deco-kinds = ("submatrix", "region", "dotline", "span-brace", "pave", "flood")

#let _without(d, ..keys) = {
  let d = d
  for k in keys.pos() { if k in d { let _ = d.remove(k) } }
  d
}

/// Splits positional arguments into rows. Math calls with `;` give arrays;
/// a flat list is a single row, like `mat`.
#let _rows-of(pos) = {
  if pos.len() == 0 { return () }
  if not pos.any(p => type(p) == array) { return (pos,) }
  let rows = ()
  for p in pos {
    if type(p) == array { rows.push(p) }
    else if _marker-of(p) != none { rows.push((p,)) }
    else {
      panic("nicematrix: cannot mix rows (arrays) and single cells in the arguments; got " + repr(p))
    }
  }
  rows
}

#let _as-content(v) = {
  if v == none { [] }
  else if type(v) == content { v }
  else if type(v) in (str, symbol, int, float) { [#v] }
  else if type(v) == function { panic("nicematrix: unexpected function in a cell (did you mean to call it?)") }
  else { [#repr(v)] }
}

#let _record(it, m, i, j, auto-dots) = {
  let base = (i: i, j: j, rowspan: 1, colspan: 1, kind: "cell", body: none, dir: none,
              label: none, opts: (:), explicit: false)
  if m == none {
    let d = if auto-dots { _auto-leader(it) } else { none }
    if d != none { return base + (kind: "leader", dir: d, body: _as-content(it)) }
    return base + (body: _as-content(it))
  }
  let kind = m.nicematrix
  if kind == "leader" {
    let span = _to-int(m.at("span", default: 1), name: "span")
    let dir = m.dir
    let rec = base + (kind: "leader", dir: dir, opts: _without(m, "nicematrix", "dir", "span"), span: span,
                      // An explicit `span` (even 1) gives the semantics of `\Hdotsfor`.
                      dotsfor: "span" in m)
    if span > 1 {
      if dir in ("l", "c") { rec.colspan = span }
      else if dir == "v" { rec.rowspan = span }
      else { panic("nicematrix: `span` is not available for diagonal leaders") }
    }
    rec.body = if dir == "l" { $dots.h$ } else if dir == "c" { $dots.c$ } else if dir == "v" { $dots.v$ } else if dir == "d" { $dots.down$ } else { $dots.up$ }
    return rec
  }
  if kind == "diagbox" {
    return base + (kind: "diagbox", body: [], lower: m.lower, upper: m.upper, opts: _without(m, "nicematrix", "lower", "upper"))
  }
  if kind == "cell" {
    let inner = _marker-of(m.body)
    if inner != none and inner.nicematrix == "diagbox" {
      // `cell(diagbox(x, y), rowspan: ..)`: a diagonal box over a block.
      return base + (
        kind: "diagbox", body: [], lower: inner.lower, upper: inner.upper,
        rowspan: _to-int(m.at("rowspan", default: 1), name: "rowspan"),
        colspan: _to-int(m.at("colspan", default: 1), name: "colspan"),
        opts: _without(m, "nicematrix", "body", "rowspan", "colspan") + _without(inner, "nicematrix", "lower", "upper"),
        explicit: true,
      )
    }
    return base + (
      kind: "cell",
      body: _as-content(m.body),
      rowspan: _to-int(m.at("rowspan", default: 1), name: "rowspan"),
      colspan: _to-int(m.at("colspan", default: 1), name: "colspan"),
      opts: _without(m, "nicematrix", "body", "rowspan", "colspan"),
      explicit: true,
    )
  }
  if kind == "brace" {
    let span = _to-int(m.at("span", default: 1), name: "span")
    let rec = base + (kind: "brace", dir: m.dir, label: m.label, opts: _without(m, "nicematrix", "dir", "label", "span"))
    if m.dir == "h" { rec.colspan = span } else { rec.rowspan = span }
    return rec
  }
  // Any other marker used as a cell: treat as normal content.
  base + (body: _as-content(it))
}

/// Parses rows into a grid.
///
/// Returns `(nrows, ncols, cells, own, hlines, vlines, decos)` where `own`
/// is a 2D array giving, for every position, the index of the record that
/// covers it.
#let _parse-body(rows, auto-dots: true) = {
  let cells = ()
  let owner = (:)
  let hlines = ()
  let vlines = ()
  let decos = ()
  let key(i, j) = str(i) + "," + str(j)

  let i = 0
  for row in rows {
    let items = row.map(it => (it, _marker-of(it)))
    let marker-row = row.len() > 0 and items.all(p => (
      p.at(1) != none and p.at(1).nicematrix in _line-kinds + _deco-kinds
    ))
    if marker-row {
      for (it, m) in items {
        if m.nicematrix == "hline" { hlines.push(m + (pos: i)) }
        else if m.nicematrix == "vline" { vlines.push(m + (pos: 0)) }
        else { decos.push(m) }
      }
      continue
    }
    let j = 0
    for (it, m) in items {
      if m != none {
        if m.nicematrix == "hline" { hlines.push(m + (pos: i + 1)); continue }
        if m.nicematrix == "vline" { vlines.push(m + (pos: j)); continue }
        if m.nicematrix in _deco-kinds { decos.push(m); continue }
      }
      while key(i, j) in owner { j += 1 }
      let rec = _record(it, m, i, j, auto-dots)
      if rec.rowspan < 1 or rec.colspan < 1 {
        panic("nicematrix: spans must be at least 1 (cell at " + key(i, j) + ")")
      }
      for di in range(rec.rowspan) {
        for dj in range(rec.colspan) { owner.insert(key(i + di, j + dj), cells.len()) }
      }
      cells.push(rec)
      j += rec.colspan
    }
    i += 1
  }

  let nrows = i
  let ncols = 0
  for c in cells {
    nrows = calc.max(nrows, c.i + c.rowspan)
    ncols = calc.max(ncols, c.j + c.colspan)
  }
  ncols = calc.max(ncols, 1)
  nrows = calc.max(nrows, 1)

  // Pad missing positions with empty cells, like `mat` does for short rows.
  let own = ()
  for i in range(nrows) {
    let r = ()
    for j in range(ncols) {
      let k = key(i, j)
      if k not in owner {
        owner.insert(k, cells.len())
        cells.push((i: i, j: j, rowspan: 1, colspan: 1, kind: "pad", body: [], dir: none,
                    label: none, opts: (:), explicit: false))
      }
      r.push(owner.at(k))
    }
    own.push(r)
  }

  (nrows: nrows, ncols: ncols, cells: cells, own: own, hlines: hlines, vlines: vlines, decos: decos)
}

// ===========================================================================
// 5. Layout
// ===========================================================================
//
// Row and column geometry.
//
// Coordinates are in a local space where `y` grows downwards; the final
// box is shifted so that everything is visible. Every row has a strut box
// (`top`, `base`, `bottom`) at least as tall as a parenthesis, exactly like
// Typst's `mat`, and a "tile" that extends to the middle of the gaps.

/// Vertical layout.
///
/// - `grid`: parse result whose records carry measurements in `m`
///   (`w`, `a`, `d`, `empty`).
/// - `o`: resolved options (`row-gap`, `cell-space`, `margin`, `r0`, `r1`).
#let _layout-rows(grid, mets, o) = {
  let R = grid.nrows
  let asc = (mets.paren-a,) * R
  let desc = (mets.paren-d,) * R
  for c in grid.cells {
    if c.rowspan != 1 { continue }
    let (a, d) = (c.m.a, c.m.d)
    if not c.m.empty {
      a += o.cell-space.top
      d += o.cell-space.bottom
    }
    asc.at(c.i) = calc.max(asc.at(c.i), a)
    desc.at(c.i) = calc.max(desc.at(c.i), d)
  }

  let gaps = range(calc.max(R - 1, 0)).map(k => {
    let g = _abs-len(_pick(o.row-gap, k))
    if k == o.r0 - 1 { g += o.margin.top }
    if k == o.r1 - 1 { g += o.margin.bottom }
    g
  })
  let lead = if o.r0 == 0 { o.margin.top } else { 0pt }

  let place-rows(asc, desc) = {
    let rows = ()
    let y = lead
    for i in range(R) {
      let top = y
      let base = y + asc.at(i)
      let bottom = base + desc.at(i)
      rows.push((top: top, base: base, bottom: bottom))
      y = bottom + if i < R - 1 { gaps.at(i) } else { 0pt }
    }
    rows
  }
  let rows = place-rows(asc, desc)

  // Cells spanning several rows only grow the rows when they do not fit.
  let grew = false
  for c in grid.cells {
    if c.rowspan < 2 { continue }
    let last = c.i + c.rowspan - 1
    let avail = rows.at(last).bottom - rows.at(c.i).top
    let need = c.m.a + c.m.d
    if need > avail {
      desc.at(last) += need - avail
      grew = true
    }
  }
  if grew { rows = place-rows(asc, desc) }

  let main = (
    top: rows.at(o.r0).top - o.margin.top,
    bottom: rows.at(o.r1 - 1).bottom + o.margin.bottom,
  )
  let tiles = range(R).map(i => (
    top: if i == o.r0 { main.top } else if i == 0 { rows.at(0).top } else if i == o.r1 { rows.at(i).top } else {
      (rows.at(i - 1).bottom + rows.at(i).top) / 2
    },
    bottom: if i == o.r1 - 1 { main.bottom } else if i == R - 1 { rows.at(i).bottom } else if i == o.r0 - 1 { rows.at(i).bottom } else {
      (rows.at(i).bottom + rows.at(i + 1).top) / 2
    },
  ))
  (rows: rows, gaps: gaps, tiles: tiles, main: main)
}

/// Horizontal layout.
///
/// Extra options in `o`: `column-gap`, `column-width` (auto, a length or
/// `"equal"`), `group` (array of minimum widths for all columns, or none),
/// `c0`, `c1`, and `need-left` / `need-right`: dictionaries from column index
/// to extra room (for the delimiters of sub-matrices). `delim-w` is the
/// `(left, right)` width of the main delimiters.
#let _layout-cols(grid, o) = {
  let C = grid.ncols
  let (c0, c1) = (o.c0, o.c1)
  let w = (0pt,) * C
  for c in grid.cells {
    if c.colspan == 1 { w.at(c.j) = calc.max(w.at(c.j), c.m.w) }
  }
  let cw = o.column-width
  if type(cw) == length or type(cw) == relative {
    let v = _abs-len(cw)
    for j in range(c0, c1) { w.at(j) = calc.max(w.at(j), v) }
  } else if type(cw) == array {
    // One minimum width per column (as written), like `w{c}{1cm}`.
    for (j, v) in cw.enumerate() {
      if j < C and v != auto and v != none { w.at(j) = calc.max(w.at(j), _abs-len(v)) }
    }
  }
  if o.group != none {
    for (k, v) in o.group.enumerate() {
      if k < C { w.at(k) = calc.max(w.at(k), v) }
    }
  }
  if cw == "equal" {
    let m = calc.max(0pt, ..w.slice(c0, c1))
    for j in range(c0, c1) { w.at(j) = m }
  }

  let need-l(j) = o.need-left.at(str(j), default: 0pt)
  let need-r(j) = o.need-right.at(str(j), default: 0pt)
  let base-gaps = range(calc.max(C - 1, 0)).map(k => _abs-len(_pick(o.column-gap, k)))
  let gaps = range(calc.max(C - 1, 0)).map(k => {
    let g = base-gaps.at(k)
    // Room for sub-matrix delimiters between two main columns.
    if k >= c0 and k + 1 < c1 {
      let extra = need-r(k) + need-l(k + 1)
      if extra > 0pt { g += extra }
    }
    g
  })

  // Columns spanning several columns only widen them when they overflow.
  for c in grid.cells {
    if c.colspan < 2 { continue }
    let js = range(c.j, c.j + c.colspan)
    let avail = js.map(j => w.at(j)).sum() + range(c.j, c.j + c.colspan - 1).map(k => gaps.at(k)).sum(default: 0pt)
    if c.m.w > avail {
      let extra = (c.m.w - avail) / c.colspan
      for j in js { w.at(j) += extra }
    }
  }

  let margin-l = o.margin.left + need-l(c0)
  let margin-r = o.margin.right + need-r(c1 - 1)
  let (dl, dr) = o.delim-w
  let cols = ()
  let x = 0pt
  for j in range(C) {
    if j == c0 { x += dl + margin-l }
    cols.push((left: x, right: x + w.at(j)))
    x += w.at(j)
    if j == c1 - 1 { x += margin-r + dr }
    if j < C - 1 { x += gaps.at(j) }
  }

  let main = (left: cols.at(c0).left - margin-l, right: cols.at(c1 - 1).right + margin-r)
  // Tiles meet in the middle of the ordinary gap: the room reserved for the
  // delimiters of sub-matrices stays on the side of their columns.
  let reserved(j, k) = if j >= c0 and j < c1 and k >= c0 and k < c1 { true } else { false }
  let tiles = range(C).map(j => (
    left: if j == c0 { main.left } else if j == 0 or j == c1 { cols.at(j).left } else {
      let extra = if reserved(j - 1, j) { need-l(j) } else { 0pt }
      cols.at(j).left - extra - base-gaps.at(j - 1) / 2
    },
    right: if j == c1 - 1 { main.right } else if j == C - 1 or j == c0 - 1 { cols.at(j).right } else {
      let extra = if reserved(j, j + 1) { need-r(j) } else { 0pt }
      cols.at(j).right + extra + base-gaps.at(j) / 2
    },
  ))
  (cols: cols, gaps: gaps, tiles: tiles, main: main, width: x)
}

// ===========================================================================
// 6. Drawing
// ===========================================================================
//
// Drawing primitives. They return "items": dictionaries `(x, y, body)`
// where `(x, y)` is where the top-left corner of `body` is placed, together
// with bounds rectangles `(x0, y0, x1, y1)` for the final box size.

#let _len(dx, dy) = calc.sqrt(calc.pow(dx / 1pt, 2) + calc.pow(dy / 1pt, 2)) * 1pt

/// A label set in script style, as a box of exactly its _ink size.
#let _label-box(body, fill: none, inset: 0pt) = {
  let e = _cell-eq(body, small: true)
  let m = _ink(e)
  let b = box(text(top-edge: "bounds", bottom-edge: "bounds", e))
  if fill != none { b = box(fill: fill, inset: inset, b) }
  (body: b, w: m.w + 2 * inset, h: m.a + m.d + 2 * inset)
}

/// Arrow head polygon with its tip at `(x, y)` pointing along `(ux, uy)`.
#let _arrow(x, y, ux, uy, size, paint) = {
  let (len, half) = (size, size * 0.45)
  let bx = x - ux * len
  let by = y - uy * len
  let pts = ((x, y), (bx + uy * half, by - ux * half), (bx - uy * half, by + ux * half))
  let x0 = calc.min(..pts.map(p => p.at(0)))
  let y0 = calc.min(..pts.map(p => p.at(1)))
  let x1 = calc.max(..pts.map(p => p.at(0)))
  let y1 = calc.max(..pts.map(p => p.at(1)))
  (
    item: (x: x0, y: y0, body: polygon(fill: paint, stroke: none, ..pts.map(p => (p.at(0) - x0, p.at(1) - y0)))),
    bound: (x0: x0, y0: y0, x1: x1, y1: y1),
  )
}

// --- Paths: straight lines and bent curves ----------------------------------

#let _lerp(a, b, t) = (a.at(0) + (b.at(0) - a.at(0)) * t, a.at(1) + (b.at(1) - a.at(1)) * t)

/// Blossom of a cubic Bézier curve: `_blossom(p, t, t, t)` is the point at
/// `t`, and the control points of the part between `t0` and `t1` are
/// `(t0, t0, t0)`, `(t0, t0, t1)`, `(t0, t1, t1)`, `(t1, t1, t1)`.
#let _blossom(p, u, v, w) = {
  let l1 = (_lerp(p.at(0), p.at(1), u), _lerp(p.at(1), p.at(2), u), _lerp(p.at(2), p.at(3), u))
  let l2 = (_lerp(l1.at(0), l1.at(1), v), _lerp(l1.at(1), l1.at(2), v))
  _lerp(l2.at(0), l2.at(1), w)
}

#let _samples = 64

/// The path of a leader from `p0` to `p1`: a straight line, or with `bend`
/// a cubic curve leaving `p0` turned by `bend` to the left of the chord and
/// reaching `p1` symmetrically (TikZ's `bend left`, with its control points
/// at 0.39 times the chord).
#let _path(p0, p1, bend) = {
  let (dx, dy) = (p1.at(0) - p0.at(0), p1.at(1) - p0.at(1))
  let l = _len(dx, dy)
  let (ux, uy) = (dx / l, dy / l)
  if bend == 0deg { return (bez: none, p0: p0, u: (ux, uy), length: l) }
  let (nx, ny) = (uy, -ux)
  let (co, si) = (calc.cos(bend), calc.sin(bend))
  let d = 0.3915 * l
  let c0 = (p0.at(0) + (ux * co + nx * si) * d, p0.at(1) + (uy * co + ny * si) * d)
  let c1 = (p1.at(0) + (-ux * co + nx * si) * d, p1.at(1) + (-uy * co + ny * si) * d)
  let bez = (p0, c0, c1, p1)
  // Arc length, sampled.
  let pts = range(_samples + 1).map(k => _blossom(bez, k / _samples, k / _samples, k / _samples))
  let cum = (0pt,)
  for k in range(_samples) {
    let (a, b) = (pts.at(k), pts.at(k + 1))
    cum.push(cum.last() + _len(b.at(0) - a.at(0), b.at(1) - a.at(1)))
  }
  (bez: bez, pts: pts, cum: cum, length: cum.last())
}

/// Curve parameter at arc length `a`.
#let _t-at(path, a) = {
  if a <= 0pt { return 0 }
  if a >= path.length { return 1 }
  let k = path.cum.position(c => c >= a)
  let (c0, c1) = (path.cum.at(k - 1), path.cum.at(k))
  let f = if c1 == c0 { 0 } else { (a - c0) / (c1 - c0) }
  (k - 1 + f) / _samples
}

/// Point at arc length `a`.
#let _point(path, a) = {
  if path.bez == none { return (path.p0.at(0) + path.u.at(0) * a, path.p0.at(1) + path.u.at(1) * a) }
  let t = _t-at(path, a)
  _blossom(path.bez, t, t, t)
}

/// Unit direction of the chord from arc length `a` to arc length `b`.
#let _dir(path, a, b) = {
  if path.bez == none { return path.u }
  let (p, q) = (_point(path, a), _point(path, b))
  let (dx, dy) = (q.at(0) - p.at(0), q.at(1) - p.at(1))
  let l = _len(dx, dy)
  if l == 0pt { path.u } else { (dx / l, dy / l) }
}

/// Draws a leader from `p0` to `p1`.
///
/// `s` is a dictionary with `fill`, `stroke` (`auto` for round dots), `radius`,
/// `spacing`, `shorten-start`, `shorten-end`, `marks`, `above`, `below`,
/// `middle`, `horizontal-labels`, `label-fill` and optionally `bend` (an
/// angle); lengths already absolute. Returns `(items, bounds)`.
#let _leader-items(p0, p1, s) = {
  let items = ()
  let bounds = ()
  let (dx, dy) = (p1.at(0) - p0.at(0), p1.at(1) - p0.at(1))
  let l = _len(dx, dy)
  if l < 1pt or l > 500cm { return (items: (), bounds: ()) }
  let path = _path(p0, p1, s.at("bend", default: 0deg))
  let L = path.length
  let (s0, s1) = (s.shorten-start, s.shorten-end)
  let r = s.radius
  let m = s.marks
  let size = s.at("mark-size", default: 4pt)
  let (head0, head1) = (m in ("<-", "<->"), m in ("->", "<->"))
  // Arrow heads take the colour of the line.
  let paint = if s.stroke == auto { s.fill } else {
    let p = stroke(s.stroke).paint
    if p == auto { s.fill } else { p }
  }

  if s.stroke == auto {
    // Round dots, spaced evenly and centred on the line (nicematrix's
    // "standard" style), at equal distances along a curve.
    let n = calc.floor((L - s0 - s1) / s.spacing)
    if n >= 0 {
      let off = (L - s.spacing * n + s0 - s1) / 2
      for k in range(n + 1) {
        let (cx, cy) = _point(path, off + s.spacing * k)
        items.push((x: cx - r, y: cy - r, body: circle(radius: r, fill: s.fill, stroke: none)))
        bounds.push((x0: cx - r, y0: cy - r, x1: cx + r, y1: cy + r))
      }
    }
  } else {
    // The line stops inside an arrow head, so that its cap does not show.
    let a = s0 + if head0 { size / 2 } else { 0pt }
    let b = L - s1 - if head1 { size / 2 } else { 0pt }
    if b > a {
      let st = s.stroke
      let w = stroke(st).thickness
      let w = if w == auto { 1pt } else { w.to-absolute() }
      if path.bez == none {
        let (ax, ay) = _point(path, a)
        let (bx, by) = _point(path, b)
        items.push((x: ax, y: ay, body: line(start: (0pt, 0pt), end: (bx - ax, by - ay), stroke: st)))
        bounds.push((x0: calc.min(ax, bx), y0: calc.min(ay, by), x1: calc.max(ax, bx), y1: calc.max(ay, by)))
      } else {
        let (ta, tb) = (_t-at(path, a), _t-at(path, b))
        let q = (
          _blossom(path.bez, ta, ta, ta), _blossom(path.bez, ta, ta, tb),
          _blossom(path.bez, ta, tb, tb), _blossom(path.bez, tb, tb, tb),
        )
        let (ox, oy) = q.at(0)
        let rel(p) = (p.at(0) - ox, p.at(1) - oy)
        items.push((x: ox, y: oy, body: curve(stroke: st,
          curve.move(rel(q.at(0))), curve.cubic(rel(q.at(1)), rel(q.at(2)), rel(q.at(3))))))
        let pts = range(17).map(k => _point(path, a + (b - a) * k / 16))
        bounds.push((
          x0: calc.min(..pts.map(p => p.at(0))) - w / 2, y0: calc.min(..pts.map(p => p.at(1))) - w / 2,
          x1: calc.max(..pts.map(p => p.at(0))) + w / 2, y1: calc.max(..pts.map(p => p.at(1))) + w / 2,
        ))
      }
    }
  }

  // Arrow tips, along the last part of the path.
  if head1 {
    let (x, y) = _point(path, L - s1)
    let (ux, uy) = _dir(path, L - s1 - size, L - s1)
    let a = _arrow(x, y, ux, uy, size, paint)
    items.push(a.item); bounds.push(a.bound)
  }
  if head0 {
    let (x, y) = _point(path, s0)
    let (ux, uy) = _dir(path, s0 + size, s0)
    let a = _arrow(x, y, ux, uy, size, paint)
    items.push(a.item); bounds.push(a.bound)
  }

  // Labels: `above`, `below` and `middle` (nicematrix's `^`, `_` and `:`),
  // at the middle of the path.
  let (mx, my) = _point(path, L / 2)
  let (tx, ty) = _dir(path, L / 2 - 0.5pt, L / 2 + 0.5pt)
  let angle = calc.atan2(tx, ty)
  // Keep the text upright.
  if angle > 90deg + 0.1deg or angle < -90deg + 0.1deg { angle += 180deg }
  let (nx, ny) = (ty, -tx)
  if ny > 0 or (ny == 0 and nx < 0) { (nx, ny) = (-nx, -ny) }
  let sep = 0.3em.to-absolute() + r
  for (key, side) in (("above", 1), ("below", -1), ("middle", 0)) {
    let lbl = s.at(key, default: none)
    if lbl == none { continue }
    let lb = if side == 0 {
      _label-box(lbl, fill: s.label-fill, inset: 0.17em.to-absolute())
    } else {
      _label-box(lbl)
    }
    let (w, h) = (lb.w, lb.h)
    let dist = if side == 0 { 0pt } else if s.horizontal-labels {
      calc.abs(nx) * w / 2 + calc.abs(ny) * h / 2 + sep
    } else { h / 2 + sep }
    let (cx, cy) = (mx + nx * dist * side, my + ny * dist * side)
    let body = if s.horizontal-labels or calc.abs(angle) < 0.1deg { lb.body } else {
      rotate(angle, reflow: false, lb.body)
    }
    items.push((x: cx - w / 2, y: cy - h / 2, body: body))
    let ext = if s.horizontal-labels { (w / 2, h / 2) } else { let e = calc.max(w, h) / 2; (e, e) }
    bounds.push((x0: cx - ext.at(0), y0: cy - ext.at(1), x1: cx + ext.at(0), y1: cy + ext.at(1)))
  }
  (items: items, bounds: bounds)
}

// ===========================================================================
// 7. Leaders
// ===========================================================================
//
// Dotted leaders: a port of the algorithm of nicematrix.
//
// From the cell holding a leader, we walk in both directions through empty
// cells until a non-empty cell (a "closed" extremity) or the border of the
// matrix / an already dotted cell (an "open" extremity). Empty cells met on
// the way are marked as dotted, so consecutive leaders give one line.
// Leaders with `span` (like `\Hdotsfor`) only look at their neighbours.

/// Direction steps.
#let _steps = (l: (0, 1), c: (0, 1), v: (1, 0), d: (1, 1), i: (1, -1))

/// Options that `connect` adds to those of `dotline`.
#let _connect-preset = (stroke: (:), marks: "->", shorten: 0.2em)

/// Resolves the drawing style of a leader from the global `dots` options and
/// the options of the marker. `at` is the cell `(i, j)` where the leader
/// starts, given to a `fill` function. Must be called in a context.
#let _leader-style(dots, opts, at: none) = {
  let o = dots + opts
  // `fill: (i, j) => color`, `none` meaning the text colour.
  let fill = if type(o.fill) == function {
    let f = if at == none { auto } else { (o.fill)(..at) }
    if f == none { auto } else { f }
  } else { o.fill }
  let fill = if fill == auto { text.fill } else { fill }
  let label-fill = if o.label-fill == auto {
    if page.fill == auto or page.fill == none { white } else { page.fill }
  } else { o.label-fill }
  let stroke = if o.stroke == auto { auto } else {
    _merge-stroke((paint: fill, thickness: 0.05em.to-absolute(), cap: "round"), o.stroke)
  }
  (
    fill: fill,
    stroke: stroke,
    radius: _abs-len(o.radius),
    spacing: _abs-len(o.spacing),
    shorten: _abs-len(o.shorten),
    shorten-start: if o.shorten-start == auto { auto } else { _abs-len(o.shorten-start) },
    shorten-end: if o.shorten-end == auto { auto } else { _abs-len(o.shorten-end) },
    marks: o.marks,
    mark-size: _abs-len(o.mark-size),
    horizontal-labels: _to-bool(o.horizontal-labels, name: "horizontal-labels"),
    label-fill: label-fill,
    above: o.at("above", default: none),
    below: o.at("below", default: none),
    middle: o.at("middle", default: none),
    explicit-shorten: "shorten" in opts or "shorten-start" in opts or "shorten-end" in opts,
    first: _to-bool(o.at("first", default: false), name: "first"),
  )
}

/// Shortening of the two extremities: global shortening only applies to
/// closed extremities, a shortening given to the leader itself applies to
/// both (as in nicematrix).
#let _shorten(st, open0, open1) = {
  let s0 = if st.shorten-start == auto { st.shorten } else { st.shorten-start }
  let s1 = if st.shorten-end == auto { st.shorten } else { st.shorten-end }
  if not st.explicit-shorten {
    if open0 { s0 = 0pt }
    if open1 { s1 = 0pt }
  }
  st + (shorten-start: s0, shorten-end: s1)
}

/// Computes all leaders.
///
/// - `g`: the grid with positioned records (`box`, `base`),
/// - `geo`: `(rows, cols, R, C, r0, r1, c0, c1)`,
/// - `bounds-of`: function `(i, j) => (rmin, rmax, cmin, cmax)` giving the
///   region in which the leader starting at `(i, j)` may extend,
/// - `dots`: global leader options, `mets`: font metrics.
///
/// Returns `(items, bounds, blocks, lines)`; `blocks` are rectangles of
/// cells `(i0, j0, i1, j1)` in which rules must not be drawn, `lines` the raw
/// geometry for tests.
#let _resolve-leaders(g, geo, bounds-of, dots, mets) = {
  let (R, C) = (geo.R, geo.C)
  let rows = geo.rows
  let cols = geo.cols
  let at(i, j) = g.cells.at(g.own.at(i).at(j))
  // Cells that stop a leader: non-empty contents (a block counts as a whole).
  let full(i, j) = {
    let c = at(i, j)
    c.kind in ("brace", "diagbox") or (c.kind == "cell" and not c.m.empty)
  }
  let dotted = range(R).map(_ => (false,) * C)

  // Open extremities use the extreme _ink of the whole row / column.
  let col-cells(j) = range(R).filter(i => full(i, j) and at(i, j).colspan == 1).map(i => at(i, j))
  let row-cells(i) = range(C).filter(j => full(i, j) and at(i, j).rowspan == 1).map(j => at(i, j))
  let open-x0(j) = { let cs = col-cells(j); if cs.len() == 0 { cols.at(j).left } else { calc.min(..cs.map(c => c.box.x0)) } }
  let open-x1(j) = { let cs = col-cells(j); if cs.len() == 0 { cols.at(j).right } else { calc.max(..cs.map(c => c.box.x1)) } }
  let open-y0(i) = { let cs = row-cells(i); if cs.len() == 0 { rows.at(i).top } else { calc.min(..cs.map(c => c.box.y0)) } }
  let open-y1(i) = { let cs = row-cells(i); if cs.len() == 0 { rows.at(i).bottom } else { calc.max(..cs.map(c => c.box.y1)) } }
  let cx(c) = (c.box.x0 + c.box.x1) / 2

  // Order: spans first, then V, D, Id, C, L (as nicematrix); within a kind,
  // leaders marked `first` come first, then reading order.
  let leaders = g.cells.filter(c => c.kind == "leader")
  let order = ()
  for kind in ("span", "v", "d", "i", "c", "l") {
    let is-for(c) = c.rowspan > 1 or c.colspan > 1 or c.at("dotsfor", default: false)
    let ls = leaders.filter(c => if kind == "span" { is-for(c) } else { c.dir == kind and not is-for(c) })
    let firsts = ls.filter(c => _to-bool(c.opts.at("first", default: false), name: "first"))
    order += firsts + ls.filter(c => not _to-bool(c.opts.at("first", default: false), name: "first"))
  }

  let items = ()
  let bnds = ()
  let blocks = ()
  let lines = ()
  let slopes = (d: none, i: none)

  for L in order {
    if dotted.at(L.i).at(L.j) { continue }
    let (di, dj) = _steps.at(L.dir)
    let (rmin, rmax, cmin, cmax) = bounds-of(L.i, L.j)
    let inside(i, j) = i >= rmin and i <= rmax and j >= cmin and j <= cmax
    let (ini, fin) = ((L.i, L.j), (L.i + L.rowspan - 1, L.j + L.colspan - 1))
    let (open0, open1) = (true, true)

    for ii in range(L.i, L.i + L.rowspan) {
      for jj in range(L.j, L.j + L.colspan) { dotted.at(ii).at(jj) = true }
    }

    if L.rowspan > 1 or L.colspan > 1 or L.at("dotsfor", default: false) {
      // `\Hdotsfor` / `\Vdotsfor`: only the immediate neighbours matter.
      let (a, b) = ((ini.at(0) - di, ini.at(1) - dj), (fin.at(0) + di, fin.at(1) + dj))
      if inside(..a) and full(..a) { ini = a; open0 = false }
      if inside(..b) and full(..b) { fin = b; open1 = false }
    } else {
      // Walk backwards, then forwards.
      for (sign, which) in ((-1, 0), (1, 1)) {
        let (i, j) = if which == 0 { ini } else { fin }
        let open = true
        while true {
          let (ni, nj) = (i + sign * di, j + sign * dj)
          if not inside(ni, nj) or dotted.at(ni).at(nj) { break }
          if full(ni, nj) { (i, j) = (ni, nj); open = false; break }
          dotted.at(ni).at(nj) = true
          (i, j) = (ni, nj)
        }
        if which == 0 { ini = (i, j); open0 = open } else { fin = (i, j); open1 = open }
      }
    }

    let (ci, cf) = (at(..ini), at(..fin))
    let (p0, p1) = (none, none)
    if L.dir == "l" or L.dir == "c" {
      let y-of(c) = if L.dir == "l" { c.base } else { c.base - mets.cell-axis }
      let x0 = if open0 { open-x0(ini.at(1)) } else { ci.box.x1 }
      let x1 = if open1 { open-x1(fin.at(1)) } else { cf.box.x0 }
      let row-y = if L.dir == "l" { rows.at(L.i).base } else { rows.at(L.i).base - mets.cell-axis }
      let y0 = if open0 { if open1 { row-y } else { y-of(cf) } } else { y-of(ci) }
      let y1 = if open1 { if open0 { row-y } else { y-of(ci) } } else { y-of(cf) }
      if L.dir == "l" {
        let r = _abs-len((dots + L.opts).radius)
        (y0, y1) = (y0 - r, y1 - r)
      }
      (p0, p1) = ((x0, y0), (x1, y1))
    } else if L.dir == "v" {
      let (x, y0, y1) = (none, none, none)
      if open0 and open1 {
        y0 = open-y0(ini.at(0))
        y1 = open-y1(fin.at(0))
        x = (cols.at(L.j).left + cols.at(L.j).right) / 2
      } else if open0 {
        y0 = open-y0(ini.at(0))
        y1 = cf.box.y0
        x = cx(cf)
      } else {
        y0 = ci.box.y1
        x = cx(ci)
        if open1 { y1 = open-y1(fin.at(0)) } else {
          y1 = cf.box.y0
          let xf = cx(cf)
          if xf != x {
            // Left-aligned column: keep the leftmost position, else the rightmost.
            x = if ci.box.x0 == cf.box.x0 { calc.min(x, xf) } else { calc.max(x, xf) }
          }
        }
      }
      (p0, p1) = ((x, y0), (x, y1))
    } else if L.dir == "d" {
      p0 = if open0 { (open-x0(ini.at(1)), open-y0(ini.at(0))) } else { (ci.box.x1, ci.box.y1) }
      p1 = if open1 { (open-x1(fin.at(1)), open-y1(fin.at(0))) } else { (cf.box.x0, cf.box.y0) }
    } else {
      // Iddots: `ini` is the upper-right extremity, `fin` the lower-left one.
      p0 = if open0 { (open-x1(ini.at(1)), open-y0(ini.at(0))) } else { (ci.box.x0, ci.box.y1) }
      p1 = if open1 { (open-x0(fin.at(1)), open-y1(fin.at(0))) } else { (cf.box.x1, cf.box.y0) }
    }

    let st = _leader-style(dots, L.opts, at: (L.i, L.j))
    // Diagonals are drawn parallel to the first one.
    if L.dir in ("d", "i") and _to-bool(dots.parallel, name: "parallel") and L.rowspan == 1 {
      let (dx, dy) = (p1.at(0) - p0.at(0), p1.at(1) - p0.at(1))
      if slopes.at(L.dir) == none {
        if dx != 0pt { slopes.insert(L.dir, dy / dx) }
      } else {
        p1 = (p1.at(0), p0.at(1) + dx * slopes.at(L.dir))
      }
    }

    let r = _leader-items(p0, p1, _shorten(st, open0, open1))
    items += r.items
    bnds += r.bounds
    blocks.push((
      i0: calc.min(ini.at(0), fin.at(0)), j0: calc.min(ini.at(1), fin.at(1)),
      i1: calc.max(ini.at(0), fin.at(0)), j1: calc.max(ini.at(1), fin.at(1)),
    ))
    lines.push((dir: L.dir, from: ini, to: fin, open: (open0, open1), p0: p0, p1: p1))
  }
  (items: items, bounds: bnds, blocks: blocks, lines: lines)
}

/// A leader between two arbitrary cells (the `dotline` decoration): from the
/// centre of each content, a ray (turned by `bend` to the left of the way
/// from `a` to `b`, symmetrically at `b`) clipped by the content.
#let _dotline-points(a, b, bend: 0deg) = {
  let ca = ((a.box.x0 + a.box.x1) / 2, (a.box.y0 + a.box.y1) / 2)
  let cb = ((b.box.x0 + b.box.x1) / 2, (b.box.y0 + b.box.y1) / 2)
  let (dx, dy) = (cb.at(0) - ca.at(0), cb.at(1) - ca.at(1))
  let l = calc.sqrt(calc.pow(dx / 1pt, 2) + calc.pow(dy / 1pt, 2)) * 1pt
  if l == 0pt { return (ca, cb) }
  let (ux, uy) = (dx / l, dy / l)
  // The left of the direction of travel, on the page (y grows downwards).
  let (nx, ny) = (uy, -ux)
  let (co, si) = (calc.cos(bend), calc.sin(bend))
  let out = (ux * co + nx * si, uy * co + ny * si)
  let inn = (-ux * co + nx * si, -uy * co + ny * si)
  let exit(c, v) = {
    let (hw, hh) = ((c.box.x1 - c.box.x0) / 2, (c.box.y1 - c.box.y0) / 2)
    let tx = if calc.abs(v.at(0)) < 1e-9 { 1e9 * 1pt } else { hw / calc.abs(v.at(0)) }
    let ty = if calc.abs(v.at(1)) < 1e-9 { 1e9 * 1pt } else { hh / calc.abs(v.at(1)) }
    calc.min(tx, ty)
  }
  let (ta, tb) = (exit(a, out), exit(b, inn))
  (
    (ca.at(0) + out.at(0) * ta, ca.at(1) + out.at(1) * ta),
    (cb.at(0) + inn.at(0) * tb, cb.at(1) + inn.at(1) * tb),
  )
}

// ===========================================================================
// 8. Rules and corners
// ===========================================================================
//
// Rules (`hlines`, `vlines`, `augment`, `hline()`, `vline()`) and the empty
// corners.
//
// A rule is cut into one segment per cell boundary; a segment is skipped
// inside blocks (spanning cells, leaders), in empty corners and in the
// exterior rows and columns, then consecutive segments are merged.

/// Indices of the lines requested by a `hlines` / `vlines` style option.
/// `n` is the number of rows (or columns), `(m0, m1)` the range of lines
/// for `true` and `borders` whether the outer lines are included.
#let _line-indices(spec, n, m0, m1, borders) = {
  if spec == none or spec == false { return () }
  if spec == true {
    let ks = range(m0 + 1, m1)
    if borders { ks = (m0,) + ks + (m1,) }
    return ks
  }
  _to-int-list(spec, name: "lines").map(k => _norm-index(k, n))
}

/// Cells belonging to the empty corners. Returns a 2D array of booleans.
///
/// `spec` is `true` (the four corners) or an alignment or an array of
/// alignments: `top + left` … and `top`, `bottom`, `left`, `right` for the
/// generalized corners of nicematrix 7.10 (N, S, W, E).
#let _corner-cells(spec, R, C, r0, r1, c0, c1, empty) = {
  let res = range(R).map(_ => (false,) * C)
  if spec == none or spec == false { return res }
  let specs = if spec == true { (top + left, top + right, bottom + left, bottom + right) } else if type(spec) == array { spec } else { (spec,) }
  let rows-td(dir) = if dir == top { range(r0, r1) } else { range(r0, r1).rev() }
  let cols-lr(dir) = if dir == left { range(c0, c1) } else { range(c0, c1).rev() }
  for s in specs {
    let (vy, hx) = (s.y, s.x)
    if vy != none and hx != none {
      // A diagonal corner: union of the empty rectangles at that corner.
      let lim = c1 - c0
      for i in rows-td(vy) {
        let run = 0
        for j in cols-lr(hx) { if empty(i, j) { run += 1 } else { break } }
        lim = calc.min(lim, run)
        if lim == 0 { break }
        for (k, j) in cols-lr(hx).enumerate() { if k < lim { res.at(i).at(j) = true } }
      }
    } else if vy != none {
      for j in range(c0, c1) {
        for i in rows-td(vy) { if empty(i, j) { res.at(i).at(j) = true } else { break } }
      }
    } else if hx != none {
      for i in range(r0, r1) {
        for j in cols-lr(hx) { if empty(i, j) { res.at(i).at(j) = true } else { break } }
      }
    }
  }
  res
}

/// Computes rule items.
///
/// `specs`: array of `(dir: "h" | "v", k, start, end, stroke, marker: bool)`
/// where `k` is the line index (a line `k` separates rows/columns `k - 1`
/// and `k`) and `[start, end)` the range of columns/rows it covers.
/// `ctx`: `(R, C, r0, r1, c0, c1, own, cells, blocks, corner, rows, cols,
/// rtiles, ctiles, main, sep)`.
#let _rule-items(specs, ctx) = {
  let items = ()
  // Lines requested through markers replace the option lines at the same
  // position (so that `hlines: true` plus two `hline()` gives a double rule).
  let with-marker = specs.filter(s => s.marker).map(s => s.dir + str(s.k))
  let specs = specs.filter(s => s.marker or (s.dir + str(s.k)) not in with-marker)

  let blocked(dir, k, t, leaders: true) = {
    // (a, b): the cells on both _sides of the boundary at position t.
    let (a, b) = if dir == "h" { ((k - 1, t), (k, t)) } else { ((t, k - 1), (t, k)) }
    let (lo, hi) = if dir == "h" { (ctx.r0, ctx.r1) } else { (ctx.c0, ctx.c1) }
    let (t-min, t-max) = if dir == "h" { (ctx.c0, ctx.c1) } else { (ctx.r0, ctx.r1) }
    if t < t-min or t >= t-max or k < lo or k > hi { return true }
    let a-in = k - 1 >= lo
    let b-in = k < hi
    let own(p) = ctx.own.at(p.at(0)).at(p.at(1))
    if a-in and b-in {
      let (ca, cb) = (own(a), own(b))
      if ca == cb and not ctx.cells.at(ca).opts.at("transparent", default: false) { return true }
      for blk in if leaders { ctx.blocks } else { () } {
        let inb(p) = blk.i0 <= p.at(0) and p.at(0) <= blk.i1 and blk.j0 <= p.at(1) and p.at(1) <= blk.j1
        if inb(a) and inb(b) { return true }
      }
    }
    let corner(p) = ctx.corner.at(p.at(0)).at(p.at(1))
    let _sides = ()
    if a-in { _sides.push(corner(a)) }
    if b-in { _sides.push(corner(b)) }
    _sides.len() > 0 and _sides.all(x => x)
  }

  let pos-of(dir, k) = {
    if dir == "h" {
      if k <= ctx.r0 { ctx.main.top } else if k >= ctx.r1 { ctx.main.bottom } else {
        (ctx.rows.at(k - 1).bottom + ctx.rows.at(k).top) / 2
      }
    } else {
      if k <= ctx.c0 { ctx.main.left } else if k >= ctx.c1 { ctx.main.right } else {
        ctx.ctiles.at(k).left
      }
    }
  }

  // Rank of each spec among the overlapping specs of the same line, for
  // double rules.
  let overlap(a, b) = a.dir == b.dir and a.k == b.k and a.start < b.end and b.start < a.end
  for (idx, s) in specs.enumerate() {
    if s.stroke == none { continue }
    let rank = specs.slice(0, idx).filter(o => overlap(o, s)).len()
    let n = specs.filter(o => overlap(o, s)).len()
    let th = _stroke-thickness(s.stroke)
    let offset = (rank - (n - 1) / 2) * (th + ctx.sep)
    let base = pos-of(s.dir, s.k) + offset

    // Runs of drawable segments.
    let runs = ()
    let cur = none
    for t in range(s.start, s.end) {
      // `augment` lines come from `mat` and ignore the leaders.
      if blocked(s.dir, s.k, t, leaders: not s.at("augment", default: false)) {
        if cur != none { runs.push(cur); cur = none }
      } else {
        cur = if cur == none { (t, t) } else { (cur.at(0), t) }
      }
    }
    if cur != none { runs.push(cur) }

    for (t0, t1) in runs {
      if s.dir == "h" {
        let (x0, x1) = (ctx.ctiles.at(t0).left, ctx.ctiles.at(t1).right)
        items.push((x: x0, y: base, body: line(start: (0pt, 0pt), end: (x1 - x0, 0pt), stroke: s.stroke)))
      } else {
        let (y0, y1) = (ctx.rtiles.at(t0).top, ctx.rtiles.at(t1).bottom)
        items.push((x: base, y: y0, body: line(start: (0pt, 0pt), end: (0pt, y1 - y0), stroke: s.stroke)))
      }
    }
  }
  items
}

// ===========================================================================
// 9. Decorations
// ===========================================================================
//
// Decorations drawn over (or under) the laid-out matrix: sub-matrix
// delimiters, braces, regions and free leaders. All functions must be
// called in a context.

/// Rows (or columns) given by `row: k` or `rows: (first, last)`, else
/// `(lo, hi)`.
#let _span(d, one, many, lo, hi) = {
  if one in d {
    let k = _to-int(d.at(one), name: one)
    return (k, k)
  }
  if many in d {
    let l = _to-int-list(d.at(many), name: many)
    if l.len() == 1 { return (l.at(0), l.at(0)) }
    if l.len() != 2 { panic("nicematrix: `" + many + "` needs `(first, last)`, got " + repr(d.at(many))) }
    return (l.at(0), l.at(1))
  }
  (lo, hi)
}

/// Reads the rectangle of a decoration and orders it: two corners `from`
/// and `to`, or `row` / `rows` / `col` / `cols` (the other direction being
/// the main block `main = (r0, r1, c0, c1)`, whole grid by default).
#let _deco-range(d, R, C, main: none) = {
  let (r0, r1, c0, c1) = if main == none { (0, R, 0, C) } else { main }
  let (i0, j0, i1, j1) = (none, none, none, none)
  let shown = none
  if d.at("from", default: none) != none {
    (i0, j0) = _to-coord(d.from, name: "from")
    (i1, j1) = _to-coord(d.to, name: "to")
    shown = "(" + str(i0) + ", " + str(j0) + ") to (" + str(i1) + ", " + str(j1) + ")"
  } else {
    (i0, i1) = _span(d, "row", "rows", r0, r1 - 1)
    (j0, j1) = _span(d, "col", "cols", c0, c1 - 1)
    shown = "rows " + str(i0) + "–" + str(i1) + ", columns " + str(j0) + "–" + str(j1)
  }
  let (i0, i1) = (_norm-index(i0, R), _norm-index(i1, R))
  let (j0, j1) = (_norm-index(j0, C), _norm-index(j1, C))
  let (i0, i1) = (calc.min(i0, i1), calc.max(i0, i1))
  let (j0, j1) = (calc.min(j0, j1), calc.max(j0, j1))
  if i0 < 0 or j0 < 0 or i1 >= R or j1 >= C {
    let kind = if d.nicematrix == "span-brace" { d.dir + "brace" } else { d.nicematrix }
    panic("nicematrix: `" + kind + "` " + shown + " is outside the " + str(R) + "×" + str(C)
      + " grid (rows and columns count from 0, as written)")
  }
  (i0: i0, j0: j0, i1: i1, j1: j1)
}

// --- Sub-matrices -----------------------------------------------------------

/// Prepares the sub-matrices once the rows are laid out: their delimiters
/// (whose width depends only on their height) and the room they need.
#let _prepare-submatrices(decos, R, C, rows, main: none) = {
  let subs = ()
  let need-left = (:)
  let need-right = (:)
  for d in decos.filter(d => d.nicematrix == "submatrix") {
    let r = _deco-range(d, R, C, main: main)
    let extra = _abs-len(d.at("extra-height", default: 0pt))
    let (top, bottom) = (rows.at(r.i0).top - extra / 2, rows.at(r.i1).bottom + extra / 2)
    let (lp, rp) = _delim-pair(d.at("delim", default: "("))
    let f = d.at("fill", default: auto)
    let xs = _abs-len(d.at("xshift", default: 0pt))
    let lxs = _abs-len(d.at("left-xshift", default: xs))
    let rxs = _abs-len(d.at("right-xshift", default: xs))
    // Unlike those of the whole matrix (which follow `mat`), the delimiters of
    // a sub-matrix are as tall as its rows, as in nicematrix: stacked
    // sub-matrices must not overlap.
    let h = (bottom - top) / 1.1
    let lg = if lp == none { none } else { _delim-glyph(lp, h, side: left, fill: f) }
    let rg = if rp == none { none } else {
      // `sup` / `sub` are attached to the right delimiter, like `\SubMatrix(..)^{T}`.
      _delim-glyph(rp, h, side: right, fill: f, tr: d.at("sup", default: none), br: d.at("sub", default: none))
    }
    let reserve = _to-bool(d.at("reserve", default: true), name: "reserve")
    if reserve {
      let wl = if lg == none { 0pt } else { lg.w } + calc.max(lxs, 0pt)
      let wr = if rg == none { 0pt } else { rg.w } + calc.max(rxs, 0pt)
      need-left.insert(str(r.j0), calc.max(need-left.at(str(r.j0), default: 0pt), wl))
      need-right.insert(str(r.j1), calc.max(need-right.at(str(r.j1), default: 0pt), wr))
    }
    subs.push(r + (
      spec: d, top: top, bottom: bottom, lg: lg, rg: rg, lxs: lxs, rxs: rxs,
      bound: _to-bool(d.at("bound", default: true), name: "bound"),
      slim: _to-bool(d.at("slim", default: false), name: "slim"),
    ))
  }
  (subs: subs, need-left: need-left, need-right: need-right)
}

/// Items of the sub-matrix delimiters. `x-extent(j, i0, i1)` gives the
/// horizontal _ink extent of column `j` (restricted to rows `i0..i1` when
/// not `none`).
#let _submatrix-items(subs, x-extent, axis) = {
  let items = ()
  let bounds = ()
  for s in subs {
    let cy = (s.top + s.bottom) / 2
    let base = cy + axis
    let rows = if s.slim { (s.i0, s.i1) } else { none }
    if s.lg != none {
      let x = x-extent(s.j0, rows).at(0) - s.lxs - s.lg.w
      items.push((x: x, y: base - _BIG, body: _placeable(s.lg.body)))
      bounds.push((x0: x, x1: x + s.lg.w, y0: base - s.lg.a, y1: base + s.lg.d))
    }
    if s.rg != none {
      let x = x-extent(s.j1, rows).at(1) + s.rxs
      items.push((x: x, y: base - _BIG, body: _placeable(s.rg.body)))
      bounds.push((x0: x, x1: x + s.rg.w, y0: base - s.rg.a, y1: base + s.rg.d))
    }
  }
  (items: items, bounds: bounds)
}

/// Rule specifications of the `hlines` / `vlines` options of sub-matrices
/// (line numbers relative to the sub-matrix).
#let _submatrix-rules(subs, default-stroke) = {
  let specs = ()
  for s in subs {
    let st = _merge-stroke(default-stroke, s.spec.at("stroke", default: auto))
    for (key, dir) in (("hlines", "h"), ("vlines", "v")) {
      let v = s.spec.at(key, default: none)
      let (n, k0) = if dir == "h" { (s.i1 - s.i0 + 1, s.i0) } else { (s.j1 - s.j0 + 1, s.j0) }
      let (t0, t1) = if dir == "h" { (s.j0, s.j1 + 1) } else { (s.i0, s.i1 + 1) }
      let ks = if v == none or v == false { () } else if v == true { range(1, n) } else {
        _to-int-list(v, name: key).map(k => _norm-index(k, n))
      }
      for k in ks { specs.push((dir: dir, k: k0 + k, start: t0, end: t1, stroke: st, marker: true)) }
    }
  }
  specs
}

// --- Braces ------------------------------------------------------------------

/// A horizontal brace of width `w` with its label; `over` puts the brace
/// above the baseline (label on top), otherwise below.
#let _hbrace-eq(w, label, over: true, fill: auto) = {
  let b = box(width: w, height: 0pt)
  let e = math.equation(if over { math.overbrace(b, label) } else { math.underbrace(b, label) })
  if fill != auto and fill != none { e = text(fill: fill, e) }
  let m = _ink(e)
  (body: e, w: m.w, a: m.a, d: m.d)
}

/// A vertical brace of height about `h` with its label; `right` puts the
/// brace on the right of the object (it opens to the left, label after).
/// Returns the pieces and the total width.
#let _vbrace-eq(h, label, right: true, fill: auto) = {
  let h = calc.max(h, 1pt)
  let g = _delim-glyph(if right { "}" } else { "{" }, h / 1.1, side: if right { right } else { left }, fill: fill)
  let lb = if label == none { none } else {
    let e = _cell-eq(label, small: true)
    if fill != auto and fill != none { e = text(fill: fill, e) }
    let m = _ink(e)
    (body: e, w: m.w, a: m.a, d: m.d)
  }
  let sep = 0.2em.to-absolute()
  let w = g.w + if lb == none { 0pt } else { sep + lb.w }
  (glyph: g, label: lb, sep: sep, w: w)
}

/// Items for a vertical brace placed with its glyph between `y0` and `y1`,
/// starting at `x` (the side facing the matrix).
#let _vbrace-items(vb, x, y0, y1, right: true, axis: 0pt) = {
  let items = ()
  let bounds = ()
  let cy = (y0 + y1) / 2
  let g = vb.glyph
  let gx = if right { x } else { x - g.w }
  items.push((x: gx, y: cy + axis - _BIG, body: _placeable(g.body)))
  bounds.push((x0: gx, x1: gx + g.w, y0: cy + axis - g.a, y1: cy + axis + g.d))
  if vb.label != none {
    let lb = vb.label
    let lx = if right { x + g.w + vb.sep } else { x - g.w - vb.sep - lb.w }
    let base = cy + (lb.a - lb.d) / 2
    items.push((x: lx, y: base - _BIG, body: _placeable(lb.body)))
    bounds.push((x0: lx, x1: lx + lb.w, y0: base - lb.a, y1: base + lb.d))
  }
  (items: items, bounds: bounds)
}

/// Items for a horizontal brace from `x0` to `x1`, its box on the line `y`.
#let _hbrace-items(x0, x1, y, label, over: true, fill: auto) = {
  let hb = _hbrace-eq(x1 - x0, label, over: over, fill: fill)
  (
    items: ((x: x0, y: y - _BIG, body: _placeable(hb.body)),),
    bounds: ((x0: x0, x1: x0 + hb.w, y0: y - hb.a, y1: y + hb.d),),
  )
}

// --- Regions -----------------------------------------------------------------

/// Items of a `region` decoration: `rect` is the rectangle to cover.
#let _region-item(d, r, default-stroke) = {
  let o = _sides(d.at("outset", default: 0pt))
  let (o-l, o-r, o-t, o-b) = (_abs-len(o.left), _abs-len(o.right), _abs-len(o.top), _abs-len(o.bottom))
  let body = rect(
    width: r.x1 - r.x0 + o-l + o-r,
    height: r.y1 - r.y0 + o-t + o-b,
    fill: d.at("fill", default: none),
    stroke: {
      let s = d.at("stroke", default: none)
      if s == none { none } else { _side-stroke(default-stroke, s) }
    },
    radius: d.at("radius", default: 0pt),
    inset: 0pt,
  )
  (x: r.x0 - o-l, y: r.y0 - o-t, body: body)
}

// ===========================================================================
// 10. Paths and flood fills (adapted from pavemat)
// ===========================================================================
//
// Paths along the grid lines and flood fills, in the style of the pavemat
// package.
//
// A path is a string of directions starting from a grid point: `W` (up),
// `A` (left), `S` (down), `D` (right). An upper-case letter draws the
// segment, a lower-case one only moves (the segment still separates the
// regions of `flood`). A group `(paint: red, thickness: 2pt)` changes the
// stroke of the following segments, up to the matching `]`.
//
// Grid points and lines are numbered within the main block, like the rules:
// the point `(i, j)` is at the crossing of the rule `i` (above the row `i`)
// and of the rule `j` (left of the column `j`).

#let _default-chars = (up: "W", down: "S", left: "A", right: "D")

/// The segments of a `pave` marker: `(dir: "h" | "v", k, t, stroke, hidden)`.
/// A segment `h` lies on the rule `k` between the column rules `t` and `t + 1`;
/// a segment `v` on the column rule `k` between the rules `t` and `t + 1`.
/// `nR` and `nC` are the numbers of rows and columns of the main block.
#let _pave-segments(p, nR, nC, base-stroke) = {
  let chars = _default-chars + p.at("chars", default: (:))
  let dirs = (:)
  for (name, ch) in chars { dirs.insert(upper(str(ch)), name) }
  let path = if type(p.path) == str { p.path } else { _plain-text(p.path) }
  let path = path.replace("'", "\"")

  let from = p.at("from", default: top + left)
  let (i, j) = if type(from) == alignment {
    (if from.y == bottom { nR } else { 0 }, if from.x == right { nC } else { 0 })
  } else {
    let (a, b) = _to-coord(from, name: "from")
    (_norm-index(a, nR + 1), _norm-index(b, nC + 1))
  }

  let stack = (_merge-stroke(base-stroke, p.at("stroke", default: auto)),)
  let segs = ()
  let cs = path.clusters()
  let k = 0
  while k < cs.len() {
    let c = cs.at(k)
    if c == "(" {
      let close = cs.slice(k).position(x => x == ")")
      if close == none { panic("nicematrix: unclosed `(` in the path " + repr(path)) }
      let spec = eval(cs.slice(k, k + close + 1).join())
      stack.push(_merge-stroke(stack.last(), spec))
      k += close + 1
      continue
    }
    if c == "[" or c.trim() == "" { k += 1; continue }
    if c == "]" {
      if stack.len() > 1 { let _ = stack.pop() }
      k += 1
      continue
    }
    let name = dirs.at(upper(c), default: none)
    if name == none { panic("nicematrix: unknown direction " + repr(c) + " in the path " + repr(path)) }
    let hidden = c != upper(c)
    let st = stack.last()
    let (ni, nj) = if name == "up" { (i - 1, j) } else if name == "down" { (i + 1, j) }
      else if name == "left" { (i, j - 1) } else { (i, j + 1) }
    let seg = if name == "right" { (dir: "h", k: i, t: j) }
      else if name == "left" { (dir: "h", k: i, t: j - 1) }
      else if name == "down" { (dir: "v", k: j, t: i) }
      else { (dir: "v", k: j, t: i - 1) }
    let inside = if seg.dir == "h" { seg.k >= 0 and seg.k <= nR and seg.t >= 0 and seg.t < nC }
      else { seg.k >= 0 and seg.k <= nC and seg.t >= 0 and seg.t < nR }
    if inside { segs.push(seg + (stroke: st, hidden: hidden)) }
    (i, j) = (ni, nj)
    k += 1
  }
  segs
}

/// Merges consecutive collinear segments with the same style, so that dash
/// patterns run continuously along a straight part of a path.
#let _merge-segments(segs) = {
  let out = ()
  for s in segs {
    let s = s + (t0: s.t, t1: s.t)
    if out.len() > 0 {
      let l = out.last()
      let same-line = l.dir == s.dir and l.k == s.k and l.stroke == s.stroke and l.hidden == s.hidden
      if same-line and (s.t == l.t1 + 1 or s.t == l.t0 - 1) {
        out.at(-1) = l + (t0: calc.min(l.t0, s.t), t1: calc.max(l.t1, s.t))
        continue
      }
    }
    out.push(s)
  }
  out
}

/// The cells (main-based `(i, j)`) connected to `start` without crossing a
/// segment of a path (drawn or hidden).
#let _flood-cells(start, nR, nC, segs) = {
  let fence = (:)
  for s in segs { fence.insert(s.dir + str(s.k) + "," + str(s.t), true) }
  let blocked(dir, k, t) = (dir + str(k) + "," + str(t)) in fence
  let seen = (:)
  let key(i, j) = str(i) + "," + str(j)
  let stack = (start,)
  seen.insert(key(..start), true)
  let cells = ()
  while stack.len() > 0 {
    let (i, j) = stack.pop()
    cells.push((i, j))
    let moves = (
      ((i + 1, j), blocked("h", i + 1, j)),
      ((i - 1, j), blocked("h", i, j)),
      ((i, j + 1), blocked("v", j + 1, i)),
      ((i, j - 1), blocked("v", j, i)),
    )
    for ((ni, nj), b) in moves {
      if b or ni < 0 or nj < 0 or ni >= nR or nj >= nC or key(ni, nj) in seen { continue }
      seen.insert(key(ni, nj), true)
      stack.push((ni, nj))
    }
  }
  cells
}

// ===========================================================================
// 11. Groups (public: nicemat-group)
// ===========================================================================
//
// Groups of matrices sharing their column widths, like nicematrix's
// `{NiceMatrixBlock}` with `auto-columns-width`.
//
// Each `nicemat` inside a group publishes the natural widths of its columns
// and delimiters in a `metadata`; all members then use the maxima (Typst's
// introspection converges in two layout iterations).

#let _group-state = state("nicematrix-group", none)
#let _group-counter = counter("nicematrix-group")

/// Makes all the `nicemat` inside `body` use the same column widths, so that
/// stacked matrices have their columns aligned.
#let nicemat-group(body) = {
  _group-counter.step()
  context {
    let id = _group-counter.get().first()
    _group-state.update(id)
    body
    _group-state.update(none)
  }
}

/// The widths shared by the group `id`: `(cols: array, delims: (l, r))`, or
/// `none` when no matrix of the group has been laid out yet.
#let _group-widths(id) = {
  let ms = query(<nicematrix-group>).filter(m => m.value.group == id).map(m => m.value)
  if ms.len() == 0 { return none }
  let n = calc.max(..ms.map(m => m.cols.len()))
  (
    cols: range(n).map(k => calc.max(0pt, ..ms.map(m => m.cols.at(k, default: 0pt)))),
    delims: (calc.max(..ms.map(m => m.delims.at(0))), calc.max(..ms.map(m => m.delims.at(1)))),
  )
}

// ===========================================================================
// 12. nicemat (public: nicemat, nicearray)
// ===========================================================================
//
// The `nicemat` function: argument resolution and the rendering pipeline
// (parse → measure → layout → leaders → rules → decorations → box).

#let _dots-defaults = (
  symbols: true,
  nullify: false,
  fill: auto,
  stroke: auto,
  radius: 0.53pt,
  spacing: 0.45em,
  shorten: 0.3em,
  shorten-start: auto,
  shorten-end: auto,
  parallel: true,
  horizontal-labels: false,
  marks: none,
  mark-size: 4pt,
  label-fill: auto,
)

/// Whether content is "empty" in the sense of nicematrix: nothing, spaces, or
/// only horizontal/vertical spacing (the analogue of `\Hspace`).
#let _content-empty(b) = {
  if b == none or b == [] { return true }
  let f = b.func()
  if f == [ ].func() or f == h or f == v { return true }
  if f == metadata { return true }
  if b.has("children") { return b.children.all(_content-empty) }
  false
}

/// The lines of a cell body written with `\` (one line: `none`).
#let _split-lines(b) = {
  if type(b) != content or not b.has("children") { return none }
  if not b.children.any(c => c.func() == linebreak) { return none }
  let lines = ((),)
  for c in b.children {
    if c.func() == linebreak { lines.push(()) } else { lines.at(-1).push(c) }
  }
  lines.map(l => if l.len() == 0 { [] } else { l.join() })
}

/// Measures a record in the math style `st` (from `_math-style`). `lines`
/// holds what multi-line cells need: the horizontal alignment of each cell
/// and the gap between lines.
#let _measure-record(c, st, dots, lines) = {
  if c.kind == "cell" and "lines" in c {
    // Lines stacked like the rows of `mat` (a `vec` without delimiters,
    // whose cells keep the style of the cell), centred on the math axis.
    let ha = (lines.align)(c)
    let stack = math.vec(delim: none, align: ha, gap: lines.gap, ..c.lines.map(l => _style-at(st.cells, l)))
    let e = _cell-eq(stack, style: st)
    let m = _ink(e)
    let forced = c.opts.at("empty", default: auto)
    let empty = if forced != auto { _to-bool(forced, name: "empty") } else { c.lines.all(_content-empty) or m.w == 0pt }
    return c + (eq: e, m: m + (empty: empty))
  }
  if c.kind == "cell" or c.kind == "pad" {
    let e = _cell-eq(c.body, style: st)
    let m = _ink(e)
    let forced = c.opts.at("empty", default: auto)
    let empty = if forced != auto { _to-bool(forced, name: "empty") } else { _content-empty(c.body) or m.w == 0pt }
    return c + (eq: e, m: m + (empty: empty))
  }
  if c.kind == "leader" {
    let nullify = _to-bool(c.opts.at("nullify", default: dots.nullify), name: "nullify")
    let spanned = c.rowspan > 1 or c.colspan > 1 or c.at("dotsfor", default: false)
    let m = if nullify or spanned { (w: 0pt, a: 0pt, d: 0pt) } else { _ink(_cell-eq(c.body, style: st)) }
    return c + (eq: none, m: m + (empty: true))
  }
  if c.kind == "diagbox" {
    // Room for the two labels on both _sides of the diagonal.
    let (lo, up) = (_cell-eq(c.lower, style: st), _cell-eq(c.upper, style: st))
    let (ml, mu) = (_ink(lo), _ink(up))
    let m = (w: ml.w + mu.w, a: mu.a + mu.d + ml.a, d: ml.d, empty: false)
    return c + (eq: none, lower-eq: lo, upper-eq: up, ml: ml, mu: mu, m: m)
  }
  // Braces are measured once the layout of the rest is known.
  c + (eq: none, m: (w: 0pt, a: 0pt, d: 0pt, empty: true))
}

/// Resolves a gap option: explicit value, then the value of a `mat` passed
/// in, then the `math.mat` set rules. Must be called in a context.
#let _gap(explicit, gap, from-mat, key) = {
  if explicit != auto { return explicit }
  if gap != auto { return gap }
  if key in from-mat { return from-mat.at(key) }
  if "gap" in from-mat { return from-mat.gap }
  if key == "row-gap" { math.mat.row-gap } else { math.mat.column-gap }
}

/// Scales a gap specification (single value or array).
#let _scale(spec, f) = if type(spec) == array { spec.map(x => x * f) } else { spec * f }

/// A matrix with the features of LaTeX's nicematrix.
///
/// Use it like `mat`: `$ nicemat(1, dots.c, 1; dots.v, dots.down, dots.v; 1, dots.c, 1) $`.
/// Dots symbols become dotted leaders that stretch between cells. See the
/// README for all options and markers.
#let nicemat(
  ..body,
  delim: auto,
  delim-fill: auto,
  align: auto,
  gap: auto,
  row-gap: auto,
  column-gap: auto,
  augment: none,
  hlines: none,
  vlines: none,
  hvlines: false,
  borders: auto,
  stroke: auto,
  fill: none,
  corners: none,
  first-row: false,
  last-row: false,
  first-col: false,
  last-col: false,
  map-cells: none,
  cell-space: 0pt,
  margin: auto,
  column-width: auto,
  baseline: horizon,
  small: auto,
  dots: (:),
  background: none,
  foreground: none,
  name: none,
  debug: false,
) = {
  if body.named().len() > 0 {
    panic("nicematrix: unknown argument(s) " + body.named().keys().map(k => "`" + k + "`").join(", "))
  }
  let pos = body.pos()
  // A `mat` element (from `show math.mat: nicemat`) provides the rows and
  // its own settings.
  let from-mat = (:)
  if pos.len() == 1 and type(pos.at(0)) == content and pos.at(0).func() == math.mat {
    let m = pos.at(0)
    pos = m.rows
    for k in ("delim", "align", "augment", "gap", "row-gap", "column-gap") {
      if m.has(k) { from-mat.insert(k, m.at(k)) }
    }
  }
  let first-row = _to-bool(first-row, name: "first-row")
  let last-row = _to-bool(last-row, name: "last-row")
  let first-col = _to-bool(first-col, name: "first-col")
  let last-col = _to-bool(last-col, name: "last-col")
  let small-opt = if small == auto { auto } else { _to-bool(small, name: "small") }
  // `debug`: `true` (cells and rules), `"cells"`, `"rules"` or `false`.
  let debug = {
    let s = if type(debug) == bool { if debug { "all" } else { "none" } } else { _plain-text(debug).trim() }
    if s == "true" { "all" } else if s == "false" { "none" } else if s in ("all", "none", "cells", "rules") { s } else {
      panic("nicematrix: `debug` must be `true`, `false`, `\"cells\"` or `\"rules\"`, got " + repr(debug))
    }
  }
  let name = if name == none { none } else if type(name) == str { name } else { _plain-text(name).trim() }
  if _to-bool(hvlines, name: "hvlines") {
    if hlines == none { hlines = true }
    if vlines == none { vlines = true }
  }
  let borders = if borders == auto { auto } else { _to-bool(borders, name: "borders") }
  if type(dots) != dictionary { panic("nicematrix: `dots` must be a dictionary of options") }
  for k in dots.keys() {
    if k not in _dots-defaults { panic("nicematrix: unknown `dots` option `" + k + "`") }
  }
  let user-dots = dots
  let augment = if augment == none { from-mat.at("augment", default: none) } else { augment }

  context {
    let delim = if delim != auto { delim } else { from-mat.at("delim", default: math.mat.delim) }
    let align = if align != auto { align } else { from-mat.at("align", default: math.mat.align) }
    let row-gap = _gap(row-gap, gap, from-mat, "row-gap")
    let column-gap = _gap(column-gap, gap, from-mat, "column-gap")
    // `small: auto`: script-size cells in inline equations (under
    // `nicemat-setup`), exactly like `mat` there; `small: true` is the
    // `small` of nicematrix, which also tightens the gaps.
    // The math style: that of the equation (level 0 in display equations,
    // 1 in inline ones under `nicemat-setup`, more when nested), or forced.
    let level = _math-level()
    let (st, scale-gaps) = if small-opt == auto { (_math-style(level), false) } else if small-opt {
      ((matrix: 1, cells: 2, flag: level >= 1), true)
    } else { (_math-style(0), false) }
    let small = st.cells >= 2
    if scale-gaps and row-gap == math.mat.row-gap { row-gap = _scale(row-gap, 0.7) }
    if scale-gaps and column-gap == math.mat.column-gap { column-gap = _scale(column-gap, 0.7) }
    // Smaller dots in small cells, unless given.
    let dots = _dots-defaults + user-dots
    if small {
      for k in ("radius", "spacing", "shorten") {
        if k not in user-dots { dots.insert(k, _dots-defaults.at(k) * 0.7) }
      }
    }

    let mets = _math-metrics(style: st)
    let default-stroke = _merge-stroke((paint: text.fill, thickness: 0.05em.to-absolute(), cap: "square"), stroke)
    let grid = _parse-body(_rows-of(pos), auto-dots: _to-bool(dots.symbols, name: "dots.symbols"))
    let (R, C) = (grid.nrows, grid.ncols)
    let r0 = if first-row { 1 } else { 0 }
    let r1 = if last-row { R - 1 } else { R }
    let c0 = if first-col { 1 } else { 0 }
    let c1 = if last-col { C - 1 } else { C }
    if r0 >= r1 or c0 >= c1 {
      panic("nicematrix: the exterior rows/columns leave no room for the matrix itself")
    }

    // Cells written on several lines with `\`.
    grid.cells = grid.cells.map(c => {
      let ls = if c.kind == "cell" { _split-lines(c.body) } else { none }
      if ls == none { c } else { c + (lines: ls) }
    })
    // Transform cell contents (code-for-first-row, RowStyle, …), line by line.
    if map-cells != none {
      grid.cells = grid.cells.map(c => {
        if c.kind != "cell" { c }
        else if "lines" in c { c + (lines: c.lines.map(l => map-cells(c.i, c.j, l))) }
        else { c + (body: map-cells(c.i, c.j, c.body)) }
      })
    }

    // --- Horizontal alignment of every cell.
    let align-at(i, j) = {
      if type(align) == function { _h-align(align(i, j)) }
      else if first-col and j == 0 { right }
      else if last-col and j == C - 1 { left }
      else if type(align) == array { _h-align(_pick(align, j)) }
      else { _h-align(align) }
    }
    let cell-align(c) = {
      let al = c.opts.at("align", default: auto)
      if al != auto { _h-align(al) } else if c.colspan > 1 { center } else { align-at(c.i, c.j) }
    }
    let line-opts = (align: cell-align, gap: _pick(row-gap, 0))
    grid.cells = grid.cells.map(c => _measure-record(c, st, dots, line-opts))

    let (lpair, rpair) = _delim-pair(delim)
    let has-delim = lpair != none or rpair != none
    let cs = _sides(cell-space)
    let cell-space = (top: _abs-len(cs.top), bottom: _abs-len(cs.bottom))
    let margin = if margin == auto {
      // Borders and fills need some room around the cells; so do the paths
      // and floods of pavemat, which always pads its grid.
      let pavemat-like = grid.decos.any(d => d.nicematrix in ("pave", "flood"))
      let pad = pavemat-like or (not has-delim and (fill != none or hlines == true or vlines == true))
      let (gx, gy) = (_abs-len(_pick(column-gap, 0)) / 2, _abs-len(_pick(row-gap, 0)) / 2)
      if pad { (left: gx, right: gx, top: gy, bottom: gy) } else { _sides(0pt) }
    } else {
      let s = _sides(margin)
      (left: _abs-len(s.left), right: _abs-len(s.right), top: _abs-len(s.top), bottom: _abs-len(s.bottom))
    }

    // --- Vertical layout, then the delimiters (their width depends only on
    // the height), then the horizontal layout.
    // Horizontal braces in rows: their height counts for the row (brace above
    // the matrix in the rows before the last exterior row, below in it).
    grid.cells = grid.cells.map(c => {
      if c.kind != "brace" or c.dir != "h" { return c }
      let over = c.i < r1
      let hb = _hbrace-eq(2em.to-absolute(), c.label, over: over, fill: c.opts.at("fill", default: auto))
      c + (over: over, m: (w: 0pt, a: if over { hb.a } else { 0pt }, d: if over { 0pt } else { hb.d }, empty: false))
    })

    let ly = _layout-rows(grid, mets, (row-gap: row-gap, cell-space: cell-space, margin: margin, r0: r0, r1: r1))
    let H = ly.main.bottom - ly.main.top
    let lglyph = if lpair != none { _delim-glyph(lpair, H, side: left, fill: delim-fill, style: st) } else { none }
    let rglyph = if rpair != none { _delim-glyph(rpair, H, side: right, fill: delim-fill, style: st) } else { none }
    let prep = _prepare-submatrices(grid.decos, R, C, ly.rows, main: (r0, r1, c0, c1))
    // Vertical braces in columns: their width counts for the column.
    grid.cells = grid.cells.map(c => {
      if c.kind != "brace" or c.dir != "v" { return c }
      let right = c.j >= c0
      let h = ly.rows.at(c.i + c.rowspan - 1).bottom - ly.rows.at(c.i).top
      let vb = _vbrace-eq(h, c.label, right: right, fill: c.opts.at("fill", default: auto))
      c + (right: right, m: (w: vb.w, a: 0pt, d: 0pt, empty: false))
    })
    let col-opts = (
      column-gap: column-gap,
      column-width: column-width,
      group: none,
      c0: c0,
      c1: c1,
      need-left: prep.need-left,
      need-right: prep.need-right,
      margin: margin,
      delim-w: (if lglyph != none { lglyph.w } else { 0pt }, if rglyph != none { rglyph.w } else { 0pt }),
    )
    let lx = _layout-cols(grid, col-opts)
    // Inside a `nicemat-group`: publish the natural widths, use the maxima.
    let gid = _group-state.get()
    let group-meta = none
    if gid != none {
      let natural = lx.cols.map(c => c.right - c.left)
      group-meta = metadata((group: gid, cols: natural, delims: col-opts.delim-w))
      let shared = _group-widths(gid)
      if shared != none {
        col-opts.group = shared.cols
        col-opts.delim-w = (calc.max(col-opts.delim-w.at(0), shared.delims.at(0)), calc.max(col-opts.delim-w.at(1), shared.delims.at(1)))
        lx = _layout-cols(grid, col-opts)
      }
    }
    let rows = ly.rows
    let cols = lx.cols
    let main = ly.main + lx.main

    // --- Position of every record: slot, content box and baseline.
    grid.cells = grid.cells.map(c => {
      let (i, j) = (c.i, c.j)
      let (i2, j2) = (i + c.rowspan - 1, j + c.colspan - 1)
      let slot = (x0: cols.at(j).left, x1: cols.at(j2).right, y0: rows.at(i).top, y1: rows.at(i2).bottom)
      let al = c.opts.at("align", default: auto)
      let ha = cell-align(c)
      let va = if al != auto { _v-align(al, fallback: none) } else { none }
      let x = slot.x0 + _align-offset(ha, slot.x1 - slot.x0, c.m.w)
      let base = if c.rowspan == 1 and va == none { rows.at(i).base } else {
        let va = if va == none { horizon } else { va }
        if va == top { slot.y0 + c.m.a }
        else if va == bottom { slot.y1 - c.m.d }
        else { (slot.y0 + slot.y1) / 2 + (c.m.a - c.m.d) / 2 }
      }
      c + (x: x, base: base, slot: slot, box: (x0: x, x1: x + c.m.w, y0: base - c.m.a, y1: base + c.m.d))
    })

    // --- Baseline of the whole matrix.
    let y-base = if baseline == horizon or baseline == auto {
      (main.top + main.bottom) / 2 + mets.axis
    } else if baseline == top {
      rows.at(r0).base
    } else if baseline == bottom {
      rows.at(r1 - 1).base
    } else if type(baseline) == dictionary and "line" in baseline {
      // Align a rule on the math axis (nicematrix's `baseline=line-i`); the
      // rule is counted within the main block, like `hlines`.
      let k = r0 + _norm-index(_to-int(baseline.line, name: "baseline"), r1 - r0)
      let y = if k <= r0 { main.top } else if k >= r1 { main.bottom } else {
        (rows.at(k - 1).bottom + rows.at(k).top) / 2
      }
      y + mets.axis
    } else {
      rows.at(_norm-index(_to-int(baseline, name: "baseline"), R)).base
    }

    // --- Items to place, by layer: (x, y, body) with (x, y) the top-left
    // corner of the placed content; and bounds rectangles for the box size.
    let layers = (under: (), rules: (), cells: (), over: ())
    let bounds = ((x0: 0pt, x1: lx.width, y0: calc.min(main.top, rows.at(0).top), y1: calc.max(main.bottom, rows.at(R - 1).bottom)),)
    let place-eq(e, x, base) = (x: x, y: base - _BIG, body: _placeable(e))

    // Delimiters of the main block.
    let dy = (main.top + main.bottom) / 2 + mets.axis
    if lglyph != none {
      let x = main.left - lglyph.w
      layers.over.push(place-eq(lglyph.body, x, dy))
      bounds.push((x0: x, x1: main.left, y0: dy - lglyph.a, y1: dy + lglyph.d))
    }
    if rglyph != none {
      layers.over.push(place-eq(rglyph.body, main.right, dy))
      bounds.push((x0: main.right, x1: main.right + rglyph.w, y0: dy - rglyph.a, y1: dy + rglyph.d))
    }

    // Cell contents.
    for c in grid.cells {
      if c.kind == "cell" {
        layers.cells.push(place-eq(c.eq, c.x, c.base))
        bounds.push(c.box)
      }
    }

    // Diagonal boxes: the diagonal of the tile and the two labels.
    for c in grid.cells.filter(c => c.kind == "diagbox") {
      let (j2, i2) = (c.j + c.colspan - 1, c.i + c.rowspan - 1)
      let t = (x0: lx.tiles.at(c.j).left, x1: lx.tiles.at(j2).right, y0: ly.tiles.at(c.i).top, y1: ly.tiles.at(i2).bottom)
      let st = _merge-stroke(default-stroke, c.opts.at("stroke", default: auto))
      layers.rules.push((x: t.x0, y: t.y0, body: line(start: (0pt, 0pt), end: (t.x1 - t.x0, t.y1 - t.y0), stroke: st)))
      let pad = 0.1em.to-absolute()
      layers.cells.push(place-eq(c.lower-eq, t.x0 + pad, t.y1 - pad - c.ml.d))
      layers.cells.push(place-eq(c.upper-eq, t.x1 - pad - c.mu.w, t.y0 + pad + c.mu.a))
    }

    // --- Dotted leaders.
    let bound-subs = prep.subs.filter(s => s.bound)
    let bounds-of(i, j) = {
      let (rmin, rmax) = if i < r0 or i >= r1 { (i, i) } else { (r0, r1 - 1) }
      let (cmin, cmax) = if j < c0 or j >= c1 { (j, j) } else { (c0, c1 - 1) }
      for s in bound-subs {
        if s.i0 <= i and i <= s.i1 and s.j0 <= j and j <= s.j1 {
          (rmin, rmax) = (calc.max(rmin, s.i0), calc.min(rmax, s.i1))
          (cmin, cmax) = (calc.max(cmin, s.j0), calc.min(cmax, s.j1))
        }
      }
      (rmin, rmax, cmin, cmax)
    }
    let geo = (R: R, C: C, r0: r0, r1: r1, c0: c0, c1: c1, rows: rows, cols: cols)
    let lead = _resolve-leaders(grid, geo, bounds-of, dots, mets)
    layers.over += lead.items
    bounds += lead.bounds

    // --- Empty corners, fills and block decorations.
    let cell-at(i, j) = grid.cells.at(grid.own.at(i).at(j))
    let corner = _corner-cells(corners, R, C, r0, r1, c0, c1, (i, j) => {
      let c = cell-at(i, j)
      c.kind in ("cell", "pad") and c.m.empty and c.rowspan == 1 and c.colspan == 1
    })
    let ctiles = lx.tiles
    let rtiles = ly.tiles
    let tile(i0, j0, i1, j1) = (x0: ctiles.at(j0).left, x1: ctiles.at(j1).right, y0: rtiles.at(i0).top, y1: rtiles.at(i1).bottom)
    let rect-item(r, fill: none, stroke: none, radius: 0pt, outset: 0pt) = {
      let o = _sides(outset)
      let (o-l, o-r, o-t, o-b) = (_abs-len(o.left), _abs-len(o.right), _abs-len(o.top), _abs-len(o.bottom))
      (x: r.x0 - o-l, y: r.y0 - o-t, body: rect(width: r.x1 - r.x0 + o-l + o-r, height: r.y1 - r.y0 + o-t + o-b,
        fill: fill, stroke: stroke, radius: radius, inset: 0pt))
    }

    // `fill`: a color, an array (cycled over the columns) or a function
    // `(i, j) => color`, for the cells of the main block outside the corners.
    let fill-at(i, j) = {
      if fill == none or corner.at(i).at(j) { none }
      else if type(fill) == function { fill(i, j) }
      else if type(fill) == array { fill.at(calc.rem(j - c0, fill.len())) }
      else { fill }
    }
    let block-fill(c) = c.opts.at("fill", default: none)
    if fill != none {
      // Runs of equal fills in each row, merged with identical runs below, to
      // avoid hairline seams between tiles.
      let runs = ()
      for i in range(r0, r1) {
        let j = c0
        while j < c1 {
          let c = cell-at(i, j)
          let f = if c.explicit and block-fill(c) != none { none } else { fill-at(i, j) }
          let j2 = j
          while j2 + 1 < c1 {
            let c2 = cell-at(i, j2 + 1)
            let f2 = if c2.explicit and block-fill(c2) != none { none } else { fill-at(i, j2 + 1) }
            if f2 == f { j2 += 1 } else { break }
          }
          if f != none { runs.push((i0: i, i1: i, j0: j, j1: j2, f: f)) }
          j = j2 + 1
        }
      }
      let merged = ()
      for r in runs {
        let k = merged.position(m => m.i1 == r.i0 - 1 and m.j0 == r.j0 and m.j1 == r.j1 and m.f == r.f)
        if k == none { merged.push(r) } else { merged.at(k).i1 = r.i1 }
      }
      for r in merged { layers.under.push(rect-item(tile(r.i0, r.j0, r.i1, r.j1), fill: r.f)) }
    }

    // Blocks: `cell(fill:, stroke:, radius:, outset:)`.
    for c in grid.cells {
      if not c.explicit { continue }
      let (f, st) = (block-fill(c), c.opts.at("stroke", default: none))
      if f == none and st == none { continue }
      let t = tile(c.i, c.j, c.i + c.rowspan - 1, c.j + c.colspan - 1)
      let radius = c.opts.at("radius", default: 0pt)
      let outset = c.opts.at("outset", default: 0pt)
      if f != none { layers.under.push(rect-item(t, fill: f, radius: radius, outset: outset)) }
      if st != none {
        layers.rules.push(rect-item(t, stroke: _side-stroke(default-stroke, st), radius: radius, outset: outset))
      }
    }

    // --- Rules.
    let specs = ()
    // Rules only live in the main block, so their positions count within it,
    // exactly like the `augment` of `mat`: line 0 is the top (left) border
    // and negative numbers count from the end.
    let opt-lines(dir, spec, st) = {
      let (m0, m1) = if dir == "h" { (r0, r1) } else { (c0, c1) }
      let (t0, t1) = if dir == "h" { (c0, c1) } else { (r0, r1) }
      let outer = if borders == auto { not has-delim } else { borders }
      _line-indices(spec, m1 - m0, 0, m1 - m0, outer).map(k => (dir: dir, k: m0 + k, start: t0, end: t1, stroke: st, marker: false))
    }
    specs += opt-lines("h", hlines, default-stroke)
    specs += opt-lines("v", vlines, default-stroke)
    if augment != none {
      let aug = if type(augment) == dictionary { augment } else { (vline: augment) }
      let ast = _merge-stroke(default-stroke, aug.at("stroke", default: auto))
      for (key, dir) in (("hline", "h"), ("vline", "v")) {
        let v = aug.at(key, default: none)
        if v == none { continue }
        // Like `mat`, augmentation lines count within the main block.
        let (n, m0) = if dir == "h" { (r1 - r0, r0) } else { (c1 - c0, c0) }
        let (t0, t1) = if dir == "h" { (c0, c1) } else { (r0, r1) }
        for k in _to-int-list(v, name: "augment") {
          specs.push((dir: dir, k: m0 + _norm-index(k, n), start: t0, end: t1, stroke: ast, marker: false, augment: true))
        }
      }
    }
    // Markers: their position comes from where they are written, or from
    // `y` / `x`; `start` and `end` are columns (rows) of the main block.
    let main-index(v, m0, n, name) = m0 + _norm-index(_to-int(v, name: name), n)
    for m in grid.hlines {
      let k = if "y" in m { main-index(m.y, r0, r1 - r0, "y") } else { m.pos }
      let st = _merge-stroke(default-stroke, m.at("stroke", default: auto))
      let start = if m.at("start", default: none) == none { c0 } else { main-index(m.start, c0, c1 - c0, "start") }
      let end = if m.at("end", default: none) == none { c1 } else { main-index(m.end, c0, c1 - c0, "end") }
      specs.push((dir: "h", k: k, start: start, end: end, stroke: st, marker: true))
    }
    for m in grid.vlines {
      let k = if "x" in m { main-index(m.x, c0, c1 - c0, "x") } else { m.pos }
      let st = _merge-stroke(default-stroke, m.at("stroke", default: auto))
      let start = if m.at("start", default: none) == none { r0 } else { main-index(m.start, r0, r1 - r0, "start") }
      let end = if m.at("end", default: none) == none { r1 } else { main-index(m.end, r0, r1 - r0, "end") }
      specs.push((dir: "v", k: k, start: start, end: end, stroke: st, marker: true))
    }
    specs += _submatrix-rules(prep.subs, default-stroke)
    let rule-ctx = (
      R: R, C: C, r0: r0, r1: r1, c0: c0, c1: c1, own: grid.own, cells: grid.cells,
      blocks: lead.blocks, corner: corner, rows: rows, cols: cols, rtiles: rtiles, ctiles: ctiles,
      main: main, sep: 0.18em.to-absolute(),
    )
    layers.rules += _rule-items(specs, rule-ctx)

    // --- Decorations.
    let full(c) = c.kind == "brace" or (c.kind == "cell" and not c.m.empty)
    // Horizontal _ink extent of column j (over the rows `rr` or all rows).
    let x-extent(j, rr) = {
      let ris = if rr == none { range(R) } else { range(rr.at(0), rr.at(1) + 1) }
      let cs = ris.map(i => cell-at(i, j)).filter(c => full(c) and c.colspan == 1 and c.kind == "cell")
      if cs.len() == 0 { (cols.at(j).left, cols.at(j).right) } else {
        (calc.min(..cs.map(c => c.box.x0)), calc.max(..cs.map(c => c.box.x1)))
      }
    }
    // Vertical _ink extent of row i (over the columns `cc` or the main ones).
    let y-extent(i, cc) = {
      let js = if cc == none { range(c0, c1) } else { range(cc.at(0), cc.at(1) + 1) }
      let cs = js.map(j => cell-at(i, j)).filter(c => full(c) and c.rowspan == 1 and c.kind == "cell")
      if cs.len() == 0 { (rows.at(i).top, rows.at(i).bottom) } else {
        (calc.min(..cs.map(c => c.box.y0)), calc.max(..cs.map(c => c.box.y1)))
      }
    }

    let sm = _submatrix-items(prep.subs, x-extent, mets.axis)
    layers.over += sm.items
    bounds += sm.bounds

    // Braces written in the rows and columns (`\Hbrace`, `\Vbrace`).
    for c in grid.cells.filter(c => c.kind == "brace") {
      let fill = c.opts.at("fill", default: auto)
      let shift = _abs-len(c.opts.at("shift", default: 0pt))
      if c.dir == "h" {
        let main-rows = (r0, r1 - 1)
        let x0 = x-extent(c.j, main-rows).at(0)
        let x1 = x-extent(c.j + c.colspan - 1, main-rows).at(1)
        let y = if c.over { rows.at(c.i).bottom - shift } else { rows.at(c.i).top + shift }
        let r = _hbrace-items(x0, x1, y, c.label, over: c.over, fill: fill)
        layers.over += r.items
        bounds += r.bounds
      } else {
        let main-cols = (c0, c1 - 1)
        let y0 = y-extent(c.i, main-cols).at(0)
        let y1 = y-extent(c.i + c.rowspan - 1, main-cols).at(1)
        let x = if c.right { cols.at(c.j).left + shift } else { cols.at(c.j).right - shift }
        let vb = _vbrace-eq(y1 - y0, c.label, right: c.right, fill: fill)
        let r = _vbrace-items(vb, x, y0, y1, right: c.right, axis: mets.axis)
        layers.over += r.items
        bounds += r.bounds
      }
    }

    // Paths along the grid lines (pavemat): all of them bound the floods.
    let (nR, nC) = (r1 - r0, c1 - c0)
    let paths = grid.decos.filter(d => d.nicematrix == "pave").map(d => _pave-segments(d, nR, nC, default-stroke))
    let all-segs = paths.flatten()
    // Positions of the rules, counted within the main block.
    let rule-y(k) = if k <= 0 { main.top } else if k >= nR { main.bottom } else { rtiles.at(r0 + k).top }
    let rule-x(k) = if k <= 0 { main.left } else if k >= nC { main.right } else { ctiles.at(c0 + k).left }
    let path-index = 0

    for d in grid.decos {
      let kind = d.nicematrix
      if kind == "pave" {
        for s in _merge-segments(paths.at(path-index)) {
          if s.hidden and debug == "none" { continue }
          let st = if s.hidden { (paint: gray, thickness: 0.5pt, dash: "dotted") } else { s.stroke }
          if s.dir == "h" {
            let (x0, x1, y) = (rule-x(s.t0), rule-x(s.t1 + 1), rule-y(s.k))
            layers.rules.push((x: x0, y: y, body: line(start: (0pt, 0pt), end: (x1 - x0, 0pt), stroke: st)))
          } else {
            let (y0, y1, x) = (rule-y(s.t0), rule-y(s.t1 + 1), rule-x(s.k))
            layers.rules.push((x: x, y: y0, body: line(start: (0pt, 0pt), end: (0pt, y1 - y0), stroke: st)))
          }
        }
        path-index += 1
      } else if kind == "flood" {
        let (i, j) = _to-coord(d.from, name: "from")
        let (i, j) = (_norm-index(i, R) - r0, _norm-index(j, C) - c0)
        if i < 0 or j < 0 or i >= nR or j >= nC {
          panic("nicematrix: `flood` must start in a cell of the matrix itself (not an exterior row or column)")
        }
        let f = d.at("fill", default: none)
        // One rectangle per run of cells in a row, to avoid seams.
        let cells = _flood-cells((i, j), nR, nC, all-segs)
        for r in range(nR) {
          let js = cells.filter(c => c.at(0) == r).map(c => c.at(1)).sorted()
          let k = 0
          while k < js.len() {
            let k2 = k
            while k2 + 1 < js.len() and js.at(k2 + 1) == js.at(k2) + 1 { k2 += 1 }
            layers.under.push(rect-item(tile(r0 + r, c0 + js.at(k), r0 + r, c0 + js.at(k2)), fill: f))
            k = k2 + 1
          }
        }
      } else if kind == "span-brace" {
        let r = _deco-range(d, R, C, main: (r0, r1, c0, c1))
        let fill = d.at("fill", default: auto)
        let shift = _abs-len(d.at("shift", default: 0pt))
        let shorten = _to-bool(d.at("shorten", default: false), name: "shorten")
        if d.dir == "h" {
          let side = d.at("side", default: top)
          let (x0, x1) = if shorten {
            (x-extent(r.j0, (r.i0, r.i1)).at(0), x-extent(r.j1, (r.i0, r.i1)).at(1))
          } else { (ctiles.at(r.j0).left, ctiles.at(r.j1).right) }
          let over = side != bottom
          let y = if over { rtiles.at(r.i0).top - shift } else { rtiles.at(r.i1).bottom + shift }
          let r = _hbrace-items(x0, x1, y, d.label, over: over, fill: fill)
          layers.over += r.items
          bounds += r.bounds
        } else {
          let side = d.at("side", default: right)
          let (y0, y1) = if shorten {
            (y-extent(r.i0, (r.j0, r.j1)).at(0), y-extent(r.i1, (r.j0, r.j1)).at(1))
          } else { (rtiles.at(r.i0).top, rtiles.at(r.i1).bottom) }
          let gapx = 0.15em.to-absolute()
          let is-right = side != left
          // Clear the delimiters of the matrix when the brace is at its edge.
          let x = if is-right {
            if r.j1 == c1 - 1 and rglyph != none { main.right + rglyph.w + gapx } else { ctiles.at(r.j1).right }
          } else {
            if r.j0 == c0 and lglyph != none { main.left - lglyph.w - gapx } else { ctiles.at(r.j0).left }
          }
          let x = if is-right { x + shift } else { x - shift }
          let vb = _vbrace-eq(y1 - y0, d.label, right: is-right, fill: fill)
          let r = _vbrace-items(vb, x, y0, y1, right: is-right, axis: mets.axis)
          layers.over += r.items
          bounds += r.bounds
        }
      } else if kind == "region" {
        let r = _deco-range(d, R, C, main: (r0, r1, c0, c1))
        let fit = d.at("fit", default: "cells")
        let rect = tile(r.i0, r.j0, r.i1, r.j1)
        if fit == "content" {
          let boxes = ()
          for i in range(r.i0, r.i1 + 1) {
            for j in range(r.j0, r.j1 + 1) {
              let c = cell-at(i, j)
              if full(c) and c.kind == "cell" { boxes.push(c.box) }
            }
          }
          if boxes.len() > 0 {
            rect = (
              x0: calc.min(..boxes.map(b => b.x0)), x1: calc.max(..boxes.map(b => b.x1)),
              y0: calc.min(..boxes.map(b => b.y0)), y1: calc.max(..boxes.map(b => b.y1)),
            )
          }
        }
        let it = _region-item(d, rect, default-stroke)
        if _to-bool(d.at("above", default: false), name: "above") { layers.over.push(it) } else { layers.under.push(it) }
      } else if kind == "dotline" {
        let (a, b) = (_to-coord(d.from, name: "from"), _to-coord(d.to, name: "to"))
        let (ia, ja) = (_norm-index(a.at(0), R), _norm-index(a.at(1), C))
        let (ib, jb) = (_norm-index(b.at(0), R), _norm-index(b.at(1), C))
        for (i, j, which) in ((ia, ja, "from"), (ib, jb, "to")) {
          if i < 0 or j < 0 or i >= R or j >= C {
            panic("nicematrix: `" + which + "` " + repr((i, j)) + " is outside the " + str(R) + "×" + str(C) + " grid")
          }
        }
        let (ca, cb) = (cell-at(ia, ja), cell-at(ib, jb))
        let opts = d
        for k in ("nicematrix", "from", "to", "connect", "bend") { let _ = opts.remove(k, default: none) }
        if d.at("connect", default: false) { opts = _connect-preset + opts }
        let bend = _to-angle(d.at("bend", default: 0deg), name: "bend")
        let (p0, p1) = _dotline-points(ca, cb, bend: bend)
        let st = _leader-style(dots, opts, at: (ia, ja))
        let s0 = if st.shorten-start == auto { st.shorten } else { st.shorten-start }
        let s1 = if st.shorten-end == auto { st.shorten } else { st.shorten-end }
        let r = _leader-items(p0, p1, st + (shorten-start: s0, shorten-end: s1, bend: bend))
        layers.over += r.items
        bounds += r.bounds
      }
    }

    // --- Final box.
    let X0 = calc.min(..bounds.map(b => b.x0))
    let X1 = calc.max(..bounds.map(b => b.x1))
    let Y0 = calc.min(..bounds.map(b => b.y0))
    let Y1 = calc.max(..bounds.map(b => b.y1))

    // Geometry handed to `background` / `foreground` (and used by `debug`),
    // in the coordinates of the final box.
    let rect-of(r) = (x: r.x0 - X0, y: r.y0 - Y0, width: r.x1 - r.x0, height: r.y1 - r.y0)
    let geometry = (
      width: X1 - X0,
      height: Y1 - Y0,
      baseline: y-base - Y0,
      axis: y-base - Y0 - mets.axis,
      main: rect-of((x0: main.left, x1: main.right, y0: main.top, y1: main.bottom)),
      rows: rows.enumerate().map(((i, r)) => (
        top: r.top - Y0, baseline: r.base - Y0, bottom: r.bottom - Y0,
        tile-top: rtiles.at(i).top - Y0, tile-bottom: rtiles.at(i).bottom - Y0,
      )),
      cols: cols.enumerate().map(((j, c)) => (
        left: c.left - X0, right: c.right - X0,
        tile-left: ctiles.at(j).left - X0, tile-right: ctiles.at(j).right - X0,
      )),
      leaders: lead.lines.map(l => (
        dir: l.dir, from: l.from, to: l.to, open: l.open,
        start: (l.p0.at(0) - X0, l.p0.at(1) - Y0), end: (l.p1.at(0) - X0, l.p1.at(1) - Y0),
      )),
      cells: range(R).map(i => range(C).map(j => {
        let c = cell-at(i, j)
        rect-of(tile(i, j, i, j)) + (
          ink: rect-of(c.box),
          baseline: c.base - Y0,
          empty: c.m.empty,
          kind: c.kind,
          origin: (c.i, c.j),
        )
      })),
    )
    let hook(h) = if h == none { () } else {
      let body = if type(h) == function { h(geometry) } else { h }
      ((x: X0, y: Y0, body: body),)
    }

    let debug-items = ()
    let tiny(body, size: 3.5pt, fill: blue.darken(20%)) = box(fill: white.transparentize(20%), inset: 0.3pt,
      text(size: size, fill: fill, font: "DejaVu Sans Mono", top-edge: "bounds", bottom-edge: "bounds", body))
    if debug in ("all", "cells") {
      // Tiles, _ink boxes and the coordinates of every cell.
      for i in range(R) {
        for j in range(C) {
          let c = cell-at(i, j)
          if c.i != i or c.j != j { continue }
          let t = tile(i, j, i + c.rowspan - 1, j + c.colspan - 1)
          debug-items.push((x: t.x0, y: t.y0, body: rect(width: t.x1 - t.x0, height: t.y1 - t.y0,
            stroke: (paint: gray, thickness: 0.3pt, dash: "dotted"))))
          if c.kind == "cell" and not c.m.empty {
            debug-items.push((x: c.box.x0, y: c.box.y0, body: rect(width: c.box.x1 - c.box.x0,
              height: c.box.y1 - c.box.y0, stroke: (paint: red.transparentize(50%), thickness: 0.2pt))))
          }
          debug-items.push((x: t.x0, y: t.y0, body: tiny(size: 3pt, fill: gray.darken(30%))[#i,#j]))
        }
      }
    }
    if debug in ("all", "rules") {
      // The numbers of the rules, as `hlines`, `vlines`, `augment` and
      // `pave` count them (within the main block): horizontal ones on the
      // left of the matrix, vertical ones above it.
      let line-st = (paint: blue.transparentize(55%), thickness: 0.3pt, dash: "densely-dotted")
      for k in range(nR + 1) {
        let y = rule-y(k)
        debug-items.push((x: main.left, y: y, body: line(length: main.right - main.left, stroke: line-st)))
        let b = tiny[#k]
        let m = measure(b)
        debug-items.push((x: X0 - m.width - 1pt, y: y - m.height / 2, body: b))
      }
      for k in range(nC + 1) {
        let x = rule-x(k)
        debug-items.push((x: x, y: main.top, body: line(angle: 90deg, length: main.bottom - main.top, stroke: line-st)))
        let b = tiny[#k]
        let m = measure(b)
        debug-items.push((x: x - m.width / 2, y: Y0 - m.height - 1pt, body: b))
      }
    }

    let order = (layers.under, hook(background), layers.rules, layers.cells, layers.over, hook(foreground), debug-items)
    box(width: X1 - X0, height: Y1 - Y0, baseline: Y1 - y-base, {
      for layer in order {
        for it in layer { place(top + left, dx: it.x - X0, dy: it.y - Y0, it.body) }
      }
      if group-meta != none [#group-meta <nicematrix-group>]
      // Named matrices publish their geometry at their top-left corner, for
      // `nicemat-cell` and `nicemat-connect`.
      if name != none { place(top + left, [#metadata((nicematrix-anchor: name, geometry: geometry)) <nicematrix-anchor>]) }
    })
  }
}

/// `nicemat` without delimiters, like nicematrix's `{NiceArray}`.
#let nicearray = nicemat.with(delim: none)

// ===========================================================================
// 13. Setup (public: nicemat-setup)
// ===========================================================================
//
// Document-level setup: `#show: nicemat-setup`.

/// Makes every `nicemat` in an inline equation follow the size of `mat`
/// there (script-size cells, like Typst's inline matrices). Nested `nicemat`
/// in the cells of another one shrink as nested `mat` do.
///
/// With `mat: true`, every `mat` of the document is also drawn by `nicemat`
/// (`show math.mat: nicemat`).
///
/// ```typ
/// #show: nicemat-setup
/// #show: nicemat-setup.with(mat: true)
/// ```
#let nicemat-setup(body, mat: false) = {
  show math.equation.where(block: false): set math.equation(supplement: _inline-flag)
  if mat {
    show math.mat: nicemat
    body
  } else {
    body
  }
}

// ===========================================================================
// 14. Named matrices (public: nicemat-cell, nicemat-connect)
// ===========================================================================
//
// Named matrices: `nicemat(name: "A", ..)` publishes its geometry, so that
// cells of different matrices can be located and connected (the analogue of
// TikZ's `remember picture` with the nodes of nicematrix).

#let _name(v) = if type(v) == str { v } else { _plain-text(v).trim() }

/// Where the cell `coord` of the matrix named `name` is on the page, or
/// `none` while the matrix has not been laid out yet (Typst lays the
/// document out again once it is known). Must be called in a context.
///
/// Returns a dictionary with `page`, the tile of the cell (`x`, `y`,
/// `width`, `height`, in absolute page coordinates), `_ink` (the rectangle of
/// its content, same keys) and `baseline`.
#let nicemat-cell(name, coord) = {
  let name = _name(name)
  let found = query(<nicematrix-anchor>).filter(m => m.value.nicematrix-anchor == name)
  if found.len() == 0 { return none }
  if found.len() > 1 {
    panic("nicematrix: " + str(found.len()) + " matrices are named `" + name + "`; names must be unique")
  }
  let m = found.first()
  let p = m.location().position()
  let cells = m.value.geometry.cells
  let (R, C) = (cells.len(), cells.first().len())
  let (i, j) = _to-coord(coord, name: "cell")
  let (i, j) = (_norm-index(i, R), _norm-index(j, C))
  if i < 0 or j < 0 or i >= R or j >= C {
    panic("nicematrix: cell " + repr(coord) + " is outside the " + str(R) + "×" + str(C) + " matrix `" + name + "`")
  }
  let c = cells.at(i).at(j)
  let shift(r) = (x: p.x + r.x, y: p.y + r.y, width: r.width, height: r.height)
  shift(c) + (page: p.page, ink: shift(c.ink), baseline: p.y + c.baseline)
}

/// Draws a line between cells of named matrices, on the same page:
/// `nicemat-connect(("A", (0, 2)), ("B", (1, 0)))`.
///
/// By default an arrow, like `connect`; it takes the same options as
/// `dotline` (`bend`, `stroke` (`auto` for dots), `marks`, `shorten`,
/// `above`, `below`, …). Put it anywhere on the page of the matrices, for
/// instance just after them; it takes no room.
#let nicemat-connect(from, to, ..args) = {
  if args.pos().len() > 0 {
    panic("nicematrix: `nicemat-connect` takes two cells `(name, (row, col))` and named options")
  }
  for (v, which) in ((from, "from"), (to, "to")) {
    if type(v) != array or v.len() != 2 {
      panic("nicematrix: `" + which + "` of `nicemat-connect` must be `(name, (row, col))`, got " + repr(v))
    }
  }
  let opts = args.named()
  let bend = _to-angle(opts.remove("bend", default: 0deg), name: "bend")
  for k in opts.keys() {
    if k not in _dots-defaults and k not in ("above", "below", "middle") {
      panic("nicematrix: unknown option `" + k + "` for `nicemat-connect`")
    }
  }
  context {
    let a = nicemat-cell(..from)
    let b = nicemat-cell(..to)
    if a != none and b != none {
      let here = here().position()
      if a.page != b.page {
        panic("nicematrix: `nicemat-connect` needs both matrices on the same page (`" + _name(from.at(0))
          + "` is on page " + str(a.page) + ", `" + _name(to.at(0)) + "` on page " + str(b.page) + ")")
      }
      if here.page != a.page {
        panic("nicematrix: put `nicemat-connect` on the page of the matrices it connects (page " + str(a.page) + ")")
      }
      let as-box(r) = (box: (x0: r.ink.x, x1: r.ink.x + r.ink.width, y0: r.ink.y, y1: r.ink.y + r.ink.height))
      let (p0, p1) = _dotline-points(as-box(a), as-box(b), bend: bend)
      let st = _leader-style(_dots-defaults + _connect-preset, opts)
      let s0 = if st.shorten-start == auto { st.shorten } else { st.shorten-start }
      let s1 = if st.shorten-end == auto { st.shorten } else { st.shorten-end }
      let r = _leader-items(p0, p1, st + (shorten-start: s0, shorten-end: s1, bend: bend))
      box(width: 0pt, height: 0pt, {
        for it in r.items { place(top + left, dx: it.x - here.x, dy: it.y - here.y, it.body) }
      })
    }
  }
}
