#import "../core/state.typ": folio-state
#import "../core/fallback.typ": missing

/// Formatter for currency values.
/// Signature: format-money(amount: int|float) -> content
#let format-money(amount) = context {
  let st = folio-state.get()

  // Try override from config
  let override = st.config.at("format-money", default: none)
  if type(override) == function {
    return override(amount)
  }

  if type(amount) != int and type(amount) != float {
    return missing("Invalid Money: " + str(amount))
  }

  let amount-str = str(calc.round(float(amount), digits: 2))
  let parts = amount-str.split(".")
  let int-part = parts.at(0)
  let dec-part = if parts.len() > 1 { parts.at(1) } else { "00" }
  if dec-part.len() == 1 { dec-part += "0" }

  let sep = ","
  let dec = "."

  let res = ""
  let count = 0
  let chars = int-part.clusters()
  for i in range(chars.len() - 1, -1, step: -1) {
    if count > 0 and calc.rem(count, 3) == 0 and chars.at(i) != "-" {
      res = sep + res
    }
    res = chars.at(i) + res
    count += 1
  }

  let currency-symbol = "$"

  return currency-symbol + res + dec + dec-part
}

/// Formatter for ISO date strings (YYYY-MM-DD).
/// Signature: format-date(date-str: str) -> content
#let format-date(date-str) = context {
  let st = folio-state.get()

  // Try override from config
  let override = st.config.at("format-date", default: none)
  if type(override) == function {
    return override(date-str)
  }

  if type(date-str) != str {
    return missing("Invalid Date: " + str(date-str))
  }

  // Validate ISO format YYYY-MM-DD with a regex before parsing
  if date-str.match(regex("^\d{4}-\d{2}-\d{2}$")) == none {
    return missing("Invalid Date Format: " + date-str)
  }

  let parts = date-str.split("-")
  let (y, m, d) = parts

  let months-en = (
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  )

  let m-idx = int(m) - 1
  if m-idx < 0 or m-idx > 11 {
    return missing("Invalid Month: " + m)
  }

  let month-name = months-en.at(m-idx)

  return month-name + " " + d + ", " + y
}

/// Formatter for percentage values.
/// Signature: format-percent(value: int|float, decimals: int) -> content
#let format-percent(value, decimals: 1) = context {
  let st = folio-state.get()

  // Try override from config
  let override = st.config.at("format-percent", default: none)
  if type(override) == function {
    return override(value)
  }

  // Handle string input (e.g., "85%" or "45.5%")
  if type(value) == str {
    let cleaned = value.replace("%", "").trim()
    if cleaned.match(regex("^-?\\d+\\.?\\d*$")) != none {
      return cleaned + "%"
    }
    return missing("Invalid Percent: " + value)
  }

  if type(value) != int and type(value) != float {
    return missing("Invalid Percent: " + str(value))
  }

  let rounded = calc.round(float(value), digits: decimals)
  return str(rounded) + "%"
}
