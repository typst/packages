#import "./alignment_backend.typ": _alignment-matrix-info, resolve-matrix-name
#import "../common/colors.typ": _diverging-gradient

/// Retrieves a scoring matrix by name from the WASM plugin.
///
/// Available scoring matrices: BLOSUM30, BLOSUM40, BLOSUM45, BLOSUM50,
/// BLOSUM62, BLOSUM70, BLOSUM80, BLOSUM90, BLOSUM100, PAM1, PAM10, PAM40,
/// PAM80, PAM120, PAM160, PAM250, EDNAFULL. Matrix names are case-insensitive.
///
/// Infinite values in the matrix (used for forbidden substitutions) are
/// represented as `float.inf` or `-float.inf`.
///
/// - name (str): Matrix name (e.g., "BLOSUM62").
/// -> dictionary with keys:
///   - name (str): Canonical matrix name.
///   - alphabet (array): Symbols covered by the matrix.
///   - matrix (array): 2D score matrix aligned to `alphabet`.
#let get-scoring-matrix(name) = {
  let canonical = resolve-matrix-name(name)
  assert(canonical != none, message: "Unknown scoring matrix: '" + name + "'.")

  let raw-result = _alignment-matrix-info(canonical)

  let n = raw-result.alphabet.len()
  assert(
    raw-result.scores.len() == n * n,
    message: "scoring matrix backend returned an unexpected score count.",
  )

  // Validate backend shape and reshape flat scores into rows.
  let matrix-2d = raw-result.scores.chunks(n)

  (
    name: raw-result.name,
    alphabet: raw-result.alphabet,
    matrix: matrix-2d,
  )
}

/// Retrieves the substitution score for a pair of characters.
///
/// Looks up the score for substituting char1 with char2 (or vice versa,
/// since matrices are symmetric) in the given scoring matrix. Character
/// lookup is case-insensitive.
///
/// - scoring-matrix (dictionary): A scoring matrix from `get-scoring-matrix`.
/// - char1 (str): First character (single character).
/// - char2 (str): Second character (single character).
/// -> int, float
#let get-score-from-matrix(scoring-matrix, char1, char2) = {
  assert(type(char1) == str, message: "char1 must be a string.")
  assert(type(char2) == str, message: "char2 must be a string.")
  assert(
    char1.len() == 1,
    message: "char1 must be a single character, got '" + char1 + "'.",
  )
  assert(
    char2.len() == 1,
    message: "char2 must be a single character, got '" + char2 + "'.",
  )

  // Case-insensitive lookup
  let c1 = upper(char1)
  let c2 = upper(char2)

  // Find indices in alphabet
  let idx1 = scoring-matrix.alphabet.position(c => c == c1)
  let idx2 = scoring-matrix.alphabet.position(c => c == c2)

  assert(
    idx1 != none,
    message: "character '"
      + char1
      + "' not found in "
      + scoring-matrix.name
      + " alphabet.",
  )
  assert(
    idx2 != none,
    message: "character '"
      + char2
      + "' not found in "
      + scoring-matrix.name
      + " alphabet.",
  )

  scoring-matrix.matrix.at(idx1).at(idx2)
}

/// Calculates background color for a score using gradient mapping.
///
/// Maps a score to a color by sampling the provided color gradient with
/// discrete steps.
///
/// - score (int, float): The score value.
/// - min-val (float): Minimum value of the scale.
/// - max-val (float): Maximum value of the scale.
/// - color-map (array, none): Array of colors or gradient stops.
///   Returns none if color-map is none or empty.
///   Returns a solid color if color-map contains one entry.
/// -> color, none
#let _get-score-color(score, min-val, max-val, color-map) = {
  if color-map == none { return none }
  if color-map.len() == 0 { return none }
  if color-map.len() == 1 {
    let single = color-map.at(0)
    if type(single) == array and single.len() > 0 {
      return single.at(0)
    } else {
      return single
    }
  }
  let ratio = if max-val == min-val { 0.5 } else {
    (score - min-val) / (max-val - min-val)
  }
  let clamped-ratio = calc.clamp(ratio, 0.0, 1.0)
  let stop-count = color-map.len()
  gradient.linear(..color-map).sharp(stop-count).sample(clamped-ratio * 100%)
}

/// Formats a score for display, handling infinity values.
///
/// Returns content with proper typographic symbols for negative signs
/// and infinity values.
///
/// - score (int, float): The score to format.
/// -> content
#let _format-score(score) = {
  if score == float.inf { sym.infinity } else if score == -float.inf {
    [#sym.minus#sym.infinity]
  } else if score < 0 {
    [#sym.minus#calc.abs(score)]
  } else { [#score] }
}

/// Prepares a resolved scoring-matrix view for one triangle mode.
///
/// Validates the requested symbols and triangle mode, resolves the visible
/// cell mask, and computes the final grid geometry once for downstream
/// rendering helpers.
///
/// - scoring-matrix (dictionary): Matrix record from `get-scoring-matrix`.
/// - symbols (array, none): Requested symbol order or none for the full alphabet.
/// - triangle (str): Which portion to display: "lower", "upper", or "full".
/// - cell-size (length): Square data-cell size.
/// -> dictionary with keys:
///   - symbols (array): Display symbols in render order.
///   - cell-values (array): 2D array of resolved score values.
///   - visible-mask (array): 2D boolean mask for cells included in the view.
///   - scale-values (array): Score values included in scale-limit calculation.
///   - row-label-side (str): Row-label placement side, `"left"` or `"right"`.
///   - col-label-side (str): Column-label placement side, `"top"` or `"bottom"`.
///   - grid-columns (array): Final grid column sizes.
///   - grid-rows (array): Final grid row sizes.
#let _prepare-scoring-matrix-view(
  scoring-matrix,
  symbols,
  triangle,
  cell-size,
) = {
  assert(
    triangle in ("lower", "upper", "full"),
    message: "triangle must be 'lower', 'upper', or 'full'.",
  )

  let display-symbols = if symbols == none { scoring-matrix.alphabet } else {
    symbols
  }

  for sym in display-symbols {
    assert(
      sym in scoring-matrix.alphabet,
      message: "symbol '"
        + sym
        + "' not found in "
        + scoring-matrix.name
        + " alphabet.",
    )
  }

  let visible-in-view = if triangle == "lower" {
    (i, j) => i >= j
  } else if triangle == "upper" {
    (i, j) => i <= j
  } else {
    (i, j) => true
  }
  let row-label-side = if triangle == "upper" { "right" } else { "left" }
  let col-label-side = if triangle == "lower" { "bottom" } else { "top" }

  let sym-to-idx = (:)
  for (i, sym) in scoring-matrix.alphabet.enumerate() {
    sym-to-idx.insert(sym, i)
  }

  let cell-values = ()
  let visible-mask = ()
  let scale-values = ()
  for (i, row-sym) in display-symbols.enumerate() {
    let row-values = ()
    let row-mask = ()
    for (j, col-sym) in display-symbols.enumerate() {
      let score = scoring-matrix
        .matrix
        .at(sym-to-idx.at(row-sym))
        .at(sym-to-idx.at(col-sym))
      let visible = visible-in-view(i, j)
      row-values.push(score)
      row-mask.push(visible)
      if visible {
        scale-values.push(score)
      }
    }
    cell-values.push(row-values)
    visible-mask.push(row-mask)
  }

  let n = display-symbols.len()
  let label-size = cell-size * 0.9
  let data-sizes = (cell-size,) * n

  (
    symbols: display-symbols,
    cell-values: cell-values,
    visible-mask: visible-mask,
    scale-values: scale-values,
    row-label-side: row-label-side,
    col-label-side: col-label-side,
    grid-columns: if row-label-side == "left" {
      (label-size,) + data-sizes
    } else {
      data-sizes + (label-size,)
    },
    grid-rows: if col-label-side == "top" {
      (label-size,) + data-sizes
    } else {
      data-sizes + (label-size,)
    },
  )
}

/// Calculates symmetric scale limits for color mapping.
///
/// Computes the maximum absolute value across the resolved scale values,
/// ignoring infinity values. Returns symmetric min/max limits centered around
/// zero.
///
/// - scale-values (array): Score values included in the active view.
/// - scale-limit (auto, int, float): User-specified limit or auto-detect.
/// -> dictionary with keys:
///   - min (int, float): Lower bound of the symmetric scale.
///   - max (int, float): Upper bound of the symmetric scale.
#let _get-scale-limits(scale-values, scale-limit) = {
  let current-max-abs = 0.0

  for val in scale-values {
    if not float.is-infinite(val) {
      current-max-abs = calc.max(current-max-abs, calc.abs(val))
    }
  }

  let limit = if scale-limit == auto { current-max-abs } else { scale-limit }
  (min: -limit, max: limit)
}

/// Generates grid cells for the scoring matrix visualization.
///
/// Creates grid cells from a prepared scoring-matrix view record.
///
/// - view (dictionary): Prepared scoring-matrix view record.
/// - label-bold (bool): Whether labels should be bold.
/// - stroke (stroke, none): Stroke for data cells.
/// - limits (dictionary): Min/max limits for color scaling.
/// - color-map (array, none): Color gradient.
/// -> array: Grid cells emitted in final row-major order for `grid(..cells)`.
#let _generate-cells(view, label-bold, stroke, limits, color-map) = {
  let cells = ()
  let blank-cell = () => grid.cell(stroke: none)[]

  let make-label = sym => grid.cell(fill: none, stroke: none)[#(
    if label-bold { strong(sym) } else { sym }
  )]

  let make-data-cell = (i, j) => {
    let score = view.cell-values.at(i).at(j)
    let bg = _get-score-color(score, limits.min, limits.max, color-map)
    grid.cell(fill: bg, stroke: stroke)[#_format-score(score)]
  }

  if view.col-label-side == "top" {
    if view.row-label-side == "left" {
      cells.push(blank-cell())
    }
    for sym in view.symbols {
      cells.push(make-label(sym))
    }
    if view.row-label-side == "right" {
      cells.push(blank-cell())
    }
  }

  for (i, row-sym) in view.symbols.enumerate() {
    if view.row-label-side == "left" {
      cells.push(make-label(row-sym))
    }
    for (j, _) in view.symbols.enumerate() {
      if view.visible-mask.at(i).at(j) {
        cells.push(make-data-cell(i, j))
      } else {
        cells.push(blank-cell())
      }
    }
    if view.row-label-side == "right" {
      cells.push(make-label(row-sym))
    }
  }

  if view.col-label-side == "bottom" {
    if view.row-label-side == "left" {
      cells.push(blank-cell())
    }
    for sym in view.symbols {
      cells.push(make-label(sym))
    }
    if view.row-label-side == "right" {
      cells.push(blank-cell())
    }
  }

  cells
}

/// Renders a scoring matrix as a visual grid.
///
/// Supports optional color gradient mapping, triangle display modes, and
/// customizable styling. The alphabet letters appear as row and column
/// headers. Scores map symmetrically around zero, so a score of 0 maps to the
/// midpoint color.
///
/// - scoring-matrix (dictionary): A scoring matrix from `get-scoring-matrix`.
/// - symbols (array, none): Subset of symbols to include and their display order. If none, uses the full alphabet from the matrix (default: none).
/// - triangle (str): Which portion to display: "lower", "upper", or "full" (default: "lower").
/// - scale-limit (auto, int, float): Maximum absolute value for the symmetric color gradient scale. If auto, uses the maximum absolute value from the displayed cells (default: auto).
/// - cell-size (length): Size of each square cell (default: 1.75em).
/// - gutter (length): Spacing between cells (default: 0pt).
/// - label-bold (bool): Whether alphabet labels should be bold (default: true).
/// - stroke (stroke, none): Stroke style for data cells (default: none).
/// - color-map (array, none): Array of colors or gradient stops for cell backgrounds.
///   none or () disables cell background fill.
///   A single entry uses a constant fill color for all cells.
///   (default: diverging red-blue gradient).
/// -> content
#let render-scoring-matrix(
  scoring-matrix,
  symbols: none,
  triangle: "lower",
  scale-limit: auto,
  cell-size: 1.75em,
  gutter: 0pt,
  label-bold: true,
  stroke: none,
  color-map: _diverging-gradient,
) = {
  let view = _prepare-scoring-matrix-view(
    scoring-matrix,
    symbols,
    triangle,
    cell-size,
  )
  let limits = _get-scale-limits(view.scale-values, scale-limit)
  let cells = _generate-cells(view, label-bold, stroke, limits, color-map)

  block(breakable: false, grid(
    columns: view.grid-columns,
    rows: view.grid-rows,
    gutter: gutter,
    align: center + horizon,
    ..cells
  ))
}
