// Utils for typing linear algebra.

#let inv(it) = $it^(-1)$
#let scr(it) = text(
  features: ("ss01",),
  box($cal(it)$)
)
#let dmat(it) = $display(mat(it))$

#let kernel = $scr(N)$
#let image = $scr(R)$

#let null = $arrow(0)$

#let span = math.op("span")
#let rank = math.op("rank")

#let linco(base) = $sum_(i = 1)^k lambda_i base_i$

#let matop(entry, rows: $m$, cols: $n$) = {
  $[entry]_(1 <= y <= rows, 1 <= x <= cols)$
}
/// One-line definition of how each entry is named in a matrix.
#let matdef(body, ..args) = matop($body_(y, x)$, ..args)

/// Visual representation of each entry.
#let matvis(entry, rows: $m$, cols: $n$, ..args) = {
  let data = (
      ($entry_(1, 1)$, $dots.c$, $entry_(1, cols)$),
      ($dots.v$, $dots.down$, $dots.v$),
      ($entry_(rows, 1)$, $dots.c$, $entry_(rows, cols)$),
    )

  return math.mat(
    ..data,
    ..args,
  )
}

#let matset = $KK^(m times n)$
#let matset2 = $KK^(n times p)$
#let matset3 = $KK^(p times q)$

#let matsq = $KK^(n times n)$
#let matsq2 = $KK^(m times m)$

#let vecset = $KK^n$
#let vecset2 = $KK^m$

// Over what characters shorthands are defined.
#let charset = "abcdepqrstvwxyz"
#let charset = upper(charset) + charset
/// Maps each common character in equations to the given op.
#let shorthand(op, space: charset) = space.clusters().map(op)

// Boldface.
#let (
  Ab, Bb, Cb, Db, Eb, Pb, Qb, Rb, Sb, Tb, Vb, Wb, Xb, Yb, Zb,
  ab, bbo, cb, db, eb, pb, qb, rb, sb, tb, vb, wb, xb, yb, zb,
) = shorthand(math.bold)
// Vectors.
#let (
  Av, Bv, Cv, Dv, Ev, Pv, Qv, Rv, Sv, Tv, Vv, Wv, Xv, Yv, Zv,
  av, bv, cv, dv, ev, pv, qv, rv, sv, tv, vv, wv, xv, yv, zv,
) = shorthand(math.arrow)
// Tildized.
#let (
  At, Bt, Ct, Dt, Et, Pt, Qt, Rt, St, Tt, Vt, Wt, Xt, Yt, Zt,
  at, bt, ct, dt, et, pt, qt, rt, st, tt, vt, wt, xt, yt, zt,
) = shorthand(math.tilde)
// Inverted.
#let (
  Ainv, Binv, Cinv, Dinv, Einv, Pinv, Qinv, Rinv, Sinv, Tinv, Vinv, Winv, Xinv, Yinv, Zinv,
  ainv, binv, cinv, dinv, einv, pinv, qinv, rinv, sinv, tinv, vinv, winv, xinv, yinv, zinv,
) = shorthand(inv)

// Short definition of a matrix' entries.
#let sdef(entry) = $[entry_(y, x)]$
// Short definition of a matrix' entries that is in a general field.
#let sdefk(entry) = $sdef(entry) in matset$
// Short definition of a matrix' entries that is in a complex field.
#let sdefc(entry) = $sdef(entry) in CC^(n times m)$

#let col(name, n: $n$) = $vec(name_1, dots.v, name_#n)$
#let row(name, n: $n$) = $dmat(name_1, ..., name_#n)$

#let vecdef(name, over: $KK$, dim: $n$) = {
  $[name_i]_(i = 1)^dim
  #if over != none { $in over^dim$ }$
}

#let same(value) = $vec(value, dots.v, value)$
