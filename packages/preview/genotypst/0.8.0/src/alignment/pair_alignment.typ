#import "../common/fixed_grid.typ": _fixed-width-grid
#import "./alignment_backend.typ": _alignment-align, resolve-matrix-name
#import "./alignment_coords.typ": _parse-coord, _validate-path

/// Private: Validates and cleans a sequence string.
///
/// Removes all whitespace characters (spaces, tabs, newlines), rejects non-ASCII
/// input, and converts to uppercase. This allows users to input sequences with
/// whitespace for readability while keeping alignment indexing ASCII-safe.
///
/// - seq (str): The sequence to validate.
/// - name (str): Name for error messages (e.g., "seq-1").
/// -> str
#let _validate-sequence(seq, name) = {
  assert(type(seq) == str, message: name + " must be a string.")
  let compact = seq.replace(regex("\\s"), "")
  assert(compact.len() > 0, message: name + " must not be empty.")
  for byte in bytes(compact) {
    assert(byte < 128, message: name + " must contain only ASCII characters.")
  }
  upper(compact)
}

/// Private: Validates scoring parameters and returns canonical matrix name if applicable.
///
/// - matrix (str, none): Scoring matrix name.
/// - match-score (int, none): Match score.
/// - mismatch-score (int, none): Mismatch score.
/// -> str, none (canonical matrix name if using matrix)
#let _validate-scoring-params(matrix, match-score, mismatch-score) = {
  // Mutual exclusivity
  assert(
    not (matrix != none and (match-score != none or mismatch-score != none)),
    message: "Cannot use both 'matrix' and 'match-score'/'mismatch-score' - they are mutually exclusive.",
  )

  // At least one scoring method
  assert(
    matrix != none or (match-score != none and mismatch-score != none),
    message: "Provide either 'matrix' or both 'match-score' and 'mismatch-score'.",
  )

  // Matrix name resolution (case-insensitive)
  if matrix != none {
    let canonical = resolve-matrix-name(matrix)
    assert(
      canonical != none,
      message: "Unknown scoring matrix: '" + matrix + "'.",
    )
    canonical
  }
}

/// Private: Builds the JSON configuration dictionary for WASM.
///
/// - canonical-matrix (str, none): Canonical matrix name.
/// - match-score (int, none): Match score.
/// - mismatch-score (int, none): Mismatch score.
/// - gap-penalty (int): Gap penalty (required).
/// - mode (str): Alignment mode.
/// -> dictionary
#let _build-config(
  canonical-matrix,
  match-score,
  mismatch-score,
  gap-penalty,
  mode,
) = {
  let config = (
    gap_open: gap-penalty,
    gap_extend: gap-penalty,
    mode: mode,
  )

  if canonical-matrix != none {
    config.insert("matrix", canonical-matrix)
  } else {
    config.insert("match_score", match-score)
    config.insert("mismatch_score", mismatch-score)
  }

  config
}

/// Private: Transforms the WASM response to the final output format.
///
/// - wasm-result (dictionary): Raw result from WASM plugin.
/// - original-seq-1 (str): Original (cleaned) first sequence.
/// - original-seq-2 (str): Original (cleaned) second sequence.
/// - mode (str): Alignment mode.
/// - canonical-matrix (str, none): Canonical matrix name.
/// - match-score (int, none): Match score.
/// - mismatch-score (int, none): Mismatch score.
/// - gap-penalty (int): Gap penalty (required).
/// -> dictionary
#let _transform-result(
  wasm-result,
  original-seq-1,
  original-seq-2,
  mode,
  canonical-matrix,
  match-score,
  mismatch-score,
  gap-penalty,
) = {
  let dp = wasm-result.dp_matrix
  let rows = dp.rows
  let cols = dp.cols

  // Convert traceback paths
  let traceback-paths = wasm-result.traceback_paths.map(path => path.map(
    coord => (coord.at(0), coord.at(1)),
  ))

  // Determine if there's a valid alignment
  let has-alignment = wasm-result.alignments.len() > 0

  (
    seq-1: original-seq-1,
    seq-2: original-seq-2,
    score: wasm-result.alignment_score,
    mode: mode,
    scoring: (
      matrix: canonical-matrix,
      match-score: match-score,
      mismatch-score: mismatch-score,
      gap-penalty: gap-penalty,
    ),
    alignments: wasm-result.alignments,
    traceback-paths: traceback-paths,
    dp-matrix: (
      rows: dp.rows,
      cols: dp.cols,
      scores: dp.scores,
      arrows: dp.arrow_bits,
    ),
    has-alignment: has-alignment,
  )
}

/// Performs pairwise sequence alignment using dynamic programming.
///
/// Aligns two sequences using either a scoring matrix (e.g., BLOSUM62) or
/// custom match/mismatch scores. Returns alignment results including the
/// DP matrix, traceback paths, and aligned sequences.
///
/// Sequences are automatically cleaned: whitespace is removed, non-ASCII input
/// is rejected, and characters are converted to uppercase. This allows input
/// like "ACG TGC\nAAA".
///
/// Available scoring matrices: BLOSUM30, BLOSUM40, BLOSUM45, BLOSUM50,
/// BLOSUM62, BLOSUM70, BLOSUM80, BLOSUM90, BLOSUM100, PAM1, PAM10, PAM40,
/// PAM80, PAM120, PAM160, PAM250, EDNAFULL. Matrix names are case-insensitive.
///
/// - seq-1 (str): First sequence to align.
/// - seq-2 (str): Second sequence to align.
/// - matrix (str, none): Scoring matrix name (e.g., "BLOSUM62"). Mutually exclusive with match/mismatch scores (default: none).
/// - match-score (int, none): Score for matching characters. Required if matrix is none (default: none).
/// - mismatch-score (int, none): Score for mismatching characters. Required if matrix is none (default: none).
/// - gap-penalty (int): Gap penalty (required).
/// - mode (str): Alignment mode: "global" or "local" (default: "global").
/// -> dictionary with keys:
///   - seq-1 (str): Cleaned first input sequence.
///   - seq-2 (str): Cleaned second input sequence.
///   - score (int): Alignment score.
///   - mode (str): Alignment mode.
///   - scoring (dictionary): Scoring settings used for the alignment.
///   - alignments (array): Alignment dictionaries with keys:
///     - seq1 (str): First aligned sequence with gaps.
///     - seq2 (str): Second aligned sequence with gaps.
///   - traceback-paths (array): Traceback paths as arrays of `(row, col)`
///     coordinates, in end-to-start order.
///   - dp-matrix (dictionary): DP matrix data with keys:
///     - rows (int): Number of DP rows.
///     - cols (int): Number of DP columns.
///     - scores (array): Flat row-major DP scores.
///     - arrows (array): Flat row-major direction bitmasks. Each integer uses
///       `1 = diagonal`, `2 = up`, and `4 = left`. Bits combine when a cell has
///       multiple optimal predecessors, so `3` means diagonal+up and `7` means
///       diagonal+up+left.
///   - has-alignment (bool): Whether at least one alignment was found.
#let align-seq-pair(
  seq-1,
  seq-2,
  matrix: none,
  match-score: none,
  mismatch-score: none,
  gap-penalty: none,
  mode: "global",
) = {
  let cleaned-seq-1 = _validate-sequence(seq-1, "seq-1")
  let cleaned-seq-2 = _validate-sequence(seq-2, "seq-2")
  let canonical-matrix = _validate-scoring-params(
    matrix,
    match-score,
    mismatch-score,
  )
  assert(gap-penalty != none, message: "gap-penalty is required.")
  assert(type(gap-penalty) == int, message: "gap-penalty must be an integer.")
  assert(
    mode in ("global", "local"),
    message: "mode must be 'global' or 'local'.",
  )

  // Build config and call WASM
  let config = _build-config(
    canonical-matrix,
    match-score,
    mismatch-score,
    gap-penalty,
    mode,
  )
  let wasm-result = _alignment-align(cleaned-seq-1, cleaned-seq-2, config)

  // Transform and return result
  _transform-result(
    wasm-result,
    cleaned-seq-1,
    cleaned-seq-2,
    mode,
    canonical-matrix,
    match-score,
    mismatch-score,
    gap-penalty,
  )
}

/// Private: Build the three alignment rows directly from a traceback path.
///
/// - seq-1-chars (array): First sequence as grapheme clusters.
/// - seq-2-chars (array): Second sequence as grapheme clusters.
/// - path (array): Traceback path as `(row, col)` arrays in start-to-end order.
/// - gap-char (str): Character for gaps.
/// - match-char (str): Character for matches.
/// - mismatch-char (str): Character for mismatches.
/// - hide-unaligned (bool): Whether to hide unaligned characters entirely.
/// - build-unaligned-mask (bool): Whether to track unaligned cells for optional coloring.
/// -> dictionary with keys:
///   - aligned1 (array): First rendered alignment row as cell contents.
///   - match-line (array): Match or mismatch indicator row as cell contents.
///   - aligned2 (array): Second rendered alignment row as cell contents.
///   - unaligned-mask (array, none): Marks visible unaligned cells when requested.
#let _build-alignment-lines(
  seq-1-chars,
  seq-2-chars,
  path,
  gap-char,
  match-char,
  mismatch-char,
  hide-unaligned,
  build-unaligned-mask,
) = {
  let first-coord = _parse-coord(path.at(0))

  let aligned1 = ()
  let match-line = ()
  let aligned2 = ()
  let unaligned-mask = if build-unaligned-mask { () } else { none }

  if not hide-unaligned {
    for i in range(first-coord.row) {
      aligned1.push(seq-1-chars.at(i))
      match-line.push(" ")
      aligned2.push(" ")
      if unaligned-mask != none { unaligned-mask.push(true) }
    }

    for j in range(first-coord.col) {
      aligned1.push(" ")
      match-line.push(" ")
      aligned2.push(seq-2-chars.at(j))
      if unaligned-mask != none { unaligned-mask.push(true) }
    }
  }

  let seq-1-pos = first-coord.row
  let seq-2-pos = first-coord.col
  let prev-coord = first-coord

  for i in range(1, path.len()) {
    let curr-coord = _parse-coord(path.at(i))
    let row-delta = curr-coord.row - prev-coord.row
    let col-delta = curr-coord.col - prev-coord.col

    if row-delta == 1 and col-delta == 1 {
      let char1 = seq-1-chars.at(seq-1-pos)
      let char2 = seq-2-chars.at(seq-2-pos)

      aligned1.push(char1)
      aligned2.push(char2)
      match-line.push(if char1 == char2 { match-char } else { mismatch-char })
      if unaligned-mask != none { unaligned-mask.push(false) }

      seq-1-pos += 1
      seq-2-pos += 1
    } else if row-delta == 0 and col-delta == 1 {
      aligned1.push(gap-char)
      aligned2.push(seq-2-chars.at(seq-2-pos))
      match-line.push(mismatch-char)
      if unaligned-mask != none { unaligned-mask.push(false) }

      seq-2-pos += 1
    } else {
      aligned1.push(seq-1-chars.at(seq-1-pos))
      aligned2.push(gap-char)
      match-line.push(mismatch-char)
      if unaligned-mask != none { unaligned-mask.push(false) }

      seq-1-pos += 1
    }

    prev-coord = curr-coord
  }

  if not hide-unaligned {
    while seq-1-pos < seq-1-chars.len() {
      aligned1.push(seq-1-chars.at(seq-1-pos))
      match-line.push(" ")
      aligned2.push(" ")
      if unaligned-mask != none { unaligned-mask.push(true) }
      seq-1-pos += 1
    }

    while seq-2-pos < seq-2-chars.len() {
      aligned1.push(" ")
      match-line.push(" ")
      aligned2.push(seq-2-chars.at(seq-2-pos))
      if unaligned-mask != none { unaligned-mask.push(true) }
      seq-2-pos += 1
    }
  }

  (
    aligned1: aligned1,
    match-line: match-line,
    aligned2: aligned2,
    unaligned-mask: unaligned-mask,
  )
}

/// Renders a formatted pairwise sequence alignment from alignment result data.
///
/// Creates a three-line display showing the first aligned sequence (with gaps),
/// match/mismatch indicators, and the second aligned sequence (with gaps).
/// The traceback path from `align-seq-pair` goes from end to start (high indices
/// to low), so it is automatically reversed before processing.
///
/// - seq-1 (str): First sequence (without gaps).
/// - seq-2 (str): Second sequence (without gaps).
/// - path (array): Traceback path as `(row, col)` arrays, in end-to-start order.
/// - gap-char (str): Character to display for gaps (default: "–").
/// - match-char (str): Character to display for matches (default: "│").
/// - mismatch-char (str): Character to display for mismatches (default: " ").
/// - hide-unaligned (bool): Hide unaligned characters entirely (default: false).
/// - unaligned-color (color, none): Color for visible unaligned characters (default: none, which uses the default text color).
/// -> content
#let render-pair-alignment(
  seq-1,
  seq-2,
  path,
  gap-char: "–",
  match-char: "│",
  mismatch-char: " ",
  hide-unaligned: false,
  unaligned-color: none,
) = {
  assert(type(seq-1) == str, message: "seq-1 must be a string.")
  assert(type(seq-2) == str, message: "seq-2 must be a string.")

  let seq1-chars = seq-1.clusters()
  let seq2-chars = seq-2.clusters()

  assert(seq1-chars.len() > 0, message: "seq-1 cannot be empty.")
  assert(seq2-chars.len() > 0, message: "seq-2 cannot be empty.")
  assert(type(path) == array, message: "path must be an array.")
  assert(path.len() > 0, message: "path cannot be empty.")

  // Reverse the path (traceback goes end-to-start, we need start-to-end)
  let reversed-path = path.rev()

  _validate-path(reversed-path, seq1-chars.len(), seq2-chars.len())

  let build-unaligned-mask = not hide-unaligned and unaligned-color != none

  let result = _build-alignment-lines(
    seq1-chars,
    seq2-chars,
    reversed-path,
    gap-char,
    match-char,
    mismatch-char,
    hide-unaligned,
    build-unaligned-mask,
  )

  context {
    let unaligned-mask = result.unaligned-mask

    let make-line-cells = (chars, apply-unaligned) => {
      if not apply-unaligned or unaligned-mask == none {
        return chars
      }

      chars
        .enumerate()
        .map(item => {
          let (i, char) = item
          if unaligned-mask.at(i) {
            text(char, fill: unaligned-color)
          } else {
            char
          }
        })
    }

    let line1-cells = make-line-cells(result.aligned1, true)
    let line2-cells = make-line-cells(result.match-line, false)
    let line3-cells = make-line-cells(result.aligned2, true)

    block(breakable: false, _fixed-width-grid(
      (line1-cells, line2-cells, line3-cells),
      row-heights: (text.size * 0.85, text.size * 1.6, text.size * 0.85),
    ))
  }
}
