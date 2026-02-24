#import "../number/complex.typ" as c: complex, is-complex, make-complex
#let math-utils-wasm = plugin("../math-utils.wasm")

#let calc-funcs = dictionary(calc)
#let math-utils-funcs = dictionary(math-utils-wasm)

#let call-wasm-complex-func(complex-func, x) = {
  let result-bytes = complex-func(
      x.re.to-bytes(),
      x.im.to-bytes(),
    )
    let re = float.from-bytes(result-bytes.slice(0, 8))
    let im = float.from-bytes(result-bytes.slice(8))
    make-complex(re, im)
}

#let call-wasm-real-func(real-func, x) = {
  let x = if type(x) == angle {
    x.rad()
  } else {
    float(x)
  }
  float.from-bytes(real-func(x.to-bytes()))
}

#let extend-calc-func-to-complex(func-name) = {
  let real-func = calc-funcs.at(func-name)
  let complex-func = math-utils-funcs.at(func-name + "_complex")
  x => {
    if is-complex(x) {
      call-wasm-complex-func(complex-func, x)
    } else {
      let x = if type(x) == angle {
        x.rad()
      } else {
        x
      }
      real-func(x)
    }
  }
}

#let define-func-with-complex(func-name) = {
  let real-func = math-utils-funcs.at(func-name)
  let complex-func = math-utils-funcs.at(func-name + "_complex")
  x => {
    if is-complex(x) {
      call-wasm-complex-func(complex-func, x)
    } else {
      call-wasm-real-func(real-func, x)
    }
  }
}

#let define-func-2-with-complex(func-name) = {
  let real-func = math-utils-funcs.at(func-name)
  let complex-func = math-utils-funcs.at(func-name + "_complex")
  (x1, x2) => {
    if is-complex(x1) or is-complex(x2) {
      let x1 = complex(x1)
      let x2 = complex(x2)
      let result-bytes = complex-func(
        x1.re.to-bytes(),
        x1.im.to-bytes(),
        x2.re.to-bytes(),
        x2.im.to-bytes(),
      )
      let re = float.from-bytes(result-bytes.slice(0, 8))
      let im = float.from-bytes(result-bytes.slice(8))
      make-complex(re, im)
    } else {
      let x1 = float(x1)
      let x2 = float(x2)
      float.from-bytes(real-func(x1.to-bytes(), x2.to-bytes()))
    }
  }
}

#let calc-funcs-with-complex = calc-funcs.keys().filter(it => (it + "_complex") in math-utils-funcs)
#let extended-calc-funcs = calc-funcs-with-complex.map(it => (it, extend-calc-func-to-complex(it))).to-dict()

