#import "@preview/fractus:0.1.0" as fr

/// Polynomial long division.
///
/// If only displaying the working of a polynomial long division without needing results in an array of numbers, use
/// `poly-div-working` instead.
///
/// == Returns
///
/// Returns a dict: `(working:, dividend:, divisor:, quotient:, remainder:, quot-coeff:, rem-coeff:)`
///
/// - `working` (`content`): displayable content showing the working (as a table)
/// - `dividend` (`math.equation`): the dividend as a math equation object
/// - `divisor` (`math.equation`): the divisor as a math equation object
/// - `quotient` (`math.equation`): the quotient as a math equation object
/// - `remainder` (`math.equation`): the remainder as a math equation object
/// - `quot-coeff` (`array`): the coefficients of the quotient polynomial as an array of fraction strings
/// - `rem-coeff` (`array`): the coefficients of the remainder polynomial as an array of fraction strings
///
///
/// - dividend (array): Coefficients of the dividend. Last element is x^0. For fractional coefficients, specify as strings e.g. "15/4".
/// - divisor (array): Coefficients of divisor. Last element is for x^0. For fractional coefficients, specify as strings e.g. "15/4".
/// - var (content): The variable of the polynomial. Default is `$x$`.
/// -> (working:, dividend:, divisor:, quotient:, remainder:, quot-coeff:, rem-coeff:)
#let poly-div(
  dividend,
  divisor,
  var: $x$
) = {

  let paren-space = 0.4em

  /// Use this function to construct fractus fraction objects.
  ///
  /// In fractus, fractions are represented as "n/d" strings, and operations operate on strings.
  let simplify = fr.simplify

  /// Use this to display a fraction string of the form `"n/d"` as a math mode fraction.
  let as-math(frc) = {
    if frc == none {
      return none
    }
    let (n, d) = frc.replace("-", "−").split("/")
    if d != "1" {
      $#n/#d$
    } else {
      $#n$
    }
  }

  let dividend = dividend.map(simplify)
  let remainder = dividend.map(x => x) // shallow copy
  let divisor = divisor.map(simplify)
  let max-quotient-deg = dividend.len() - divisor.len()
  let quotient = (simplify(0),) * (max-quotient-deg + 1)

  // List of table cells for the columns below the dividend, excludes
  // the divisor, quotient, and dividend itself.
  //
  // One element per table row.
  let working-table-rows = ()

  // List of start positions of table horizontal lines
  // for denoting subtractions
  let subtraction-underline-pos = ()

  /// Express polynomial coefficients as list of table cells
  /// (left padding not included, right padding included)
  let expr-cells(poly) = {
    let cells = ()
    for (idx, coeff) in poly.enumerate() {
      if fr.float(coeff) != 0 {
        if idx != poly.len() - 1 {
          // non-constant term, no need to specify 1 or -1, just use + or -
          if idx != 0 and fr.float(coeff) > 0 {
            // prepend explicit + for subsequent terms
            coeff = if fr.float(coeff) == 1 {$+$} else {$+ #as-math(coeff)$}
          } else if fr.float(coeff) == 1 {
            // if leading term and positive 1 coeficient, no need coefficient.
            coeff = $$
          } else if fr.float(coeff) == -1 {
            coeff = $-$
          } else if fr.float(coeff) >= 0 {
            coeff = as-math(coeff)
          } else {
            coeff = $-#as-math(fr.opposite(coeff))$
          }
        } else {
          if idx != 0 and fr.float(coeff) > 0 {
            coeff = $+#as-math(coeff)$
          } else if fr.float(coeff) >= 0 {
            coeff = as-math(coeff)
          } else {
            coeff = $-#as-math(fr.opposite(coeff))$
          }
        }
        let deg = poly.len() - 1 - idx
        if deg > 1 {
          cells.push([$#coeff#var^#deg$])
        } else if deg == 1 {
          cells.push([#coeff#var])
        } else {
          cells.push([#coeff])
        }
      } else {
        if idx != 0 {
          cells.push([]) // empty cell for 0 coefficient
        } else {
          cells.push($0$)
        }
      }
    }
    return cells
  }

  while remainder.len() >= divisor.len() {
    let quotient-degree = remainder.len() - divisor.len()
    let quotient-coeff = fr.division(remainder.first(), divisor.first())
    let subtract = divisor.map(x => fr.product(x, quotient-coeff)) + (simplify(0),) * quotient-degree
    let rem = remainder.zip(subtract).map(((x, s)) => fr.difference(x, s))
    if fr.float(rem.first()) != 0 {
      panic("Failed to eliminate top degree coefficient")
    }
    quotient.at(quotient.len() - quotient-degree - 1) = quotient-coeff
    remainder = rem
    while remainder.len() >= 1 and fr.float(remainder.first()) == 0 {
      remainder = remainder.slice(1)
    }
    if quotient-coeff != 0 {
      let sub-cells = expr-cells(subtract)
      sub-cells.first() = $- ($ + sub-cells.first()
      sub-cells.last() = sub-cells.last() + $)$
      working-table-rows.push(sub-cells)
      let remainder-cells = expr-cells(remainder)
      if remainder-cells.len() != 0 {
        remainder-cells.last() = remainder-cells.last() + $#h(paren-space)$
      }
      working-table-rows.push(remainder-cells)
      subtraction-underline-pos.push(1 + dividend.len() - divisor.len() - quotient-degree)
    }
  }

  let columns = 1 + dividend.len()
  let cells = ()
  // quotient row
  let quot-cells = expr-cells(quotient)
  quot-cells.last() = quot-cells.last() + $#h(paren-space)$
  cells += ([],) * (columns - quotient.len()) + quot-cells
  // divisor & dividend row
  let div-cells = expr-cells(dividend)
  div-cells.last() = div-cells.last() + $#h(paren-space)$
  cells += (expr-cells(divisor).reduce((acc, x) => acc + x), ) + div-cells
  // working rows
  for row-cells in working-table-rows {
    cells += ([],) * (columns - row-cells.len()) + row-cells
  }
  let content = table(
    align: right,
    inset: (x: 0pt, y: 5pt),
    column-gutter: 2pt,
    columns: columns,
    stroke: none,
    table.vline(x: 1, start: 1, end: 2, stroke: 0.7pt),
    table.hline(y: 1, start: 1, stroke: 0.7pt),
    ..subtraction-underline-pos.enumerate().map(((idx, start)) => table.hline(y: 3 + idx * 2, start: start, stroke: 0.7pt)),
    ..cells
  )
  (
    working: content,
    dividend: expr-cells(dividend).reduce((acc, x) => acc + x),
    divisor: expr-cells(divisor).reduce((acc, x) => acc + x),
    quotient: expr-cells(quotient).reduce((acc, x) => acc + x),
    remainder: expr-cells(remainder).reduce((acc, x) => acc + x),
    quot-coeff: quotient,
    rem-coeff: remainder
  )
}

/// Use this to directly show the working for a polynomial long division.
///
/// - dividend (array): Coefficients of the dividend. Last element is x^0. For fractional coefficients, specify as strings e.g. "15/4".
/// - divisor (array): Coefficients of divisor. Last element is for x^0. For fractional coefficients, specify as strings e.g. "15/4".
/// - var (content): The variable of the polynomial
///
/// -> (working:, quotient:, remainder:, quot-coeff:, rem-coeff:)
#let poly-div-working(dividend, divisor, var: $x$) = {
  poly-div(dividend, divisor, var: var).at("working")
}