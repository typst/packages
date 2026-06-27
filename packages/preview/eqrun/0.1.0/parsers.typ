#import "./utils.typ"

#let text(input) = {
  if utils.is-number(input) or regex("[-+]") in input.text {
    (
      code: input.text,
      math: input.text,
    )
  } else if regex("^[⋅∗×]$") in input.text {
    (
      code: "*",
      math: input.text,
    )
  } else if regex("^[\/÷]$") in input.text {
    (
      code: "/",
      math: input.text,
    )
  } else {
    let name = utils.get-sym-name(input.text.replace(" ", "-"))
    (
      code: name,
      math: "#cleanup(" + name + ")",
    )
  }
}

#let attach(input, parse) = {
  let name = if input.has("b") {
    text(input.base).code + "-" + utils.get-sym-name(input.b.text)
  } else {
    text(input.base).code
  }

  let name = name.replace(" ", "-")

  if not input.has("t") {
    return (code: name, math: "#cleanup(" + name + ")")
  }

  if input.t.has("text") {
    if utils.is-number(input.t) {
      (
        code: "calc.pow(" + name + ", " + input.t.text + ")",
        math: "#cleanup(" + name + ")^(" + input.t.text + ")",
      )
    } else {
      (
        code: name + "-" + utils.get-sym-name(input.t.text),
        math: "#cleanup(" + name + "-" + utils.get-sym-name(input.t.text) + ")",
      )
    }
  } else {
    let t = utils.stringify(parse(input.t))
    (
      code: "calc.pow(" + name + ", " + t.code + ")",
      math: "#cleanup(" + name + ")^(" + t.math + ")",
    )
  }
}

#let frac(input, parse) = {
  let num = parse(input.num)
  let den = parse(input.denom)

  (
    code: "(" + num.map(i => i.code).join(" ") + ")/(" + den.map(i => i.code).join(" ") + ")",
    math: "(" + num.map(i => i.math).join(" ") + ")/(" + den.map(i => i.math).join(" ") + ")",
  )
}

// root as in sqrt, not as in a tree of nodes
#let root(input, parse) = {
  let index = utils.stringify(parse(if input.has("index") { input.index } else { [2] }))
  let radicand = utils.stringify(parse(input.radicand))

  (
    code: "calc.root(" + radicand.code + ", " + index.code + ")",
    math: if input.has("index") {
      "root(" + index.math + ", " + radicand.math + ")"
    } else {
      "sqrt(" + radicand.math + ")"
    },
  )
}

#let array(input) = {
  utils.to-array(input).filter(elem => elem != [ ]).map(token => {
    if token.func() == math.attach {
      attach(token, array)
    } else if token.func() == math.root {
      root(token, array)
    } else if token.func() == math.frac {
      frac(token, array)
    } else if token.func() == math.lr {
      array(token.body.children)
    } else {
      text(token)
    }
  }).flatten()
}

