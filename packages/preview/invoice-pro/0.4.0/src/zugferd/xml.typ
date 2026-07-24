#import "../utils/coercion.typ": to-string

// Escape a value for safe embedding in XML text/attribute content.
#let xml-escape(s) = {
  let text = to-string(s) + ""
  text
    .replace("&", "&amp;")
    .replace("<", "&lt;")
    .replace(">", "&gt;")
    .replace("\"", "&quot;")
    .replace("'", "&apos;")
}

// Format a decimal/float as a ZUGFeRD amount string (dot separator, 2 decimal places).
#let fmt-amount(d) = {
  let raw-string = str(calc.round(d, digits: 2))
  let (num, decimal, ..) = raw-string.split(".") + ("00",)
  num + "." + (decimal + "00").slice(0, 2)
}

// Format a decimal rate (0.19) as a ZUGFeRD percentage string ("19.00").
#let fmt-rate(rate) = {
  let percent = calc.round(float(rate) * 100, digits: 2)
  fmt-amount(percent)
}

// Format a datetime as YYYYMMDD for the ZUGFeRD date format code 102.
#let fmt-date(date) = date.display("[year][month][day]")

// Serialize a Typst dictionary/value to XML format.
#let dict-to-xml(data) = {
  if data == none {
    return ""
  }
  if type(data) != dictionary {
    return xml-escape(data)
  }

  data
    .pairs()
    .map(((tag, body)) => {
      if body == none {
        return ""
      }

      if type(body) == array {
        return body.map(item => dict-to-xml(((tag): item))).join()
      }

      if type(body) == dictionary {
        let attrs = body
          .pairs()
          .filter(((k, _)) => k.starts-with("@"))
          .map(((k, v)) => " " + k.slice(1) + "=\"" + xml-escape(v) + "\"")
          .join()

        let children = body
          .pairs()
          .filter(((k, _)) => not k.starts-with("@"))
          .map(((k, v)) => {
            if k == "" {
              dict-to-xml(v)
            } else {
              dict-to-xml(((k): v))
            }
          })
          .join()

        return if children == "" {
          "<" + tag + attrs + " />"
        } else {
          "<" + tag + attrs + ">" + children + "</" + tag + ">"
        }
      }

      return "<" + tag + ">" + xml-escape(body) + "</" + tag + ">"
    })
    .join()
}

