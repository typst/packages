
/// Solve a system of linear equations $A dot arrow(x) = arrow(b)$
/// where $A$ is a tridiagonal matrix.
/// See https://en.wikipedia.org/wiki/Tridiagonal_matrix_algorithm
/// for more information.
///
/// Returns the solutions $arrow(x) in RR^n$ of the system of linear equqations.
///
/// -> array
#let thomas-algorithm(
  /// The matrix $A in RR^(n times n)$ of the system of linear equations.
  /// The data format is an array of arrays, in row-major order.
  ///
  /// -> array
  A,
  /// The vector $arrow(b) in RR^n$ of the system of linear equations.
  ///
  /// -> array
  b,
) = {
  let n = b.len()

  if n == 1 {
    return (b.at(0) / A.at(0).at(0),)
  }

  let beta = (0,) * n
  let gamma = (0,) * n
  let y = (0,) * n

  beta.at(0) = A.at(0).at(0)
  gamma.at(0) = A.at(0).at(1) / beta.at(0)
  y.at(0) = b.at(0) / beta.at(0)

  for i in range(1, n) {
    let d-i = A.at(i).at(i)
    let e-i = A.at(i).at(i - 1)
    beta.at(i) = d-i - e-i * gamma.at(i - 1)

    if i < n - 1 {
      let c-i = A.at(i).at(i + 1)
      gamma.at(i) = c-i / beta.at(i)
    }

    // backward elimination
    y.at(i) = (b.at(i) - e-i * y.at(i - 1)) / beta.at(i)
  }

  let x = (0,) * n
  x.at(n - 1) = y.at(n - 1)

  // forward elimination
  for i in range(n - 2, -1, step: -1) {
    x.at(i) = y.at(i) - gamma.at(i) * x.at(i + 1)
  }

  x
}

