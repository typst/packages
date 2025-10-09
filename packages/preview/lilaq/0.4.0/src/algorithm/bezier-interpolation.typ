#import "linear-system.typ": thomas-algorithm

/// Solves for a system of linear equations $A dot arrow(x) = arrow(b)$
/// for the control points of the Bézier spline in either $x$ or $y$.
///
/// Returns an array of all control points (including start and end points) in $x$ or $y$.
///
/// -> array
#let solve-control-points-1d(
  /// The matrix $A$ of the system of linear equations.
  /// -> array
  A,
  /// The vector $b$ of the system of linear equations.
  /// -> array
  b,
  /// The dimension $n$ of the system of linear eqautions.
  /// -> int
  n,
) = {
  let s = range(2, n).map(i => (
    2 * (2 * b.at(i - 1) + b.at(i))
  ))
  s.insert(0, b.at(0) + 2 * b.at(1))
  s.push(8 * b.at(n - 1) + b.at(n))

  // first control points
  let c1 = thomas-algorithm(A, s)
  // second control points
  let c2 = range(0, n - 1).map(i => 2 * b.at(i + 1) - c1.at(i + 1))
  c2.push(0.5 * (c1.at(n - 1) + b.at(n)))

  let points = c1.zip(c2, b.slice(1)).flatten()
  points.insert(0, b.at(0))

  points
}

/// Calculates the control points (including start and end points) for a Bézier spline
/// which interpolates the given data set.
/// For the boundary conditions a curvature of 0 was chosen for the start and end points.
///
/// Math from https://omaraflak.medium.com/b%C3%A9zier-interpolation-8033e9a262c2
///
/// Returns an array of points (2D arrays).
///
/// -> array
#let bezier-splines(
  /// $x$ coordinates of the given points.
  /// -> array
  x,
  /// $y$ coordinates of the given points.
  /// -> array
  y,
) = {
  let n = y.len() - 1

  if n < 2 {
    panic("at least 3 points are required for calculating a Bézier spline")
  }

  let A = ((0,) * (n),) * (n)
  for i in range(1, n - 1) {
    A.at(i).at(i) = 4
    A.at(i + 1).at(i) = 1
    A.at(i).at(i + 1) = 1
  }
  A.at(0).at(0) = 2
  A.at(1).at(0) = 1
  A.at(0).at(1) = 1
  A.at(n - 1).at(n - 1) = 7
  A.at(n - 1).at(n - 2) = 2

  let points-x = solve-control-points-1d(A, x, n)
  let points-y = solve-control-points-1d(A, y, n)

  let points = points-x.zip(points-y)

  points
}
