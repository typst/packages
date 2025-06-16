#import "helpers.typ" as H

#let default-hundreds-separator = state("separator-state", ",")
#let default-decimal = state("decimal-state", ".")

/// Converts a float to a string where the comma, decimal, and precision can be customized.
///
/// ```example
/// #format-float(123456, precision: 2, pad: true)\
/// #format-float(123456.1121, precision: 1, hundreds-separator: "_")
/// ```
///
/// - hundreds-separator (auto,str): The character to use to separate hundreds
/// - decimal (auto,str): The character to use to separate the integer and fractional portions
/// - precision (none,int): The number of digits to show after the decimal point. If `none`,
///   then no rounding will be done.
/// - pad (bool): If true, then the fractional portion will be padded with zeros to match the
///   precision if needed.
/// -> str
#let format-float(number,
  hundreds-separator: auto,
  decimal: auto,
  precision: none,
  pad: false,
) = {
  // Adds commas after each 3 digits to make
  // pricing more readable
  if hundreds-separator == auto {
    hundreds-separator = default-hundreds-separator.display()
  }
  if precision != none {
    number = calc.round(number, digits: precision)
  }
  if decimal == auto {
    decimal = default-decimal.display()
  }

  // negative != hyphen, so grab from unicode
  let negative-sign = str.from-unicode(0x2212)
  let sign = if number < 0 { negative-sign } else { "" }
  let number-pieces = str(number).split(".")
  let integer-portion = number-pieces.at(0).trim(negative-sign)
  let num-with-commas = ""
  for ii in range(integer-portion.len()) {
    if calc.rem(ii, 3) == 0 and ii > 0 {
      num-with-commas = hundreds-separator + num-with-commas
    }
    num-with-commas = integer-portion.at(-ii - 1) + num-with-commas
  }

  let frac-portion = if number-pieces.len() > 1 {
    number-pieces.at(1)
  } else {
    ""
  }
  if precision != none and pad {
    for _ in range(precision - frac-portion.len()) {
      frac-portion = frac-portion + "0"
    }
  }

  if frac-portion != "" {
    num-with-commas = num-with-commas + decimal + frac-portion
  }
  sign + num-with-commas
}

/// Converts a float to a United States dollar amount.
///
/// ```example
/// #format-usd(12.323)\
/// #format-usd(-12500.29)
/// ```
///
/// - number (float,int): The number to convert
/// - ..args (any): Passed to @@format-float()
/// -> str
#let format-usd(number, ..args) = {
  // "negative" sign if needed
  let sign = if number < 0 {str.from-unicode(0x2212)} else {""}
  let currency = "$"
  [#sign#currency]
  format-float(
    calc.abs(number), precision: 2, pad: true
  )
}


#let format-percent(number, ..args) = {
  format-float(number * 100, ..args) + "%"
}

#let format-content(value) = {
  if type(value) == str {
    value = eval(value, mode: "markup")
  }
  value
}

#let DEFAULT-TYPE-FORMATS = (
  string: (default-value: "", align: left),
  content: (display: format-content, align: left),
  float: (align: right),
  integer: (align: right),
  percent: (display: format-percent, align: right),
  // TODO: Better country-robust currency
  // currency: (display: format-currency, align: right),
  index: (align: right),
)


#let _value-to-display(value, value-info) = {
  if value == none {
    // TODO: Allow customizing `none` representation
    return value
  }
  if "display" in value-info {
    H.eval-str-or-function(value-info.display, scope: (value: value), positional: value)
  } else {
    value
  }
}

#let title-case(field) = field.replace("-", " ").split(" ").map(
  word => upper(word.at(0)) + word.slice(1)
).join(" ")


#let _field-info-to-tablex-kwargs(field-info) = {
  let get-eval(dict, key, default) = {
    let value = dict.at(key, default: default)
    if type(value) == "string" {
      eval(value)
    }
    else {
      value
    }
  }

  let (names, aligns, widths) = ((), (), ())
  for (key, info) in field-info.pairs() {
    if "title" in info {
      let original-field = key
      let scope = (field: original-field, title-case-field: title-case(original-field))
      key = H.eval-str-or-function(info.at("title"), scope: scope, positional: original-field)
      if type(key) not in (str, content) {
        key = repr(key)
      }
    }
    names.push(key)
    let default-align = if info.at("type", default: none) == "string" { left } else { right }
    aligns.push(get-eval(info, "align", default-align))
    widths.push(get-eval(info, "width", auto))
  }
  // Keys correspond to tablex specs other than "names" which is positional
  (names: names, align: aligns, columns: widths)
}

/// Converts a @@TableData into a `tablex` table. This is the main (and only intended)
/// way of rendering `tada` data. Most keywords can be overridden for customizing the
/// output.
///
/// ```example
/// #let td = TableData(
///   data: (a: (1, 2), b: (3, 4)),
/// // Tables can carry their own kwargs, too
///   tablex-kwargs: (inset: (x: 3em, y: 0.5em))
/// )
/// #to-tablex(td, fill: red)
/// ```
///
/// - td (TableData): The data to render
/// - ..tablex-kwargs (any): Passed to `tablex`
#let to-tablex(td, tablex-version: "0.0.6", ..tablex-kwargs) = {
  import "@preview/tablex:" + tablex-version: tablex, cellx, rowspanx

  let (field-info, type-info) = (td.field-info, td.type-info)
  // Order by field specification
  let to-show = field-info.keys().filter(
    key => not field-info.at(key).at("hide", default: false)
  )
  let subset = H.keep-keys(td.data, keys: to-show)
  // Make sure field info matches data order
  field-info = H.keep-keys(field-info, keys: subset.keys(), reorder: true)
  let display-columns = subset.pairs().map(key-column => {
    let (key, column) = key-column
    column.map(value => _value-to-display(value, field-info.at(key)))
  })
  let rows = H.transpose-values(display-columns)

  let col-spec = _field-info-to-tablex-kwargs(field-info)
  let names = col-spec.remove("names")
  // We don't want a completely flattened array, since some cells may contain many values.
  // So use sum() to join rows together instead
  tablex(..td.tablex-kwargs, ..col-spec, ..tablex-kwargs, ..names, ..rows.sum())
}