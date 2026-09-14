// -> func/common.typ

#import "../init.typ": (
  real-funcs,
  complex-funcs
)
#import "init.typ": extend-calc-func-to-complex, define-func-with-complex
#import "../number/complex/init.typ": from, is_, make-complex
#import "../number/complex/arith.typ": div as c_div
#import "../number/complex/const.typ": nan as c_nan
#let math-utils-wasm = plugin("../math-utils.wasm")

#let /*pub*/ exp = extend-calc-func-to-complex("exp")
#let /*pub*/ ln(x) = {
  if is_(x) or x < 0 {
    (complex-funcs.ln)(x)
  } else if x == 0 {
    -float.inf
  } else {
    calc.ln(x)
  }
}

#let log-complex(x, base: 10.0) = {
  if base == 2 {
    (complex-funcs.log2)(x)
  } else if base == 10 {
    (complex-funcs.log10)(x)
  } else {
    c_div(
      (complex-funcs.ln)(x),
      ln(base),
    )
  }
}

#let /*pub*/ log(x, base: 10.0) = {
  if is_(x) {
    log-complex(x, base: base)
  } else if x < 0 {
    log-complex(from(x), base: base)
  } else if x == 0 {
    if is_(base) or base <= 0 {
      c_nan
    } else if base < 1 {
      float.inf
    } else if base == 1 {
      float.nan
    } else {
      -float.inf
    }
  } else {
    calc.log(x, base: base)
  }
}

#let /*pub*/ sin = extend-calc-func-to-complex("sin")
#let /*pub*/ cos = extend-calc-func-to-complex("cos")
#let /*pub*/ tan = extend-calc-func-to-complex("tan")
#let /*pub*/ sinh = extend-calc-func-to-complex("sinh")
#let /*pub*/ cosh = extend-calc-func-to-complex("cosh")
#let /*pub*/ tanh = extend-calc-func-to-complex("tanh")

#let /*pub*/ asin(x) = {
  if is_(x) or x < -1 or x > 1 {
    (complex-funcs.asin)(x)
  } else {
    calc.asin(x)
  }
}

#let /*pub*/ acos(x) = {
  if is_(x) or x < -1 or x > 1 {
    (complex-funcs.acos)(x)
  } else {
    calc.acos(x)
  }
}

#let /*pub*/ atan = extend-calc-func-to-complex("atan")
#let /*pub*/ asinh = define-func-with-complex("asinh")

#let /*pub*/ acosh(x) = {
  if is_(x) or x < 1 {
    (complex-funcs.acosh)(x)
  } else {
    (real-funcs.acosh)(x)
  }
}

#let /*pub*/ atanh(x) = {
  if is_(x) or x < -1 or x > 1 {
    (complex-funcs.atanh)(x)
  } else {
    (real-funcs.atanh)(x)
  }
}

#let /*pub*/ abs(x) = {
  if is_(x) {
    let (re, im) = x
    calc.norm(re, im)
  } else {
    calc.abs(x)
  }
}

#let /*pub*/ arg(x) = {
  if is_(x) {
    let (re, im) = x
    calc.atan2(re, im)
  } else if x >= 0 {
    0deg
  } else {
    180deg
  }
}
