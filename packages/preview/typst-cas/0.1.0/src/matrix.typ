// =========================================================================
// CAS Matrix Algebra
// =========================================================================
// Matrix operations: add, multiply, determinant, inverse, transpose, solve.
// =========================================================================

#import "expr.typ": *
#import "simplify.typ": simplify

// --- Helpers ---

/// Get matrix dimensions: (rows, cols)
#let mat-dims(m) = {
  let nrows = m.rows.len()
  let ncols = m.rows.at(0).len()
  (nrows, ncols)
}

/// Get element at (i, j) — 0-indexed
#let mat-at(m, i, j) = {
  m.rows.at(i).at(j)
}

// --- Arithmetic ---

/// Matrix addition: A + B
#let mat-add(a, b) = {
  let (ar, ac) = mat-dims(a)
  let rows = range(ar).map(i => range(ac).map(j => simplify(add(mat-at(a, i, j), mat-at(b, i, j)))))
  cmat(rows)
}

/// Matrix subtraction: A - B
#let mat-sub(a, b) = {
  let (ar, ac) = mat-dims(a)
  let rows = range(ar).map(i => range(ac).map(j => simplify(sub(mat-at(a, i, j), mat-at(b, i, j)))))
  cmat(rows)
}

/// Scalar * Matrix
#let mat-scale(c, m) = {
  let c = if type(c) == int or type(c) == float { num(c) } else { c }
  let (r, cols) = mat-dims(m)
  let rows = range(r).map(i => range(cols).map(j => simplify(mul(c, mat-at(m, i, j)))))
  cmat(rows)
}

/// Matrix multiplication: A * B
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

/// Matrix transpose
#let mat-transpose(m) = {
  let (r, c) = mat-dims(m)
  let rows = range(c).map(j => range(r).map(i => mat-at(m, i, j)))
  cmat(rows)
}

// --- Determinant ---

/// Determinant via cofactor expansion (up to 4x4)
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

// --- Inverse (2x2 and 3x3) ---

/// Matrix inverse for 2x2 matrices
#let mat-inv(m) = {
  let (n, _) = mat-dims(m)

  if n == 2 {
    let det = mat-det(m)
    let a = mat-at(m, 0, 0)
    let b = mat-at(m, 0, 1)
    let c = mat-at(m, 1, 0)
    let d = mat-at(m, 1, 1)
    let inv-det = cdiv(num(1), det)
    return mat-scale(inv-det, cmat(((d, neg(b)), (neg(c), a))))
  }

  // For 3x3+: compute via adjugate/det
  if n == 3 {
    let det = mat-det(m)
    // Cofactor matrix
    let cofactors = range(n).map(i => range(n).map(j => {
      let minor-rows = range(n)
        .filter(ii => ii != i)
        .map(ii => range(n).filter(jj => jj != j).map(jj => mat-at(m, ii, jj)))
      let minor-det = mat-det(cmat(minor-rows))
      if calc.rem(i + j, 2) == 0 { minor-det } else { simplify(neg(minor-det)) }
    }))
    let adj = mat-transpose(cmat(cofactors))
    return mat-scale(cdiv(num(1), det), adj)
  }

  // Unsupported
  return none
}

// --- Solve Ax = b ---

/// Solve Ax = b using Cramer's rule (for small systems)
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
