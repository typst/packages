// Minimal 3-vector / 3x3-matrix helpers for the scene core.
// Plain arrays only; deliberately cetz-free so the core has no renderer deps.

/// Adds two vectors component-wise.
/// - a (vector): The vector on the left hand side.
/// - b (vector): The vector on the right hand side.
/// -> vector
#let vadd(a, b) = a.zip(b).map(((x, y)) => x + y)

/// Subtracts two vectors component-wise.
/// - a (vector): The vector to subtract from.
/// - b (vector): The vector to subtract.
/// -> vector
#let vsub(a, b) = a.zip(b).map(((x, y)) => x - y)

/// Multiplies a vector by a scalar.
/// - a (vector): The vector to scale.
/// - s (float): The scale factor.
/// -> vector
#let vscale(a, s) = a.map(x => x * s)

/// Calculates the dot product of two vectors.
/// - a (vector): The vector on the left hand side.
/// - b (vector): The vector on the right hand side.
/// -> float
#let vdot(a, b) = a.zip(b).map(((x, y)) => x * y).sum()

/// Calculates the cross product of two 3-vectors.
/// - a (vector): The vector on the left hand side.
/// - b (vector): The vector on the right hand side.
/// -> vector
#let vcross(a, b) = (
  a.at(1) * b.at(2) - a.at(2) * b.at(1),
  a.at(2) * b.at(0) - a.at(0) * b.at(2),
  a.at(0) * b.at(1) - a.at(1) * b.at(0),
)

/// Returns the length/magnitude of a vector.
/// - a (vector): The vector to measure.
/// -> float
#let vlen(a) = calc.sqrt(vdot(a, a))

/// Normalizes a vector (divides by its length).
/// - a (vector): The vector to normalize.
/// -> vector
#let vnorm(a) = vscale(a, 1 / vlen(a))

/// Multiplies a matrix (array of rows) with a vector.
/// - m (matrix): The matrix, given as an array of row vectors.
/// - v (vector): The vector to multiply.
/// -> vector
#let mvec(m, v) = m.map(row => vdot(row, v))

/// Linear interpolation between two vectors.
/// - a (vector): The vector to interpolate from.
/// - b (vector): The vector to interpolate to.
/// - t (float): The factor to interpolate by. `0` is `a`, `1` is `b`.
/// -> vector
#let lerp(a, b, t) = vadd(vscale(a, 1 - t), vscale(b, t))
