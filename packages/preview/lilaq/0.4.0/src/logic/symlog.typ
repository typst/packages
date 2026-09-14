#import "../math.typ": sign


#let symlog-transform(base, threshold, linscale) = {
  let c = linscale / (1. - 1. / base)
  let log-base = calc.ln(base)

  x => {
    if x == 0 { return 0. }
    let abs = calc.abs(x)
    if abs <= threshold { return x * c }
    return sign(x) * threshold * (c + calc.ln(abs / threshold) / log-base)
  }
}