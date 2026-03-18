#import "@preview/t4t:0.2.0": is

#let _is-elem(elem, name) = {
  return type(elem) == "content" and repr(elem.func()) == name
}

#let res-default = (body: none, power: none, qualifier: none, per: none)

// NULL unicode character as a marker
#let NULL-after = [\u{FFFF} ]
#let NULL-before = [ \u{FFFF}]


#let tothe = (x) => math.attach(NULL-after, t: x)
#let raiseto = (x) => math.attach(NULL-before, t: x)
#let qualifier = (x) => math.attach(NULL-after, b: x)

#let parse-math-units(input, options) = {
  let results = ()

  let stack = (if is.elem(math.equation, input) and not input in options.units.values() and not input in options.prefixes.values()  {
    input.body
  } else {
    input
  },)

  let res = res-default
  let prefix = none
  let per = 0
  let func = none

  while stack.len() > 0 {
    let cur = stack.pop()
    func = none

    if cur != true {
      func = repr(cur.func())
      
      if func == "attach" {
        if "t" in cur.fields() {
          res.power = cur.t
        }
        if "b" in cur.fields() {
          res.qualifier = cur.b
        }
        if not cur.base in (NULL-after, NULL-before) {
          stack.push(cur.base)
        } else if cur.base == NULL-after {

          let last = if results.last().per == none {
            results.last()
          } else {
            results.last().per.last()
          }

          if res.power != none {
            last.power = res.power
            res.power = none
          }
          if res.qualifier != none {
            last.qualifier = res.qualifier
            res.qualifier = none
          }

          if results.last().per == none {
            results.last() = last
          } else {
            results.last().per.last() = last
          }
        }
      } else if func == "frac" {
        stack += (cur.denom, true, cur.num)
      } else if func == "class" {
        if cur.class == "unary" {
          prefix = cur.body
        } else if cur.class == "binary" and cur.body == [per] {
          per += if options.sticky-per {
            9999 // If there is a unit this long I'll be impressed
          } else {
            1
          }
        }
      } else if func in ("text", "equation", "display") {
        res.body += cur
      } else if func == "lr" {
        stack.push(cur.body.children.slice(1, -1).join())
      } else if func == "sequence" {
        stack += cur.children.rev()
        if per > 0 {
          per += cur.children.filter(x => x == [ ]).len()
        }
      }
    }
    if (cur == true or func == "space") and res.body != none or stack.len() == 0 {
      if prefix != none {
        res.body = prefix + res.body
        prefix = none
      }
      if per > 0 {
        if results.len() == 0 {
          results.push(res-default)
        }
        results.last().per += (res,)
        per -= 1
      } else {
        results.push(res)
      }
      if cur == true {
        per += 1
      }
      res = res-default
    }
  }

  if not options.sticky-per and per > 0 {
    panic("A per somewhere does not have a denominator")
  }

  return results
}

#let parse-string-units(input, options) = {

  return parse-math-units(
    eval(
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
    ),
    options
  )

}

#let display-units(input, options, top: false) = {
  let result = ()
  let stack = input.rev()
  let pers = ()
  while stack.len() > 0 {
    let cur = stack.pop()
    let res = cur.at("body", default: [])

    if cur.power != none or cur.qualifier != none {
      // Need to add bracket qualifier before turning res into an attach
      if options.qualifier-mode == "bracket" and cur.qualifier != none {
        res += "(" + cur.qualifier + ")"
      } else if options.qualifier-mode == "phrase" and cur.qualifier != none{
        res += options.qualifier-phrase + cur.qualifier
      }

      if options.power-half-as-sqrt {
        res = math.sqrt(res)
        cur.power = none
      }

      res = math.attach(
        res, 
        t: cur.power,
        // b will be none if false
        b: if options.qualifier-mode == "subscript" {
          cur.qualifier
        }
      )
      if options.qualifier-mode == "combine" and cur.qualifier != none {
        res += if res.t != none {
          "(" + cur.qualifier + ")"
        } else {
          cur.qualifier
        }
      }
    }
    if cur.per != none {
      if options.per-mode == "power" {
        result.push(res)
        result.push(
          display-units(
            cur.per.map(p => {
              let minus = [#sym.minus]
              let power = if p.power != none {
                if _is-elem(p.power, "sequence") {
                  if p.power.children.first() == minus {
                    p.power.children.slice(1)
                  } else {
                    p.power.children.insert(0, minus)
                  }.join()
                } else {
                  minus + p.power
                }
              } else {
                $-1$
              }
              p.power = power
              return p
            }), 
            options
          )
        )
        continue
      } else if options.per-mode == "fraction" {
        res = math.frac(
            res,
            display-units(cur.per, options)
          )
      } else if options.per-mode == "symbol" {
        // let brackets = 
        let denom = display-units(cur.per, options)
        if options.bracket-unit-denominator and cur.per.len() > 1 {
          denom = "(" + denom + ")"
        }
        res = res + options.per-symbol + denom
      }
    }

    result.push(res)
  }

  result = result.join(options.inter-unit-product)

  return if top {
    math.upright(result)
  } else {
    result
  }
}