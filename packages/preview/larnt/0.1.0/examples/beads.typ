// Takes more than a minute to render.
#set page(margin: 0pt, height: auto)
#import "@preview/suiji:0.5.1"
#import "../lib.typ": *

#{
  let normalize(values, a, b) = {
    let lo = calc.min(..values)
    let hi = calc.max(..values)
    return values.map(v => a + (v - lo) / (hi - lo) * (b - a))
  }

  let low_pass(values, alpha) = {
    let result = ()
    let y = 0.0
    for x in values {
      y -= alpha * (y - x)
      result.push(y)
    }
    return result
  }

  let low_pass_noise(rng, n, alpha, iterations) = {
    let (rng, result) = suiji.random-f(rng, size: n)
    for _ in range(iterations) {
      result = low_pass(result, alpha)
    }
    return (rng, normalize(result, -1.0, 1.0))
  }

  let n = 200
  let rng = suiji.gen-rng-f(1211)
  let shapes = ()
  for _ in range(50) {
    let xs
    (rng, xs) = low_pass_noise(rng, n, 0.3, 4)
    let ys
    (rng, ys) = low_pass_noise(rng, n, 0.3, 4)
    let zs
    (rng, zs) = low_pass_noise(rng, n, 0.3, 4)
    let ss
    (rng, ss) = low_pass_noise(rng, n, 0.3, 4)

    let position = (0., 0., 0.)
    for i in range(n) {
      shapes.push(outline(sphere(position, 0.1)))
      let s = (ss.at(i) + 1) / 2 * 0.1 + 0.01
      let v = (xs.at(i), ys.at(i), zs.at(i))
      v = v.map(x => x / calc.norm(..v) * s)
      position = position.zip(v).map(x => x.sum())
    }
  }
  render(
    eye: (8.0, 8.0, 8.0),
    step: 1.0,
    ..shapes,
  )
}
