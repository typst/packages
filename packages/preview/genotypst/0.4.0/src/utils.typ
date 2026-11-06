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

/// Clamps a numeric value between bounds.
///
/// - value (length): Value to clamp.
/// - min (length): Lower bound.
/// - max (length): Upper bound.
/// -> length
#let _clamp(value, min, max) = {
  if value < min { min } else if value > max { max } else { value }
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

/// Private: Converts a flat row-major array to a 2D array.
///
/// Takes a flat array and reshapes it into a 2D nested array using
/// row-major indexing: element at (i, j) = flat[i * cols + j].
///
/// - values (array): Flat array of values.
/// - rows (int): Number of rows in the output.
/// - cols (int): Number of columns in the output.
/// -> array
#let _flat-to-2d(values, rows, cols) = {
  range(rows).map(i => range(cols).map(j => values.at(i * cols + j)))
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
