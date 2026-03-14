// ── Utility Functions ─────────────────────────────────────────────────────────

/// Formats a number as currency (MXN by default)
///
/// - `amount`: Number or Float to format
#let format-currency(amount) = {
  // Can be expanded to be configurable
  "$" + str(amount) + " MXN"
}

/// Helper function to calculate a numeric relative risk score based on
/// text labels or numbers. Useful for sorting grids.
///
/// - `prob`: String ("Alta", "Media", "Baja") or numeric (1-3)
/// - `impact`: String ("Alta", "Media", "Baja") or numeric (1-3)
#let risk-score(prob, impact) = {
  let val(v) = {
    if type(v) == int or type(v) == float { return v }
    let lowered = lower(v)
    if lowered in ("alta", "alto", "high") { 3 } else if lowered in ("media", "medio", "medium") { 2 } else { 1 }
  }
  return val(prob) * val(impact)
}

/// Convert risk score back to color
#import "brand.typ": naranja-main, rojo-error, verde-exito
#let risk-color(score) = {
  if score >= 6 {
    rojo-error
  } else if score >= 3 {
    naranja-main
  } else {
    verde-exito
  }
}
