#import "constants.typ": (
  _aa-characters, _dna-characters, _rna-characters, residue-palette,
)

#let _alignment-plugin = plugin("alignment.wasm")

// Cache available matrices at module load time (loaded once)
#let _available-matrices = json(_alignment-plugin.list_matrices()).matrices

/// Resolves a scoring matrix name to its canonical form.
///
/// Performs case-insensitive lookup against available matrices from the WASM plugin.
/// Returns the canonical matrix name (e.g., "BLOSUM62") if found, or none if not found.
///
/// - name (str): Matrix name to look up (case-insensitive).
/// -> str, none
#let resolve-matrix-name(name) = {
  let upper-name = upper(name)
  if upper-name in _available-matrices {
    upper-name
  } else {
    none
  }
}

/// Guesses the sequence alphabet based on the characters present in the sequences.
///
/// Analyzes the sequences to determine whether they are amino acids ("aa"),
/// DNA ("dna"), or RNA ("rna"). Returns "dna" if U is not present,
/// "rna" if U is present, and "aa" if amino acid specific characters
/// are found.
///
/// - sequences (dictionary, array): A dictionary mapping identifiers to sequences, or an array of sequences.
/// -> str
#let _guess-seq-alphabet(sequences) = {
  let sequences = if type(sequences) == dictionary { sequences.values() } else {
    sequences
  }
  let observed = (:)
  for seq in sequences {
    for char in seq.clusters() {
      observed.insert(upper(char), true)
    }
  }

  let observed-keys = observed.keys()
  let dna-rna-chars = _dna-characters + _rna-characters
  let all-known = _aa-characters + dna-rna-chars

  if not observed-keys.any(char => char in all-known) {
    panic(
      "Could not guess sequence type. Please explicitly define sequence type.",
    )
  }

  if observed-keys.any(char => (
    char in _aa-characters and char not in dna-rna-chars
  )) {
    "aa"
  } else if "U" in observed-keys {
    "rna"
  } else {
    "dna"
  }
}

/// Computes the sequence conservation of MSA column using the method described
/// in Schneider, T.D., and Stephens, R.M. "Sequence logos: a new way to display
/// consensus sequences" (1990).
///
/// Calculates the information content (measured in bits) for a single column
/// of a multiple sequence alignment, using Shannon entropy with optional small
/// sample correction and occupancy scaling.
///
/// - counts (dictionary): Dictionary mapping characters to their counts in the column.
/// - total-non-gap (int): Total number of non-gap characters in the column.
/// - num-sequences (int): Total number of sequences in the alignment.
/// - sampling-correction (bool): Apply small sample correction.
/// - alphabet-size (int): Size of the alphabet.
/// -> float
#let _compute-sequence-conservation(
  counts,
  total-non-gap,
  num-sequences,
  sampling-correction,
  alphabet-size,
) = {
  if total-non-gap == 0 { return 0.0 }

  let max-bits = calc.log(alphabet-size, base: 2.0)

  let entropy = 0.0
  for count in counts.values() {
    let p = count / total-non-gap
    if p > 0 {
      entropy -= p * calc.log(p, base: 2.0)
    }
  }

  // Small sample correction
  let en = 0.0
  if sampling-correction {
    en = (alphabet-size - 1.0) / (2.0 * total-non-gap * calc.ln(2.0))
  }

  let r = calc.max(0.0, max-bits - (entropy + en))

  // Occupancy scaling
  let occupancy = total-non-gap / num-sequences
  occupancy * r
}

/// Computes column statistics for a set of sequences.
///
/// Counts occurrences of each valid character at a specific position across
/// all sequences in the alignment. Matching is case-insensitive.
///
/// - sequences (array): Array of sequence strings.
/// - pos (int): The column position to analyze (0-indexed).
/// - alphabet-characters (array): Array of valid alphabet characters.
/// -> dictionary with keys:
///   - counts: dictionary mapping characters to their counts
///   - total-non-gap: int, total count of valid characters
#let _get-column-stats(sequences, pos, alphabet-characters) = {
  let counts = (:)
  let total-non-gap = 0
  let alphabet-set = alphabet-characters.map(char => upper(char))
  for seq in sequences {
    if pos < seq.len() {
      let char = upper(seq.at(pos))
      if char in alphabet-set {
        counts.insert(char, counts.at(char, default: 0) + 1)
        total-non-gap += 1
      }
    }
  }
  (counts: counts, total-non-gap: total-non-gap)
}

/// Resolves alphabet configuration based on the specified alphabet or auto-detection.
///
/// Returns a configuration dictionary containing the alphabet size, character set,
/// and color palette. If alphabet is auto, automatically detects the
/// sequence type.
///
/// - alphabet (auto, str): The alphabet type: auto, "aa", "dna", or "rna".
/// - sequences (array): Array of sequence strings for auto-detection.
/// -> dictionary with keys:
///   - size: int, size of the alphabet (20 for amino acids, 4 for DNA/RNA)
///   - chars: array, array of valid characters
///   - palette: dictionary, color mapping for characters
#let _resolve-alphabet-config(alphabet, sequences) = {
  assert(
    alphabet == auto or alphabet in ("aa", "dna", "rna"),
    message: "Alphabet must be auto, 'aa', 'dna', or 'rna'.",
  )

  let type = if alphabet == auto { _guess-seq-alphabet(sequences) } else {
    alphabet
  }

  if type == "aa" {
    (size: 20, chars: _aa-characters, palette: residue-palette.aa.default)
  } else if type == "dna" {
    (size: 4, chars: _dna-characters, palette: residue-palette.dna.default)
  } else if type == "rna" {
    (size: 4, chars: _rna-characters, palette: residue-palette.rna.default)
  }
}

/// Checks whether a palette covers all residues in a sequence list.
///
/// Returns a dictionary with an `ok` flag and a `missing` array containing
/// residues not found in the palette.
///
/// - palette (dictionary): Dictionary mapping residues to colors.
/// - sequences (array): Array of sequence strings.
/// - ignore-gaps (bool): Skip gap characters (default: true).
/// - gap-chars (array): Gap characters to ignore (default: ("-", "—", ".")).
/// - case-sensitive (bool): Match residues case-sensitively (default: true).
/// -> dictionary with keys:
///   - ok: bool
///   - missing: array
#let _check-palette-coverage(
  palette,
  sequences,
  ignore-gaps: true,
  gap-chars: ("-", "—", "."),
  case-sensitive: true,
) = {
  assert(
    type(palette) == dictionary,
    message: "palette must be a dictionary mapping residues to colors.",
  )
  assert(type(sequences) == array, message: "sequences must be an array.")

  let observed = (:)
  for seq in sequences {
    for char in seq.clusters() {
      if ignore-gaps and char in gap-chars { continue }
      let key = if case-sensitive { char } else { upper(char) }
      observed.insert(key, true)
    }
  }

  let palette-keys = (:)
  for key in palette.keys() {
    let normalized = if case-sensitive { key } else { upper(key) }
    palette-keys.insert(normalized, true)
  }

  let missing = ()
  for key in observed.keys() {
    if not (key in palette-keys) { missing.push(key) }
  }

  (ok: missing.len() == 0, missing: missing.sorted())
}

/// Renders a fixed-width grid using the current text font.
///
/// Cells can be passed as raw content or as dictionaries with `body` and
/// optional `fill` and `outset` values. When `cell-width` is none, it is
/// measured from the current font using the wider of "W" and "M".
///
/// - rows (array): 2D array of cell contents or dictionaries.
/// - cell-width (length, none): Fixed cell width (default: none).
/// - row-heights (array, none): Row heights (default: none).
/// - column-gutter (length): Column gap (default: 0pt).
/// - row-gutter (length): Row gap (default: 0pt).
/// - cell-outset (dictionary, none): Outset applied to each cell (default: none).
/// - cell-align (alignment): Cell content alignment (default: center + horizon).
/// -> content
#let _fixed-width-grid(
  rows,
  cell-width: none,
  row-heights: none,
  column-gutter: 0pt,
  row-gutter: 0pt,
  cell-outset: none,
  cell-align: center + horizon,
) = context {
  if rows.len() == 0 { return }

  let row-count = rows.len()
  let col-count = rows.first().len()
  if col-count == 0 { return }
  assert(
    rows.all(row => row.len() == col-count),
    message: "All rows must have the same number of cells.",
  )
  if row-heights != none {
    assert(
      row-heights.len() == row-count,
      message: "row-heights length must match the number of rows.",
    )
  }

  let width = if cell-width == none {
    calc.max(measure(text("W")).width, measure(text("M")).width)
  } else {
    cell-width
  }
  let columns = (width,) * col-count
  let cells = ()

  for (row-index, row) in rows.enumerate() {
    let row-height = if row-heights != none { row-heights.at(row-index) } else {
      none
    }
    for cell in row {
      let body = cell
      let fill = none
      let outset = cell-outset

      if type(cell) == dictionary {
        body = cell.at("body", default: [])
        fill = cell.at("fill", default: none)
        outset = cell.at("outset", default: outset)
      }

      let content = if body == none { [] } else { body }
      cells.push(box(
        width: width,
        ..(if row-height != none { (height: row-height) } else { () }),
        fill: fill,
        outset: if outset == none { (:) } else { outset },
        align(cell-align, content),
      ))
    }
  }

  grid(
    columns: columns,
    column-gutter: column-gutter,
    row-gutter: row-gutter,
    ..(if row-heights != none { (rows: row-heights) } else { () }),
    ..cells,
  )
}

/// Validates that all sequences in the MSA have the same length.
///
/// Ensures that all sequences in a multiple sequence alignment have identical
/// lengths. Throws an error if sequences have different lengths.
///
/// - msa-dict (dictionary): Dictionary mapping sequence identifiers to sequences.
/// -> none
#let _validate-msa(msa-dict) = {
  let sequences = msa-dict.values()
  if sequences.len() > 0 {
    let expected-len = sequences.first().len()
    assert(
      sequences.all(s => s.len() == expected-len),
      message: "All sequences must be of equal length.",
    )
  }
}

/// Validates an optional integer lower-bounded by `min`.
///
/// - value (int, none): Value to validate.
/// - name (str): Parameter name for error messages.
/// - min (int): Minimum allowed value.
/// -> none
#let _validate-optional-int-at-least(value, name, min) = {
  if value == none { return }
  assert(type(value) == int, message: name + " must be an integer.")
  assert(
    value >= min,
    message: name + " must be >= " + str(min) + ".",
  )
}

/// Validates an optional integer window with inclusive bounds.
///
/// - start (int, none): Optional start value.
/// - end (int, none): Optional end value.
/// - start-name (str): Name for start in error messages.
/// - end-name (str): Name for end in error messages.
/// - min (int): Minimum allowed value for both bounds.
/// -> none
#let _validate-interval(
  start,
  end,
  start-name: "start",
  end-name: "end",
  min: 1,
) = {
  _validate-optional-int-at-least(start, start-name, min)
  _validate-optional-int-at-least(end, end-name, min)
  if start != none and end != none {
    assert(
      start <= end,
      message: start-name + " must be <= " + end-name + ".",
    )
  }
}

/// Resolves a 1-indexed inclusive window to 0-indexed [start, end).
///
/// - start (int, none): Optional 1-indexed inclusive start.
/// - end (int, none): Optional 1-indexed inclusive end.
/// - max-len (int): Maximum valid 1-indexed position.
/// - window-name (str): Name used in error messages.
/// -> dictionary with keys:
///   - actual-start: int, 0-indexed inclusive start
///   - actual-end: int, 0-indexed exclusive end
#let _resolve-1indexed-window(start, end, max-len, window-name: "window") = {
  assert(type(max-len) == int, message: "max-len must be an integer.")
  assert(max-len >= 0, message: "max-len must be non-negative.")
  _validate-interval(start, end)

  let actual-start = if start == none { 0 } else { calc.max(0, start - 1) }
  let actual-end = if end == none { max-len } else { calc.min(end, max-len) }
  let start-label = if start == none { "none" } else { str(start) }
  let end-label = if end == none { "none" } else { str(end) }

  assert(
    actual-start < actual-end,
    message: (
      "Resolved "
        + window-name
        + " window is empty. Check start/end (1-indexed, inclusive). "
        + "Received start="
        + start-label
        + ", end="
        + end-label
        + "; resolved start="
        + str(actual-start + 1)
        + ", end="
        + str(actual-end)
        + "."
    ),
  )

  (actual-start: actual-start, actual-end: actual-end)
}

/// Clamps a numeric value between bounds.
///
/// - value (length): Value to clamp.
/// - min (length): Lower bound.
/// - max (length): Upper bound.
/// -> length
#let _clamp(value, min, max) = {
  if value < min { min } else if value > max { max } else { value }
}

/// Resolves a potentially relative length to an absolute length.
///
/// - value (length): Length value to resolve.
/// -> length
#let _resolve-length(value) = {
  measure(box(width: value)[]).width
}

/// Formats a scale label with optional unit.
///
/// - value (float): Scale value.
/// - unit (str, none): Optional unit suffix.
/// -> str
#let _format-scale-label(value, unit) = {
  let rounded = calc.round(value, digits: 2)
  let nearest-int = calc.round(rounded)
  let display-value = if calc.abs(rounded - nearest-int) < 1e-6 {
    int(nearest-int)
  } else {
    rounded
  }

  if unit == none { str(display-value) } else {
    str(display-value) + " " + unit
  }
}

/// Rounds a scale length to 1/2.5/5 x 10^n.
///
/// - target (float): Target scale length.
/// -> float
#let _round-scale(target) = {
  if target <= 0 { return 1 }

  let exponent = calc.floor(calc.log(target))
  let base = calc.pow(10, exponent)
  let scaled = target / base
  let step = if scaled <= 1 { 1 } else if scaled <= 2.5 { 2.5 } else if (
    scaled <= 5
  ) { 5 } else if scaled <= 7.5 {
    7.5
  } else { 10 }
  step * base
}

/// Floors a scale length to 1/2.5/5/7.5 x 10^n.
///
/// - target (float): Maximum allowed scale length.
/// -> float
#let _floor-scale(target) = {
  if target <= 0 { return 0 }

  let exponent = calc.floor(calc.log(target))
  let base = calc.pow(10, exponent)
  let scaled = target / base
  let step = if scaled >= 10 { 10 } else if scaled >= 7.5 { 7.5 } else if (
    scaled >= 5
  ) { 5 } else if scaled >= 2.5 {
    2.5
  } else { 1 }
  step * base
}

/// Resolves the effective scale-bar length and width.
///
/// - scale-length (auto, int, float): Requested scale length.
/// - region-length (float): Length of the underlying coordinate region.
/// - x-scale (length): Length per coordinate unit.
/// - max-bar-width (length): Maximum drawable bar width.
/// - zero-length-message (str): Error message used when region-length <= 0.
/// -> dictionary
#let _resolve-scale-bar-length(
  scale-length,
  region-length,
  x-scale,
  max-bar-width,
  zero-length-message: "Cannot render scale bar for zero-length region.",
) = {
  assert(
    scale-length == auto
      or type(scale-length) == int
      or type(scale-length) == float,
    message: "scale-length must be auto or a positive number.",
  )
  if scale-length != auto {
    assert(scale-length > 0, message: "scale-length must be positive.")
  }
  assert(region-length > 0, message: zero-length-message)

  let max-bar-width-abs = _resolve-length(max-bar-width)
  let x-scale-abs = _resolve-length(x-scale)
  assert(
    max-bar-width-abs > 0pt,
    message: "Cannot render scale bar: available width is too small.",
  )
  assert(
    x-scale-abs > 0pt,
    message: "Cannot render scale bar: scale conversion is zero.",
  )

  let max-fit-length = max-bar-width-abs / x-scale-abs

  let resolved-length = if scale-length == auto {
    let candidate = _round-scale(region-length / 10)
    if candidate <= max-fit-length {
      candidate
    } else {
      _floor-scale(max-fit-length)
    }
  } else {
    scale-length
  }

  let resolved-width = resolved-length * x-scale-abs
  let fit-tolerance = 0.01pt
  let scale-length-label = if scale-length == auto {
    "auto"
  } else {
    str(scale-length)
  }

  assert(
    resolved-length > 0,
    message: "Could not resolve a positive scale length that fits the available width.",
  )
  assert(
    resolved-width <= max-bar-width-abs + fit-tolerance,
    message: (
      "scale-length "
        + scale-length-label
        + " does not fit the available width for the current dimensions."
    ),
  )

  (length: resolved-length, width: resolved-width)
}

/// Draws a horizontal line segment.
///
/// - x (length): Starting x-position.
/// - y (length): Starting y-position.
/// - length (length): Segment length.
/// - stroke (stroke): Line stroke styling.
/// -> content
#let _draw-horizontal-segment(x, y, length, stroke) = {
  if length > 0pt {
    place(top + left, dx: x, dy: y, line(
      start: (0pt, 0pt),
      end: (length, 0pt),
      stroke: stroke,
    ))
  }
}

/// Draws a vertical line segment.
///
/// - x (length): Starting x-position.
/// - y (length): Starting y-position.
/// - length (length): Segment length.
/// - stroke (stroke): Line stroke styling.
/// -> content
#let _draw-vertical-segment(x, y, length, stroke) = {
  if length > 0pt {
    place(top + left, dx: x, dy: y, line(
      start: (0pt, 0pt),
      end: (0pt, length),
      stroke: stroke,
    ))
  }
}

/// Draws a scale-bar row with centered, clamped label.
///
/// - row-width (length): Width of the scale-bar row.
/// - bar-top (length): Top offset for the scale bar.
/// - bar-left (length): Left offset for the scale bar.
/// - bar-width (length): Scale bar width.
/// - tick-height (length): Tick height.
/// - label-gap (length): Gap between ticks and label.
/// - label-size (length): Label font size.
/// - label-color (color): Label color.
/// - label (str): Label text.
/// - stroke-color (color): Stroke color for bar and ticks.
/// - stroke-width (length): Stroke thickness for bar and ticks.
/// -> content
#let _draw-scale-bar-row(
  row-width,
  bar-top,
  bar-left,
  bar-width,
  tick-height,
  label-gap,
  label-size,
  label-color,
  label,
  stroke-color,
  stroke-width,
) = context {
  let row-width-abs = _resolve-length(row-width)
  let bar-left-abs = _resolve-length(bar-left)
  let bar-width-abs = _resolve-length(bar-width)
  let stroke = (paint: stroke-color, thickness: stroke-width, cap: "round")
  let label-text = text(
    size: label-size,
    fill: label-color,
    bottom-edge: "descender",
  )[#label]
  let label-size-box = measure(label-text)
  let label-width-abs = _resolve-length(label-size-box.width)
  let label-left = _clamp(
    bar-left-abs + bar-width-abs / 2 - label-width-abs / 2,
    0pt,
    calc.max(0pt, row-width-abs - label-width-abs),
  )

  box(
    width: row-width-abs,
    height: bar-top + tick-height + label-gap + label-size-box.height,
    {
      _draw-horizontal-segment(
        bar-left-abs,
        bar-top + tick-height / 2,
        bar-width-abs,
        stroke,
      )
      _draw-vertical-segment(bar-left-abs, bar-top, tick-height, stroke)
      _draw-vertical-segment(
        bar-left-abs + bar-width-abs,
        bar-top,
        tick-height,
        stroke,
      )
      place(
        top + left,
        dx: label-left,
        dy: bar-top + tick-height + label-gap,
        label-text,
      )
    },
  )
}

/// Draws a coordinate axis with ticks and labels.
///
/// - coordinate-axis (bool): Whether to draw the axis.
/// - region-start (float): Region start coordinate.
/// - region-end (float): Region end coordinate.
/// - region-length (float): Region length.
/// - track-width (length): Axis width.
/// - axis-top (length): Axis top offset.
/// - tick-height (length): Tick height.
/// - label-gap (length): Gap between tick and label.
/// - label-size (length): Label font size.
/// - unit (str, none): Unit suffix.
/// - axis-color (color): Axis label color.
/// - axis-stroke (stroke): Stroke styling.
/// - axis-left (length): Left offset for axis line and ticks (default: 0pt).
/// -> content
#let _draw-coordinate-axis(
  coordinate-axis,
  region-start,
  region-end,
  region-length,
  track-width,
  axis-top,
  tick-height,
  label-gap,
  label-size,
  unit,
  axis-color,
  axis-stroke,
  axis-left: 0pt,
) = {
  if coordinate-axis {
    _draw-horizontal-segment(axis-left, axis-top, track-width, axis-stroke)

    if region-length <= 0 {
      let tick = region-start
      let label = _format-scale-label(tick, unit)
      let label-text = text(
        size: label-size,
        fill: axis-color,
        bottom-edge: "descender",
      )[#label]
      let label-width = measure(label-text).width
      let label-max-left = calc.max(
        axis-left,
        axis-left + track-width - label-width,
      )
      let x = axis-left + track-width / 2

      _draw-vertical-segment(x, axis-top, tick-height, axis-stroke)
      place(
        top + left,
        dx: _clamp(x - label-width / 2, axis-left, label-max-left),
        dy: axis-top + tick-height + label-gap,
        label-text,
      )
      return
    }

    let tick-step = _round-scale(region-length / 10)
    let first-tick = calc.ceil(region-start / tick-step) * tick-step
    let tick = first-tick

    while tick <= region-end {
      let x = axis-left + track-width * ((tick - region-start) / region-length)
      let label = _format-scale-label(tick, unit)
      let label-text = text(
        size: label-size,
        fill: axis-color,
        bottom-edge: "descender",
      )[#label]
      let label-width = measure(label-text).width
      let label-max-left = calc.max(
        axis-left,
        axis-left + track-width - label-width,
      )

      _draw-vertical-segment(x, axis-top, tick-height, axis-stroke)
      place(
        top + left,
        dx: _clamp(x - label-width / 2, axis-left, label-max-left),
        dy: axis-top + tick-height + label-gap,
        label-text,
      )

      tick += tick-step
    }
  }
}

/// Private: Converts a flat row-major array to a 2D array.
///
/// Takes a flat array and reshapes it into a 2D nested array using
/// row-major indexing: element at (i, j) = flat[i * cols + j].
///
/// - cell-values (array): Flat array of cell values.
/// - rows (int): Number of rows in the output.
/// - cols (int): Number of columns in the output.
/// -> array
#let _flat-to-2d(cell-values, rows, cols) = {
  range(rows).map(i => range(cols).map(j => cell-values.at(i * cols + j)))
}

/// Private: Converts WASM i32 infinity representations to Typst floats.
///
/// The WASM plugin uses i32::MIN (-2147483648) for negative infinity
/// and i32::MAX (2147483647) for positive infinity. This function
/// converts these sentinel values to Typst's float.inf representation.
///
/// - value (int): The value to convert.
/// -> int, float
#let _convert-infinity(value) = {
  if value == -2147483648 { -float.inf } else if value == 2147483647 {
    float.inf
  } else { value }
}
