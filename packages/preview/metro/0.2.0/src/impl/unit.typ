#import "@preview/t4t:0.3.2": is
#import "/src/utils.typ": combine-dict, content-to-string

// NULL unicode character as a marker
#let NULL-after = [\u{FFFF} ]
#let NULL-before = [ \u{FFFF}]


#let tothe = (x) => math.attach(NULL-after, t: x)
#let raiseto = (x) => math.attach(NULL-before, t: x)
#let qualifier = (x) => math.attach(NULL-after, b: x)

#let parse(options, input) = {
  parse = parse.with(options)
  let func = repr(input.func())
  let out = (:)
  
  return if func == "attach" {
    if "t" in input.fields() {
      let power = float(content-to-string(input.t))
      if power < 0 {
        power *= -1
        (is-per: true)
      }
      (power: power)
    }
    if "b" in input.fields() {
      (qualifier: input.b)
    }
    (
      body: if input.base not in (NULL-after, NULL-before) {
        parse(input.base)
      } else {
        input.base
      }
    )
  } else if func == "frac" {
    (
      body: parse(input.num),
      per: (parse(input.denom),),
    )
  } else if func == "class" {
    if input.class == "unary" {
      (prefix: input.body)
    } else if input.class == "binary" and input.body == [per] {
      (is-per: true, body: NULL-before)
    }
  } else if func in ("text", "equation", "display") {
    (
      body: if func == "text" {
        input.text
      } else {
        input.body  
      }
    )
  } else if func == "lr" {
    parse(input.body.children.slice(1, -1).join())
  } else if func == "root" {
    (power: 0.5, body: parse(input.radicand))
  } else if func == "sequence" {
    let result = ((:),)
    let out = (:)
    let per-stuck = false
    for child in input.children {
      child = parse(child)
      if child == none {
        continue
      }

      if "body" in child {
        let body = child.remove("body")
        if body != NULL-after and "body" in out {
          if per-stuck or out.at("is-per", default: false) {
            result.last().per = result.last().at("per", default: ()) + (out,)
          } else {
            result.push(out)
          }
          if options.sticky-per and child.at("is-per", default: false) and body == NULL-before {
            per-stuck = true
          }
          out = (:)
        }
        if body not in (NULL-before, NULL-after) {
          out.body = body 
        }
      }
      if "power" in child {
        out.power = out.at("power", default: 1) * child.remove("power")
      }
      for (k, v) in child {
        if v != none {
          out.insert(k, v)
        }
      }
    }
    if "body" in out {
      if per-stuck or out.at("is-per", default: false) {
        result.last().per = result.last().at("per", default: ()) + (out,)
      } else {
        result.push(out)
      }
    }
    if result.len() > 1 {
      (body: result)
    } else {
      result.first()
    }
  }

}

#let display(options, input) = {
  let quantity-product = options.quantity-product
  options.quantity-product = none
  display = display.with(options)
  let out = if "body" in input {
    if type(input.body) == array {
      input.body.map(display).filter(x => x != none).join(options.inter-unit-product)
    } else if type(input.body) == dictionary {
      display(input.body)
    } else {
      input.body
    }
  }

  if "prefix" in input {
    out = input.prefix + out
  }
  
  if "power" in input or "qualifier" in input {
    if options.power-half-as-sqrt and "power" in input and calc.abs(calc.fract(input.power)) == 0.5 {
      input.power -= 0.5
      out = math.sqrt(out)
    }
    let has-qualifier = "qualifier" in input

    if has-qualifier {
      if options.qualifier-mode == "bracket" {
        out += "(" + input.qualifier + ")"
      } else if options.qualifier-mode == "phrase"{
        out += options.qualifier-phrase + input.qualifier
      }
    }

    out = math.attach(
      out,
      t: if "power" in input and input.power != 0 {
        str(input.power) 
      },
      b: if has-qualifier and options.qualifier-mode == "subscript" {
        input.qualifier
      }
    )
    if has-qualifier and options.qualifier-mode == "combine" {
      out += if out.t != none {
        "(" + input.qualifier + ")"
      } else {
        input.qualifier
      }
    }
  }

  if "per" in input {
    if options.per-mode == "power" { 
      out += if "body" in input { 
        options.inter-unit-product
      } + input.per.map(p => {
        p.power = p.at("power", default: 1) * -1
        display(p)
      }).join(options.inter-unit-product)
    } else if options.per-mode == "fraction" {
      out = math.frac(
        out,
        input.per.map(display).join(options.inter-unit-product)
      )
    } else if options.per-mode == "symbol" {
      let denom = input.per.map(display).join(options.inter-unit-product)
      if options.bracket-unit-denominator and input.per.len() > 1 {
        denom = "(" + denom + ")"
      }
      out += [#options.per-symbol] + [#denom]
    }
  }

  // Don't add a quantiy-prdouct if its in symbol mode and has a per 1/kg not 1 /kg
  return if quantity-product != none and (options.per-mode != "symbol" or "body" in input) { quantity-product + h(0pt)} + out
}

#let default-options = (
  inter-unit-product: sym.space.thin,
  per-symbol: sym.slash,
  bracket-unit-denominator: true,
  per-mode: "power",
  power-half-as-sqrt: false,
  qualifier-mode: "subscript",
  qualifier-phrase: "",
  sticky-per: false,
  units: none,
  prefixes: none,
  prefix-power-tens: none,
  powers: none,
  qualifiers: none,

  quantity-product: none
)

#let unit(unit, ..options) = {
  let input = unit
  assert(type(input) in (str, content), message: "Expected string or content input type, got " + type(input) + " instead.")
  options = combine-dict(
    options.named(),
    default-options,
    only-update: true,
  )

  if is.str(input) {
    // Converts the string input into math content
    // The first replace adds quote marks around words attached to underscores otherwise math doesn't capture the qualifier correctly.
    // Second replace removes slashes with pers as they allow no numerator to be present.
    input = eval(
      input.replace(regex("_(\w+)|(?:(?:_|of)\((.+?)\))"), (m) => {
        let c = m.captures
        "_\"" + if c.first() == none { 
          c.last()
        } else {
          c.first()
        } + "\""
      }).replace("/", " per ").trim(), 
      mode: "math",
      scope: options.units + options.prefixes + options.powers + options.qualifiers + (
        per: math.class("binary", "per"),
        tothe: tothe,
        raiseto: raiseto,
      )
    )
  }

  // When math content is passed directly it comes as an equation which we normally don't want to step into. If the equation is not exactly a known unit or prefix step into it.
  if is.elem(math.equation, input) and not input in options.units.values() and not input in options.prefixes.values() {
    input = input.body
  }

  math.upright(math.equation(
    display(options, parse(options, input))
  ))

}