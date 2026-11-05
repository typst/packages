#import "util.typ": *


#let SI = (
  units: (
    second: "s", s: "s",
    meter: "m", m: "m",
    gram: "g", g: "g",
    ampere: "A", A: "A",
    kelvin: "K", K: "K",
    mole: "mol", mol: "mol",
    candela: "cd", cd: "cd",

    hertz: "Hz", Hz: "Hz",
    radian: "rad", rad: "rad",
    steradian: "sr", sr: "sr",
    newton: "N", N: "N",
    pascal: "Pa", Pa: "Pa",
    joule: "J", J: "J",
    watt: "W", W: "W",
    coulomb: "C", C: "C",
    volt: "V", V: "V",
    farad: "F", F: "F",
    ohm: "Ω", Ω: "Ω", o: "Ω",
    siemens: "S", S: "S",
    weber: "Wb", Wb: "Wb",
    tesla: "T", T: "T",
    henry: "H", H: "H",
    celcius: "℃", oC: "℃",
    lumen: "lm", lm: "lm",
    lux: "lx", lx: "lx",
    becquerel: "Bq", Bq: "Bq",
    gray: "Gy", Gy: "Gy",
    sievert: "Sv", Sv: "Sv",
    katal: "kat", kat: "kat",
  ),
  prefixes: (
    quetta: "Q", Q: "Q",
    ronna: "R", R: "R",
    yotta: "Y", Y: "Y",
    zetta: "Z", Z: "Z",
    exa: "E", E: "E",
    peta: "P", P: "P",
    tera: "T", T: "T",
    giga: "G", G: "G",
    mega: "M", M: "M",
    kilo: "k", k: "k",
    hecto: "h", h: "h",
    deca: "da", da: "da",

    deci: "d", d: "d",
    centi: "c", c: "c",
    milli: "m", m: "m",
    micro: "μ", μ: "μ", u: "μ",
    nano: "n", n: "n",
    pico: "p", p: "p",
    femto: "f", f: "f",
    atto: "a", a: "a",
    zepto: "z", z: "z",
    yocto: "y", y: "y",
    ronto: "r", r: "r",
    quecto: "q", q: "q",
  )
)


// [coeff][prefix]<ident>[exp][(desc)]
#let strunit(value) = {
  assert-type(value, str)
  assert(value.len() > 0, message: "Invalid unit: " + value)
  let str-value = value
  let value = value.codepoints()
  let alpha = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".codepoints()
  let greek = "αβγδεζηθικλμνξοπρσςτυφχψωΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ".codepoints()
  let extra = "%$".codepoints()
  let digits = "1234567890".codepoints()

  let unit = (coef: none, ident: none, per: false, exp: none, desc: none)
  
  let i = 0
  (unit.coef, i) = strtok(value, 0, c => c in digits)
  unit.coef = if unit.coef == "" { 1 } else { int(unit.coef) }
  assert(unit.coef != 0, message: "Invalid unit: " + str-value)

  // missing required ident
  assert(value.len() > i, message: "Invalid unit: " + str-value)

  (unit.ident, i) = strtok(value, i, c => c in alpha + greek + extra)
  assert(unit.ident.len() > 0, message: "Invalid unit: " + str-value)
  
  let si-unit = SI.units.keys()
    .filter(si-unit => unit.ident.ends-with(si-unit))
    .fold("", (acc, u) => if u.len() > acc.len() { u } else { acc })
  //assert(false, message: repr(unit.ident) + " || " + repr(SI.units.keys()))
  //assert(false, message: repr(SI.units.keys().filter(si-unit => unit.ident.ends-with(si-unit))))
  let si-prefix = if si-unit != none {
    SI.prefixes.keys().find(p => p == unit.ident.trim(si-unit, at: end))
  }

  if si-unit != none and si-prefix != none {
    unit.ident = SI.prefixes.at(si-prefix) + SI.units.at(si-unit)
  }
  else if si-unit != none and unit.ident in SI.units {
    unit.ident = SI.units.at(si-unit)
  }

  unit.per = value.len() > i and value.at(i) == "-"
  if unit.per { i += 1 }

  (unit.exp, i) = strtok(value, i, c => c in "1234567890")
  unit.exp = if unit.exp == "" { 1 } else { int(unit.exp) }
  assert(unit.exp != 0, message: "Invalid unit: " + str-value)

  if value.len() > i and value.at(i) == "(" {
    (unit.desc, i) = strtok(value, i + 1, c => c != ")")
    assert(unit.desc != "", message: "Invalid unit: " + str-value)
    assert(value.len() > i and value.at(i) == ")", message: "Invalid unit: " + str-value)
    i += 1
  }
  

  assert(value.len() == i, message: "Invalid unit: " + str-value)
  unit
}


#let strunits(value) = {
  value.replace(regex("\\s*\/\\s*"), " /")
    .split()
    .fold((), (acc, u) => 
      if u.starts-with("/") {
        let result = strunit(u.slice(1))
        result.per = true
        acc.push(result)
        acc
      }
      else {
        acc.push(strunit(u))
        acc
      } 
    )
}
