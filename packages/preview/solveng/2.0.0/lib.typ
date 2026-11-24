// solveng – unit-aware calculations that read like your notes, like a Mathcad worksheet.
//
//   #import units: mA, mAh, h              // units, constants, operations and modifiers are imported where you use them
//   #import modifiers: solve
//   #show: worksheet                       // the math in the document is calculated:
//   $I := 30 mA$, $Q_0 := 3450 mAh$        //   := defines
//   $t := Q_0 / I => #h$                    //   a trailing = shows the value (bold), in hours
//   $x^2 = 4 -> solve(x)$                  //   -> the symbolic result, or solves

#import "src/api.typ": worksheet, calculate
#import "src/core.typ": clear
#import "src/keywords.typ": any
#import "src/defined.typ": defined
#import "src/graph.typ": graph
#import "src/compile.typ": compile
#import "src/value.typ": value
#import "src/operation.typ": base-unit, unit, constant, operation
// bindings only where imported, never through `*`: #import units: km, mA, s, #import operations: tri, sgn,
// #import constants: pi, i and #import modifiers: solve, digits
#import "src/unit-words.typ" as units
#import "src/builtins.typ" as operations

#import "src/constants.typ" as constants
#import "src/modifiers.typ" as modifiers
