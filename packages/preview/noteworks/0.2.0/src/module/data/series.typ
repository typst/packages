// =====================================================
// SERIES - Data series for scatter/line plots
// =====================================================
// Provides functions for loading and plotting data from CSV or arrays

#import "../shape/point.typ": point

/// Create a data series from an array of coordinate pairs
/// Supports scatter plots, line plots, and connected points
///
/// Parameters:
/// - data: Array of (x, y) tuples or points
/// - plot-type: "scatter", "line", or "both" (default: "scatter")
/// - label: Optional label for legend
/// - style: Optional style overrides (stroke, fill, marker)
#let data-series(
  data,
  plot-type: "scatter",
  label: none,
  style: auto,
) = (
  type: "data-series",
  data: data,
  plot-type: plot-type,
  label: label,
  style: style,
)

/// Parse CSV text into array of (x, y) tuples
/// Expects format: x,y with optional header row
///
/// Parameters:
/// - csv-text: Raw CSV content as string
/// - has-header: Whether to skip first row (default: true)
/// - x-col: Column index for x values (default: 0)
/// - y-col: Column index for y values (default: 1)
#let parse-csv(csv-text, has-header: true, x-col: 0, y-col: 1) = {
  let lines = csv-text.split("\n").filter(l => l.trim() != "")
  let start = if has-header { 1 } else { 0 }

  let result = ()
  for i in range(start, lines.len()) {
    let cols = lines.at(i).split(",")
    if cols.len() > calc.max(x-col, y-col) {
      let x = float(cols.at(x-col).trim())
      let y = float(cols.at(y-col).trim())
      result.push((x, y))
    }
  }
  result
}

/// Create data series from CSV text
///
/// Parameters:
/// - csv-text: CSV content string (use `read("path.csv")` to load)
/// - plot-type: "scatter", "line", or "both" (default: "scatter")
/// - has-header: Whether CSV has header row (default: true)
/// - x-col: Column index for x values (default: 0)
/// - y-col: Column index for y values (default: 1)
/// - label: Optional label
/// - style: Optional style overrides
#let csv-series(
  csv-text,
  plot-type: "scatter",
  has-header: true,
  x-col: 0,
  y-col: 1,
  label: none,
  style: auto,
) = {
  let data = parse-csv(csv-text, has-header: has-header, x-col: x-col, y-col: y-col)
  data-series(data, plot-type: plot-type, label: label, style: style)
}

/// Create polar data series from (r, θ) pairs
/// θ should be in radians
///
/// Parameters:
/// - data: Array of (r, θ) tuples
/// - plot-type: "scatter", "line", or "both" (default: "scatter")
/// - label: Optional label
/// - style: Optional style overrides
#let polar-data-series(
  data,
  plot-type: "scatter",
  label: none,
  style: auto,
) = {
  // Convert polar to cartesian for internal storage
  let cartesian-data = data.map(pt => {
    let (r, theta) = pt
    (r * calc.cos(theta), r * calc.sin(theta))
  })

  (
    type: "data-series",
    data: cartesian-data,
    plot-type: plot-type,
    label: label,
    style: style,
    is-polar: true,
  )
}

/// Check if object is a data series
#let is-data-series(obj) = {
  type(obj) == dictionary and obj.at("type", default: none) == "data-series"
}
