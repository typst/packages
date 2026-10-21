///! Standard-normal helpers and theoretical quantile dispatch.
///!
///! Used by stat helpers (e.g., `mean-cl-normal`) and exposed publicly so
///! future geoms (e.g., a Q-Q plot) can reuse the same approximation.
///! Also hosts `theoretical-quantile`, the small dispatch used by the
///! Q-Q stats to pick a reference distribution.

#import "errors.typ": fail-enum, fail-range

/// Inverse of the standard-normal cumulative distribution function.
///
/// Implements Acklam's rational approximation (2003), accurate to about `1.15e-9` across the unit interval, including the tails. Inputs at or outside the open interval `(0, 1)` panic so callers do not silently receive an undefined result.
///
/// - p: Probability in the open interval `(0, 1)`.
///
/// Returns: Quantile `z` such that `P(Z <= z) = p` for `Z ~ N(0, 1)`.
///
/// The 97.5th percentile is the canonical 1.96 normal quantile used in two-sided 95% intervals.
///
/// ```typst
/// #let z = qnorm(0.975)
/// // z ≈ 1.96
/// ```
///
/// Use `qnorm` to derive a custom symmetric confidence multiplier for any level.
///
/// ```typst
/// #let level = 0.99
/// #let mult = qnorm(0.5 + level / 2)
/// ```
#let qnorm(p) = {
  if p <= 0 or p >= 1 {
    fail-range("qnorm", "p", p, 0, 1)
  }
  let a = (
    -3.969683028665376e+01,
    2.209460984245205e+02,
    -2.759285104469687e+02,
    1.383577518672690e+02,
    -3.066479806614716e+01,
    2.506628277459239e+00,
  )
  let b = (
    -5.447609879822406e+01,
    1.615858368580409e+02,
    -1.556989798598866e+02,
    6.680131188771972e+01,
    -1.328068155288572e+01,
  )
  let c = (
    -7.784894002430293e-03,
    -3.223964580411365e-01,
    -2.400758277161838e+00,
    -2.549732539343734e+00,
    4.374664141464968e+00,
    2.938163982698783e+00,
  )
  let d = (
    7.784695709041462e-03,
    3.224671290700398e-01,
    2.445134137142996e+00,
    3.754408661907416e+00,
  )
  let p-low = 0.02425
  let p-high = 1 - p-low
  let q
  if p < p-low {
    let qq = calc.sqrt(-2 * calc.ln(p))
    q = (
      (
        (
          (((c.at(0) * qq + c.at(1)) * qq + c.at(2)) * qq + c.at(3)) * qq
            + c.at(4)
        )
          * qq
          + c.at(5)
      )
        / (
          (((d.at(0) * qq + d.at(1)) * qq + d.at(2)) * qq + d.at(3)) * qq + 1
        )
    )
  } else if p <= p-high {
    let qq = p - 0.5
    let r = qq * qq
    q = (
      (
        ((((a.at(0) * r + a.at(1)) * r + a.at(2)) * r + a.at(3)) * r + a.at(4))
          * r
          + a.at(5)
      )
        * qq
        / (
          (
            (((b.at(0) * r + b.at(1)) * r + b.at(2)) * r + b.at(3)) * r
              + b.at(4)
          )
            * r
            + 1
        )
    )
  } else {
    let qq = calc.sqrt(-2 * calc.ln(1 - p))
    q = (
      -(
        (
          (((c.at(0) * qq + c.at(1)) * qq + c.at(2)) * qq + c.at(3)) * qq
            + c.at(4)
        )
          * qq
          + c.at(5)
      )
        / (
          (((d.at(0) * qq + d.at(1)) * qq + d.at(2)) * qq + d.at(3)) * qq + 1
        )
    )
  }
  q
}

/// Theoretical quantile for a Q-Q reference distribution.
///
/// Dispatches to the inverse CDF of the chosen reference family. `"normal"` calls `qnorm`, `"uniform"` returns `p` directly (the quantile of `Uniform(0, 1)` at probability `p`), and `"exponential"` returns `-ln(1 - p)` (the quantile of `Exp(1)` at probability `p`).
///
/// - p: Probability in the open interval `(0, 1)`.
/// - distribution: One of `"normal"`, `"uniform"`, or `"exponential"`.
///
/// Returns: Theoretical quantile at probability `p`.
///
/// Same probability under the three supported reference distributions.
///
/// ```typst
/// #let z-norm = theoretical-quantile(0.5, "normal")     // 0
/// #let z-uni  = theoretical-quantile(0.5, "uniform")    // 0.5
/// #let z-exp  = theoretical-quantile(0.5, "exponential") // ~0.693
/// ```
///
/// Build an array of plotting positions for use inside a custom Q-Q derivation.
///
/// ```typst
/// #let n = 5
/// #let qs = range(0, n).map(i => theoretical-quantile((i + 0.5) / n, "normal"))
/// ```
#let theoretical-quantile(p, distribution) = {
  if distribution == "normal" {
    qnorm(p)
  } else if distribution == "uniform" {
    if p <= 0 or p >= 1 {
      fail-range("theoretical-quantile", "p", p, 0, 1)
    }
    p
  } else if distribution == "exponential" {
    if p <= 0 or p >= 1 {
      fail-range("theoretical-quantile", "p", p, 0, 1)
    }
    -calc.ln(1 - p)
  } else {
    fail-enum(
      "theoretical-quantile",
      "distribution",
      distribution,
      ("normal", "uniform", "exponential"),
    )
  }
}
