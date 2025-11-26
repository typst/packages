#import "../number/complex/init.typ" as c: (
  from,
  is_,
  make-complex,
  to-bytes as c_to-bytes,
  from-bytes as c_from-bytes,
)
#import "../init.typ": (
  real-funcs,
  complex-funcs
)
#let math-utils-wasm = plugin("../math-utils.wasm")

#let calc-funcs = dictionary(calc)
#let math-utils-funcs = dictionary(math-utils-wasm)

#let extend-calc-func-to-complex(func-name) = {
  let real-func = calc-funcs.at(func-name)
  let complex-func = complex-funcs.at(func-name)
  x => {
    if is_(x) {
      complex-func(x)
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

#let define-func(func-name) = {
  let func = math-utils-funcs.at(func-name)
  x => {
    if is_(x) {
      panic("function `" + func + "` does not support complex input.")
    } else {
      func(x)
    }
  }
}

#let define-func-with-complex(func-name) = {
  let real-func = real-funcs.at(func-name)
  let complex-func = complex-funcs.at(func-name, default: none)
  x => {
    if is_(x) {
      if complex-func == none {
        panic("function `" + func-name + "` does not support complex input.")
      } else {
        complex-func(x)
      }
    } else {
      real-func(x)
    }
  }
}

#let define-func-2-with-complex(func-name) = {
  let real-func = real-funcs.at(func-name)
  let complex-func = complex-funcs.at(func-name)
  (x1, x2) => {
    if is_(x1) or is_(x2) {
      complex-func(x1, x2)
    } else {
      real-func(x1, x2)
    }
  }
}
