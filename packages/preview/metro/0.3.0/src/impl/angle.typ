#import "/src/utils.typ": content-to-string, combine-dict
#import "/src/defs/units.typ": rad, arcminute, arcsecond
#import "num/num.typ"

#let default-options = (
  angle-mode: "input",
  angle-symbol-degree: sym.degree,
  angle-symbol-minute: arcminute,
  angle-symbol-second: arcsecond,
  angle-separator: none,
  number-angle-product: none
)

// The following is used for complex numbers

#let is-angle(ang) = {
  let typ = type(ang)
  return typ == angle or (typ == str and ang.ends-with(regex("deg|rad"))) or (typ == content and repr(ang.func()) == "sequence" and ang.children.last() in (math.deg, rad))
}

#let to-number(ang) = {
  let typ = type(ang)
  return if typ == angle {
    ang
  } else if typ == str {
    float(ang.slice(0, ang.len() - 3)) * if ang.ends-with("deg") { 1deg } else { 1rad }
  } else {
    let children = ang.children
    let mult = if children.pop() == math.deg { 1deg } else { 1rad }
    float(content-to-string(children.join())) * mult
  }
}

// Note the options should hold num options
#let parse(options, ang) = {
  let typ = type(ang)
  return num.parse(
    options,
    to-number(ang) / if options.at("complex-angle-unit", default: "degrees") == "degrees" { 1deg } else { 1rad }
  )
}

// The following is used for the `ang` function

#let get-options(options) = combine-dict(options, default-options + num.default-options, only-update: true)

#let ang(ang, options) = {
  options = get-options(options)

  let input-mode = if ang.len() > 1 { "arc" } else { "decimal" }

  if options.angle-mode != "input" and input-mode != options.angle-mode {
    let to-float = num.to-float.with(options)
    ang = if input-mode == "arc" {
      (to-float(ang.first()) + to-float(ang.at(1)) / 60 + if ang.len() > 2 { to-float(ang.at(2)) / 3600},)
    } else {
      let a = to-float(ang.first())
      (calc.trunc(a),)
      a = calc.fract(a) * 60
      (calc.trunc(a),)
      a = calc.fract(a) * 60
      (calc.round(a),)
    }
  }

  let symbols = (
    options.angle-symbol-degree,
    options.angle-symbol-minute,
    options.angle-symbol-second
  )
  return math.equation({
    ang.zip(symbols).map(
      ((a, s)) => num.num(a, options) + options.number-angle-product + s
    ).join(options.angle-separator)
  })

}