// This file contains functions related to bezier curve calculation
#import "vector.typ"

// Map number v from range (ds, de) to (ts, te)
#let _map(v, ds, de, ts, te) = {
  let d1 = de - ds
  let d2 = te - ts
  let v2 = v - ds
  let r = v2 / d1
  return ts + d2 * r
}

/// Get point on quadratic bezier at position t
///
/// - a (vector): Start point
/// - b (vector): End point
/// - c (vector): Control point
/// - t (float): Position on curve [0, 1]
/// -> vector
#let quadratic-point(a, b, c, t) = {
  // (1-t)^2 * a + 2 * (1-t) * t * c + t^2 b
  return vector.add(
    vector.add(
      vector.scale(a, calc.pow(1-t, 2)),
      vector.scale(c, 2 * (1-t) * t)
    ),
    vector.scale(b, calc.pow(t, 2))
  )
}

/// Get dx/dt of quadratic bezier at position t
///
/// - a (vector): Start point
/// - b (vector): End point
/// - c (vector): Control point
/// - t (float): Position on curve [0, 1]
/// -> vector
#let quadratic-derivative(a, b, c, t) = {
  // 2(-a(1-t) + bt - 2ct + c)
  return vector.scale(
    vector.add(
      vector.sub(
        vector.add(
          vector.scale(vector.neg(a), (1 - t)),
          vector.scale(b, t)),
        vector.scale(c, 2 * t)),
      c)
  , 2)
}

/// Get point on cubic bezier curve at position t
///
/// - a (vector):  Start point
/// - b (vector):  End point
/// - c1 (vector): Control point 1
/// - c2 (vector): Control point 2
/// - t (float):   Position on curve [0, 1]
/// -> vector
#let cubic-point(a, b, c1, c2, t) = {
  // (1-t)^3*a + 3*(1-t)^2*t*c1 + 3*(1-t)*t^2*c2 + t^3*b
  vector.add(
    vector.add(
      vector.scale(a, calc.pow(1-t, 3)),
      vector.scale(c1, 3 * calc.pow(1-t, 2) * t)
    ),
    vector.add(
      vector.scale(c2, 3*(1-t)*calc.pow(t,2)),
      vector.scale(b, calc.pow(t, 3))
    )
  )
}

/// Get dx/dt of cubic bezier at position t
///
/// - a (vector): Start point
/// - b (vector): End point
/// - c1 (vector): Control point 1
/// - c2 (vector): Control point 2
/// - t (float): Position on curve [0, 1]
/// -> vector
#let cubic-derivative(a, b, c1, c2, t) = {
  // -3(a(1-t)^2 + t(-2c2 - bt + 3 c2 t) + c1(-1 + 4t - 3t^2))
  vector.scale(
    vector.add(
      vector.add(
        vector.scale(a, calc.pow((1 - t), 2)),
        vector.scale(
          vector.sub(
            vector.add(
              vector.scale(b, -1 * t),
              vector.scale(c2, 3 * t)
            ),
            vector.scale(c2, 2)
          ),
          t
        )
      ),
      vector.scale(c1, -3 * calc.pow(t, 2) + 4 * t - 1)
    ),
    -3
  )
}

/// Get bezier curves ABC coordinates
///
///        /A\  <-- Control point of quadratic bezier
///       / | \
///      /  |  \
///     /_.-B-._\  <-- Point on curve
///    ,'   |   ',
///   /     |     \
///  s------C------e  <-- Point on line between s and e
///
/// - s (vector): Curve start
/// - e (vector): Curve end
/// - B (vector): Point on curve
/// - t (fload): Position on curve [0, 1]
/// - deg (int): Bezier degree (2 or 3)
/// -> (tuple) Tuple of A, B and C vectors
#let to-abc(s, e, B, t, deg: 2) = {
  let tt = calc.pow(t, deg)
  let u(t) = {
    (calc.pow(1 - t, deg) /
     (tt + calc.pow(1 - t, deg)))
  }
  let ratio(t) = {
    calc.abs((tt + calc.pow(1 - t, deg) - 1) /
             (tt + calc.pow(1 - t, deg)))
  }

  let C = vector.add(vector.scale(s, u(t)), vector.scale(e, 1 - u(t)))
  let A = vector.sub(B, vector.scale(vector.sub(C, B), 1 / ratio(t)))

  return (A, B, C)
}


/// Compute control points for quadratic bezier through 3 points
///
/// - s (vector): Curve start
/// - e (vector): Curve end
/// - B (vector): Point on curve
///
/// -> (s, e, c) Cubic bezier curve points
#let quadratic-through-3points(s, B, e) = {
  let d1 = vector.dist(s, B)
  let d2 = vector.dist(e, B)
  let t = d1 / (d1 + d2)

  let (A, B, C) = to-abc(s, e, B, t, deg: 2)

  return (s, e, A)
}

/// Compute control points for cubic bezier through 3 points
///
/// - s (vector): Curve start
/// - e (vector): Curve end
/// - B (vector): Point on curve
///
/// -> (s, e, c1, c2) Cubic bezier curve points
#let cubic-through-3points(s, B, e) = {
  let d1 = vector.dist(s, B)
  let d2 = vector.dist(e, B)
  let t = d1 / (d1 + d2)

  let (A, B, C) = to-abc(s, e, B, t, deg: 3)

  let d = vector.sub(B, C)
  if vector.len(d) == 0 {
    return (s, e, s, e)
  }

  d = vector.norm(d)
  d = (-d.at(1), d.at(0))
  d = vector.scale(d, vector.dist(s, e) / 3)
  let c1 = vector.add(A, vector.scale(d, t))
  let c2 = vector.sub(A, vector.scale(d, (1 - t)))

  let is-right = ((e.at(0) - s.at(0))*(B.at(1) - s.at(1)) -
                  (e.at(1) - s.at(1))*(B.at(0) - s.at(0))) < 0
  if is-right {
    (c1, c2) = (c2, c1)
  }

  return (s, e, c1, c2)
}

/// Convert quadratic bezier to cubic
///
/// - s (vector): Curve start
/// - e (vector): Curve end
/// - c (vector): Control point
///
/// -> (s, e, c1, c2)
#let quadratic-to-cubic(s, e, c) = {
  let c1 = vector.add(s, vector.scale(vector.sub(c, s), 2/3))
  let c2 = vector.add(e, vector.scale(vector.sub(c, e), 2/3))
  return (s, e, c1, c2)
}

/// Split a cubic bezier into two cubic beziers at t
///
/// - s  (vector): Curve start
/// - e  (vector): Curve end
/// - c1 (vector): Control point 1
/// - c2 (vector): Control point 2
/// - t  (float): t 0..1
/// -> ((s, e, c1, c2), (s, e, c1, c2))
#let split(s, e, c1, c2, t) = {
  t = calc.max(0, calc.min(t, 1))

  let split-rec(pts, t, left, right) = {
    if pts.len() == 1 {
      left.push(pts.at(0))
      right.push(pts.at(0))
    } else {
      let new-pts = ()
      for i in range(0, pts.len() - 1) {
        if i == 0 {
          left.push(pts.at(i))
        }
        if i == pts.len() - 2 {
          right.push(pts.at(i + 1))
        }
        new-pts.push(vector.add(vector.scale(pts.at(i), (1 - t)),
                                vector.scale(pts.at(i + 1), t)))
      }
      (left, right) = split-rec(new-pts, t, left, right)
    }
    return (left, right)
  }
  let (left, right) = split-rec((s, c1, c2, e), t, (), ())

  return ((left.at(0), left.at(3), left.at(1), left.at(2)),
          (right.at(0), right.at(3), right.at(1), right.at(2)))
}

/// Shorten curve by length d. A negative length shortens from the end.
///
/// - s  (vector): Curve start
/// - e  (vector): Curve end
/// - c1 (vector): Control point 1
/// - c2 (vector): Control point 2
/// - d  (float): Distance to shorten by
/// -> (s, e, c1, c2) Shortened curve
#let shorten(s, e, c1, c2, d) = {
  if d == 0 {
    return (s, e, c1, c2)
  }

  let num-samples = 6
  let split-t = 0
  if d > 0 {
    let travel = 0
    let last = cubic-point(s, e, c1, c2, 0)

    for t in range(0, num-samples + 1) {
      let t = t / num-samples
      let curr = cubic-point(s, e, c1, c2, t)
      let dist = calc.abs(vector.dist(last, curr))
      travel += dist
      if travel >= d {
        split-t = t - (travel - d) / num-samples
        break
      }
      last = curr
    }
  } else {
    let travel = 0
    let last = cubic-point(s, e, c1, c2, 1)

    for t in range(num-samples, -1, step: -1) {
      let t = t / num-samples
      let curr = cubic-point(s, e, c1, c2, t)
      let dist = calc.abs(vector.dist(last, curr))
      travel -= dist
      if travel <= d {
        split-t = t - (travel - d) / num-samples
        break
      }
      last = curr
    }
  }

  let (left, right) = split(s, e, c1, c2, split-t)
  return if d > 0 { right } else { left }
}

/// Align curve points pts to the line start-end
#let align(pts, start, end) = {
  let (x, y, _) = start
  let a = -calc.atan2(end.at(1) - y, end.at(0) - x)
  return pts.map(p => {
    ((p.at(0) - x) * calc.cos(-a) - (pt.at(1) - y) * calc.sin(-a),
     (p.at(0) - x) * calc.sin(-a) - (pt.at(1) - y) * calc.cos(-a),
     p.at(2))
  })
}

/// Find cubic curve extrema by calculating
/// the roots of the curves first derivative.
///
/// -> (array of vector) List of extrema points
#let cubic-extrema(s, e, c1, c2) = {
  // Compute roots of a single dimension (x, y, z) of the
  // curve by using the abc formula for finding roots of
  // the curves first derivative.
  let dim-extrema(a, b, c1, c2) = {
    let f0 = 3*(c1 - a)
    let f1 = 6*(c2 - 2*c1 + a)
    let f2 = 3*(b - 3*c2 + 3*c1 - a)

    if f1 == 0 and f2 == 0 {
      return ()
    }

    // Linear function
    if f2 == 0 {
      return (-f0 / f1,)
    }

    // No real roots
    let discriminant = f1*f1 - 4*f0*f2
    if discriminant < 0 {
      return ()
    }

    if discriminant == 0 {
      return (-f1 / (2*f2),)
    }
    
    return ((-f1 - calc.sqrt(discriminant)) / (2*f2),
            (-f1 + calc.sqrt(discriminant)) / (2*f2))
  }

  let pts = ()
  let dims = calc.max(s.len(), e.len())
  for dim in range(dims) {
    let ts = dim-extrema(s.at(dim, default: 0), e.at(dim, default: 0),
                         c1.at(dim, default: 0), c2.at(dim, default: 0))
    for t in ts {
      // Discard any root outside the bezier range
      if t >= 0 and t <= 1 {
        pts.push(cubic-point(s, e, c1, c2, t))
      }
    }
  }
  return pts
}

/// Return aabb coordinates for cubic bezier curve
///
/// -> (bottom-left, top-right)
#let cubic-aabb(s, e, c1, c2) = {
  let (lo, hi) = (s, e)
  for dim in range(lo.len()) {
    if lo.at(dim) > hi.at(dim) {
      (lo.at(dim), hi.at(dim)) = (hi.at(dim), lo.at(dim))
    }
  }
  for pt in cubic-extrema(s, e, c1, c2) {
    for dim in range(pt.len()) {
      lo.at(dim) = calc.min(lo.at(dim), hi.at(dim), pt.at(dim))
      hi.at(dim) = calc.max(lo.at(dim), hi.at(dim), pt.at(dim))
    }
  }
  return (lo, hi)
}

/// Returns a cubic bezier between p2 and p3 for a catmull-rom curve
/// through all four points.
///
/// - p1 (vector): Point 1
/// - p2 (vector): Point 2
/// - p3 (vector): Point 3
/// - p4 (vector): Point 4
/// - k  (float): Tension between 0 and 1
/// -> (a, b, c1, c2)
#let _catmull-section-to-cubic(p1, p2, p3, p4, k) = {
  return (p2, p3,
          vector.add(p2, vector.scale(vector.sub(p3, p1), 1/(k * 6))),
          vector.sub(p3, vector.scale(vector.sub(p4, p2), 1/(k * 6))))
}

/// Returns a list of cubic beziert for a catmull curve through points
///
/// - points (array): Array of 2d points
/// - k (float): Strength between 0 and oo
#let catmull-to-cubic(points, k, close: false) = {
  k = calc.max(k, 0.1)
  k = if k < .5 {
    1 / _map(k, .5, 0, 1, 10)
  } else {
    _map(k, .5, 1, 1, 10)
  }

  let len = points.len()
  if len == 2 {
    return ((points.at(0), points.at(1),
             points.at(0), points.at(1)),)
  } else if len > 2 {
    let curves = ()

    let (i0, iN) = if close {
      (-1, 0)
    } else {
      (0, -1)
    }

    curves.push(_catmull-section-to-cubic(points.at(i0), points.at(0),
                                          points.at(1), points.at(2), k))
    for i in range(1, len - 2, step: 1) {
      curves.push(_catmull-section-to-cubic(
        ..range(i - 1, i + 3).map(i => points.at(i)), k))
    }

    curves.push(_catmull-section-to-cubic(
      points.at(-3), points.at(-2), points.at(-1), points.at(iN), k))

    if close {
      curves.push(_catmull-section-to-cubic(
        points.at(-2), points.at(-1), points.at(0), points.at(1), k))
    }

    return curves
  }
  return ()
}
