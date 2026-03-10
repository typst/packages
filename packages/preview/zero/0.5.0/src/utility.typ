
/// Takes a number by integer and fractional part and
/// shifts specified number of digits left. Negative values
/// for `digits` produce a right-shift. Numbers are automatically
/// padded with zeros but both integer and fractional parts
/// may become "empty" when they are zero. 
#let shift-decimal-left(integer, fractional, digits) = {
  if digits < 0 {
    let available-digits = calc.min(-digits, fractional.len())
    integer += fractional.slice(0, available-digits)
    integer += "0" * (-digits - available-digits)
    fractional = fractional.slice(available-digits)
    if integer.starts-with("0") {
      integer = (integer + ";").trim("0").slice(0,-1)
    }
  } else {
    let available-digits = calc.min(digits, integer.len())
    fractional = integer.slice(integer.len() - available-digits) + fractional
    fractional = "0" * (digits - available-digits) + fractional
    integer = integer.slice(0, integer.len() - available-digits)
  }
  return (integer, fractional)
}

#assert.eq(shift-decimal-left("123", "456", 0), ("123", "456"))
#assert.eq(shift-decimal-left("123", "456", 2), ("1", "23456"))
#assert.eq(shift-decimal-left("123", "456", 5), ("", "00123456"))
#assert.eq(shift-decimal-left("123", "456", -2), ("12345", "6"))
#assert.eq(shift-decimal-left("123", "456", -5), ("12345600", ""))
#assert.eq(shift-decimal-left("0", "0012", -4), ("12", ""))
#assert.eq(shift-decimal-left("0", "0012", -2), ("", "12"))
