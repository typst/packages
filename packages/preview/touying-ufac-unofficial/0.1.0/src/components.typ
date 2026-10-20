// touying-ufac-unofficial — components: color emphases, list markers and pills, `#icon`, the boxes (`emph-box`,
// `quote-box`, `eq-box`), `#cols`, the Markdown-like paragraph rewriting (`> box`, `"quote"`, `-> item`, `#arrows`) and
// the `local` wrapper around codly.
#import "@preview/touying:0.7.4": *
#import "@preview/codly:1.3.0" as _codly
#import "constants.typ": colors
#import "utils.typ": *
#import "icons.typ" as _icons

// ---------- emphasis ----------
/// Bold text in UFAC blue: the same as `#alert` (Touying's method) and as the `~~text~~` shorthand. Inside a pill
/// (a `===` subtitle, an exercise header, the title of an @emph-box) it turns UFAC yellow, where blue would vanish.
///
/// ```example
/// A #primary[definition], the same as ~~this shorthand~~.
/// ```
/// -> content
#let primary(
  /// Text to emphasize. -> content
  body,
) = context text(fill: _emph-color(colors.primary), weight: "bold", body)

/// Bold text in UFAC yellow. It is weak on white: meant for short labels and dark backgrounds.
///
/// ```example
/// A #secondary[remark] in yellow.
/// ```
/// -> content
#let secondary(
  /// Text to emphasize. -> content
  body,
) = text(fill: colors.secondary, weight: "bold", body)

/// Bold text in red, for warnings and problems.
///
/// ```example
/// #tertiary[Caution:] the gradient vanishes.
/// ```
/// -> content
#let tertiary(
  /// Text to emphasize. -> content
  body,
) = text(fill: colors.tertiary, weight: "bold", body)

/// Bold text in green, for advantages and correct answers.
///
/// ```example
/// #quaternary[Correct:] the series converges.
/// ```
/// -> content
#let quaternary(
  /// Text to emphasize. -> content
  body,
) = text(fill: colors.quaternary, weight: "bold", body)

// ---------- list markers and pills ----------
/// Markers of `-` lists by level: filled square, rotated hollow square, smaller hollow circle.
/// -> array
#let _markers(
  /// Color of the three markers. -> color
  color,
) = (
  move(square(fill: color, size: 0.4em, radius: 0.1em), dy: 0.2em),
  move(rotate(square(stroke: color + 2pt, size: 0.3em, radius: 0.1em), -20deg), dy: 0.4em),
  move(circle(stroke: color + 1.2pt, radius: 0.13em), dy: 0.4em),
)
/// Rounded label with white bold text on `color` (subtitles `===`/`====`, exercise/example header). Pushes
/// `kind: "pill"` on the color stack so `*bold*`, `#alert`, `raw` and `#icon` inside it pick readable colors.
/// -> content
#let _pill(
  /// Text of the label. -> content
  body,
  /// Fill of the label. -> color
  color: colors.primary,
) = box(fill: color, radius: 5pt, inset: (x: .7em), outset: (y: .4em),
  text(fill: white, weight: "bold", _in-box(color, body, kind: "pill")))

// ---------- icons ----------
/// SVG source of an Octicon filled with `color` (the name → paths table is in `icons.typ`).
/// -> str
#let _icon-svg(
  /// Name of the icon. -> str
  name,
  /// Fill color. -> color
  color,
) = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 16 16\" width=\"16\" height=\"16\" fill=\"" + color.to-hex() + "\">" + _icons.data.at(name) + "</svg>"
/// An icon of the Octicons set (320 names), already wrapped in a `box` for inline use. An unknown name is a compile
/// error.
///
/// ```example
/// #icon("check-circle", color: colors.quaternary) Done,
/// #icon("alert") attention and a big
/// #icon("rocket", size: 1.6em, color: colors.primary)
/// ```
/// -> content
#let icon(
  /// Name of the icon, e.g. `"check"`, `"alert"`, `"light-bulb"`, `"mark-github"`. -> str
  name,
  /// Fill color. With `auto` it follows the context like bold text: white inside a pill (a `===` subtitle, an
  /// exercise header, the title of an @emph-box), the box or title color inside @emph-box and `==`, black elsewhere.
  /// -> auto | color
  color: auto,
  /// Width and height of the icon. -> length
  size: 1em,
  /// Baseline of the box; the default aligns the icon with the text. -> relative
  baseline: 25%,
) = {
  // Inside the section slide the `set image(width:, height:)` does not reach the icon: both dimensions are explicit.
  assert(name in _icons.data, message: "unknown icon: \"" + name + "\" (see icons.typ for the available names)")
  context {
    let c = if color != auto { color } else if _in-pill() { white } else { _current-box-color(colors.neutral-darkest) }
    box(baseline: baseline, image(bytes(_icon-svg(name, c)), width: size, height: size, alt: name, format: "svg"))
  }
}

// ---------- boxes ----------
/// Box without title: thin border (the old `note-box`).
/// -> content
#let _note-box(
  /// Border color. -> color
  color,
  /// Content. -> content
  body,
) = block(stroke: 0.05em + color, inset: (x: 1em, y: .7em), radius: 5pt, width: 100%, _flow(body))
/// Box with the title as a badge overlapping the top border (the `boxed-style` of showybox in 0.0.1): the badge is
/// centered on the border line and left-aligned with the body text; the box starts at the top of the badge.
/// Compact insets: badge `x: .8em, y: .3em`, body `x: .9em, top: .45em` (+ half a badge), `bottom: .55em`.
/// -> content
#let _fancy-box(
  /// Border and badge color. -> color
  color,
  /// Text of the badge. -> content
  title,
  /// Content. -> content
  body,
) = {
  // the badge is a pill: `*x*` white, `~~x~~`/`#primary` yellow and `raw` inverted, as in `_pill` (kind "pill")
  let badge = box(fill: color, radius: 5pt, inset: (x: .8em, y: .3em), text(fill: white, weight: "bold", _in-box(color, title, kind: "pill")))
  context {
    let h = measure(badge).height
    pad(top: h / 2, block(stroke: 0.05em + color, radius: 5pt, width: 100%, inset: (x: .9em, top: h / 2 + .45em, bottom: .55em), {
      place(top + left, dx: 0.05em, dy: -(h + .45em), badge)
      _flow(body)
    }))
  }
}
/// The equation when `body` (ignoring spaces) is a single equation, else `none`.
///
/// #test(
///   `_only-eq([$x$]) == $x$`,
///   `_only-eq([ $ x $ ]).block`,
///   `_only-eq([a $x$]) == none`,
/// )
/// -> content | none
#let _only-eq(
  /// Body of an @eq-box. -> content
  body,
) = {
  let ch = _children(body).map(_unstyle).filter(c => not _is-space(c))
  if ch.len() == 1 and ch.first().func() == math.equation { ch.first() } else { none }
}
/// Emphasis box. Without a title it has a thin border; with a title, a badge sits over the top border. Inside the
/// box the `-` markers, the `->` arrow, `*bold*`, `==highlight==` and `#underline` take the box color; an explicit
/// `#arrows(color:)`, `#highlight(fill:)` or `#underline(stroke:)` wins. Colors by convention: primary for
/// definitions, quaternary for advantages, tertiary for problems, secondary for remarks.
///
/// ```example
/// #emph-box(color: colors.quaternary, title: [Pros])[
///   - Fast and *simple*
///   - Works with ==highlights==
/// ]
/// ```
///
/// Shorthand, always in the primary color: a paragraph whose lines start with `>`; a first line `> == Title` gives the
/// title. Only inline content fits the shorthand. For a framed equation see @eq-box.
/// -> content
#let emph-box(
  /// Color of the border and badge, and of the bold text, markers, arrows and highlights inside. -> color
  color: colors.primary,
  /// Badge over the top border; `none` gives the thin-border box. -> none | content
  title: none,
  /// Content of the box. -> content
  body,
) = {
  set list(marker: _markers(color))
  set text(fill: colors.neutral-darkest)
  _in-box(color, if title == none { _note-box(color, body) } else { _fancy-box(color, title, body) })
}
/// Equation box: a light frame around a key equation (the `key-eq` helper of the lecture decks). It goes *inside*
/// the equation, like the `boxeq` of the bookly package, so the equation keeps its centering, spacing and numbering,
/// and a part of an equation can be framed too. The body is written as math, between dollar signs; it is set in
/// display style whatever the spacing around it. A box around the whole equation is padded generously, a box around
/// a part of one tightly, and in both cases the frame holds tall fractions and the limits of sums.
///
/// It also works in a line of text or in an inline equation: there the body is in text style and the box does not
/// change the line spacing.
///
/// ```example
/// The output #eq-box[$y = phi(v)$] and the
/// mean #eq-box[$1/N sum_i y_i$].
/// ```
///
/// ```example
/// $ #eq-box[$v = bold(w)^top bold(x)$] $
///
/// $ y = #eq-box(color: colors.quaternary)[$phi(v)$] + b $
/// ```
///
/// Shorthand, always in the primary color: `>` in front of a block equation, on the same line or alone on the line
/// before it.
///
/// ```example
/// > $ E = 1/(2N) sum_i (y_i - hat(y)_i)^2 $
/// ```
/// -> content
#let eq-box(
  /// Base color of the fill and border; `auto` is blue, or the box color inside an @emph-box. -> auto | color
  color: auto,
  /// The equation, as math: `[$x = 2$]` or `($x = 2$)`. -> content
  body,
) = {
  // A content block inside an equation is markup, not math: `#eq-box[x = 2]` would be the upright text "x=2", and
  // `_` or `*` in it would not even parse. Refuse it with a hint rather than render it wrong.
  let ch = _children(body)
  assert(not ch.all(c => _is-text(c) or _is-space(c)), message: "eq-box: write the body as math, between dollar signs: #eq-box[$"
    + ch.map(c => if _is-text(c) { c.text } else { " " }).join() + "$]")
  let eq = _only-eq(body)
  _eq-mark   // tells the shorthand rule that this equation is already boxed (see `_eq-mark`)
  context {
    let where = _eq-ctx.get()   // "whole" | "part" of a block equation, or `none`: running text or inline math
    let c = if color == auto { _current-box-color(colors.primary) } else { color }
    // The content of a `box` inside an equation is not laid out as math, so it becomes an equation of its own: in
    // display style inside a block equation (a nested `$x$` alone would be in text style: small fractions, limits
    // beside the sum), in text style in a line of text, where display style would blow up the line.
    // The frame of an inline equation is trimmed to the text edges (15.97pt against 25.53pt for the same equation as
    // a block, measured 2026-09-18): tall fractions and the limits of a sum stuck out of the box. With the edges at
    // the glyph bounds the frame holds the whole equation; in a line of text a zero-width strut keeps a lone `x` from
    // getting a lower box than its neighbours.
    let inner = if eq == none { body } else {
      set text(top-edge: "bounds", bottom-edge: "bounds")
      if where == none { box(width: 0pt, height: 0.95em, baseline: 0.22em) }
      math.equation(block: false, if where == none { eq.body } else { math.display(eq.body) })
    }
    // No `baseline`: the box keeps the baseline of its content (measured against inset + baseline and against
    // outset, 2026-09-18), so a partly framed equation and a box in a line of text stay aligned. In a line of text
    // the vertical padding is an `outset`, which does not add to the line height.
    let padding = if where == "whole" { (inset: (x: 0.9em, y: 0.45em)) }
      else if where == "part" { (inset: (x: 0.35em, y: 0.3em)) }
      else { (inset: (x: 0.3em), outset: (y: 0.2em)) }
    box(fill: c.lighten(92%), stroke: 0.8pt + c.lighten(35%), radius: if where == none { 0.3em } else { 0.4em }, ..padding, inner)
  }
}

/// Quotation box: a vertical bar on the left. Typst's `#quote(attribution: [Author])[…]` is shown as a `quote-box`
/// too, with the attribution on the right.
///
/// ```example
/// #quote-box(color: colors.primary)[
///   All models are wrong, but some are useful.
/// ]
/// ```
///
/// Shorthand: a paragraph made only of `"quoted"` runs, one per line; each run becomes a box and the colors cycle
/// secondary, primary, quaternary, tertiary. Quotes inside a sentence are left alone.
/// -> content
#let quote-box(
  /// Color of the bar. -> color
  color: colors.secondary,
  /// The quotation. -> content
  body,
) = block(stroke: (left: .25em + color), inset: (left: 1em, y: .6em), width: 100%, body)

// ---------- columns ----------
/// Columns: a thin wrapper over Touying's `cols` (a `grid`), with an optional divider. Touying's own `side-by-side`
/// (no divider) is still available.
///
/// ```example
/// #cols(divider: true, columns: (1fr, 2fr))[
///   Left
/// ][
///   -> the shorthands work
///   -> inside a column
/// ]
/// ```
/// -> content
#let cols(
  /// Column widths, as Touying accepts them: `auto` (equal widths) or an array such as `(1fr, 2fr)`. -> auto | array
  columns: auto,
  /// Space between the columns. -> length
  gutter: 1em,
  /// A blue vertical bar (2.2pt) between the columns; the gutter is then used as inset. -> bool
  divider: false,
  /// One content block per column. -> content
  ..bodies,
) = {
  // each column gets a leading `parbreak()` (`_flow`) so the paragraph rewrites also work in a single-paragraph column
  let bodies = bodies.pos().map(_flow)
  if divider {
    components.cols(columns: columns, gutter: 0pt,
      inset: (x, _) => (left: if x > 0 { gutter / 2 } else { 0pt }, right: gutter / 2, y: 0pt),
      stroke: (x, _) => (left: if x > 0 { colors.primary + 2.2pt } else { none }),
      ..bodies)
  } else { components.cols(columns: columns, gutter: gutter, ..bodies) }
}

// ---------- paragraph rewriting: `> box`, `"quote"`, `-> item` ----------
/// Drops the leading `>` (and one space) of a text node; a lone `>` disappears.
///
/// #test(
///   `_strip-gt([> item]) == [item]`,
///   `_strip-gt([>item]) == [item]`,
///   `_strip-gt([>]) == none`,
///   `_strip-gt([plain]) == [plain]`,
/// )
/// -> content | none
#let _strip-gt(
  /// A text node. -> content
  c,
) = { let s = c.text; if s == ">" { none } else if s.starts-with("> ") { text(s.slice(2)) } else if s.starts-with(">") { text(s.slice(1)) } else { c } }
/// `> text` → `emph-box`; `> == Title` on the first line → the title. Line breaks inside the paragraph arrive as
/// `[ ]` and the text `> == Title` arrives sliced (`[>] [ ] [==] [ ] [Title] …`), so the title runs until the next
/// child that starts with `>`.
/// -> content
#let _blockquote(
  /// Children of the paragraph. -> array
  children,
) = {
  let title = none; let rest = children
  if rest.len() >= 3 and rest.at(0).text == ">" and _is-space(rest.at(1)) and _is-text(rest.at(2)) and rest.at(2).text == "==" {
    rest = rest.slice(3); let t = ()
    while rest.len() > 0 and not (_is-text(rest.at(0)) and rest.at(0).text.starts-with(">")) { t.push(rest.remove(0)) }
    title = t.sum(default: [])
  }
  emph-box(title: title, rest.map(c => if _is-text(c) { _strip-gt(c) } else { c }).filter(c => c != none).sum(default: []))
}
/// A paragraph made only of `"…"` runs (one per line) → one `quote-box` per run, colors cycling
/// secondary → primary → quaternary → tertiary. Anything outside the quotes except spaces cancels the rewrite.
/// -> content | none
#let _quotes(
  /// Children of the paragraph. -> array
  children,
) = {
  let items = (); let cur = none
  for c in children {
    if _is-dq(c) { if cur == none { cur = () } else { items.push(cur); cur = none } }
    else if cur != none { cur.push(c) } else if not _is-space(c) { return none }
  }
  if cur != none or items.len() == 0 { return none }
  let palette = (colors.secondary, colors.primary, colors.quaternary, colors.tertiary)
  items.enumerate().map(((i, it)) => quote-box(color: palette.at(calc.rem(i, palette.len())), it.sum(default: []))).join()
}
/// Consecutive `-> item` lines → a `list` with a `→` marker (blue, the box color inside `emph-box`, or `color`).
/// In markup `->` is not the arrow: Typst emits the text nodes `[-]` and `[> item]` when `-` opens the line
/// without a space; the pair is what is detected here.
/// -> content
#let _arrows(
  /// Children of the paragraph. -> array
  children,
  /// Color of the arrow; `auto` is blue, or the box color inside an @emph-box. -> auto | color
  color,
) = {
  let items = (); let cur = (); let i = 0
  while i < children.len() {
    let c = children.at(i)
    if _is-text(c) and c.text == "-" and i + 1 < children.len() and _is-text(children.at(i + 1)) and children.at(i + 1).text.starts-with(">") {
      if cur != () { items.push(cur); cur = () }
      cur.push(_strip-gt(children.at(i + 1))); i += 2
    } else {
      if _is-space(c) and i + 1 < children.len() and _is-text(children.at(i + 1)) and children.at(i + 1).text == "-" { i += 1; continue }
      cur.push(c); i += 1
    }
  }
  if cur != () { items.push(cur) }
  let marker = if color == auto { context text(fill: _current-box-color(colors.primary), sym.arrow.r) } else { text(fill: color, sym.arrow.r) }
  list(marker: marker, ..items.map(it => it.sum(default: [])))
}
/// The `show par` rule of the theme. It inspects `it.body.children`: a lone `>` → signal for the next block
/// equation (@eq-box); a first text child starting with `>` → `emph-box`; first and last children
/// `smartquote(double: true)` → `quote-box`es; `[-]` followed by `[> …]` → arrow list. `\> word` and `-\> word` are
/// escapes (see `_escaped-after`); `\"…\"` already arrives as the text `"`, not as a `smartquote`.
/// `> $x$` (inline equation on the `>` line) does NOT become an `eq-box`, by decision (2026-09-16): the equation
/// reaches `show par` already realized as an opaque `inline` between two `tag`s, without a body. Wrapping every
/// inline equation in a `box` (`show math.equation.where(block: false): it => box(it)`, which arrives with a
/// recoverable `body`) would make it possible, but the side effect on all inline equations is not worth it; it
/// stays a plain box and the limitation is documented.
/// -> content
#let _rewrite-par(
  /// The paragraph. -> content
  it,
  /// Color of the `->` arrows, see @arrows. -> auto | color
  arrow-color: auto,
) = {
  let ch = _children(it.body); let first = ch.at(0)
  if ch.all(c => _is-space(c) or (_is-text(c) and c.text.trim() == ">")) { return _key-eq.update(colors.primary) }
  if _is-text(first) and first.text.starts-with(">") and not (first.text == ">" and _escaped-after(ch, 1)) { return _blockquote(ch) }
  if _is-dq(first) and _is-dq(ch.last()) { let q = _quotes(ch); if q != none { return q } }
  if _is-text(first) and first.text == "-" and ch.len() > 1 and _is-text(ch.at(1)) and ch.at(1).text.starts-with(">") and not (ch.at(1).text == ">" and _escaped-after(ch, 2)) { return _arrows(ch, arrow-color) }
  it
}
/// Arrow lists with the arrow in another color, for everything inside the body. The `-> item` shorthand itself
/// needs no function: consecutive lines starting with `->` become one list with a blue arrow (the box color inside an
/// @emph-box). The list must start the paragraph, and `-\> item` escapes it.
///
/// ```example
/// #arrows(color: colors.quaternary)[
///   -> green here
///   -> and here
/// ]
/// ```
/// -> content
#let arrows(
  /// Color of the arrows. -> color
  color: colors.primary,
  /// Content with `-> item` paragraphs. -> content
  body,
) = {
  // the inner `show par` replaces the global one and returns a `list`, so nothing is processed twice
  show par: _rewrite-par.with(arrow-color: color)
  body
}

// ---------- code ----------
/// Per-block code settings: codly's `local`, re-exported by the theme so that its code box and `raw` handling also
/// apply inside (this `local` shadows codly's). Typical uses: `#local(number-format: none)[…]` hides the line numbers,
/// `#local(display-name: true)[…]` shows the language label and
/// `#local(highlights: ((line: 2, fill: colors.secondary-lighter),))[…]` highlights a line. codly's `codly-range` and
/// `no-codly` need no wrapper.
/// -> content
#let local(
  /// Content with the code blocks. -> content
  body,
  /// Any argument of codly's `codly` function. -> any
  ..args,
) = {
  // codly's `local` installs a `show raw.where(block: true)` that is more inner than the theme's rules, so the gate
  // and the box go inside the body (see `_gate-raw`, `_code-box`)
  _codly.local(_gate-raw(_code-box(body)), ..args)
}
