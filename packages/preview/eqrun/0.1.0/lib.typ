#let eqrun-builder(initial-state, debug: false, precision: 2) = {
  import "parsers.typ"

  let vars = state("eqrun", initial-state)

  let stateless-run(state, equation, precision) = {
    let tokens = equation.body.children

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

      let left-side = parsers.array(left-side).at(0).code.replace("vars.", "")

      (left-side, right-side)
    }

    let tokens = parsers.array(right-side)
    let result = tokens.map(token => token.code).join(" ")
    let has-variables = "vars." in result
    let values = tokens.map(token => token.math).join(" ")

    if not debug {
      values = eval(
        values,
        mode: "math",
        scope: (
          cleanup: (val) => str(calc.round(val, digits: precision)),
          ..state,
        ),
      )
      result = calc.round(eval(result, scope: state), digits: precision)
    }

    (
      variable: left-side,
      result: result,
      equation: if has-variables {
        $ equation = values = result $
      } else {
        $ equation = result $
      },
    )
  }

  (..args, precision: precision) => {
    let equation = args.at(0, default: none)

    if equation == none {
      return vars.get()
    }

    vars.update(old => {
      let (equation, variable, result) = stateless-run(old, equation, precision)

      old.insert(variable, result)
      old.insert("eqrun-output", equation)
      old
    })
    context vars.get().eqrun-output
  }
}

