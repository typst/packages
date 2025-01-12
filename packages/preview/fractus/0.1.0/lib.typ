#let _frac(it) = {
  if type(it) == int {
    (numerator: it, denominator: 1)
  } else if type(it) == decimal {
    let decimal_part = str(it).match(regex("[+-]?\d+(?:[.](\d*))?")).at("captures").at(0)
    let exp = if decimal_part == none {0} else {decimal_part.len()}
    let denominator = calc.pow(10,exp)
    (numerator: int(it*denominator), denominator: denominator)
  } else if type(it) == dictionary and ("numerator" in it) and ("denominator" in it) {
    it
  } else if type(it) == str {
    let it = it.match(regex("^([+-]?\d+)\/([+-]?\d+)$"))
    if it == none {
      panic("not a fraction")
    } else {
      let it = it.at("captures").map(int)
      (numerator: it.at(0), denominator: it.at(1))
    }
  } else {
    panic("not a fraction")
  }
}

#let _str(n) = {
  /**
  "-" (U+002D) and the minus sign "−" (U+2212) are not the same.
  The str() function generates the minus sign.
  **/
  str(n.numerator).replace("−","-")+"/"+str(n.denominator).replace("−","-")
}

#let _simplify(n) = {
  if n.denominator.signum() == -1 {
    n.numerator = n.numerator * -1
    n.denominator = n.denominator * -1
  }
  
  let divider = calc.gcd(n.numerator, n.denominator)
  (
    numerator: calc.div-euclid(n.numerator, divider),
    denominator: calc.div-euclid(n.denominator, divider)
  )
}

#let simplify(n) = {
  _str(_simplify(_frac(n)))
}

#let _opposite(n) = {
  (numerator: n.numerator * -1, denominator: n.denominator)
}

#let opposite(n) = {
  _str(_opposite(_simplify(_frac(n))))
}

#let _inverse(n) = {
  (numerator: n.denominator, denominator: n.numerator)
}

#let inverse(n) = {
  _str(_simplify(_inverse(_frac(n))))
}

#let display(n, style: "inline") = {
  let n = _frac(n)
  if n.denominator == 1 {
    n.numerator
  } else {
    eval("$" + style + "((" + str(n.numerator) + ")/(" + str(n.denominator) + "))$") 
  }
}

#let float(n) = {
  let n = _simplify(_frac(n))
  n.numerator/n.denominator
}

#let _sum(..args) = {
  let denominator = args.pos().map(n => n.denominator).dedup().reduce(calc.lcm)
  _simplify((
    numerator: args.pos().map(
      n => calc.div-euclid(denominator, n.denominator)*n.numerator
    ).sum(),
    denominator: denominator
  ))
}

#let sum(..args) = {
  let args = args.pos().map(_frac).map(_simplify)
  _str(_sum(..args))
}

#let difference(n, m) = {
  (n, m) = (n, m).map(_frac).map(_simplify)
  sum(n, _opposite(m))
}

#let _product(..args) = {
  _simplify((
    numerator: args.pos().map(n => n.numerator).product(),
    denominator: args.pos().map(n => n.denominator).product()
  ))
}

#let product(..args) = {
  let args = args.pos().map(_frac).map(_simplify)
  _str(_product(..args))
}

#let division(n, m) = {
  (n, m) = (n, m).map(_frac).map(_simplify)
  product(n, _inverse(m))
}

#let _eq(..args) = {
  let denominator = args.pos().map(n => n.denominator).dedup().reduce(calc.lcm)
  args.pos().map(n => calc.div-euclid(denominator, n.denominator)*n.numerator).dedup().len() == 1
}

#let eq(..args) = {
  let args = args.pos().map(_frac).map(_simplify)
  _eq(..args)
}
