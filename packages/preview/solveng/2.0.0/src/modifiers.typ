/// Modifiers for the clause after a trailing `=` or `->`: `solve`, `substitute`, `assume`, `simplify`, `expand`, `factor`, `steps`, `digits`, `sci`, `eng`, `fraction`.
///
/// Import the ones you use, where you use them: `#import modifiers: solve, digits`. Typst imports are lexical, so
/// they apply to that file or block and the ones nested in it; nothing comes along with
/// `#import "@preview/solveng:2.0.0": *`. A renamed import works the same: `#import modifiers: solve as löse`,
/// then `$x^2 = 4 -> löse(x)$`.
///
/// ```typ
/// #import modifiers: solve
/// #show: worksheet
/// $x^2 = 4 -> solve(x)$
/// ```

/// ## Modifiers
///
/// The clause after a trailing `=` or `->` takes a unit and modifiers, separated by commas: `$t => #h, digits(2)$`,
/// `$x^2 = 4 -> solve(x)$`. Modifiers are Typst bindings of solveng's `modifiers` module, and importing them is the
/// only way to use them: `#import modifiers: solve, simplify` (or `#import modifiers: *`). Like any import, it holds
/// only where it's written; `#import "@preview/solveng:2.0.0": *` brings none. Renamed imports
/// (`#import modifiers: solve as löse`) work as the original. `solve`, `substitute`, `assume` and `digits` are functions,
/// called with what they take; `simplify`, `expand`, `factor`, `steps`, `sci`, `eng` and `fraction` are written on their own.
///
/// ```typ
/// #import "@preview/solveng:2.0.0": *
/// #import modifiers: solve, digits, sci
/// #import units: h, mA, mAh
/// #show: worksheet
/// $I := 30 mA$, $Q := 3450 mAh$
/// $Q/2 = I t -> solve(t)$
/// $t => #h, digits(3)$
/// $I => sci$
/// ```

#import "keywords.typ": _key
// Keep invalid arguments in the clause so the worksheet reports them normally.
#let _modifier(name, args) = {
  if args.named().len() > 0 { return _key("invalid named arguments for " + name + ": " + args.named().keys().join(", ")) }
  _key(name, ..args.pos())
}

/// Returns solutions for these names without changing definitions: `$x^2 - 4 = 0 -> solve(x)$`.
///
/// - ..names (content): What to solve for.
/// -> content
#let solve(..names) = _modifier("solve", names)
/// The result with these variables' formulas and constants' expressions put in, every other name kept:
/// `$P := U^2/R -> substitute(U)$`, `$E := m #c^2 -> substitute(#c)$`. A constant alone shows its expression
/// as written: `$#i -> substitute(#i)$` is √−1, where a simplified result would be i again.
///
/// - ..names (content): The variables and constants whose formulas to put in.
/// -> content
#let substitute(..names) = _modifier("substitute", names)
/// Assumptions for this symbolic calculation: `$Re(a z) = a Re(z) -> assume(a in RR)$`
/// is true. Import `assume` from `modifiers`. Real scalar names and sign constraints such as `x > 0`, `x >= 0`, `x < 0`, `x <= 0` are supported; assumptions
/// apply to this result and do not change definitions or later calculations.
/// Use it after `->` on expressions and equations, without `solve` or a definition.
/// A known nonreal value or an incompatible sign contradicts the assumption and reports an error. If a
/// name already has a symbolic definition, assume its free scalar names instead.
/// Without assumptions, equations may show `true for a in RR and b in RR`: a
/// sufficient condition, not an exhaustive description of all solutions. This
/// automatic check considers up to sixteen names in expressions of size at most 512.
///
/// ```typ
/// #import "@preview/solveng:2.0.0": *
/// #import operations: Re
/// #import modifiers: assume
/// #show: worksheet
/// $Re(a z + b w) = a Re(z) + b Re(w) ->$
/// $Re(a z + b w) = a Re(z) + b Re(w) -> assume(a in RR, b in RR)$
/// ```
///
/// - ..conditions (content): Real scalar or sign assumptions, for example `a in RR, x > 0`.
/// -> content
#let assume(..conditions) = _modifier("assume", conditions)
/// Optional explicit spelling of the default symbolic result; bare `->` is preferred.
/// The symbolic result, what `->` shows anyway: `$f := (x^2 - 1)/(x - 1) -> simplify$`. Of an equation, where it
/// holds: one side brought to zero and split into factors, each factor zero – `$x^2 = x -> simplify$` is
/// x = 0 ∨ x = 1; true when it always holds, false when never.
#let simplify = _key("simplify")
/// The symbolic result multiplied out: `$(x + 1)^2 -> expand$` is x² + 2x + 1. An equation side by side.
#let expand = _key("expand")
/// The symbolic result in factors: `$x^3 - x -> factor$` is x (x − 1)(x + 1), a fraction's numerator and
/// denominator each. An equation side by side. Splits off common factors, repeated factors and factors of degree one
/// in a name; numbers aren't split into primes, and decimals can't be factored.
#let factor = _key("factor")
/// The way to what `->` shows, a line each: `$F(a p) = a F(p) -> steps$` shows the equation with the definitions
/// put in, one side zero, in factors, and where it holds; an expression goes from the definitions put in to its
/// simplified number-form. Not with `solve`.
#let steps = _key("steps")
/// Decimals with n significant digits: `$t => #h, digits(2)$`.
///
/// - n (int, content): The digits, 1…15.
/// -> content
#let digits(n) = _key("digits", n)
/// Scientific notation: `$C => sci$` → 2.2 · 10⁻⁶ F.
#let sci = _key("sci")
/// Engineering notation, exponents in steps of 3: `$f => eng$`.
#let eng = _key("eng")
/// Exact fraction-style: `$I / 3 => fraction$` → ⅙ A.
#let fraction = _key("frac")
