#import "@preview/t4t:0.2.0": is
#import "../utils.typ": combine-dict

#let _is-elem(elem, name) = {
  return type(elem) == "content" and repr(elem.func()) == name
}


// NULL unicode character as a marker
#let NULL-after = [\u{FFFF} ]
#let NULL-before = [ \u{FFFF}]


#let tothe = (x) => math.attach(NULL-after, t: x)
#let raiseto = (x) => math.attach(NULL-before, t: x)
#let qualifier = (x) => math.attach(NULL-after, b: x)

// Converts an array of dictionaries into math content
#let display-units(input, options, top: false) = {
  let result = ()
  // This isn't really a stack we could just use a for loop to be honest.
  // Recursion is used here because the input already has been parsed so we know we won't have to modify a previous element. Only the current one.
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

// Converts content or string into an array of dictionaries then passes them to display-units
#let _unit(input, options) = {
  assert(type(input) in ("string", "content"), message: "Expected string or content input type, got " + type(input) + " instead.")

  let input = if type(input) == "string" {
    // Converts the string input into math content
    // The first replace adds quote marks around words attached to underscores otherwise math doesn't capture the qualifier correctly.
    // Second replace removes slashes with pers as they allow no numerator to be present.
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
    )
  } else {
    input
  }


  // When math content is passed directly it comes as an equation which we normally don't want to step into. If the equation is not exactly a known unit or prefix step into it.
  if is.elem(math.equation, input) and not input in options.units.values() and not input in options.prefixes.values() {
    input = input.body
  }

  // Loop over the content as a stack to avoid recursion. We also need to directly modify previous res so recursion isn't the best solution here.
  let stack = (input,)

  // Use a default instead of empty dictionary as sometimes need to append content which would require a check to see if the key has been already added or not.
  let res-default = (body: none, power: none, qualifier: none, per: none)
  // Operate on res which eventually gets pushed onto results
  let res = res-default
  let results = ()
  // The current prefix to prepend onto res.body when it gets pushed to results
  let prefix = none
  // How many res left to push to the previous ones per
  let per = 0
  // The string of the content's function
  let func = none

  while stack.len() > 0 {
    // current, normally content but can be `true` when res becomes a numerator and causes per to increment
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

        // Use NULL-* as a marker for powers and qualifiers as they won't be directly attached to their body. We don't need to process them as they shouldn't be outputed
        if not cur.base in (NULL-after, NULL-before) {
          stack.push(cur.base)
        } else if cur.base == NULL-after {
          // Add the res power and qualifier to the previous.
          // We don't do this to a NULL-before as the res will persist for the next loop.
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
        // This is where cur can become true
        stack += (cur.denom, true, cur.num)
      } else if func == "class" {
        // We use classes as special markers
        if cur.class == "unary" {
          // unary is always a prefix, we add a check in future to make sure the prefix is known.
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

  return display-units(results, options, top: true)
}

#let unit(unit, ..options) = {
  return _unit(
    unit,
    combine-dict(
      options.named(),
      (
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
      ),
      only-update: true,
    )
  )
}