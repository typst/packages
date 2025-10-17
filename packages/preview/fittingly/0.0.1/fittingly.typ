/// Compute a (weighted) least squares linear fit.
/// -> dict
#let weighted_least_squares(x_vals, y_vals, y_weights) = {
  assert.eq(x_vals.len(), y_vals.len(), message: "The number of x-values and y-values must be the same.")
  assert.eq(y_vals.len(), y_weights.len(), message: "The number of y-values and y-weights must be the same.")

  let inner_prod(a, b) = a.zip(b).map(val => val.at(0) * val.at(1)).sum()

  let S = y_weights.sum()
  let S_x = inner_prod(y_weights, x_vals)
  let S_y = inner_prod(y_weights, y_vals)
  let S_xx = inner_prod(y_weights, x_vals.map(x => x * x))
  let S_yy = inner_prod(y_weights, y_vals.map(x => x * x))
  let S_xy = inner_prod(y_weights, x_vals.zip(y_vals).map(val => val.at(0) * val.at(1)))
  let Delta = S * S_xx - S_x * S_x

  let chi_square = S_yy - (S_xx * S_y * S_y + S * S_xy * S_xy - 2 * S_x * S_y * S_xy) / Delta

  let reduced_chi_square = chi_square / (x_vals.len() - 2)

  return (
    b: (S * S_xy - S_x * S_y) / Delta,
    a: (S_xx * S_y - S_x * S_xy) / Delta,
    var_a: S_xx / Delta,
    var_b: S / Delta,
    cov: -S_x / Delta,
    chi_square: chi_square,
    reduced_chi_square: reduced_chi_square,
  )
}

#let confidence_interval(x_vals, fit, sigma: 1) = {
  (
    upper: x_vals.map(x => fit.a + fit.b * x + sigma * calc.sqrt(fit.var_a + x * x * fit.var_b + 2 * x * fit.cov)),
    lower: x_vals.map(x => fit.a + fit.b * x - sigma * calc.sqrt(fit.var_a + x * x * fit.var_b + 2 * x * fit.cov)),
  )
}
