// -> func/common.typ

#import "init.typ": extend-calc-func-to-complex, define-func-with-complex, call-wasm-real-func, call-wasm-complex-func
#import "../number/complex.typ" as c: complex, is-complex, make-complex
#let math-utils-wasm = plugin("../math-utils.wasm")

#let /*pub*/ exp = extend-calc-func-to-complex("exp")
#let /*pub*/ ln(x) = {
  if is-complex(x) {
    call-wasm-complex-func(math-utils-wasm.ln_complex, x)
  } else if x < 0 {
    call-wasm-complex-func(math-utils-wasm.ln_complex, complex(x))
  } else if x == 0 {
    -float.inf
  } else {
    calc.ln(x)
  }
}

#let log-complex(x, base: 10.0) = {
  if base == 2 {
    call-wasm-complex-func(math-utils-wasm.log2_complex, x)
  } else if base == 10 {
    call-wasm-complex-func(math-utils-wasm.log10_complex, x)
  } else {
    c.div(
      call-wasm-complex-func(math-utils-wasm.ln_complex, x),
      ln(base),
    )
  }
}

#let /*pub*/ log(x, base: 10.0) = {
  if is-complex(x) {
    log-complex(x, base: base)
  } else if x < 0 {
    log-complex(complex(x), base: base)
  } else if x == 0 {
    if is-complex(base) or base <= 0 {
      c.nan
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
  if is-complex(x) {
    call-wasm-complex-func(math-utils-wasm.asin_complex, x)
  } else if x < -1 or x > 1 {
    call-wasm-complex-func(math-utils-wasm.asin_complex, complex(x))
  } else {
    calc.asin(x)
  }
}

#let /*pub*/ acos(x) = {
  if is-complex(x) {
    call-wasm-complex-func(math-utils-wasm.acos_complex, x)
  } else if x < -1 or x > 1 {
    call-wasm-complex-func(math-utils-wasm.acos_complex, complex(x))
  } else {
    calc.acos(x)
  }
}

#let /*pub*/ atan = extend-calc-func-to-complex("atan")
#let /*pub*/ asinh = define-func-with-complex("asinh")

#let /*pub*/ acosh(x) = {
  if x < 1 {
    x = complex(x)
  }
  if is-complex(x) {
    call-wasm-complex-func(math-utils-wasm.acosh_complex, x)
  } else {
    call-wasm-real-func(math-utils-wasm.atanh, x)
  }
}

#let /*pub*/ atanh(x) = {
  if x < -1 or x > 1 {
    x = complex(x)
  }
  if is-complex(x) {
    call-wasm-complex-func(math-utils-wasm.atanh_complex, x)
  } else {
    call-wasm-real-func(math-utils-wasm.atanh, x)
  }
}

#let /*pub*/ abs(x) = {
  if is-complex(x) {
    let (re, im) = x
    calc.norm(re, im)
  } else {
    calc.abs(x)
  }
}

#let /*pub*/ arg(x) = {
  if is-complex(x) {
    let (re, im) = x
    calc.atan2(re, im)
  } else if x >= 0 {
    0deg
  } else {
    180deg
  }
}
