#import "assertions.typ": *


/// Count the leading zeros in a string of digits
#let count-leading-zeros(
  /// A string of digits
  /// -> str
  string,
) = {
  string.len() - string.trim("0", at: start).len()
}


/// Rounds an integer given as a string of digits to a given digit place.
#let round-integer(
  /// The integer string to round.
  /// -> str
  integer,
  /// The digit place to round to.
  place,
  /// The rounding direction.
  /// -> "nearest" | "towards-infinity" | "towards-negative-infinity" | "towards-zero" | "away-from-zero"
  dir: "nearest",
  /// How to round ties.
  /// -> "away-from-zero" | "towards-zero" | "to-odd" | "to-even" | "towards-infinity" | "towards-negative-infinity"
  ties: "away-from-zero",
  /// The sign of the number.
  /// -> "+" | "-"
  sign: "+",
) = {
  if place == 0 { return "" }
  if dir == "towards-infinity" {
    if sign == "+" { dir = "away-from-zero" } else { dir = "towards-zero" }
  }
  if dir == "towards-negative-infinity" {
    if sign == "-" { dir = "away-from-zero" } else { dir = "towards-zero" }
  }

  if dir == "towards-zero" {
    return integer.slice(0, place)
  } else if dir == "away-from-zero" {
    let x = float(integer.slice(0, place) + "." + integer.slice(place))
    integer = str(int(calc.ceil(x)))
  } else if dir == "nearest" {
    let fractional = integer.slice(place)
    if fractional.trim("0", at: end) == "5" {
      if ties == "away-from-zero" {} else if ties == "towards-zero" {
        fractional = "4"
      } else if ties == "to-even" {
        let ls-integer-digit = integer.slice(place - 1, place)
        if calc.even(int(ls-integer-digit)) {
          fractional = "4"
        }
      } else if ties == "to-odd" {
        let ls-integer-digit = integer.slice(place - 1, place)
        if calc.odd(int(ls-integer-digit)) {
          fractional = "4"
        }
      } else if ties == "towards-infinity" {
        let ls-integer-digit = integer.slice(place - 1, place)
        if sign == "-" {
          fractional = "4"
        }
      } else if ties == "towards-negative-infinity" {
        let ls-integer-digit = integer.slice(place - 1, place)
        if sign == "+" {
          fractional = "4"
        }
      }
    }
    let x = float(integer.slice(0, place) + "." + fractional)
    integer = str(int(calc.round(x)))
  }
  if place > integer.len() {
    integer = "0" * (place - integer.len()) + integer
  }
  return integer
}




/// Rounds or pads a number given by an integer part and a fractional part
/// to a given number of total digits (including the integer digits). The
/// rounding direction may be `"nearest"`, `"towards-infinity"`, or `"towards-negative-infinity"`.
/// The number `total-digits` cannot be negative. If it exceeds the number
/// of available digits and `pad` is set to `true`, the number is padded
/// with zeros.
#let round-or-pad(
  int,
  frac,
  total-digits,
  sign: "+",
  dir: "nearest",
  ties: "away-from-zero",
  pad: true,
  precision: 2
) = {
  total-digits = calc.max(0, total-digits)
  let number = int + frac
  if total-digits < number.len() {
    number = round-integer(
      number,
      total-digits,
      dir: dir,
      ties: ties,
      sign: sign,
    )
    let new-int-digits = int.len() + number.len() - total-digits
    if total-digits < int.len() {
      number += "0" * (int.len() - total-digits)
    }

    int = number.slice(0, new-int-digits)
    frac = number.slice(new-int-digits)
  } else if type(pad) == std.int {
    let max-pad = total-digits - number.len()
    frac += "0" * calc.clamp(pad - precision + max-pad, 0, max-pad)
  } else if pad {
    frac += "0" * (total-digits - number.len())
  }
  return (int, frac)
}



/// Rounds (or pads) a number given by an integer part and a fractional part.
/// Different modes are supported.
#let round(
  /// Integer part. -> str
  int,
  /// Fractional part. -> str
  frac,
  sign: "+",
  /// Rounding mode.
  /// - `"places"`: The number is rounded to the number of places after the
  ///   decimal point given by the `precision` parameter.
  /// - `"figures"`: The number is rounded to a number of significant figures.
  /// - `"uncertainty"`: Requires giving the uncertainty. The uncertainty is rounded
  ///   to significant figures given by the `precision` argument and then the number
  ///   is rounded to the same number of places as the uncertainty.
  mode: none,
  /// The precision to round to. See parameter `mode` for the different modes.
  /// -> int
  precision: 2,
  /// Rounding direction.
  /// -> str
  direction: "nearest",
  ties: "away-from-zero",
  /// Determines whether the number should be padded with zeros if the number has less
  /// digits than the rounding precision. If an integer is given, determines the minimum
  /// number of decimal digits (`mode: "places"`) or significant figures (`mode: "figures"`)
  /// to display. The parameter `pad` has no effect in `mode: "uncertainty"`.
  /// -> bool | int
  pad: true,
  /// Uncertainty
  pm: none,
) = {
  if mode == none { return (int, frac, pm) }
  if mode == "uncertainty" and pm == none { return (int, frac, pm) }


  assert-option(mode, "round-mode", ("places", "figures", "uncertainty"))

  // Removal hint
  if direction == "down" {
    assert(
      false,
      message: "In zero:0.5.0, the rounding direction \"down\" has been renamed to \"towards-negative-infinity\"",
    )
  } else if direction == "up" {
    assert(
      false,
      message: "In zero:0.5.0, the rounding direction \"up\" has been renamed to \"towards-infinity\"",
    )
  }
  assert-option(direction, "round-direction", (
    "nearest",
    "towards-infinity",
    "towards-negative-infinity",
    "away-from-zero",
    "towards-zero",
  ))

  let round-digit = precision
  if mode == "places" {
    round-digit += int.len()
  } else if mode == "figures" {
    let full-number = int + frac
    let leading-zeros = (
      full-number.len() - full-number.trim("0", at: start).len()
    )
    round-digit += leading-zeros
  }

  if mode == "uncertainty" {
    let round-digit-pm
    let is-symmetric = type(pm.first()) != array
    if is-symmetric {
      round-digit-pm = count-leading-zeros(pm.join()) + precision
      pm = round-or-pad(..pm, round-digit-pm, dir: direction, pad: true, precision: precision)
      round-digit = round-digit-pm + int.len() - pm.first().len()
    } else {
      let place = calc.max(
        ..pm.map(u => (
          count-leading-zeros(u.join()) + precision - u.first().len()
        )),
      )
      round-digit = place + int.len()
      pm = pm.map(u => round-or-pad(
        ..u,
        place + u.first().len(),
        dir: direction,
        pad: true,
        precision: precision
      ))
    }
  }

  return (
    ..round-or-pad(
      int,
      frac,
      round-digit,
      dir: direction,
      pad: pad,
      sign: sign,
      ties: ties,
      precision: precision
    ),
    pm,
  )
}

