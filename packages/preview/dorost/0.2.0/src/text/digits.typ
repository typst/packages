#let persian-digits(value) = {
  if type(value) != str and type(value) != int {
    panic("dorost: persian-digits accepts only strings and integers")
  }
  let result = str(value)
  let persian = ("۰", "۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹")
  for digit in range(10) {
    result = result.replace(str(digit), persian.at(digit))
  }
  result
}
