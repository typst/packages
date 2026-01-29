// ctz-euclide/src/conic/projectile.typ
// Projectile motion functions

#import "../util.typ"

// =============================================================================
// PROJECTILE FUNCTIONS
// =============================================================================

/// Compute time range for projectile
#let projectile-time-max-raw(origin, velocity, gravity, t-max: auto, y-floor: none) = {
  if t-max != auto {
    return t-max
  }

  let y0 = origin.at(1)
  let vy = velocity.at(1)
  let g = gravity

  if y-floor != none and g != 0 {
    let a = 0.5 * g
    let b = -vy
    let c = y-floor - y0
    let disc = b * b - 4 * a * c
    if disc >= 0 {
      let root = calc.sqrt(disc)
      let t1 = (-b + root) / (2 * a)
      let t2 = (-b - root) / (2 * a)
      let t = calc.max(t1, t2)
      if t > 0 {
        return t
      }
    }
  }

  if g != 0 and vy > 0 {
    return 2 * vy / g
  }

  1
}

/// Projectile position at time t
#let projectile-position-raw(origin, velocity, gravity, t) = {
  (
    origin.at(0) + velocity.at(0) * t,
    origin.at(1) + velocity.at(1) * t - 0.5 * gravity * t * t,
    origin.at(2, default: 0),
  )
}

/// Projectile velocity at time t
#let projectile-velocity-raw(velocity, gravity, t) = {
  (
    velocity.at(0),
    velocity.at(1) - gravity * t,
    0,
  )
}

/// Sample points on a projectile trajectory
#let projectile-points-raw(origin, velocity, gravity, t-max, steps: 80, y-floor: none) = {
  let t-end = projectile-time-max-raw(origin, velocity, gravity, t-max: t-max, y-floor: y-floor)
  let pts = ()
  for i in range(0, steps + 1) {
    let t = t-end * i / steps
    pts.push(projectile-position-raw(origin, velocity, gravity, t))
  }
  (pts, t-end)
}
