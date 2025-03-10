#let is_rational_zero(x) = {
  x.num == 0
}

#let is_rational_one(x) = {
  x.num == x.denom
}

#let is_rational_neg_one(x) = {
  x.num == -x.denom
}

#let is_rational_pos(x) = {
  (x.num / x.denom) > 0
}

#let rational_abs(x) = {
  (num: calc.abs(x.num), denom: calc.abs(x.denom))
}

#let is_real_zero(x) = {
  let (key,) = x.keys()

  if key == "Float" {
    x.Float == 0.0
  } else {
    is_rational_zero(x.Rational)
  }
}

#let is_real_one(x) = {
  let (key,) = x.keys()

  if key == "Float" {
    x.Float == 1.0
  } else {
    is_rational_one(x.Rational)
  }
}

#let is_real_neg_one(x) = {
  let (key,) = x.keys()

  if key == "Float" {
    x.Float == -1.0
  } else {
    is_rational_neg_one(x.Rational)
  }
}

#let is_real_pos(x) = {
  let (key,) = x.keys()

  if key == "Float" {
    x.Float > 0.0
  } else {
    is_rational_pos(x.Rational)
  }
}

#let real_abs(x) = {
  let (key,) = x.keys()

  if key == "Float" {
    (Float: calc.abs(x.Float))
  } else {
    (Rational: rational_abs(x.Rational))
  }
}

#let typeset_rational(x) = {
  let sign = $$
  if x.num / x.denom < 0 {
    x.num = calc.abs(x.num)
    x.denom = calc.abs(x.denom)
    sign = $-$
  }
  if x.denom == 1 {
    $sign#x.num$
  } else if x.num == 0 {
    $sign#x.num$
  } else {
    $sign (#x.num)/(#x.denom)$
  }
}

#let typeset_float(x) = {
  let val = calc.round(x, digits: 5)
  return $val$
}

#let typeset_real(x) = {
  let (key,) = x.keys()

  if key == "Rational" {
    return typeset_rational(x.Rational)
  } else {
    return typeset_float(x.Float)
  }
}

#let typeset_complex(x) = {
  
  if is_real_zero(x.real) {
    if is_real_zero(x.imag) {
      $0$
    } else if is_real_one(x.imag) {
      $i$
    } else if is_real_neg_one(x.imag) {
      $-i$
    } else {
      let imrat = typeset_real(x.imag)
      $imrat i$
    }
  } else {
    typeset_real(x.real)
    
    if is_real_one(x.imag) {
      $ + i$
    } else if is_real_neg_one(x.imag) {
      $ - i$
    } else if not is_real_zero(x.imag) {
      if is_real_pos(x.imag) {
        let imrat = typeset_real(x.imag)
        $ + imrat$
      } else {
        let imrat = typeset_real(real_abs(x.imag))
        $ - imrat$
      }
      $i$
    }
  }
}

#let typeset_mat(m) = {
  let values = m.data
  let rows = ()
  for y in range(m.rows) {
    let row = ()
    for x in range(m.cols) {
      let idx = x * m.rows + y
      row.push(typeset_complex(values.at(idx)))
    }
    rows.push(row)
  }

  math.mat(..rows)
}

#let funcs = (
  Rational: typeset_rational,
  Complex: typeset_complex,
  Mat: typeset_mat,
  Float: typeset_float,
)

#let typeset(value) = {
  let (key,) = value.keys()

  if key == "Real" {
    return typeset(value.at(key))
  }

  (funcs.at(key))(value.at(key))
}

