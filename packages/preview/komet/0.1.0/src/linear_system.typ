#import "plugin.typ": komet-plugin

/// Solves a system of linear equations $A arrow(x) = arrow(b)$
/// where $A$ is a tridiagonal matrix.
/// See https://en.wikipedia.org/wiki/Tridiagonal_matrix_algorithm
/// for more information.
///
/// Panics if there's a mismatch in the matrix or vector dimensions.
///
/// Returns the solutions $arrow(x) in RR^n$ of the system of linear equations.
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
  let n = A.len()

  for row in A {
    assert.eq(row.len(), n, message: "matrix is not square")
  }
  assert.eq(b.len(), n, message: "vector dimension does not match matrix dimension")

  let A = cbor.encode(A.map(row => row.map(float)))
  let b = cbor.encode(b.map(float))

  cbor(komet-plugin.thomas_algorithm(A, b))
}

