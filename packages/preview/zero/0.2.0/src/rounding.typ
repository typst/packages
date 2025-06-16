#import "assertations.typ": *

#let count-leading-zeros(integer-string) = {
  integer-string.len() - integer-string.trim("0", at: start).len()
}


/// Rounds an integer given as a string of digits to a given digit place. 
/// The rounding direction may be `"nearest"`, `"up"`, or `"down"`. 
#let round-integer(num-string, digit, dir: "nearest") = {
  if digit == 0 { return "" }
  if dir == "down" {
    return num-string.slice(0, digit)
  } else if dir == "up" {
    let x = float(num-string.slice(0, digit) + "." + num-string.slice(digit))
    num-string = str(int(calc.ceil(x)))
  } else if dir == "nearest" {
    let x = float(num-string.slice(0, digit) + "." + num-string.slice(digit))
    num-string = str(int(calc.round(x)))
  }
  if digit > num-string.len() {
    num-string = "0" * (digit - num-string.len()) + num-string
  }
  return num-string
}

#assert.eq(round-integer("123", 2, dir: "down"), "12")
#assert.eq(round-integer("123", 1, dir: "down"), "1")
#assert.eq(round-integer("9989823", 7, dir: "down"), "9989823")
#assert.eq(round-integer("123", 0, dir: "down"), "")

#assert.eq(round-integer("120", 2, dir: "up"), "12")
#assert.eq(round-integer("123", 2, dir: "up"), "13")
#assert.eq(round-integer("1200000000002", 2, dir: "up"), "13")
#assert.eq(round-integer("999000003", 3, dir: "up"), "1000")

#assert.eq(round-integer("2234", 1, dir: "nearest"), "2")
#assert.eq(round-integer("2234", 0, dir: "nearest"), "")
#assert.eq(round-integer("0022", 3, dir: "nearest"), "002")
#assert.eq(round-integer("0395", 3, dir: "nearest"), "040")
#assert.eq(round-integer("999", 2, dir: "nearest"), "100")



/// Rounds or pads a number given by an integer part and a fractional part
/// to a given number of total digits (including the integer digits). The 
/// rounding direction may be `"nearest"`, `"up"`, or `"down"`. 
/// The number `total-digits` cannot be negative. If it exceeds the number
/// of available digits and `pad` is set to `true`, the number is padded
/// with zeros. 
#let round-or-pad(int, frac, total-digits, dir: "nearest", pad: true) = {
  total-digits = calc.max(0, total-digits)
  let number = int + frac
  if total-digits < number.len() {
    number = round-integer(number, total-digits, dir: dir)
    let new-int-digits = int.len() + number.len() - total-digits
    if total-digits < int.len() {
      number += "0" * (int.len() - total-digits)
    }
    
    int = number.slice(0, new-int-digits)
    frac = number.slice(new-int-digits)
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
  /// Rounding mode.
  /// - `"places"`: The number is rounded to the number of places after the 
  ///   decimal point given by the `precision` parameter. 
  /// - `"figures"`: The number is rounded to a number of significant figures.
  /// - `"uncertainty"`: Requires giving the uncertainty. The uncertainty is rounded
  ///   to significant figures given by the `precision` argument and then the number
  ///   is rounded to the same number of places as the uncertainty. 
  mode: none,
  /// The precision to round to. See parameter `mode` for the different modes. -> int
  precision: 2,
  /// Rounding direction. 
  /// - `"nearest"`: Rounding takes place in the usual fashion, rounding to the nearer 
  ///   number, e.g., 2.34 -> 2.3 and 2.36 -> 2.4. 
  /// - `"down"`: Always rounds down, e.g., 2.38 -> 2.3, 2.30 -> 2.3. 
  /// - `"up"`: Always rounds up, e.g., 2.32 -> 2.4, 2.30 -> 2.3. 
  /// -> str
  direction: "nearest",
  /// Determines whether the number should be padded with zeros if the number has less
  /// digits than the rounding precision. 
  /// -> boolean
  pad: true,
  /// Uncertainty
  pm: none
) = {
  if mode == none { return (int, frac, pm) }
  if mode == "uncertainty" and pm == none { return (int, frac, pm) }

  

  assert-option(mode, "round-mode", ("places", "figures", "uncertainty"))
  assert-option(direction, "round-direction", ("nearest", "up", "down"))
  
  let round-digit = precision
  if mode == "places" {
    round-digit += int.len()
  } else if mode == "figures" {
    let full-number = int + frac
    let leading-zeros = full-number.len() - full-number.trim("0", at: start).len()
    round-digit += leading-zeros
  }

  if mode == "uncertainty" {
    let round-digit-pm
    let is-symmetric = type(pm.first()) != array
    if is-symmetric { 
      round-digit-pm = count-leading-zeros(pm.join()) + precision
      pm = round-or-pad(..pm, round-digit-pm, dir: direction, pad: true)
      round-digit = round-digit-pm + int.len() - pm.first().len()
    } else {
      let place = calc.max(
        ..pm.map(u => count-leading-zeros(u.join()) + precision - u.first().len())
      )
      round-digit = place + int.len()
      pm = pm.map(u => round-or-pad(..u, place + u.first().len(), dir: direction, pad: true))
    }
  }

  return (..round-or-pad(int, frac, round-digit, dir: direction, pad: pad), pm)
}


#let round-places = round.with(mode: "places")
#let round-figures = round.with(mode: "figures")

#assert.eq(round("23", "5", mode: none), ("23", "5", none))

#assert.eq(round-places("1", "234", precision: 3), ("1", "234", none))
#assert.eq(round-places("1", "234", precision: 2), ("1", "23", none))
#assert.eq(round-places("1", "234", precision: 1), ("1", "2", none))
#assert.eq(round-places("1", "234", precision: 0), ("1", "", none))
#assert.eq(round-places("23", "534", precision: -1), ("20", "", none))
#assert.eq(round-places("12345", "534", precision: -3), ("12000", "", none))
#assert.eq(round-places("2", "234", precision: -3), ("0", "", none))
#assert.eq(round-places("", "0022", precision: 3), ("", "002", none))

#assert.eq(round-places("1", "1", precision: 0), ("1", "", none))
#assert.eq(round-places("1", "1", precision: 3), ("1", "100", none))
#assert.eq(round-places("1", "1", precision: 5), ("1", "10000", none))
#assert.eq(round-places("1", "1", precision: 5), ("1", "10000", none))
#assert.eq(round-places("1", "1", precision: 5, pad: false), ("1", "1", none))


#assert.eq(round-figures("1", "234", precision: 4), ("1", "234", none))
#assert.eq(round-figures("1", "234", precision: 3), ("1", "23", none))
#assert.eq(round-figures("1", "234", precision: 2), ("1", "2", none))
#assert.eq(round-figures("1", "234", precision: 1), ("1", "", none))
#assert.eq(round-figures("1", "234", precision: 0), ("0", "", none))
#assert.eq(round-figures("1", "234", precision: -1), ("0", "", none))

#assert.eq(round-figures("1", "2", precision: 4), ("1", "200", none))
#assert.eq(round-figures("1", "2", precision: 4, pad: false), ("1", "2", none))

#assert.eq(round-figures("0", "00126", precision: 2), ("0", "0013", none))
#assert.eq(round-figures("0", "000126", precision: 3), ("0", "000126", none))



#assert.eq(round-places("99", "92", precision: 2), ("99", "92", none))
#assert.eq(round-places("99", "92", precision: 0), ("100", "", none))
#assert.eq(round-places("99", "99", precision: 1), ("100", "0", none))
#assert.eq(round-places("99", "99", precision: -1), ("100", "", none))
#assert.eq(round-places("1", "299995", precision: 5), ("1", "30000", none))
#assert.eq(round-places("1", "299994", precision: 5), ("1", "29999", none))
#assert.eq(round-places("523", "", precision: -2), ("500", "", none))


#assert.eq(round("42", "3734", pm: ("", "0025"), precision: 2, mode: "uncertainty"), ("42", "3734", ("", "0025")))
#assert.eq(round("42", "3734", pm: ("", "0025"), precision: 1, mode: "uncertainty"), ("42", "373", ("", "003")))
#assert.eq(round("42", "3734", pm: ("2", "2"), precision: 1, mode: "uncertainty"), ("42", "", ("2", "")))
#assert.eq(round("42", "3734", pm: ("2", "2"), precision: 2, mode: "uncertainty"), ("42", "4", ("2", "2")))
#assert.eq(round("42", "3734", pm: ("2", "2"), precision: 3, mode: "uncertainty"), ("42", "37", ("2", "20")))

#assert.eq(round("4211", "3734", pm: ("230", "2"), precision: 1, mode: "uncertainty"), ("4200", "", ("200", "")))

#assert.eq(round("1", "23", pm: ("0", "2"), precision: 1, mode: "uncertainty"), ("1", "2",  ("0", "2")))
#assert.eq(round("123", "9", pm: ("020", ""), precision: 1, mode: "uncertainty"), ("120", "",  ("020", "")))
#assert.eq(
  round("1", "23", pm: (("0", "2"), ("0", "3")), precision: 1, mode: "uncertainty"), 
  ("1", "2",  (("0", "2"), ("0", "3")))
)
#assert.eq(
  round("123", "9", pm: (("020", ""), ("30", "")), precision: 1, mode: "uncertainty"), 
  ("120", "",  (("020", ""), ("30", "")))
)
#assert.eq(
  round("1", "23", pm: (("0", "24"), ("0", "3")), precision: 1, mode: "uncertainty"), 
  ("1", "2",  (("0", "2"), ("0", "3")))
)
#assert.eq(
  round("1", "23", pm: (("0", "04"), ("0", "3")), precision: 1, mode: "uncertainty"), 
  ("1", "23",  (("0", "04"), ("0", "30")))
)
