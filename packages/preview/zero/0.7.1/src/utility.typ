
/// Takes a number by integer and fractional part and
/// shifts specified number of digits left. Negative values
/// for `digits` produce a right-shift. Numbers are automatically
/// padded with zeros but both integer and fractional parts
/// may become "empty" when they are zero.
/// -> (str, str)
#let shift-decimal-left(
  /// The integer part of a number as a string of digits.
  /// -> str
  integer,
  /// The fractional part of a number as a string of digits.
  /// -> str
  fractional,
  /// By how many digits to shift the number.
  /// -> int
  digits: 0,
) = {
  if digits < 0 {
    let available-digits = calc.min(-digits, fractional.len())
    integer += fractional.slice(0, available-digits)
    integer += "0" * (-digits - available-digits)
    fractional = fractional.slice(available-digits)
    if integer.starts-with("0") {
      integer = (integer + ";").trim("0").slice(0, -1)
    }
  } else {
    let available-digits = calc.min(digits, integer.len())
    fractional = integer.slice(integer.len() - available-digits) + fractional
    fractional = "0" * (digits - available-digits) + fractional
    integer = integer.slice(0, integer.len() - available-digits)
  }
  if integer == "" {
    integer = "0"
  }
  return (integer, fractional)
}

#assert.eq(shift-decimal-left("123", "456", digits: 0), ("123", "456"))
#assert.eq(shift-decimal-left("123", "456", digits: 2), ("1", "23456"))
#assert.eq(shift-decimal-left("123", "456", digits: 5), ("0", "00123456"))
#assert.eq(shift-decimal-left("123", "456", digits: -2), ("12345", "6"))
#assert.eq(shift-decimal-left("123", "456", digits: -5), ("12345600", ""))
#assert.eq(shift-decimal-left("0", "0012", digits: -4), ("12", ""))
#assert.eq(shift-decimal-left("0", "0012", digits: -2), ("0", "12"))


#let process-breakable(breakable) = {
  let default = (
    uncertainty: false,
    power: false,
    unit: false,
  )

  if breakable == false {
    return default
  }
  if breakable == true {
    return (
      uncertainty: true,
      power: true,
      unit: true,
    )
  }
  if type(breakable) == dictionary {
    return default + breakable
  }
  assert(false)
}

#let info-to-float(value) = {
  let f = float(
    value.sign
      + value.int
      + if value.frac != "" { "." + value.frac }
      + if value.e != none and not value.e.contains(".") { "e" + value.e },
  )

  if value.e != none and value.e.contains(".") {
    f *= calc.pow(10, float(value.e))
  }
  return f
}

#let info-to-uncertainty(value) = if value.pm != none {
  if type(value.pm.first()) == array {
    value.pm.map(x => float(x.at(0) + "." + x.at(1) + if value.e != none { "e" + value.e }))
  } else {
    float(value.pm.at(0) + "." + value.pm.at(1) + if value.e != none { "e" + value.e })
  }
}

#let create-num-metadata(info, raw, args) = [#metadata((
  info: info,
  raw: raw,
  args: args,
))<zero-num>]

#let create-qty-metadata(info, raw, unit, ..args) = [#metadata((
  info: info,
  unit: unit,
  raw: raw,
  args: args,
))<zero-qty>]

#let create-unit-metadata(unit, ..args) = [#metadata((
  unit: unit,
  args: args,
))<zero-unit>]

#let _sequence = ([A] + [B]).func()
#let retrieve-metadata(it) = {
  if type(it) == content and it.func() == _sequence {
    if it.children.first().func() == metadata {
      return it.children.first().value
    }
  }
}
