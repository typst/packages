// =========================================================================
// CAS Matrix Algebra
// =========================================================================
// Matrix operations: add, subtract, multiply, transpose, determinant,
// inverse, solve (Cramer's rule), eigenvalues, and eigenvectors.
// All matrices are CAS expression dicts built with cmat().
// =========================================================================

#import "expr.typ": *
#import "simplify.typ": simplify

// --- Helpers ---

/// Get matrix dimensions.
///
/// - m: CAS matrix.
/// - returns: (rows, cols) tuple of integers.
#let mat-dims(m) = {
  let nrows = m.rows.len()
  let ncols = m.rows.at(0).len()
  (nrows, ncols)
}

/// Get element at position (i, j). Zero-indexed.
///
/// - m: CAS matrix.
/// - i: Row index (0-based).
/// - j: Column index (0-based).
/// - returns: CAS expression at that position.
#let mat-at(m, i, j) = {
  m.rows.at(i).at(j)
}

// --- Arithmetic ---

/// Element-wise matrix addition: A + B. Matrices must have the same dimensions.
///
/// - a: First matrix.
/// - b: Second matrix.
/// - returns: Sum matrix.
#let mat-add(a, b) = {
  let (ar, ac) = mat-dims(a)
  let rows = range(ar).map(i => range(ac).map(j => simplify(add(mat-at(a, i, j), mat-at(b, i, j)))))
  cmat(rows)
}

/// Element-wise matrix subtraction: A − B.
///
/// - a: First matrix.
/// - b: Second matrix.
/// - returns: Difference matrix.
#let mat-sub(a, b) = {
  let (ar, ac) = mat-dims(a)
  let rows = range(ar).map(i => range(ac).map(j => simplify(sub(mat-at(a, i, j), mat-at(b, i, j)))))
  cmat(rows)
}

/// Scalar multiplication: c · M.
///
/// - c: Scalar (number or CAS expression).
/// - m: CAS matrix.
/// - returns: Scaled matrix.
#let mat-scale(c, m) = {
  let c = if type(c) == int or type(c) == float { num(c) } else { c }
  let (r, cols) = mat-dims(m)
  let rows = range(r).map(i => range(cols).map(j => simplify(mul(c, mat-at(m, i, j)))))
  cmat(rows)
}

/// Matrix multiplication: A × B. Requires cols(A) = rows(B).
///
/// - a: Left matrix (m×n).
/// - b: Right matrix (n×p).
/// - returns: Product matrix (m×p).
#let mat-mul(a, b) = {
  let (ar, ac) = mat-dims(a)
  let (br, bc) = mat-dims(b)
  // ac must equal br
  let rows = range(ar).map(i => range(bc).map(j => {
    let terms = range(ac).map(k => mul(mat-at(a, i, k), mat-at(b, k, j)))
    let result = terms.at(0)
    for t in range(1, terms.len()) {
      result = add(result, terms.at(t))
    }
    simplify(result)
  }))
  cmat(rows)
}

/// Matrix transpose: swap rows and columns.
///
/// - m: CAS matrix (m×n).
/// - returns: Transposed matrix (n×m).
#let mat-transpose(m) = {
  let (r, c) = mat-dims(m)
  let rows = range(c).map(j => range(r).map(i => mat-at(m, i, j)))
  cmat(rows)
}

// --- Determinant ---

/// Determinant of an n×n matrix via recursive cofactor expansion along the first row.
/// Works for any size, but O(n!) so best for small matrices (≤5).
///
/// - m: Square CAS matrix.
/// - returns: Determinant as a CAS expression.
#let mat-det(m) = {
  let (n, _) = mat-dims(m)

  if n == 1 { return mat-at(m, 0, 0) }

  if n == 2 {
    return simplify(sub(
      mul(mat-at(m, 0, 0), mat-at(m, 1, 1)),
      mul(mat-at(m, 0, 1), mat-at(m, 1, 0)),
    ))
  }

  // Cofactor expansion along first row
  let result = num(0)
  for j in range(n) {
    // Minor: remove row 0, col j
    let minor-rows = range(1, n).map(i => range(n).filter(k => k != j).map(k => mat-at(m, i, k)))
    let minor = cmat(minor-rows)
    let cofactor = mul(mat-at(m, 0, j), mat-det(minor))
    if calc.rem(j, 2) == 0 {
      result = add(result, cofactor)
    } else {
      result = sub(result, cofactor)
    }
  }
  simplify(result)
}

// --- Inverse (n×n via adjugate/det) ---

/// Matrix inverse: A⁻¹ via adjugate/determinant formula.
/// Works for any n×n matrix. Uses fast formula for 2×2.
///
/// - m: Square CAS matrix.
/// - returns: Inverse matrix (CAS matrix).
#let mat-inv(m) = {
  let (n, _) = mat-dims(m)

  if n == 1 {
    return cmat(((cdiv(num(1), mat-at(m, 0, 0)),),))
  }

  if n == 2 {
    let det = mat-det(m)
    let a = mat-at(m, 0, 0)
    let b = mat-at(m, 0, 1)
    let c = mat-at(m, 1, 0)
    let d = mat-at(m, 1, 1)
    let inv-det = cdiv(num(1), det)
    return mat-scale(inv-det, cmat(((d, neg(b)), (neg(c), a))))
  }

  // General n×n: inverse = adjugate / det
  let det = mat-det(m)
  // Build cofactor matrix
  let cofactors = range(n).map(i => range(n).map(j => {
    let minor-rows = range(n)
      .filter(ii => ii != i)
      .map(ii => range(n).filter(jj => jj != j).map(jj => mat-at(m, ii, jj)))
    let minor-det = mat-det(cmat(minor-rows))
    if calc.rem(i + j, 2) == 0 { minor-det } else { simplify(neg(minor-det)) }
  }))
  // Adjugate = transpose of cofactor matrix
  let adj = mat-transpose(cmat(cofactors))
  mat-scale(cdiv(num(1), det), adj)
}

// --- Solve Ax = b ---

/// Solve Ax = b using Cramer's rule. Works for any n×n system.
///
/// - a: Coefficient matrix (n×n CAS matrix).
/// - b-vec: Right-hand side column as an array of n CAS expressions.
/// - returns: Array of n solution expressions [x₁, x₂, ..., xₙ].
///
/// example
/// mat-solve(cmat(((2, 1), (1, 3))), (num(5), num(6)))
/// 
#let mat-solve(a, b-vec) = {
  let (n, _) = mat-dims(a)
  let det-a = mat-det(a)

  // b-vec is an array of expressions (column vector)
  let solutions = range(n).map(j => {
    // Replace column j of A with b
    let modified-rows = range(n).map(i => range(n).map(k => if k == j { b-vec.at(i) } else { mat-at(a, i, k) }))
    simplify(cdiv(mat-det(cmat(modified-rows)), det-a))
  })
  solutions
}

// =========================================================================
// EIGENVALUES AND EIGENVECTORS
// =========================================================================

/// Compute eigenvalues of a 2×2 matrix.
/// Uses the trace/determinant formula: λ = (tr ± √(tr² − 4·det)) / 2.
///
/// - m: 2×2 CAS matrix.
/// - returns: Array of eigenvalue expressions (1 or 2 elements).
///   Returns empty array if matrix is not 2×2.
///
/// example
/// mat-eigenvalues(cmat(((2, 1), (1, 2))))  // => (num(3), num(1))
/// 
#let mat-eigenvalues(m) = {
  let (n, _) = mat-dims(m)

  if n == 2 {
    // det(A - λI) = λ² - tr(A)·λ + det(A) = 0
    let a = mat-at(m, 0, 0)
    let b = mat-at(m, 0, 1)
    let c = mat-at(m, 1, 0)
    let d = mat-at(m, 1, 1)

    // trace = a + d, det = ad - bc
    let tr = simplify(add(a, d))
    let det = simplify(sub(mul(a, d), mul(b, c)))

    // λ = (tr ± sqrt(tr² - 4·det)) / 2
    let disc = simplify(sub(pow(tr, num(2)), mul(num(4), det)))

    // If discriminant is a number, compute directly
    if is-type(disc, "num") {
      if disc.val > 0 {
        let sq = num(calc.sqrt(disc.val))
        return (
          simplify(cdiv(add(tr, sq), num(2))),
          simplify(cdiv(sub(tr, sq), num(2))),
        )
      }
      if disc.val == 0 {
        return (simplify(cdiv(tr, num(2))),)
      }
      // Negative discriminant: return symbolic
    }

    // Return symbolic eigenvalues
    return (
      simplify(cdiv(add(tr, sqrt-of(disc)), num(2))),
      simplify(cdiv(sub(tr, sqrt-of(disc)), num(2))),
    )
  }

  // Unsupported size
  return ()
}

/// Compute eigenvectors for a 2×2 matrix.
/// For each eigenvalue, finds the corresponding eigenvector by solving (A − λI)v = 0.
///
/// - m: 2×2 CAS matrix.
/// - returns: Array of (eigenvalue, (v₁, v₂)) pairs. Empty if not 2×2.
///
/// example
/// mat-eigenvectors(cmat(((2, 1), (1, 2))))  // => ((3, (1, 1)), (1, (1, -1)))
/// 
#let mat-eigenvectors(m) = {
  let (n, _) = mat-dims(m)
  if n != 2 { return () }

  let eigenvals = mat-eigenvalues(m)
  let results = ()

  for lam in eigenvals {
    // (A - λI) v = 0
    // Use first row: (a - λ)·v1 + b·v2 = 0 => v2 = -(a-λ)/b · v1
    let a-lam = simplify(sub(mat-at(m, 0, 0), lam))
    let b = mat-at(m, 0, 1)

    // If b is zero, try second row
    if is-type(b, "num") and b.val == 0 {
      let c = mat-at(m, 1, 0)
      if is-type(c, "num") and c.val == 0 {
        // Both off-diagonal are zero => standard basis vectors
        results.push((lam, (num(1), num(0))))
      } else {
        results.push((lam, (num(0), num(1))))
      }
    } else {
      // v = (b, -(a-λ)) = (b, λ-a) normalized
      results.push((lam, (b, simplify(neg(a-lam)))))
    }
  }

  results
}
