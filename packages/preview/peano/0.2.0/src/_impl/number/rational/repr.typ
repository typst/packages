// -> number/rational/repr.typ

#import "init.typ": from

#let /*pub*/ to-str(
    n,
    plus-sign: false,
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
        if hyphen-minus { "-" } else { "\u{2212}" }
      } else if plus-sign { "+" }
      sgn-str + "\u{221E}"
    }
  } else {
    let sgn-str = if not sign {
      if hyphen-minus { "-" } else { "\u{2212}" }
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
  denom-one: false,
  sign-on-num: false,
) = {
  let n = from(n)
  let (sign, num, den) = n
  if den == 0 {
    if num == 0 {
      $"NaN"$
    } else if not sign {
      $-oo$
    } else if plus-sign {
      $+oo$
    } else {
      $oo$
    }
  } else if den == 1 and not denom-one {
    $#sign-math(sign, num, plus-sign: plus-sign) #num$
  } else if sign-on-num {
    $(#sign-math(sign, num, plus-sign: plus-sign) #num) / #den$
  } else {
    $#sign-math(sign, num, plus-sign: plus-sign) #num / #den$
  }
}
