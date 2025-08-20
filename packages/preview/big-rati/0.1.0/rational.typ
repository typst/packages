#let _p = plugin("typst_plugin_bigrational.wasm")

#let rational(x) = {
  let convert-scalar(x) = if type(x) == str {
    bytes(x)
  } else if type(x) == int {
    bytes(if x < 0 {
      "-" + str(x).slice(3, none)
    } else {
      str(x)
    })
  } else {
    panic("Required a scalar, representing an integer")
  }

  if type(x) == bytes {
    x
  } else if type(x) in (int, str) {
    let numer = convert-scalar(x)
    _p.rational(numer, bytes("1"))
  } else if type(x) == array and x.len() == 2 {
    let (n, d) = x
    _p.rational(convert-scalar(n), convert-scalar(d))
  } else {
    panic("Required a scalar, representing an integer, or an array of two such scalars")
  }
}

#let add(a, b) = {
  let a = rational(a)
  let b = rational(b)

  _p.add(a, b)
}

#let sub(a, b) = {
  let a = rational(a)
  let b = rational(b)

  _p.sub(a, b)
}

#let mul(a, b) = {
  let a = rational(a)
  let b = rational(b)

  _p.mul(a, b)
}

#let div(a, b) = {
  let a = rational(a)
  let b = rational(b)

  _p.div(a, b)
}

#let rem(a, b) = {
  let a = rational(a)
  let b = rational(b)

  _p.rem(a, b)
}

#let abs-diff(a, b) = {
  let a = rational(a)
  let b = rational(b)

  _p.abs_diff(a, b)
}

#let cmp(a, b) = {
  let a = rational(a)
  let b = rational(b)

  let ordering-bytes = _p.cmp(a, b)

  int.from-bytes(ordering-bytes)
}

#let neg(x) = {
  let x = rational(x)

  _p.neg(x)
}

#let abs(x) = {
  let x = rational(x)

  _p.abs(x)
}

#let ceil(x) = {
  let x = rational(x)

  _p.ceil(x)
}

#let floor(x) = {
  let x = rational(x)

  _p.floor(x)
}

#let round(x) = {
  let x = rational(x)

  _p.round(x)
}

#let trunc(x) = {
  let x = rational(x)

  _p.trunc(x)
}

#let fract(x) = {
  let x = rational(x)

  _p.fract(x)
}

#let recip(x) = {
  let x = rational(x)

  _p.recip(x)
}

#let pow(x, n) = {
  let x = rational(x)
  let n = int.to-bytes(n)

  _p.pow(x, n)
}

#let clamp(x, min, max) = {
  let x = rational(x)
  let min = rational(min)
  let max = rational(max)

  _p.clamp(x, min, max)
}

#let min(a, b) = {
  let a = rational(a)
  let b = rational(b)

  _p.min(a, b)
}

#let max(a, b) = {
  let a = rational(a)
  let b = rational(b)

  _p.max(a, b)
}

#let repr(x, is-mixed: true) = {
  let x = rational(x)
  let is-mixed = if is-mixed { bytes("\u{1}") } else { bytes("\u{0}") }

  let repr-bytes = _p.repr(x, is-mixed)

  let variant = repr-bytes.at(0)
  if variant == 0  [
    $#(str(repr-bytes.slice(1, none)))$
  ] else if variant == 1 {
    let sign = repr-bytes.at(1)
    let MINUS = 0

    let numer-len = int.from-bytes(repr-bytes.slice(2, count: 8))
    let numer = str(repr-bytes.slice(10, count: numer-len))
    
    let denom-len = int.from-bytes(repr-bytes.slice(10 + numer-len, count: 8))
    let denom = str(repr-bytes.slice(10 + numer-len + 8, count: denom-len))

    $#(if sign == MINUS [-] else [])#str(numer)/#str(denom)$
  } else if variant == 2 {
    let whole-len = int.from-bytes(repr-bytes.slice(1, count: 8))
    let whole = str(repr-bytes.slice(9, count: whole-len))
    
    let numer-len = int.from-bytes(repr-bytes.slice(9 + whole-len, count: 8))
    let numer = str(repr-bytes.slice(9 + whole-len + 8, count: numer-len))
    
    let denom-len = int.from-bytes(repr-bytes.slice(9 + whole-len + 8 + numer-len, count: 8))
    let denom = str(repr-bytes.slice(9 + whole-len + 8 + numer-len + 8, count: denom-len))

    $#str(whole)#str(numer)/#str(denom)$
  } else {
    panic("Unknown variant: " + str(variant))
  }
}

#let numerator(x) = {
  let x = rational(x)

  let numer-bytes = _p.numerator(x)

  str(numer-bytes)
}

#let denominator(x) = {
  let x = rational(x)

  let denom-bytes = _p.denominator(x)

  str(denom-bytes)
}

#let to-decimal-str(x, precision: 8) = {
  let x = rational(x)
  str(_p.to_decimal_string(x, int.to-bytes(precision)))
}

#let to-float(x, precision: 8) = {
  float(to-decimal-str(x, precision: precision))
}

#let to-decimal(x, precision: 8) = {
  decimal(to-decimal-str(x, precision: precision))
}
