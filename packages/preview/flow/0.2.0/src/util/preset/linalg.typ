// Utils for typing linear algebra.

#let ovl = math.overline
/// Inversion.
#let inv(it) = $it^(-1)$
// Transposition.
#let trp(it) = $it^upright(T)$
// Conjugate transposition.
#let ctrp(it) = $it^upright(H)$

/// Alternate calligraphic handstyle.
/// Not supported by all math fonts.
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
#let ipr(..args) = $lr(angle.l #args.pos().join[,] angle.r)$

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
// Transposed.
#let (
  AT, BT, CT, DT, ET, PT, QT, RT, ST, TTr, VT, WT, XT, YT, ZT,
  aT, bT, cT, dT, eT, pT, qT, rT, sT, tT, vT, wT, xT, yT, zT,
) = shorthand(trp)
// Conjugate transposed.
#let (
  AH, BH, CH, DH, EH, PH, QH, RH, SH, TH, VH, WH, XH, YH, ZH,
  aH, bH, cH, dH, eH, pH, qH, rH, sH, tH, vH, wH, xH, yH, zH,
) = shorthand(ctrp)

// Vector boldfaced.
#let (
  Avb, Bvb, Cvb, Dvb, Evb, Pvb, Qvb, Rvb, Svb, Tvb, Vvb, Wvb, Xvb, Yvb, Zvb,
  avb, bvb, cvb, dvb, evb, pvb, qvb, rvb, svb, tvb, vvb, wvb, xvb, yvb, zvb,
) = shorthand(ch => math.bold(math.arrow(ch)))
// Vector tildized.
#let (
  Ava, Bva, Cva, Dva, Eva, Pva, Qva, Rva, Sva, Tva, Vva, Wva, Xva, Yva, Zva,
  ava, bva, cva, dva, eva, pva, qva, rva, sva, tva, vva, wva, xva, yva, zva,
) = shorthand(ch => math.tilde(math.arrow(ch)))
// Vector transposed.
#let (
  AvT, BvT, CvT, DvT, EvT, PvT, QvT, RvT, SvT, TvT, VvT, WvT, XvT, YvT, ZvT,
  avT, bvT, cvT, dvT, evT, pvT, qvT, rvT, svT, tvT, vvT, wvT, xvT, yvT, zvT,
) = shorthand(ch => trp(math.arrow(ch)))
// Vector conjugate transposed.
#let (
  AvH, BvH, CvH, DvH, EvH, PvH, QvH, RvH, SvH, TvH, VvH, WvH, XvH, YvH, ZvH,
  avH, bvH, cvH, dvH, evH, pvH, qvH, rvH, svH, tvH, vvH, wvH, xvH, yvH, zvH,
) = shorthand(ch => ctrp(math.arrow(ch)))

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
