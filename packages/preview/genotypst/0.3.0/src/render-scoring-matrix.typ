#import "utils.typ": (
  _alignment-plugin, _convert-infinity, _flat-to-2d, resolve-matrix-name,
)
#import "constants.typ": _diverging-gradient

/// Retrieves a scoring matrix by name from the WASM plugin.
///
/// Fetches the specified substitution matrix and returns it as a structured
/// dictionary containing the alphabet and a 2D score matrix. Matrix names
/// are case-insensitive.
///
/// Available matrices: BLOSUM30, BLOSUM40, BLOSUM50, BLOSUM62, BLOSUM70,
/// BLOSUM80, BLOSUM90, BLOSUM100, PAM1, PAM10, PAM40, PAM80, PAM120, PAM160,
/// PAM250, EDNAFULL.
///
/// Infinite values in the matrix (used for forbidden substitutions) are
/// represented as `float.inf` or `-float.inf`.
///
/// - name (str): Matrix name (case-insensitive, e.g., "BLOSUM62" or "blosum62").
/// -> dictionary
#let get-scoring-matrix(name) = {
  // Validate and resolve matrix name
  let canonical = resolve-matrix-name(name)
  assert(canonical != none, message: "Unknown scoring matrix: '" + name + "'.")

  // Call WASM plugin
  let raw-result = json(_alignment-plugin.matrix_info(bytes(canonical)))

  // Convert flat scores to 2D
  let n = raw-result.alphabet.len()
  let matrix-2d = _flat-to-2d(raw-result.scores, n, n)

  // Convert infinity values
  let matrix-converted = matrix-2d.map(row => row.map(
    score => _convert-infinity(score),
  ))

  // Return structured result
  (
    name: raw-result.name,
    alphabet: raw-result.alphabet,
    matrix: matrix-converted,
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
  // Validate input types
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
    message: "Character '"
      + char1
      + "' not found in "
      + scoring-matrix.name
      + " alphabet.",
  )
  assert(
    idx2 != none,
    message: "Character '"
      + char2
      + "' not found in "
      + scoring-matrix.name
      + " alphabet.",
  )

  // Return score
  scoring-matrix.matrix.at(idx1).at(idx2)
}

/// Private: Calculates background color for a score using gradient mapping.
///
/// Maps a score to a color by sampling the provided color gradient with
/// discrete steps. Returns none if no color map is provided.
///
/// - score (int, float): The score value.
/// - min-val (float): Minimum value of the scale.
/// - max-val (float): Maximum value of the scale.
/// - color-map (array, none): Array of colors or gradient stops.
/// -> color, none
#let _get-score-color(score, min-val, max-val, color-map) = {
  if color-map == none { return none }
  let ratio = if max-val == min-val { 0.5 } else {
    (score - min-val) / (max-val - min-val)
  }
  let clamped-ratio = calc.clamp(ratio, 0.0, 1.0)
  let stop-count = color-map.len()
  gradient.linear(..color-map).sharp(stop-count).sample(clamped-ratio * 100%)
}

/// Private: Formats a score for display, handling infinity values.
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

/// Private: Calculates symmetric scale limits for color mapping.
///
/// Computes the maximum absolute value across the rendered triangle,
/// ignoring infinity values. Returns symmetric min/max limits centered
/// around zero.
///
/// - values (array): 2D array of score values.
/// - triangle (str): Which triangle to consider: "lower", "upper", or "full".
/// - scale-limit (auto, int, float): User-specified limit or auto-detect.
/// -> dictionary
#let _get-scale-limits(values, triangle, scale-limit) = {
  let current-max-abs = 0.0

  for (i, row) in values.enumerate() {
    for (j, val) in row.enumerate() {
      let in-triangle = if triangle == "lower" { i >= j } else if (
        triangle == "upper"
      ) { i <= j } else { true }

      if in-triangle and not float.is-infinite(val) {
        current-max-abs = calc.max(current-max-abs, calc.abs(val))
      }
    }
  }

  let limit = if scale-limit == auto { current-max-abs } else { scale-limit }
  (min: -limit, max: limit)
}

/// Private: Generates grid cells for the scoring matrix visualization.
///
/// Creates an array of grid cells with labels positioned according to
/// the triangle mode. Handles "lower", "upper", and "full" triangle modes.
///
/// - symbols (array): Array of symbol characters.
/// - values (array): 2D array of score values.
/// - triangle (str): Triangle mode.
/// - label-bold (bool): Whether labels should be bold.
/// - stroke (stroke, none): Stroke for data cells.
/// - limits (dictionary): Min/max limits for color scaling.
/// - color-map (array, none): Color gradient.
/// -> array
#let _generate-cells(
  symbols,
  values,
  triangle,
  label-bold,
  stroke,
  limits,
  color-map,
) = {
  let cells = ()

  let make-label(sym) = {
    grid.cell(fill: none, stroke: none)[#(
      if label-bold { strong(sym) } else { sym }
    )]
  }

  let make-data-cell(i, j) = {
    let score = values.at(i).at(j)
    let bg = _get-score-color(score, limits.min, limits.max, color-map)
    grid.cell(fill: bg, stroke: stroke)[#_format-score(score)]
  }

  let make-empty-cell() = grid.cell(stroke: none)[]

  let should-render(i, j) = {
    if triangle == "full" { true } else if triangle == "lower" { i >= j } else {
      i <= j
    }
  }

  if triangle == "upper" {
    // Top labels row
    for sym in symbols { cells.push(make-label(sym)) }
    cells.push(make-empty-cell())

    // Data rows + Right labels
    for (i, row-sym) in symbols.enumerate() {
      for (j, _) in symbols.enumerate() {
        if should-render(i, j) { cells.push(make-data-cell(i, j)) } else {
          cells.push(make-empty-cell())
        }
      }
      cells.push(make-label(row-sym))
    }
  } else if triangle == "lower" {
    // Left labels + Data rows
    for (i, row-sym) in symbols.enumerate() {
      cells.push(make-label(row-sym))
      for (j, _) in symbols.enumerate() {
        if should-render(i, j) { cells.push(make-data-cell(i, j)) } else {
          cells.push(make-empty-cell())
        }
      }
    }
    // Bottom labels row
    cells.push(make-empty-cell())
    for sym in symbols { cells.push(make-label(sym)) }
  } else {
    // Full matrix: labels on left and top
    cells.push(make-empty-cell())
    for sym in symbols { cells.push(make-label(sym)) }

    for (i, row-sym) in symbols.enumerate() {
      cells.push(make-label(row-sym))
      for (j, _) in symbols.enumerate() {
        cells.push(make-data-cell(i, j))
      }
    }
  }

  cells
}

/// Renders a scoring matrix as a visual grid.
///
/// Creates a visual representation of a substitution matrix with optional
/// color gradient mapping, triangle display modes, and customizable styling.
/// The alphabet letters appear as row and column headers.
/// Scores map symmetrically around zero, so a score of 0 maps to the midpoint color.
///
/// - scoring-matrix (dictionary): A scoring matrix from `get-scoring-matrix`.
/// - symbols (array, none): Subset of symbols to include and their display order. If none, uses the full alphabet from the matrix (default: none).
/// - triangle (str): Which portion to display: "lower", "upper", or "full" (default: "lower").
/// - scale-limit (auto, int, float): Maximum absolute value for the symmetric color gradient scale. If auto, uses the maximum absolute value from the displayed cells (default: auto).
/// - cell-size (length): Size of each square cell (default: 1.75em).
/// - gutter (length): Spacing between cells (default: 0pt).
/// - label-bold (bool): Whether alphabet labels should be bold (default: true).
/// - stroke (stroke, none): Stroke style for data cells (default: none).
/// - color-map (array, none): Array of colors or gradient stops for cell backgrounds. If none, cells have no background color (default: diverging red-blue gradient).
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
  // Validate triangle parameter
  assert(
    triangle in ("lower", "upper", "full"),
    message: "triangle must be 'lower', 'upper', or 'full'.",
  )

  // Determine display symbols
  let display-symbols = if symbols == none { scoring-matrix.alphabet } else {
    symbols
  }

  // Validate requested symbols exist in alphabet
  for sym in display-symbols {
    assert(
      sym in scoring-matrix.alphabet,
      message: "Symbol '"
        + sym
        + "' not found in "
        + scoring-matrix.name
        + " alphabet.",
    )
  }

  // Build symbol-to-index mapping
  let sym-to-idx = (:)
  for (i, sym) in scoring-matrix.alphabet.enumerate() {
    sym-to-idx.insert(sym, i)
  }

  // Extract values for requested symbols
  let values = display-symbols.map(row-sym => display-symbols.map(
    col-sym => scoring-matrix
      .matrix
      .at(sym-to-idx.at(row-sym))
      .at(sym-to-idx.at(col-sym)),
  ))

  // Calculate scale limits
  let limits = _get-scale-limits(values, triangle, scale-limit)

  // Generate grid cells
  let cells = _generate-cells(
    display-symbols,
    values,
    triangle,
    label-bold,
    stroke,
    limits,
    color-map,
  )

  // Calculate grid dimensions
  let n = display-symbols.len()
  let label-size = cell-size * 0.9
  let data-sizes = (cell-size,) * n

  let (grid-cols, grid-rows) = if triangle == "lower" {
    ((label-size,) + data-sizes, data-sizes + (label-size,))
  } else if triangle == "upper" {
    (data-sizes + (label-size,), (label-size,) + data-sizes)
  } else {
    ((label-size,) + data-sizes, (label-size,) + data-sizes)
  }

  // Render grid
  block(breakable: false, grid(
    columns: grid-cols,
    rows: grid-rows,
    gutter: gutter,
    align: center + horizon,
    ..cells
  ))
}
