#let _fraction(n, domain) = {
  if type(domain) == int or type(domain) == float {
    domain = (0.0, domain)
  }

  let start = domain.first()
  let end = domain.last()
  let min = calc.min(..domain)
  let max = calc.max(..domain)

  n = calc.clamp(n, min, max)

  n = (n - start) / (end - start)
  n = calc.clamp(n, 0.0, 1.0)

  n
}

#let new(
  start: 0.5, // red = 1, green = 2, blue = 3
  rotations: -1.5,
  saturate: 1.0,
  gamma: 1.0,
  reverse: false,
  domain: (0.0, 1.0),
  type: color,
) = {
  (value, domain: domain, type: type) => {
    value = _fraction(value, domain)
    if reverse { value = 1 - value }

    if start > 3.0 {
      let start = calc.rem-euclid(start, 3.0)
    }

    let angle = 2 * calc.pi * ((start / 3.0) + 1 + (rotations * value))

    value = calc.pow(value, gamma)
    let amp = saturate * value * (1 - value) / 2.0

    let r = value + (amp * ((-0.14861 * calc.cos(angle)) + (1.78277 * calc.sin(angle))))
    let g = value + (amp * ((-0.29227 * calc.cos(angle)) - (0.90649 * calc.sin(angle))))
    let b = value + (amp * (1.97294 * calc.cos(angle)))

    r = calc.clamp(r, 0.0, 1.0)
    g = calc.clamp(g, 0.0, 1.0)
    b = calc.clamp(b, 0.0, 1.0)

    if type == color {
      return oklch(rgb(..(r, g, b).map(it => it * 100%)))
    }

    if type == dictionary {
      return (r: r, g: g, b: b)
    }
  }
}

#let cubehelix = new()

#let colors(num, func: cubehelix) = {
  if std.type(num) != int or num < 1 {
    panic("number of colors must be a positive integer")
  }

  if num < 2 {
    return (func(0.5, domain: (0, 1), type: color),)
  }

  let a = ()
  for i in std.range(num) {
    let c = func(i, domain: num - 1, type: color)
    a.push(c)
  }

  a
}

#let gradient-map(func) = colors(256, func: func)
#let gradient = gradient-map(cubehelix)
