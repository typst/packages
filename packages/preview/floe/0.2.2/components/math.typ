// ============================================================================
// FLOE DESIGN SYSTEM — MATHEMATICAL COMPONENTS (components/math.typ)
// Systems, Control, Matrix Calculus Notation & Semantic Equation Dissection
// ============================================================================
#import "../core/lib.typ": *
#import "../primitives/lib.typ": badge

// ----------------------------------------------------------------------------
// 1. Canonical Operators & Spaces
// ----------------------------------------------------------------------------

#let argmin  = math.op("arg min", limits: true)
#let argmax  = math.op("arg max", limits: true)
#let diag    = math.op("diag")
#let rank    = math.op("rank")
#let tr      = math.op("tr")
#let sign    = math.op("sign")
#let epi     = math.op("epi")
#let conv    = math.op("conv")
#let dom     = math.op("dom")
#let Vol     = math.op("Vol")
#let span    = math.op("span")
#let col     = math.op("col")
#let row     = math.op("row")
#let dim     = math.op("dim")
#let null    = math.op("null")
#let ker     = math.op("ker")
#let im      = math.op("im")
#let Re      = math.op("Re")
#let Im      = math.op("Im")
#let grad    = math.op("grad")
#let div     = math.op("div")
#let curl    = math.op("curl")
#let adj     = math.op("adj")
#let sinc    = math.op("sinc")
#let Eop     = math.op("EE", limits: false)
#let Var     = math.op("Var", limits: false)
#let Cov     = math.op("Cov", limits: false)
#let ZMWN    = $"ZMWN"$
#let ddot(x) = math.dot.double(x)
#let to      = math.arrow.r
#let implies = math.arrow.r.double
#let iff     = math.arrow.l.r.double
#let infinity = math.oo
#let succcurlyeq = math.succ.eq
#let ddots   = math.dots.down
#let tensor  = math.times.o
#let top     = math.top

// Canonical spaces and differentials shorthand
#let st      = $quad "s.t." quad$
#let Rn      = $RR^n$
#let Rm      = $RR^m$
#let Rp      = $RR^p$
#let Cn      = $CC^n$
#let Cm      = $CC^m$
#let Rnxn    = $RR^(n times n)$
#let Rnxm    = $RR^(n times m)$
#let Rpxn    = $RR^(p times n)$
#let Rpxm    = $RR^(p times m)$
#let dt      = $d t$
#let dx      = $d x$
#let dy      = $d y$
#let dz      = $d z$

// ----------------------------------------------------------------------------
// 2. Universal Equation Dissection & Term Highlighting (Domain-Agnostic)
// ----------------------------------------------------------------------------

/// Highlights any mathematical sub-expression in bold with the specified color token
#let math-hl(color, expr) = text(fill: color, weight: "bold")[$#expr$]

/// Domain-agnostic numbered term highlighters matching `term-palette` (`c-term-1` .. `c-term-6`)
#let t1(expr) = math-hl(c-term-1, expr)
#let t2(expr) = math-hl(c-term-2, expr)
#let t3(expr) = math-hl(c-term-3, expr)
#let t4(expr) = math-hl(c-term-4, expr)
#let t5(expr) = math-hl(c-term-5, expr)
#let t6(expr) = math-hl(c-term-6, expr)

/// Annotated Underbrace / Overbrace helpers with matching label colors
#let math-annot(term, label, color: c-term-1) = {
  $underbrace(#text(fill: color, weight: "bold")[$#term$], #text(fill: color, size: text-scale.xs, font: fonts.sans, weight: "bold")[#label])$
}
#let math-annot-top(term, label, color: c-term-1) = {
  $overbrace(#text(fill: color, weight: "bold")[$#term$], #text(fill: color, size: text-scale.xs, font: fonts.sans, weight: "bold")[#label])$
}

/// Universal Equation Term Legend Box
/// Accepts either 3-tuples `(color, symbol, description)` or 2-tuples `(symbol, description)`
/// which automatically cycle through `palette` (defaults to `term-palette`).
#let eq-legend(palette: term-palette, ..items) = {
  block(
    width: 100%,
    fill: slate-100,
    stroke: strokes.border + slate-300,
    radius: radii.md,
    inset: (x: 10pt, y: 7.5pt),
    above: 8pt,
    below: 8pt,
  )[
    #set text(font: fonts.sans, size: 8.4pt, fill: slate-800)
    #set par(justify: false)
    #grid(
      columns: (auto, 1fr),
      gutter: 8pt,
      align: (horizon, horizon),
      ..items.pos().enumerate().map(((idx, it)) => {
        let col = if it.len() >= 3 { it.at(0) } else { palette.at(calc.rem(idx, palette.len())) }
        let sym = if it.len() >= 3 { it.at(1) } else { it.at(0) }
        let desc = if it.len() >= 3 { it.at(2) } else { it.at(1) }
        (
          badge(
            sym,
            fill: col.lighten(88%),
            text-color: col,
            stroke: strokes.hairline + col.lighten(35%),
          ),
          [#desc],
        )
      }).flatten()
    )
  ]
}
