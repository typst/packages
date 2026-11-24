#let unit(
  value,
  per-mode: "^",
  product: " "
) = {
  import "util.typ": assert-type, assert-enum
  import "strunit.typ": strunits
  assert-type(value, str)
  assert-type(per-mode, str)
  assert-type(product, str)
  assert-enum(per-mode, "^", "/", "-")
  assert-enum(product, " ", ".")

  let show-unit = unit => {
    let per-exp = unit.per and per-mode == "^"
    let explicit-exp = unit.exp != 1 or per-exp
    if unit.coef != 1 { str(unit.coef) }
    if explicit-exp and unit.desc != none {
      math.attach(unit.ident,
        b: unit.desc,
        t: if per-exp [−] + [#unit.exp]
      )
    }
    else if explicit-exp {
      math.attach(unit.ident, t: if per-exp [−] + [#unit.exp])
    } else if unit.desc != none {
      math.attach(unit.ident, b: unit.desc)
    }
    else { unit.ident }
  }

  let units = strunits(value)
  
  product = if product == "." [⋅] else [ ]

  math.equation(math.upright(
    if per-mode == "^" {
      units.map(show-unit).join(product)
    }
    else if per-mode == "/" {
      let per-units = units.filter(unit => unit.per)
      let units = units.filter(unit => not unit.per)
      
      units.map(show-unit).join(product) + if per-units.len() >= 1 {(
        if units.len() >= 1 [ ] + [/] + [ ]
        + if per-units.len() > 1 {
          [(] + per-units.map(show-unit).join(product) + [)]
        } else {
          per-units.map(show-unit).join(product)
        }
      )}
    }
    else if per-mode == "-" {
      let per-units = units.filter(unit => unit.per)
      let units = units.filter(unit => not unit.per)

      if per-units.len() >= 1 {
        math.frac(
          if units.len() >= 1 { units.map(show-unit).join(product) } else [1],
          per-units.map(show-unit).join(product)
        )
      } else {
        units.map(show-unit).join(product)
      }
    }
  ))
}

#let number(
  value,
  e: none,
  pm: none,
  u: none,
  precision: auto,
  digits: auto,
  fixed: auto,
  point: auto, 
  explicit-sign: false,
  compact: false,
  show-pm: true,
  two-digit-rule-threshold: 0,

  u-opts: (per-mode: "^", product: "."),
) = {
  import "util.typ": assert-type, assert-enum
  assert-type(e, int, required: false)
  assert-type(pm, str, int, float, decimal, dictionary, required: false)
  assert-type(u, str, required: false)
  assert-type(precision, int, required: false)
  assert-type(digits, int, required: false)
  assert-type(fixed, bool, required: false)
  assert-type(point, type(auto), str)
  assert-type(explicit-sign, bool)
  assert-type(two-digit-rule-threshold, int)

  let is-asymetric-uncertainty = type(pm) == dictionary
  assert-enum(point, auto, ".", ",")
  if type(precision) == int {
    assert(precision > 0, message: "Invalid precision: " + str(precision))
  }
  if is-asymetric-uncertainty {
    assert("high" in pm and "low" in pm, message: "Invalid uncertainty: " + repr(pm))
  }

  import "richnum.typ": richnum
  import "strnum.typ"

  if pm == 0 or (type(pm) == str and pm.trim("0") in ("", ".")) { pm = none }

  if type(value) == str {
    let richnum = richnum(value)
    value = strnum.strnum(richnum.r)
    if e == none { e = richnum.e }
    if pm == none { pm = richnum.pm }
    if u == none { u = richnum.u }
    if point == auto { point = richnum.point }
    if explicit-sign == false { explicit-sign = richnum.explicit-sign }
    if fixed == auto { fixed = true }
    if digits == auto and precision == auto {
      digits = if value.decimal == none { 0 } else { value.decimal.len() }
    }
    if compact == false { compact = richnum.compact }
    if type(pm) == dictionary { is-asymetric-uncertainty = true }
  } else {
    value = strnum.strnum(value)
  }

  if point == auto { point = "," }
  if explicit-sign == auto { explicit-sign = false }
  if fixed == auto { fixed = false }

  if is-asymetric-uncertainty {
      pm.high = strnum.strnum(pm.high)
      pm.low = strnum.strnum(pm.low)
      pm.high.sign = none
      pm.low.sign = none
  } else if pm != none {
      pm = strnum.strnum(pm)
      pm.sign = none
  }
    
  if e == auto {
    e = strnum.first-sigfig(value) - 1
  }

  if e != none and e != 0 and fixed == false {
    value = strnum.shift(value, e)
    if is-asymetric-uncertainty {
      pm.high = strnum.shift(pm.high, e)
      pm.low = strnum.shift(pm.low, e)
    } else if pm != none {
      pm = strnum.shift(pm, e)
    }
  }

  if precision == auto and pm == none { precision = 3 }

  let round-to = if digits != auto {
    -digits + 1
  } else if precision == auto and is-asymetric-uncertainty {
    let first-sigfig = calc.max(strnum.first-sigfig(pm.high), strnum.first-sigfig(pm.low))
    if strnum.at-sigfig(pm.low, first-sigfig) <= two-digit-rule-threshold and strnum.at-sigfig(pm.high, first-sigfig) <= two-digit-rule-threshold {
      first-sigfig - 1
    } else {
      first-sigfig
    }
  } else if precision == auto and pm != none {
    let first-sigfig = strnum.first-sigfig(pm)
    if strnum.at-sigfig(pm, first-sigfig) <= two-digit-rule-threshold {
      first-sigfig - 1
    } else {
      first-sigfig
    }
  } else if precision != none and is-asymetric-uncertainty {
    calc.max(
      strnum.first-sigfig(pm.high),
      strnum.first-sigfig(pm.low)
    ) - precision + 1
  } else if precision != none and pm != none {
    strnum.first-sigfig(pm) - precision + 1
  } else if precision != none {
    strnum.first-sigfig(value) - precision + 1
  } else if pm == none {
    strnum.last-digit(value)
  } else if is-asymetric-uncertainty {
    calc.min(strnum.last-digit(value), calc.min(strnum.last-digit(pm.high), strnum.last-digit(pm.low)))
  } else {
    calc.min(strnum.last-digit(value), strnum.last-digit(pm))
  }

  if round-to != none {
    value = strnum.round(value, round-to)
    if is-asymetric-uncertainty {
      pm.high = strnum.round(pm.high, round-to)
      pm.low = strnum.round(pm.low, round-to)
    } else if pm != none {
      pm = strnum.round(pm, round-to)
    }
  }

  let result = strnum.str(value, point: point)

  if is-asymetric-uncertainty {
    result = math.attach(result,
      t: [+] + strnum.str(pm.high, point: point),
      b: [−] + strnum.str(pm.low, point: point)
    )
  } else if pm != none and compact {
    result += [(] + if pm.integer == "0" { pm.decimal.trim("0", at: start) } else { strnum.str(pm, point: point) } + [)]
  } else if pm != none {
    result += [±] + strnum.str(pm, point: point)
  }

  if e != none and e != 0 {
    if pm != none and not is-asymetric-uncertainty { result = [(] + result + [)] }
    result += [×] + math.attach(t: str(e))[10]
  }

  if u != none {
    if (e != none and e != 0) or (pm != none and show-pm and not is-asymetric-uncertainty and not compact) { result = [(] + result + [)] }
    result += [ ]
    result += unit(u, ..u-opts).body
  }

  math.equation(result)
}

/// TODO: parse case value = "{deg};[arcmin];[arcsec]"
#let angle(
  value,
  pm: none,
  precision: auto,

  point: ",",
  mode: "decimal"
) = {
  import "util.typ": assert-type, assert-enum, group-digits
  assert-type(value, int, float, str, decimal)
  assert-type(mode, str)
  assert-enum(mode, "decimal", "arc")

  import "strnum.typ"
  import "richnum.typ": richnum

  let arc(strnum) = if strnum.decimal == none {
    (deg: strnum.integer, arcmin: none, arcsec: none)
  } else {
    let dec = float("." + strnum.decimal)
    let arcmin = calc.floor(60 * dec)
    let arcsec = calc.round(3600 * (dec - arcmin / 60), digits: 2)
    arcmin = if arcmin == 0 { arcmin = none } else { str(arcmin) }
    arcsec = if arcsec == 0 { arcsec = none } else { str(arcsec) }

    (deg: strnum.integer, arcmin: arcmin, arcsec: arcsec)
  }

  let show-arc = arc => (
    group-digits(arc.deg) + "°"
    + if arc.arcmin != none { " " + group-digits(arc.arcmin) + "′" }
    + if arc.arcsec != none { " " + strnum.str(strnum.strnum(arc.arcsec), point: point) + "″" }
  )
  
  let richnum = richnum(value, pm: pm, precision: precision)
  assert.eq(richnum.e, none, message: "Invalid angle: " + repr(value))
  assert.eq(richnum.u, none, message: "Invalid angle: " + repr(value))

  if mode == "decimal" {
    let result = strnum.str(richnum.r, point: point)
    
    if richnum.pm != none {
      result = [(] + result + [±] + strnum.str(richnum.pm, point: point) + [)]
    }

    math.equation(result + [°])
  } else if mode == "arc" {
    let result = show-arc(arc(richnum.r))
    if richnum.pm != none {
      result = [(] + result + [±] + show-arc(arc(richnum.pm)) + [)]
    }

    math.equation(result)
  }
}
