/// Modifiers for the clause after a trailing `=` or `->`: `solve`, `substitute`, `simplify`, `digits`, `sci`, `eng`, `fraction`.
///
/// Import the ones you use, where you use them: `#import modifiers: solve, digits`. Typst imports are lexical, so
/// they apply to that file or block and the ones nested in it; nothing comes along with
/// `#import "@preview/solveng:1.0.0": *`. A renamed import works the same: `#import modifiers: solve as löse`,
/// then `$x^2 = 4 -> löse(x)$`.
///
/// ```typ
/// #import modifiers: solve
/// #show: worksheet
/// $x^2 = 4 -> solve(x)$
/// ```

/// ## Modifiers
///
/// The clause after a trailing `=` or `->` takes a unit and modifiers, separated by commas: `$t = #h, digits(2)$`,
/// `$x^2 = 4 -> solve(x)$`. Modifiers are Typst bindings of solveng's `modifiers` module, and importing them is the
/// only way to use them: `#import modifiers: solve, simplify` (or `#import modifiers: *`). Like any import, it holds
/// only where it's written; `#import "@preview/solveng:1.0.0": *` brings none. Renamed imports
/// (`#import modifiers: solve as löse`) work as the original. `solve`, `substitute` and `digits` are functions,
/// called with what they take; `simplify`, `sci`, `eng` and `fraction` are written on their own.
///
/// ```typ
/// #import "@preview/solveng:1.0.0": *
/// #import modifiers: solve, digits, sci
/// #import units: h, mA, mAh
/// #show: worksheet
/// $I := 30 mA$, $Q := 3450 mAh$
/// $Q/2 = I t -> solve(t)$
/// $t = #h, digits(3)$
/// $I = sci$
/// ```

#import "keywords.typ": _key

/// Solves an equation for these names (and defines them): `$x^2 - 4 = 0 -> solve(x)$`.
///
/// - ..names (content): What to solve for.
/// -> content
#let solve(..names) = _key("solve", ..names.pos())
/// The result with these variables' formulas and constants' expressions put in, every other name kept:
/// `$P := U^2/R -> substitute(U)$`, `$E := m #c^2 -> substitute(#c)$`. A constant alone shows its expression
/// as written: `$#i -> substitute(#i)$` is √−1, where a simplified result would be i again.
///
/// - ..names (content): The variables and constants whose formulas to put in.
/// -> content
#let substitute(..names) = _key("substitute", ..names.pos())
/// The symbolic result, what `->` shows anyway: `$f := (x^2 - 1)/(x - 1) -> simplify$`.
#let simplify = _key("simplify")
/// Decimals with n significant digits: `$t = #h, digits(2)$`.
///
/// - n (int, content): The digits, 1…15.
/// -> content
#let digits(n) = _key("digits", n)
/// Scientific notation: `$C = sci$` → 2.2 · 10⁻⁶ F.
#let sci = _key("sci")
/// Engineering notation, exponents in steps of 3: `$f = eng$`.
#let eng = _key("eng")
/// Exact fractions: `$I / 3 = fraction$` → ⅙ A.
#let fraction = _key("frac")
