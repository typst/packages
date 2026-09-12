#import calc: abs, exp, ln
#import "gamma.typ": gamma, ln-gamma

/// Computes the regularized lower incomplete beta function
/// $
/// I_x (a,b) = 1/Beta(a,b) integral_0^x t^(a-1) (1-t)^(b-1) dif t
/// $
/// `a > 0`, `b > 0`, `1 >= x >= 0` where `a` is the first beta parameter, `b` is the second beta parameter, and `x` is the upper limit of the integral.
///
/// - a (float, int): The first beta parameter $a > 0$.
/// - b (float, int): The second beta parameter $b > 0$.
/// -> function
#let beta-reg(a, b) = {
  assert(a > 0.0, message: "Beta function parameter a must be greater than 0")
  assert(b > 0.0, message: "Beta function parameter b must be greater than 0")
  x => {
    assert(0.0 <= x and x <= 1.0, message: "Beta function parameter x must be in the range [0, 1]")

    let MIN_POSITIVE = 2.2250738585072014e-308
    let F64_PREC = 0.00000000000000011102230246251565

    let bt = if x == 0.0 or x == 1.0 {
      0.0
    } else {
      exp(ln-gamma(a + b) - ln-gamma(a) - ln-gamma(b) + a * ln(x) + b * ln(1.0 - x))
    }
    bt

    let symm_transform = x >= (a + 1.0) / (a + b + 2.0)
    let eps = F64_PREC
    let fpmin = MIN_POSITIVE / eps

    //TODO: why are we shadowing with themselves?
    let a = a
    let b = b
    let x = x
    if symm_transform {
      let swap = a
      x = 1.0 - x
      a = b
      b = swap
    }

    let qab = a + b
    let qap = a + 1.0
    let qam = a - 1.0
    let c = 1.0
    let d = 1.0 - qab * x / qap

    if abs(d) < fpmin {
      d = fpmin
    }
    d = 1.0 / d
    let h = d

    for m in range(1, 141) {
      let m = m // TODO
      let m2 = m * 2.0
      let aa = m * (b - m) * x / ((qam + m2) * (a + m2))
      d = 1.0 + aa * d

      if abs(d) < fpmin {
        d = fpmin
      }

      c = 1.0 + aa / c
      if abs(c) < fpmin {
        c = fpmin
      }

      d = 1.0 / d
      h = h * d * c
      aa = -(a + m) * (qab + m) * x / ((a + m2) * (qap + m2))
      d = 1.0 + aa * d

      if abs(d) < fpmin {
        d = fpmin
      }

      c = 1.0 + aa / c

      if abs(c) < fpmin {
        c = fpmin
      }

      d = 1.0 / d
      let del = d * c
      h *= del

      if abs(del - 1.0) <= eps {
        return if symm_transform {
          1.0 - bt * h / a
        } else {
          bt * h / a
        }
      }
    }

    if symm_transform {
      1.0 - bt * h / a
    } else {
      bt * h / a
    }
  }
}
