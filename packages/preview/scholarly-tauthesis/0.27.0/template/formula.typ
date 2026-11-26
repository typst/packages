#import "command-dictionary.typ": command-dictionary

//
// A formula whose alternative text coincides with the source
// code of the formula.
//
// The functions of this file accept the source code of a
// formula as a string. The string is typeset in math mode
// with the Typst function eval, against the notation dictionary
// imported above together with the normal math mode names, and
// the same string is used as the alternative text of the
// resulting math.equation element. The alternative text of
// such a formula is therefore its source code by construction.
//
// The commands are meant to be called from code mode, and the
// hyphenated ones only from code mode, since a hyphen reads
// as a subtraction inside math mode. A single-word command
// may also be called from inside math mode, with its
// arguments as strings.
//

#let formula-fn(
  block: false,
  command-dictionary: (:),
  numbered: true,
  equation-source-code-string,
) = math.equation(
  block: block,
  alt: equation-source-code-string
    .trim()
    .replace(
      regex("[\s\n]+"),
      sym.space
    ),
  numbering: nn => context if numbered {
    numbering(math.equation.numbering, nn)
  } else {
    none
  },
  eval(
    mode: "math",
    scope: command-dictionary,
    equation-source-code-string.trim(),
  ),
)

// An inline formula, equal to a call of math.equation with the
// named argument block: false.

#let formula = formula-fn.with(
  block: false,
  command-dictionary: command-dictionary,
)

// A block-level formula, equal to a call of math.equation with
// the named argument block: true. Block-level formulas are
// numbered by default.

#let block-formula = formula-fn.with(
  block: true,
  command-dictionary: command-dictionary,
)

// A shorthand for the inline formula, for typing convenience.

#let ff = formula

// A number attached to one or more units, given as strings,
// pieced together using narrow non-breaking spaces. The unit
// names are resolved through the command dictionary.

#let unitful(number, ..units) = formula(number) + sym.space.nobreak.narrow + units.pos().map(formula).join(sym.space.nobreak.narrow)

// A range of numbers between two unitful endpoints, joined by
// an en dash. Again, the numbers and unit names are all given
// as strings.

#let unitful-range(start, end, ..units) = {
  formula(start)
  sym.zwj
  sym.dash.en
  sym.zwj
  formula(end)
  sym.space.nobreak.narrow
  units.pos().map(formula).join(sym.space.nobreak.narrow)
}
