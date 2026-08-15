// Gaussian kernel density estimation shared by stat-density and
// stat-ydensity. Kernels are evaluated directly (O(pairs × n) per call),
// workable for plot-sized inputs.

#import "errors.typ": fail-type
#import "summaries.typ": quantile-type-7

// Grid extension beyond the data range, in bandwidths. Matches R's
// `density(..., cut = 3)` default for the Gaussian kernel.
#let _CUT = 3

// Silverman's rule of thumb (R's `bw.nrd0`): 0.9 times the lesser of the
// standard deviation and IQR/1.34, times n^(-1/5), with R's fallback chain
// when the spread estimate degenerates to zero.
#let bw-nrd0(values) = {
  let n = values.len()
  let mean = values.sum() / n
  let sd = calc.sqrt(
    values.map(v => (v - mean) * (v - mean)).sum() / (n - 1),
  )
  let sorted = values.sorted()
  let iqr = quantile-type-7(sorted, 0.75) - quantile-type-7(sorted, 0.25)
  let spread = calc.min(sd, iqr / 1.34)
  if spread == 0 { spread = sd }
  if spread == 0 { spread = calc.abs(values.first()) }
  if spread == 0 { spread = 1.0 }
  0.9 * spread * calc.pow(n, -0.2)
}

// R's `bw.nrd` (Scott's variation): like `bw-nrd0` but with the 1.06
// factor. MASS::kde2d seeds its per-axis bandwidths from this rule.
#let bw-nrd(values) = {
  bw-nrd0(values) * 1.06 / 0.9
}

// Panic unless the shared KDE parameters are well-formed. `scope` names the
// calling stat so the message points at the user-facing constructor.
#let validate-kde-params(scope, params) = {
  let bw = params.at("bw", default: auto)
  if bw != auto and (type(bw) not in (int, float) or bw <= 0) {
    fail-type(scope, "bw", bw, "a positive number or `auto`")
  }
  let adjust = params.at("adjust", default: 1)
  if type(adjust) not in (int, float) or adjust <= 0 {
    fail-type(scope, "adjust", adjust, "a positive number")
  }
  let n = params.at("n", default: 512)
  if type(n) != int or n < 2 {
    fail-type(scope, "n", n, "an integer of at least 2")
  }
  let trim = params.at("trim", default: false)
  if type(trim) != bool {
    fail-type(scope, "trim", trim, "a boolean")
  }
}

// Weighted Gaussian KDE of `pairs` (dicts with numeric `x` and positive
// weight `w`; the caller filters) over `n` evenly spaced grid points. The
// grid spans the data range, extended by `_CUT` bandwidths per side unless
// `trim`. `bw: auto` applies `bw-nrd0`; `adjust` multiplies the bandwidth.
// Returns `(rows, bw)` where rows carry `(x: grid value, density:)`.
#let kde-1d(pairs, bw: auto, adjust: 1, n: 512, trim: false) = {
  let xs = pairs.map(p => p.x)
  let total-weight = pairs.map(p => p.w).sum()
  let resolved-bw = if bw == auto { bw-nrd0(xs) } else { float(bw) }
  resolved-bw = resolved-bw * adjust

  let x-lo = calc.min(..xs)
  let x-hi = calc.max(..xs)
  if not trim {
    x-lo -= _CUT * resolved-bw
    x-hi += _CUT * resolved-bw
  }
  let norm = 1 / (resolved-bw * calc.sqrt(2 * calc.pi))

  let rows = range(n).map(i => {
    let g = if x-hi == x-lo { x-lo } else {
      x-lo + (x-hi - x-lo) * i / (n - 1)
    }
    let density = (
      pairs
        .map(p => {
          let z = (g - p.x) / resolved-bw
          p.w * calc.exp(-0.5 * z * z)
        })
        .sum()
        * norm
        / total-weight
    )
    (x: g, density: density)
  })
  (rows: rows, bw: resolved-bw)
}

// Evenly spaced grid over the data range extended by `_CUT` bandwidths so
// the density decays towards zero before the boundary.
#let _kde-axis(values, bw, n) = {
  let lo = calc.min(..values) - _CUT * bw
  let hi = calc.max(..values) + _CUT * bw
  range(n).map(i => lo + (hi - lo) * i / (n - 1))
}

// One axis's kernel-bandwidth resolution for `kde-2d`: `auto` applies
// `bw-nrd / 4` (the kernel standard deviation MASS::kde2d derives from its
// full-width `h`), with a positive floor for degenerate spreads.
#let _kde-2d-bw(values, bw, adjust) = {
  let resolved = if bw == auto { bw-nrd(values) / 4 } else { float(bw) }
  resolved = resolved * adjust
  if resolved <= 0 { 1.0 } else { resolved }
}

// Weighted 2D Gaussian product-kernel density of `pairs` (dicts with
// numeric `x`, `y` and positive weight `w`; the caller filters) over an
// `n × n` grid (or `(nx, ny)` tuple). `bw: auto` derives per-axis kernel
// standard deviations from `bw-nrd / 4`; a number applies to both axes and
// an `(x, y)` tuple sets them separately. The product kernel is separable,
// so each axis's kernel matrix is evaluated once and combined per cell.
// Returns `(xs, ys, z, z-lo, z-hi, bw)` in the layout the contour and
// isoband consumers expect (`z` indexed `z.at(xi).at(yi)`).
#let kde-2d(pairs, bw: auto, adjust: 1, n: 50) = {
  let (nx, ny) = if type(n) == array { n } else { (n, n) }
  let (bw-x, bw-y) = if type(bw) == array { bw } else { (bw, bw) }
  let xs-data = pairs.map(p => p.x)
  let ys-data = pairs.map(p => p.y)
  let hx = _kde-2d-bw(xs-data, bw-x, adjust)
  let hy = _kde-2d-bw(ys-data, bw-y, adjust)

  let xs = _kde-axis(xs-data, hx, nx)
  let ys = _kde-axis(ys-data, hy, ny)
  let kernel-x = xs.map(g => xs-data.map(v => {
    let z = (g - v) / hx
    calc.exp(-0.5 * z * z)
  }))
  let kernel-y = ys.map(g => ys-data.map(v => {
    let z = (g - v) / hy
    calc.exp(-0.5 * z * z)
  }))
  let weights = pairs.map(p => p.w)
  let total-weight = weights.sum()
  let norm = 1 / (2 * calc.pi * hx * hy * total-weight)
  let n-data = pairs.len()

  let z = ()
  let z-lo = none
  let z-hi = none
  for kx in kernel-x {
    let column = ()
    for ky in kernel-y {
      let density = (
        range(n-data).map(d => weights.at(d) * kx.at(d) * ky.at(d)).sum() * norm
      )
      z-lo = if z-lo == none { density } else { calc.min(z-lo, density) }
      z-hi = if z-hi == none { density } else { calc.max(z-hi, density) }
      column.push(density)
    }
    z.push(column)
  }
  (xs: xs, ys: ys, z: z, z-lo: z-lo, z-hi: z-hi, bw: (hx, hy))
}
