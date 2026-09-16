#let eqrun-builder(initial-state, debug: false, precision: 2) = {
  import "parsers.typ"
  import "utils.typ"

  let vars = state("eqrun", initial-state)

  let stateless-run(state, equation, precision, unit) = {
    let tokens = if equation.body.has("children") {
      equation.body.children
    } else {
      (equation.body,)
    }

    let (left-side, right-side) = {
      let left-side = ()
      let right-side = ()
      let eq-ahead = true

      for token in tokens {
        if token == [#math.eq] {
          eq-ahead = false
          continue
        }

        if eq-ahead { left-side.push(token) } else { right-side.push(token) }
      }

      if eq-ahead {
        right-side = (..left-side)
        left-side = ([result],)
      }

      let left-side = parsers.array(left-side).at(0).code

      (left-side, right-side)
    }

    let tokens = parsers.array(right-side)
    let result = tokens.map(token => token.code).join(" ")
    let values = tokens.map(token => token.math).join(" ")
    let has-variables = "cleanup(" in values

    if regex("^[.,\\d]+$") in result {
      return (
        variable: left-side,
        result: eval(result),
        equation: $ equation unit $,
      )
    }

    if not debug {
      if has-variables {
        values = eval(
          values,
          mode: "math",
          scope: (
            cleanup: (val) => str(calc.round(val, digits: precision)),
            ..state,
          ),
        )
      }
      result = calc.round(eval(result, scope: state), digits: precision)
    }

    (
      variable: left-side,
      result: result,
      equation: if has-variables {
        $ equation = values = result unit $
      } else {
        $ equation = result unit $
      },
    )
  }

  (..args, precision: precision, unit: none) => {
    let equation = args.at(0, default: none)

    if equation == none {
      return vars.get()
    }

    if unit == none {
      unit = ""
    } else {
      unit = $space unit$
    }

    vars.update(old => {
      let (equation, variable, result) = stateless-run(old, equation, precision, unit)

      old.insert(variable, result)
      old.insert("eqrun-output", equation)
      old
    })
    context vars.get().eqrun-output
  }
}

