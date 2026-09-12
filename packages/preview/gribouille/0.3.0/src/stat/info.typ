///! Per-stat metadata.
///!
///! `stat-info(name)` returns a static record describing what columns a
///! stat's `apply()` publishes. The `outputs` list is consulted by
///! `after-stat(<string>)` to validate column references at layer-prepare
///! time; an empty `outputs` list suppresses validation (used for stats
///! whose row shape passes through input data unchanged, e.g., `identity`
///! and `unique`, or whose outputs cannot be enumerated statically, e.g.,
///! `manual`).

#let _STAT-INFO = (
  identity: (outputs: ()),
  bin: (outputs: ("x", "y", "width", "_count", "_density")),
  "bin-2d": (
    outputs: (
      "x",
      "y",
      "_count",
      "_density",
      "xmin",
      "xmax",
      "ymin",
      "ymax",
    ),
  ),
  "bin-hex": (outputs: ("x", "y", "_count", "_density")),
  bindot: (outputs: ("x", "y", "_bin-count", "width")),
  contour: (outputs: ("x", "y", "group", "_level")),
  "contour-filled": (outputs: ("x", "y", "group", "_level")),
  count: (outputs: ("x", "_count")),
  sum: (outputs: ("x", "y", "_n", "_prop")),
  smooth: (outputs: ("x", "y", "ymin", "ymax")),
  boxplot: (
    outputs: (
      "x",
      "lower",
      "middle",
      "upper",
      "ymin",
      "ymax",
      "whisker-lo",
      "whisker-hi",
      "outliers",
    ),
  ),
  summary: (outputs: ("x", "y", "xmin", "xmax", "ymin", "ymax")),
  "summary-bin": (outputs: ("x", "y", "ymin", "ymax")),
  "summary-2d": (outputs: ("x", "y", "_value", "xmin", "xmax", "ymin", "ymax")),
  "summary-hex": (outputs: ("x", "y", "_value")),
  ecdf: (outputs: ("x", "y")),
  unique: (outputs: ()),
  qq: (outputs: ("theoretical", "sample")),
  "qq-line": (outputs: ("theoretical", "sample")),
  function: (outputs: ("x", "y")),
  ellipse: (outputs: ("x0", "y0", "a", "b", "angle")),
  quantile: (outputs: ("x", "y", "group", "_quantile")),
  manual: (outputs: ()),
  connect: (outputs: ("x", "y")),
  align: (outputs: ("x", "y")),
)

/// Look up the metadata record for a stat by name.
///
/// Returns `(outputs: ())` for an unknown stat so callers can treat unknown stats as "no contract" without branching.
///
/// - name: Stat name string (e.g., `"bin"`, `"count"`).
///
/// Returns: Dict with `outputs` (array of column names).
#let stat-info(name) = _STAT-INFO.at(name, default: (outputs: ()))

/// Every stat name registered in `apply-stat`'s dispatcher.
///
/// Used by tests to confirm `stat-info` covers every stat and by validation paths that want to know the canonical name set.
///
/// Returns: Array of stat name strings.
#let stat-names() = _STAT-INFO.keys()
