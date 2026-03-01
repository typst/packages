#let format-int(
  number,
  leading-zeros: true,
  leading-zeros-max: 3,
) = {
  let temp-number = int(number)
  let has-to-insert-leading-zeroes = leading-zeros
  let result = ""

  if temp-number == 0 {
    result = "0"
  }

  while temp-number > 0 or has-to-insert-leading-zeroes {
    result = str(calc.rem(temp-number, 10)) + result

    if result.len() >= leading-zeros-max {
      has-to-insert-leading-zeroes = false
    }

    temp-number = int(temp-number / 10)
  }

  result
}

#let format-currency(
  number,
  currency-thousands-separator,
  currency-comma-separator,
  currency-symbol,
  precision: 2,
) = {
  let number-before-comma = calc.floor(number)
  let number-after-comma = number - number-before-comma

  let thousands-blocks = ()
  if number-before-comma == 0 {
    thousands-blocks.insert(0, "0")
  }
  let temp-number = number-before-comma
  while temp-number > 0 {
    thousands-blocks.insert(0, format-int(calc.rem(temp-number, 1000), leading-zeros: temp-number >= 1000))
    temp-number = calc.floor(temp-number / 1000)
  }

  let result = thousands-blocks.join(currency-thousands-separator)

  let frac = calc.floor(number-after-comma * calc.pow(10, precision))
  result = result + currency-comma-separator + str(format-int(frac, leading-zeros: true, leading-zeros-max: precision))


  if currency-symbol == "$" {
    result = currency-symbol + result
  } else if currency-symbol == "€" {
    result = result + " " + currency-symbol
  } else {
    result = result + currency-symbol
  }

  result
}

#let sign(name) = {
  v(2em)
  line(length: 15em, stroke: 0.5pt)
  v(-0.4em)
  [#name]
}

/// Resolves the currency dict
/// Has to be called in context
#let resolve-currency(
  currency,
  i18n-currency,
) = {
  (
    currency-comma-separator: if currency.currency-comma-separator != none {
      currency.currency-comma-separator
    } else {
      i18n-currency.currency-comma-separator
    },
    currency-thousands-separator: if currency.currency-thousands-separator != none {
      currency.currency-thousands-separator
    } else {
      i18n-currency.currency-thousands-separator
    },
    currency-symbol: if currency.currency-symbol != none {
      currency.currency-symbol
    } else {
      i18n-currency.currency-symbol
    },
  )
}
