#import "../utils/coercion.typ": to-decimal, to-ratio
#import "../utils/text.typ": invalid-xml-chars, invalid-xml-class, plain-text

/// The characters `xml-escape` has to change, as the body of a character
/// class of a regex: the markup characters and the characters XML 1.0 does
/// not allow (`invalid-xml-class` of utils/text.typ), built from the same
/// class so that the two cannot drift apart.
#let escaped-class = "&<>\"'" + invalid-xml-class

// Most values contain none of them. Compiled on first use (a call without
// arguments is memoized): the serializer writes plain texts without calling
// `xml-escape`.
#let _needs-escape() = regex("[" + escaped-class + "]")

// Escape a value for safe embedding in XML text/attribute content.
#let xml-escape(s) = {
  let value = if type(s) == str { s } else { plain-text(s) }
  // One scan instead of six replacements for the common case.
  if not value.contains(_needs-escape()) { return value }
  value
    .replace(invalid-xml-chars, "")
    .replace("&", "&amp;")
    .replace("<", "&lt;")
    .replace(">", "&gt;")
    .replace("\"", "&quot;")
    .replace("'", "&apos;")
}

#let _zero = decimal("0")

/// Formats a number for the XML: `.` as decimal separator, an ASCII minus sign,
/// no thousands separators, rounded to `max-digits` and padded to `min-digits`
/// decimals.
///
/// -> str
#let fmt-number(value, min-digits: 2, max-digits: 2) = {
  // The amounts of the model are decimals already.
  let number = if type(value) == decimal { value } else if (
    value == none or value == auto
  ) { _zero } else {
    to-decimal(value)
  }
  let rounded = calc.round(number, digits: max-digits)
  let (whole, fraction, ..) = str(calc.abs(rounded)).split(".") + ("",)
  fraction = fraction.trim("0", at: end, repeat: true)
  if fraction.len() < min-digits {
    fraction += "0" * (min-digits - fraction.len())
  }
  let result = if fraction == "" { whole } else { whole + "." + fraction }
  if rounded < _zero { "-" + result } else { result }
}

// The formats below are `fmt-number` with other arguments rather than
// functions that call it, which would add a call per number.

// Format a monetary amount (exactly 2 decimals, as required by BR-DEC-*).
#let fmt-amount = fmt-number

// Format a unit price (BT-146, BT-148), which keeps every decimal: the price
// the invoice prints (with the fine decimals of its locale), or the net price
// of a gross price, which has 6 decimals or more, 13 for a quantity of
// billions (see logic/net-amounts.typ). 28 is the most a decimal has, so
// nothing is rounded here.
#let fmt-price = fmt-number.with(max-digits: 28)

// Format a quantity (BT-129, BT-149) without losing its decimals.
#let fmt-quantity = fmt-number.with(max-digits: 6)

/// The decimals of a VAT rate in percent the XML states (BT-96, BT-103,
/// BT-119, BT-152). EN 16931 does not limit them; 4 state every real rate
/// exactly, e.g. 9.975%.
#let rate-digits = 4

// Format a decimal rate (0.19) as a ZUGFeRD percentage string: "19.00",
// "5.50", "9.975".
#let fmt-rate(rate) = fmt-number(
  to-ratio(rate) * 100,
  max-digits: rate-digits,
)

// Format a datetime as YYYYMMDD for the ZUGFeRD date format code 102.
#let fmt-date(date) = if type(date) == datetime and date.year() != none {
  date.display("[year][month][day]")
} else { none }

// A text written as it is: not blank, and nothing `xml-escape` changes.
#let _plain = {
  let c = escaped-class
  regex("^[^" + c + "]*[^\\s" + c + "][^" + c + "]*$")
}

// The element `tag` with the value `body` (see `dict-to-xml`). One call per
// element with children: plain texts, the common leaves, are written in the
// loop.
#let _element(tag, body) = {
  if body == none { return "" }
  if type(body) == array {
    let out = ""
    for item in body { out += _element(tag, item) }
    return out
  }
  if type(body) != dictionary {
    let text = if type(body) == str and _plain in body { body } else {
      xml-escape(body)
    }
    return if text.trim() == "" { "" } else {
      "<" + tag + ">" + text + "</" + tag + ">"
    }
  }
  let attrs = ""
  let out = ""
  for (key, value) in body {
    if value == none { continue }
    if type(value) == str and _plain in value {
      if key.starts-with("@") {
        attrs += " " + key.slice(1) + "=\"" + value + "\""
      } else if key == "" { out += value } else {
        out += "<" + key + ">" + value + "</" + key + ">"
      }
    } else if key.starts-with("@") {
      attrs += " " + key.slice(1) + "=\"" + xml-escape(value) + "\""
    } else if key == "" {
      if type(value) == dictionary {
        for (k, v) in value { out += _element(k, v) }
      } else { out += xml-escape(value) }
    } else { out += _element(key, value) }
  }
  // An identifier or code without its value would be invalid.
  if "" in body and out.trim() == "" { return "" }
  if out == "" { "<" + tag + attrs + " />" } else {
    "<" + tag + attrs + ">" + out + "</" + tag + ">"
  }
}

/// Serializes the builder's element tree `data` (see build.typ) into XML,
/// without the XML declaration. Keys starting with `@` are attributes, the
/// key `""` is the text of an element with attributes; an array repeats its
/// element. `none` and blank texts are left out, and so is an element whose
/// text is; an element without children is written empty.
///
/// -> str
#let dict-to-xml(data) = {
  if type(data) != dictionary {
    return if data == none { "" } else { xml-escape(data) }
  }
  let out = ""
  for (tag, body) in data { out += _element(tag, body) }
  out
}
