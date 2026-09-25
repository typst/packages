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
  sign: "+"

) = {
  if place == 0 { panic("") }

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


/// Compute the absolute digit to round to, given a decimal from two strings, 
/// a precision and a rounding mode of either `"places"` or `"figures"`. 
/// 
/// Examples:
/// - `2.123` (`"2", "123"`), `mode: "places", precision: 2`
///       ↑ 
///       round to second place, i.e., third digit in total
/// - `2.123` (`"2", "123"`), `mode: "figures", precision: 2`
///      ↑ 
///      round to second figure, i.e., second digit in total
/// 
#let get-rounding-digit(int, frac, mode, precision) = {
  if mode == "places" {
    precision + int.len()
  } else if mode == "figures" {
    if (int + frac).trim("0") == "" {
      int.len()
    } else {
      precision + count-leading-zeros(int + frac)
    }
  }
}


/// Pads a decimal number to given precision with given rounding mode. 
/// Examples with `pad: true`:
/// - `62.1` (`"62", "1"`), `mode: "places", precision: 2`
///    → `"62.10` 
/// - `0.003` (`"0", "003"`), `mode: "figures", precision: 4`
///    → `"0.003000` 
#let pad-decimal(int, frac, pad, mode, precision) = {
  let rounding-digit = get-rounding-digit(int, frac, mode, precision)

  rounding-digit = calc.max(0, rounding-digit)
  let number = int + frac

  if rounding-digit > number.len() {
    if type(pad) == std.int {
      let max-pad = rounding-digit - number.len()
      frac += "0" * calc.clamp(pad - precision + max-pad, 0, max-pad)
    } else if pad {
      frac += "0" * (rounding-digit - number.len())
    }
  }
  
  (int, frac)
}


/// Rounds a decimal number to given precision with given rounding mode. 
/// 
/// If rounding is applied, the returned fractional part is stripped from
/// trailing zeros. 
#let round-decimal(

  /// Integer part of a decimal number. 
  /// -> str
  int,

  /// Fractional part of a decimal number. 
  /// -> str
  frac,

  /// The sign of the number. 
  /// -> "+" | "-"
  sign: "+",

  /// -> int
  precision: 2,

  /// -> "nearest" | "towards-infinity" | "towards-negative-infinity"
  dir: "nearest",

  ties: "away-from-zero",

  /// -> "places" | "figures"
  mode: "places",

) = {
  let rounding-digit = get-rounding-digit(int, frac, mode, precision)
  if rounding-digit < 0 { return ("", "")}

  let number = int + frac

  if rounding-digit < number.len() {
    number = round-integer(
      "0" + number, // prevent errors when rounding-digit is 0
      1 + rounding-digit,
      dir: dir,
      ties: ties,
      sign: sign,
    )

    // We ALWAYS need to pad the integer part, e.g. when rounding
    // 123 to the hundreds, round-integer gives 1 but we want 100. 
    if rounding-digit < int.len() {
      number += "0" * (int.len() - rounding-digit)
    }

    let new-int-digits = int.len() + 1
    int = number.slice(0, new-int-digits)
    frac = number.slice(new-int-digits).trim("0", at: end)
  }

  (int.trim("0", at: start), frac)
}





/// Rounds (and/or pads) a number given by an integer part and a fractional 
/// part. 
#let round(

  /// Integer part. 
  /// -> str
  int,

  /// Fractional part. 
  /// -> str
  frac,

  /// The sign of the number. 
  /// -> "+" | "-"
  sign: "+",

  /// Rounding mode.
  /// - `"places"`: The number is rounded to the number of places after the
  ///   decimal point given by the `precision` parameter.
  /// - `"figures"`: The number is rounded to a number of significant figures.
  mode: "places",

  /// The precision to round to. See parameter `mode` for the different modes. 
  /// If set to `auto` or `none`, no rounding is performed. 
  /// -> int | auto | none
  precision: 2,

  /// Rounding direction.
  /// -> str
  direction: "nearest",

  /// How to round ties.
  /// -> "away-from-zero" | "towards-zero" | "to-odd" | "to-even" | "towards-infinity" | "towards-negative-infinity"
  ties: "away-from-zero",

  /// Determines whether the number should be padded with zeros if the number 
  /// has less digits than the rounding precision. If an integer is given, 
  /// determines the minimum number of decimal digits (`mode: "places"`) or 
  /// significant figures (`mode: "figures"`) to display. 
  /// -> bool | int
  pad: true,

  ..

) = {
  if precision in (auto, none) {
    return (int, frac)
  }


  assert-option(mode, "round-mode", ("places", "figures"))

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


  pad-decimal(
    ..round-decimal(
      int, frac, 
      precision: precision,
      mode: mode,
      dir: direction,
      sign: sign,
      ties: ties,
    ),
    pad, mode, precision
  )
}


/// Rounds a number to the same decimal place as its uncertainty. 
#let round-to-uncertainty(
  
  /// Integer part. 
  /// -> str
  int,

  /// Fractional part. 
  /// -> str
  frac,

  /// Uncertainty, given as a tuple of integer and fractional part. Can also be a tuple of two tuples, in the case of asymmetric uncertainty.
  /// -> (str, str) | ((str, str), (str, str))
  uncertainty,

  /// The sign of the number. 
  /// -> "+" | "-"
  sign: "+",

  /// The precision to round the uncertainty to. If `auto`, the uncertainty
  /// left as is. If given as an int, the precision is interpreted in terms 
  /// of number of significant figures. Alternatively, a dictionary of the form
  /// `(places: int)` can be passed to specify the precision in terms of decimal 
  /// places.
  /// -> auto | int | dictionary
  precision: auto,

  /// Rounding direction.
  /// -> str
  direction: "nearest",

  /// How to round ties.
  /// -> "away-from-zero" | "towards-zero" | "to-odd" | "to-even" | "towards-infinity" | "towards-negative-infinity"
  ties: "away-from-zero",

  /// Determines whether the number should be padded with zeros if the number 
  /// has less digits than the rounding precision. If an integer is given, 
  /// determines the minimum number of decimal digits (`mode: "places"`) or 
  /// significant figures (`mode: "figures"`) to display. 
  /// -> bool | int
  pad: true,
  ..

) = {
  let is-symmetric = type(uncertainty.first()) != array
  if is-symmetric {
    uncertainty = (uncertainty,)
  }
  
  /// Find the (fractional) place of the smallest uncertainty
  let places = if precision == auto {
    calc.max(
      ..uncertainty.map(((i, f)) => f.len())
    )
  } else if type(precision) == std.int {
    precision + calc.max(
      ..uncertainty.map(((i, f)) => count-leading-zeros(i + f) - i.len())
    )
  } else if type(precision) == dictionary {
    assert(
      precision.keys() == ("places",), 
      message: "Expected a dictionary with the key \"places\""
    )
    precision.places
  } else {
    assert(
      false,
      message: "Unexpected argument " + repr(precision) + " for uncertainty-precision"
    )
  }

  uncertainty = uncertainty
    .map(((i, f)) => round-decimal(
      i, f,
      dir: direction,
      precision: places, 
      mode: "places"
    ))
    .map(((i, f)) => pad-decimal(
      i, f,
      pad, 
      "places",
      places 
    ))

  if is-symmetric {
    uncertainty = uncertainty.first()
  }
  
  // Then, round number to the same number of places as the uncertainty. 
  (
    ..pad-decimal(
      ..round-decimal(
        int, frac, 
        precision: places,
        mode: "places",
        dir: direction,
        sign: sign,
        ties: ties,
      ),
      pad, "places", places
    ),
    uncertainty
  )
}
