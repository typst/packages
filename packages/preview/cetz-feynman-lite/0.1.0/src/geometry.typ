// Shared centerline sampling for waves, arrows, and endpoint checks.
#let point(path, t) = {
  if path.kind == "line" {
    let (a, b) = path.points
    (a.at(0) * (1 - t) + b.at(0) * t, a.at(1) * (1 - t) + b.at(1) * t)
  } else if path.kind == "cubic" {
    let u = 1 - t
    let (a, c1, c2, b) = path.points
    (u*u*u*a.at(0) + 3*u*u*t*c1.at(0) + 3*u*t*t*c2.at(0) + t*t*t*b.at(0),
      u*u*u*a.at(1) + 3*u*u*t*c1.at(1) + 3*u*t*t*c2.at(1) + t*t*t*b.at(1))
  } else if path.kind == "arc" {
    let a = path.points.first()
    let angle = path.start + t * path.delta
    (a.at(0) + path.radius * (calc.cos(angle) - calc.cos(path.start)),
      a.at(1) + path.radius * (calc.sin(angle) - calc.sin(path.start)))
  } else {
    let angle = -90deg + t * 360deg
    let x = path.size * path.aspect * calc.cos(angle)
    let y = path.size * (1 + calc.sin(angle))
    let r = path.angle - 90deg
    (path.origin.at(0) + x * calc.cos(r) - y * calc.sin(r),
      path.origin.at(1) + x * calc.sin(r) + y * calc.cos(r))
  }
}
#let tangent(path, t) = {
  let a = point(path, t - 0.0001)
  let b = point(path, t + 0.0001)
  let dx = b.at(0) - a.at(0)
  let dy = b.at(1) - a.at(1)
  let d = calc.sqrt(dx*dx + dy*dy)
  (dx/d, dy/d)
}
#let wave(path) = {
  let samples = range(65).map(i => point(path, i/64))
  let length = range(64).fold(0, (s, i) => {
    let a = samples.at(i)
    let b = samples.at(i+1)
    s + calc.sqrt(calc.pow(b.at(0)-a.at(0), 2) + calc.pow(b.at(1)-a.at(1), 2))
  })
  let cycles = calc.max(3, calc.round(length / 0.42))
  let n = int(cycles * 20)
  range(n + 1).map(i => {
    let t = i/n
    let p = point(path, t)
    let dir = tangent(path, t)
    let offset = if i == 0 or i == n {0} else {
      0.085 * calc.sin(t * cycles * 360deg) * calc.min(1, t*12, (1 - t)*12)
    }
    (p.at(0) - dir.at(1)*offset, p.at(1) + dir.at(0)*offset)
  })
}
