// -> number/rational/repr.typ

#import "init.typ": from

#let minus-sign(hyphen-minus) = {
  if hyphen-minus { "-" } else { "\u{2212}" }
}

#let /*pub*/ repr(n) = {
  let n = from(n)
  let (sign, num, den) = n
  if den == 0 {
    if num == 0 {
      "NaN"
    } else {
      if sign { "inf" } else { "-inf" }
    }
  } else if den == 1 {
    (if not sign { "-" }) + str(num)
  } else {
    (if not sign { "-" }) + str(num) + "/" + str(den)
  }
}

#let /*pub*/ to-str(
    n,
    plus-sign: false,
    signed-zero: false,
    signed-inf: false,
    denom-one: false,
    hyphen-minus: false,
) = {
  let n = from(n)
  let (sign, num, den) = n

  if den == 0 {
    if num == 0 {
      "NaN"
    } else {
      let sgn-str = if not sign {
        minus-sign(hyphen-minus)
      } else if plus-sign or signed-inf { "+" }
      sgn-str + "\u{221E}"
    }
  } else {
    let sgn-str = if not sign {
      if num == 0 and not signed-zero { none }
      else { minus-sign(hyphen-minus) }
    } else if plus-sign { "+" }

    if den == 1 and not denom-one {
      sgn-str + str(num)
    } else {
      sgn-str + str(num) + "/" + str(den)
    }
  }
}

#let sign-math(sgn, n, plus-sign: false) = {
  if not sgn {
    $-$
  } else if plus-sign and n > 0 {
    $+$
  } else {
    $$
  }
}

#let /*pub*/ to-math(
  n,
  plus-sign: false,
  signed-zero: false,
  signed-inf: false,
  denom-one: false,
  sign-on-num: false,
  fmt: none,
  display: false,
) = {
  let n = from(n)
  let (sign, num, den) = n
  let result = if den == 0 {
    if num == 0 {
      $"NaN"$
    } else if not sign {
      $-oo$
    } else if plus-sign {
      $+oo$
    } else {
      $oo$
    }
  } else if num == 0 {
    if signed-zero {
      if sign { $+0$ } else { $-0$ }
    }
    else { $0$ }
  } else if den == 1 and not denom-one {
    $#sign-math(sign, num, plus-sign: plus-sign) #num$
  } else if sign-on-num {
    $(#sign-math(sign, num, plus-sign: plus-sign) #num) / #den$
  } else {
    $#sign-math(sign, num, plus-sign: plus-sign) #num / #den$
  }
  if display { $math.display(result)$ } else { result }
}
