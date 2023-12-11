#import "@preview/tablex:0.0.6": tablex, cellx, rowspanx
#import "helpers.typ": unique-row-keys, keep-keys

#let default-hundreds-separator = state("separator-state", ",")
#let default-decimal = state("decimal-state", ".")

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


#let format-percent(number, ..args) = {
  format-float(number * 100, ..args) + "%"
}

#let format-string = eval.with(mode: "markup")

#let DEFAULT-TYPE-FORMATS = (
  string: (default-value: "", display: format-string),
  float: (display: /*format-float*/ auto, align: right),
  integer: (display: /*format-float*/ auto, align: right),
  percent: (display: format-percent, align: right),
  // TODO: Better country-robust currency
  // currency: (display: format-currency, align: right),
  index: (align: right),
)


#let _value-to-display(value, value-info, row) = {
  if value == none {
    // TODO: Allow customizing `none` representation
    return value
  }
  let display-func = value-info.at("display", default: auto)
  if type(display-func) == str {
    value = eval(
      display-func,
      mode: "markup",
      scope: (value: value),
    )
  } else if display-func != auto {
    value = display-func(value)
  }
  value
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
      key = info.at("title")
      if type(key) == str {
        key = eval(
          key,
          mode: "markup",
          scope: (field: original-field, title-case-field: title-case(original-field))
        )
      } else if type(key) == function {
        key = key(original-field)
      }
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

#let to-tablex(td, ..tablex-kwargs) = {
  let (rows, field-info, type-info) = (td.rows, td.field-info, td.type-info)
  // Order by field specification
  let to-show = field-info.keys().filter(
    key => not field-info.at(key).at("hide", default: false)
  )
  field-info = keep-keys(field-info, keys: to-show)
  let rows-with-fields = rows.map(keep-keys.with(keys: to-show))
  let out = rows-with-fields.map(row => {
    row.pairs().map(
      // `pair` is a tuple of (key, value) for each field in the row
      pair => _value-to-display(pair.at(1), field-info.at(pair.at(0)), row)
    )
  })

  let col-spec = _field-info-to-tablex-kwargs(field-info)
  let names = col-spec.remove("names")
  tablex(..td.tablex-kwargs, ..col-spec, ..tablex-kwargs, ..names, ..out.flatten())
}