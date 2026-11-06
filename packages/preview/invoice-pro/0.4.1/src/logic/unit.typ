#import "../locale/lang/base.typ": base-language
#import "../locale/region/base.typ": base-region

#let resolve-locale(locale) = {
  if type(locale) == function {
    return locale(base-language, base-region)
  } else if type(locale) == dictionary {
    return locale
  }
  panic("Invalid locale type: " + type(locale))
}

#let resolve-locale-strings(locale) = {
  let ctx = resolve-locale(locale)
  if "strings" in ctx {
    return ctx.strings
  }
  return ctx
}

#let resolve-plural(locale, value, quantity) = {
  if type(value) != dictionary or locale == none or quantity == none {
    return value
  }
  let ctx = resolve-locale(locale)
  let resolver = if "resolve-plural" in ctx {
    ctx.resolve-plural
  } else if (
    "strings" in ctx
      and "meta" in ctx.strings
      and "resolve-plural" in ctx.strings.meta
  ) {
    ctx.strings.meta.resolve-plural
  } else if "meta" in ctx and "resolve-plural" in ctx.meta {
    ctx.meta.resolve-plural
  } else {
    none
  }

  if resolver != none {
    return resolver(value, quantity)
  }
  let fallback = value.pairs().first(default: (none, none)).last()
  return value.at("singular", default: fallback)
}

#let make-unit(code, name) = (code: code, name: name, display: name)

#let piece(locale) = make-unit(
  "H87",
  resolve-locale-strings(locale).units.piece,
)
#let pieces = piece
#let stk = piece
#let pc = piece
#let pcs = piece

#let unit-set(locale) = make-unit(
  "SET",
  resolve-locale-strings(locale).units.at("set"),
)
#let set-unit = unit-set
#let sets = unit-set

#let pair(locale) = make-unit("PR", resolve-locale-strings(locale).units.pair)
#let pairs = pair
#let pr = pair

#let lump-sum(locale) = make-unit(
  "LS",
  resolve-locale-strings(locale).units.at("lump-sum"),
)
#let lumpsum = lump-sum
#let ls = lump-sum
#let pauschal = lump-sum
#let flat = lump-sum

#let hour(locale) = make-unit("HUR", resolve-locale-strings(locale).units.hour)
#let hours = hour
#let h = hour
#let hr = hour
#let hrs = hour

#let day(locale) = make-unit("DAY", resolve-locale-strings(locale).units.day)
#let days = day
#let d = day

#let month(locale) = make-unit(
  "MON",
  resolve-locale-strings(locale).units.month,
)
#let months = month
#let mo = month

#let year(locale) = make-unit("ANN", resolve-locale-strings(locale).units.year)
#let years = year
#let y = year
#let yr = year

#let kilogram(locale) = make-unit(
  "KGM",
  resolve-locale-strings(locale).units.kilogram,
)
#let kilograms = kilogram
#let kg = kilogram

#let gram(locale) = make-unit("GRM", resolve-locale-strings(locale).units.gram)
#let grams = gram
#let g = gram

#let tonne(locale) = make-unit(
  "TNE",
  resolve-locale-strings(locale).units.tonne,
)
#let tonnes = tonne
#let t = tonne

#let metre(locale) = make-unit(
  "MTR",
  resolve-locale-strings(locale).units.metre,
)
#let metres = metre
#let meter = metre
#let meters = metre
#let m = metre

#let square-metre(locale) = make-unit(
  "MTK",
  resolve-locale-strings(locale).units.at("square-metre"),
)
#let square-metres = square-metre
#let square-meter = square-metre
#let square-meters = square-metre
#let sqm = square-metre
#let m2 = square-metre

#let millimetre(locale) = make-unit(
  "MMT",
  resolve-locale-strings(locale).units.millimetre,
)
#let millimetres = millimetre
#let millimeter = millimetre
#let millimeters = millimetre
#let mm = millimetre

#let centimetre(locale) = make-unit(
  "CMT",
  resolve-locale-strings(locale).units.centimetre,
)
#let centimetres = centimetre
#let centimeter = centimetre
#let centimeters = centimetre
#let cm = centimetre

#let kilometre(locale) = make-unit(
  "KMT",
  resolve-locale-strings(locale).units.kilometre,
)
#let kilometres = kilometre
#let kilometer = kilometre
#let kilometers = kilometre
#let km = kilometre

#let litre(locale) = make-unit(
  "LTR",
  resolve-locale-strings(locale).units.litre,
)
#let litres = litre
#let liter = litre
#let liters = litre
#let l = litre

#let cubic-metre(locale) = make-unit(
  "MTQ",
  resolve-locale-strings(locale).units.at("cubic-metre"),
)
#let cubic-metres = cubic-metre
#let cubic-meter = cubic-metre
#let cubic-meters = cubic-metre
#let m3 = cubic-metre

#let resolve(unit, locale, quantity: none, default: none) = {
  let resolved = if type(unit) == function {
    unit(locale)
  } else if unit == auto {
    if type(default) == function {
      default(locale)
    } else {
      default
    }
  } else {
    unit
  }

  if type(resolved) == dictionary {
    if "display" in resolved or "name" in resolved or "code" in resolved {
      let disp = resolved.at("display", default: resolved.at(
        "name",
        default: none,
      ))
      let name-val = resolved.at("name", default: resolved.at(
        "display",
        default: none,
      ))

      if quantity != none and locale != none {
        disp = resolve-plural(locale, disp, quantity)
        name-val = resolve-plural(locale, name-val, quantity)
      }

      resolved.insert("display", disp)
      resolved.insert("name", name-val)
    } else {
      let val = if quantity != none and locale != none {
        resolve-plural(locale, resolved, quantity)
      } else {
        resolved.values().first(default: none)
      }
      resolved = (display: val, name: val)
    }
  } else if type(resolved) != none {
    if quantity != none and locale != none and type(resolved) == dictionary {
      resolved = resolve-plural(locale, resolved, quantity)
    }
  }
  resolved
}
