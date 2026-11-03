// Typesetting expressions, errors and HTML.
/// ## Errors
///
/// Problems (a missing value, units that don't match, a real calculation that would need complex numbers, a typo) are shown as a red note where they happen; the rest of the document still compiles:
///
/// > ⚠ solveng: 'U' in 'P := U I' isn't defined – define it first with :=, or solve for it: … -> solve(U)
///
/// `#show: worksheet.with(errors: "panic")` stops the compilation instead (useful in CI). Unknown named arguments of `worksheet`, `defined` and `graph` are reported the same way; those of `compile` stop the compilation.
///
/// ## HTML
///
/// With `typst compile --features html --format html`, equations become MathML, `defined` columns that reflow with the width (or a table with `style: "column"`), graphs inline SVGs (via `html.frame`) that shrink with the page, errors styled notes. One small stylesheet is added to the page (math font STIX Two Math / Cambria Math / Latin Modern Math, spacing, table stripes; classes `solveng`, `solveng-defs`, `solveng-list`, `solveng-plot`, `solveng-error`; types are `solveng-chip` with `solveng-type`, coloured inline). It follows the reader's light or dark scheme: chips and errors take their dark colours, graphs are drawn live in the page's `Canvas`/`currentColor` (the static picture only shows without scripts). HTML export is experimental in Typst; in column layout browsers drop the space after a leading `=`.

#import "config.typ": *

// types aren't maths: small filled blue chips that stand out from it; the mark (:) tinted lighter than the unit,
// so the two can't be confused. `dark` holds the colors for a dark page; a chip without them keeps its colors there.
#let _CHIPS = (
  type: (fill: rgb("#cdeafb"), mark: rgb("#2b8ac4"), ink: rgb("#0c4a6e"),
    dark: (fill: rgb("#123a4f"), mark: rgb("#63bff0"), ink: rgb("#b4dcf3"))),
)
// the color, or one that follows the page's scheme when the chip has a dark version of it
#let _chip-color(light, dark) = if dark == light { light.to-hex() } else { "light-dark(" + light.to-hex() + ", " + dark.to-hex() + ")" }
// (in HTML MathML has no boxes and drops text colours: an <mrow> styled inline, so chips: still sets them)
#let _chip(kind, mark, u, cf) = {
  let ch = cf.at("chips", default: auto)
  if type(ch) == function { return ch(kind, mark, u) }
  let base = _CHIPS.at(kind)
  let given = if type(ch) == dictionary { ch.at(kind, default: (:)) } else { (:) }
  let c = base + given
  context if _target() == "html" {
    // the dark colors the page scheme picks; a color the document gives itself keeps, unless it gives a dark one too
    let own-dark = given.at("dark", default: (:))
    let scheme = base.at("dark", default: (:)) + own-dark
    let color(key) = {
      let light = c.at(key)
      _chip-color(light, if key in given and key not in own-dark { light } else { scheme.at(key, default: light) })
    }
    let style = "background-color: " + color("fill") + "; color: " + color("ink") + "; border-radius: 0.3em; padding: 0.16em 0.28em; font-size: 0.7em"
    html.elem("mrow", attrs: (class: "solveng-chip solveng-" + kind, style: style), html.elem("mrow", attrs: (style: "color: " + color("mark")), mark) + h(0.1667em) + u)
  } else {
    box(fill: c.fill, radius: 0.3em, inset: (x: 0.28em, y: 0.16em), baseline: 0.1em, text(size: 0.7em, fill: c.ink, $#text(fill: c.mark, mark) thin #u$))
  }
}

// HTML: one stylesheet per document (browsers set math fonts on <math> itself, so inline styles can't reach it).
// It follows the reader's scheme: `light-dark()` resolves against the page's `color-scheme`, the plots draw in
// `Canvas`/`currentColor` themselves, and only the static picture of a graph, drawn for a light page, is inverted.
#let _css-done = state("solveng-css", false)
#let _CSS = ":root { color-scheme: light dark; }
.solveng, .solveng-list { font-size: 1.12em; }
.solveng { margin: 0.9em 0; overflow-x: auto; overflow-y: hidden; }
.solveng math, .solveng-list math { font-family: 'STIX Two Math', 'Cambria Math', 'Latin Modern Math', math; }
.solveng-list { border-collapse: collapse; margin: 0.7em 0; }
.solveng-defs { columns: var(--w) auto; column-gap: 2.5em; margin: 0.7em 0; font-size: 1.12em; }
.solveng-defs > div { break-inside: avoid; display: flex; gap: 0.3em; padding: 0.15em 0; white-space: nowrap; }
.solveng-defs > div > span:first-child { flex: 0 0 var(--n); text-align: right; }
.solveng-plot { margin: 0.9em 0; text-align: center; }
.solveng-plot svg { max-width: 100%; height: auto !important; margin: 0 auto; }
@media (prefers-color-scheme: dark) { .solveng-plot-static svg { filter: invert(1) hue-rotate(180deg); } }
.solveng-defs math { font-family: 'STIX Two Math', 'Cambria Math', 'Latin Modern Math', math; }
.solveng-list td { padding: 0.25em 0.4em; white-space: nowrap; }
.solveng-list tr:nth-child(even) td { background: rgba(127, 127, 127, 0.07); }
.solveng-error { color: light-dark(#b3261e, #ffb4ab); background: light-dark(#fdecea, #45201d); border-radius: 3px; padding: 0.1em 0.35em; font-size: 0.9em; }
div.solveng-error { border-left: 3px solid light-dark(#b3261e, #ffb4ab); padding: 0.4em 0.7em; margin: 0.6em 0; }"
#let _css() = context if not _css-done.get() { html.elem("style", _CSS); _css-done.update(true) }
// math block or inline; in HTML a spaced, scrollable block
// solveng's own equations carry a mark, so its rules never read them, even before its state settles
#let _OWN = metadata("solveng-own")
#let _own(eq) = eq.body.has("children") and eq.body.children.any(c => c == _OWN)
#let _eqn(body, cf) = {
  let e = math.equation(block: cf.block, _OWN + body)
  if cf.block and _target() == "html" { _css(); html.elem("div", attrs: (class: "solveng"), e) } else { e }
}
// problems are shown where they happen (worksheet(errors: "panic") stops instead)
#let _errc(msg, cf, wide: false) = {
  if cf.at("errors", default: "document") == "panic" { panic("solveng: " + msg) }
  if _target() == "html" {
    _css()
    html.elem(if wide { "div" } else { "span" }, attrs: (class: "solveng-error"), "⚠ solveng: " + msg)
  } else {
    let t = text(fill: rgb("#b3261e"), size: 0.9em)[⚠ solveng: #msg]
    if wide { block(width: 100%, fill: rgb("#fdecea"), stroke: (left: 2pt + rgb("#b3261e")), inset: (x: 8pt, y: 6pt), radius: 2pt, t) }
    else { box(fill: rgb("#fdecea"), inset: (x: 3pt, y: 1pt), outset: (y: 2pt), radius: 2pt, t) }
  }
}
// a problem with a call's arguments, also for editors (no element of its own, like equations passed to worksheet)
#let _err-now(msg) = context _errc(msg, _cf.get(), wide: true) + [#metadata((kind: "error", element: none, message: msg, source: ""))<solveng>]
// output of the package: its equations are not read as definitions by worksheet's math rule
#let _busy = state("solveng-busy", 0)
#let _mine(body) = _busy.update(n => n + 1) + body + _busy.update(n => n - 1)
// repr, not comparisons and str: editors infer the parameters' types from what their values are passed to
#let _tn(x) = repr(type(x)).trim("type(", at: start).trim(")", at: end)
