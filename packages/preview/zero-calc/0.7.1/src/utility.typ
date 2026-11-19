#import "@preview/zero:0.7.1": *
#import impl.utility: *
#import "units.typ"

#let symbol-names = (
  math.alpha: "alpha",
  math.Alpha: "Alpha",
  math.beta: "beta",
  math.Beta: "Beta",
  math.gamma: "gamma",
  math.Gamma: "Gamma",
  math.delta: "delta",
  math.Delta: "Delta",
  math.epsilon: "epsilon",
  math.Epsilon: "Epsilon",
  math.zeta: "zeta",
  math.Zeta: "Zeta",
  math.eta: "eta",
  math.Eta: "Eta",
  math.theta: "theta",
  math.Theta: "Theta",
  math.iota: "iota",
  math.Iota: "Iota",
  math.kappa: "kappa",
  math.Kappa: "Kappa",
  math.lambda: "lambda",
  math.Lambda: "Lambda",
  math.mu: "mu",
  math.Mu: "Mu",
  math.nu: "nu",
  math.Nu: "Nu",
  math.xi: "xi",
  math.Xi: "Xi",
  math.omicron: "omicron",
  math.Omicron: "Omicron",
  math.pi: "pi",
  math.Pi: "Pi",
  math.rho: "rho",
  math.Rho: "Rho",
  math.sigma: "sigma",
  math.Sigma: "Sigma",
  math.tau: "tau",
  math.Tau: "Tau",
  math.upsilon: "upsilon",
  math.Upsilon: "Upsilon",
  math.phi: "phi",
  math.Phi: "Phi",
  math.chi: "chi",
  math.Chi: "Chi",
  math.psi: "psi",
  math.Psi: "Psi",
  math.omega: "omega",
  math.Omega: "Omega",
)


#let prefixes = (
  "k": 3,
  "M": 6,
  "G": 9,
  "T": 12,
  "P": 15,
  "E": 18,
  "d": -1,
  "c": -2,
  "m": -3,
  "µ": -6,
  "n": -9,
  "p": -12,
  "f": -15,
  "a": -18,
)

#let typst-builtin-symbol = [--].func()
#let valid-number-regex = regex("[+\-]?(\d+\.\d*|\d*\.\d+|\d+)([e][+\-]?\d+)?")
#let invisible-symbols = regex("[, \)]")
#let illegal-symbols = regex("[.−\(]")

#let to-str(content) = {
  if content == none {
    return none
  } else if type(content) == str {
    content
  } else if content.has("text") {
    let alternative-name = symbol-names.at(content.text, default: none)
    if alternative-name != none {
      alternative-name
    } else if (type(content.text) == str) {
      content.text
    } else {
      to-str(content.text)
    }
  } else if content.func() == math.attach {
    (
      to-str(content.base) + "-",
      to-str(content.at("b", default: none)),
      to-str(content.at("br", default: none)),
      to-str(content.at("bl", default: none)),
      to-str(content.at("t", default: none)),
      to-str(content.at("tr", default: none)),
      to-str(content.at("tl", default: none)),
    )
      .filter(x => x != none)
      .join()
  } else if content.has("children") {
    content.children.map(to-str).join("")
  } else if content.has("body") {
    to-str(content.body)
  } else if content == [ ] {
    "-"
  }
}

#let as-float(value) = {
  if value.at("float", default: none) != none {
    value.float
  } else if value.at("raw", default: none) != none and (type(value.raw) == int or type(value.raw) == float) {
    value.raw
  } else if value.at("info", default: none) != none {
    info-to-float(value.info)
  } else {
    0
  }
}
#let as-uncertainty(value) = {
  if value.at("uncertainty", default: none) != none {
    value.uncertainty
  } else if value.at("info", default: none) != none {
    info-to-uncertainty(value.info)
  }
}

#let as-round(value) = {
  let args = value.at("args", default: none)
  if args != none {
    return args.named().at("round", default: value.at("round", default: none))
  }
  return value.at("round", default: none)
}

#let is-finite(x) = type(x) != float or (x == x and calc.abs(x) != float.inf)

#let round-float-noise(x) = {
  if x == none or x == 0 or type(x) != float or not is-finite(x) { return x }
  let n = 12 - calc.floor(calc.log(calc.abs(x), base: 10))
  if calc.abs(n) > 22 { return x }
  let scale = float("1e" + str(calc.abs(n)).replace("−", "-"))
  if n >= 0 { float(calc.round(x * scale)) / scale } else { float(calc.round(x / scale)) * scale }
}

#let round-option(round, key) = {
  if round == none { return none }
  let value = round.at(key, default: none)
  if value == auto { none } else { value }
}
#let leading-zeros(digits) = digits.len() - digits.trim("0", at: start).len()
#let int-e(info) = if info.e == none { 0 } else { int(info.e) }

#let figures-to-places(int, frac, precision) = {
  let digits = int + frac
  if digits.trim("0") == "" { return 0 }
  precision + leading-zeros(digits) - int.len()
}

#let places-to-figures(int, frac, places) = {
  let digits = int + frac
  let lead = leading-zeros(digits)
  if lead == digits.len() { return calc.max(1, places + 1) }
  calc.max(1, places + int.len() - lead)
}

#let operand-digits(info, round) = {
  let mode = round-option(round, "mode")
  if mode == none { mode = "places" }
  let precision = round-option(round, "precision")
  let (int, frac) = (info.int, info.frac)
  let places = if precision == none { frac.len() } else if mode == "figures" {
    figures-to-places(int, frac, precision)
  } else { precision }
  let figures = if precision != none and mode == "figures" { precision } else {
    places-to-figures(int, frac, places)
  }
  let result = (e: int-e(info), places: places, figures: figures, u-places: none, u-figures: none)
  let pm = info.at("pm", default: none)
  if pm not in (none, ()) {
    if type(pm.first()) == array { pm = pm.first() }
    let (pint, pfrac) = pm
    let spec = round-option(round, "uncertainty-precision")
    let u-places = if spec == none { pfrac.len() } else if type(spec) == dictionary { spec.places } else {
      figures-to-places(pint, pfrac, spec)
    }
    let u-figures = if type(spec) == int { spec } else { places-to-figures(pint, pfrac, u-places) }
    result += (u-places: u-places, u-figures: u-figures)
  }
  result
}
#let get-last-digits(infos) = {
  if infos == () { return none }
  let digits = infos.map(((info, round)) => operand-digits(info, round))
  let value = calc.min(calc.max(..digits.map(d => d.e - d.places)), calc.min(..digits.map(d => d.e)))
  let with-error = digits.filter(d => d.u-places != none)
  let uncertainty = if with-error.len() > 0 { calc.max(..with-error.map(d => d.e - d.u-places)) }
  if uncertainty != none { value = uncertainty }
  (value: value, uncertainty: uncertainty)
}

#let get-sig-figs(infos) = {
  if infos == () { return none }
  let digits = infos.map(((info, round)) => operand-digits(info, round))
  let round = (precision: calc.min(..digits.map(d => d.figures)), mode: "figures", pad: true)
  let uncertainties = digits.filter(d => d.u-figures != none).map(d => d.u-figures)
  if uncertainties.len() > 0 { round += (uncertainty-precision: calc.min(..uncertainties)) }
  round
}
#let round-significant(x, precision) = {
  let places = precision - 1 - calc.floor(calc.log(x, base: 10))
  if places > 300 { return x }
  if places >= 0 { calc.round(x, digits: places) } else {
    let scale = float("1e" + str(-places))
    calc.round(x / scale) * scale
  }
}

#let round-at(x, lsd) = {
  if x == 0 or not is-finite(x) { return x }
  if lsd <= 0 { calc.round(x, digits: calc.min(-lsd, 300)) } else {
    let scale = float("1e" + str(lsd))
    calc.round(x / scale) * scale
  }
}

#let get-value-e(value, round: none) = {
  if value == 0 or not is-finite(value) { return 0 }
  let x = calc.abs(round-float-noise(value))
  let precision = round-option(round, "precision")
  if precision != none and round-option(round, "mode") == "figures" { x = round-significant(x, precision) }
  calc.floor(calc.log(x, base: 10))
}

#let result-e(value, round: none) = {
  let e = get-value-e(value, round: round)
  if e == 1 { 0 } else { e }
}

#let rss(terms) = {
  terms = terms.filter(x => x != none)
  if terms != () { calc.sqrt(terms.map(t => t * t).sum()) }
}

#let create-info(value, uncertainty, e) = {
  if not is-finite(value) { return impl.parsing.parse-numeral(value) }
  let value = round-float-noise(value)
  let uncertainty = round-float-noise(uncertainty)
  let (integer, fractional) = impl.utility.shift-decimal-left(
    ..impl.parsing.decompose-unsigned-float-numeral(str(calc.abs(value))),
    digits: e,
  )
  return (
    int: integer,
    frac: fractional,
    sign: if value >= 0 { "+" } else { "-" },
    pm: if uncertainty != none {
      impl.utility.shift-decimal-left(
        ..impl.parsing.decompose-unsigned-float-numeral(str(calc.abs(uncertainty))),
        digits: e,
      )
    },
    e: if e != 0 { str(e).replace("−", "-") },
  )
}

#let uncertainty-precision-of(uncertainty, digits, e) = {
  let last = if digits.uncertainty != none { digits.uncertainty } else { digits.value }
  let figures = if uncertainty == 0 { 0 } else { get-value-e(uncertainty) - last + 1 }
  (uncertainty-precision: if figures >= 1 { figures } else { (places: calc.max(0, e - last)) })
}
#let create-add-result(value, uncertainty, digits, plain: true) = {
  if digits == none {
    return (info: create-info(value, uncertainty, if plain { 0 } else { result-e(value) }), round: none)
  }
  let last = digits.value
  let rounded = round-at(value, last)
  let e = if plain { 0 } else { result-e(rounded) }

  if rounded == 0 {
    let info = create-info(0.0, uncertainty, e)
    if uncertainty == none {
      return (info: info + (frac: "0" * calc.max(0, -last)), round: none)
    }
    return (
      info: info,
      round: (mode: "figures", pad: true, precision: calc.max(1, 1 - last))
        + uncertainty-precision-of(uncertainty, digits, e),
    )
  }

  let shown = if get-value-e(rounded) != get-value-e(value) { rounded } else { value }
  let round = (
    mode: "figures",
    pad: true,
    precision: calc.max(1, get-value-e(shown) - last + 1),
  )
  if uncertainty != none { round += uncertainty-precision-of(uncertainty, digits, e) }
  (info: create-info(shown, uncertainty, e), round: round)
}

#let flag-special(result) = {
  let x = result.at("float", default: none)
  if type(x) != float { return result }
  if x != x { result.undefined = true } else if calc.abs(x) == float.inf { result.infinite = true }
  result
}
#let is-undefined(x) = type(x) == dictionary and x.at("undefined", default: false)
#let is-infinite(x) = type(x) == dictionary and x.at("infinite", default: false)

#let undefined-result(head, data) = (
  float: float.nan,
  uncertainty: none,
  info: (int: "", frac: "", sign: "+", pm: none, e: none),
  round: none,
  unit: none,
  constant: false,
  source: (head: head, data: data),
  args: arguments(),
  undefined: true,
)

#let num-metadata(info, raw, args) = flag-special((
  float: if type(raw) != float and type(raw) != int { impl.utility.info-to-float(info) } else { raw },
  uncertainty: impl.utility.info-to-uncertainty(info),
  info: info,
  args: args,
))

#let merge-args(terms, unit: none) = {
  let named = (:)
  for term in terms.rev() {
    let args = term.at("args", default: none)
    if args == none { continue }
    let operand-named = args.named()
    let _ = operand-named.remove("round", default: none)
    if not units.equal(term.at("unit", default: none), unit) {
      let _ = operand-named.remove("alt", default: none)
    }
    named += operand-named
  }
  arguments(..named)
}

#let with-call-args(result, call) = {
  let inherited = result.at("args", default: none)
  let named = if inherited == none { (:) } else { inherited.named() }
  result.args = arguments(..(named + call.named()))
  result
}

#let assert-usable(data) = {
  assert(
    not is-undefined(data),
    message: "zcalc: an operand is undefined (e.g. a division by zero), it cannot be used in another calculation.",
  )
  assert(not is-infinite(data), message: "zcalc: an operand is infinite, it cannot be used in another calculation.")
  data
}

#let create-result-metadata(value) = [#metadata(value)<calc-result>]

#let default-state = (
  preferred-units: (),
)

#let zcalc-state = state("zcalc-state", default-state)

#let normalise-quantity(candidate, allow-special: false) = {
  let t = type(candidate)
  let data = impl.utility.retrieve-metadata(candidate)
  if data == none {
    if t == dictionary {
      data = candidate
    } else if (t == int or t == float or t == str or t == content) {
      data = num-metadata(impl.parsing.parse-numeral(candidate), candidate, arguments())
    }
  }
  if data != none and not allow-special { assert-usable(data) }
  data
}

#let normalise-constant(candidate) = {
  let data = normalise-quantity(candidate, allow-special: true)
  assert(not is-undefined(data), message: "zcalc: a constant cannot be undefined.")
  data.constant = true
  data
}

#let normalise-quantities(quantities) = quantities.map(candidate => normalise-quantity(candidate))
