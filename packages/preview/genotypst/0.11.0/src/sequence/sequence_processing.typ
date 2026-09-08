/// Canonicalizes a residue palette to uppercase keys.
///
/// Duplicate keys that normalize to the same residue are allowed only if they
/// map to the same color.
///
/// - palette (dictionary): Dictionary mapping residues to colors.
/// -> dictionary
#let _prepare-palette(palette) = {
  assert(
    type(palette) == dictionary,
    message: "palette must be a dictionary mapping residues to colors.",
  )

  let prepared = (:)
  for (key, color) in palette.pairs() {
    assert(type(key) == str, message: "palette keys must be strings.")
    let canonical-key = upper(key)
    if canonical-key in prepared {
      assert(
        prepared.at(canonical-key) == color,
        message: "Palette defines conflicting colors for residues that normalize to '"
          + canonical-key
          + "'.",
      )
      continue
    }
    prepared.insert(canonical-key, color)
  }
  prepared
}

/// Looks up a residue color using case-insensitive palette matching.
///
/// - palette (dictionary): Prepared palette with canonical uppercase keys.
/// - residue (str): Residue symbol to match.
/// -> color, none
#let _lookup-palette-color(palette, residue) = palette.at(
  upper(residue),
  default: none,
)

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
/// Counts occurrences of each valid character at a specific position across all
/// sequences in the alignment. Matching is case-insensitive.
///
/// - sequences (array): Array of sequence strings.
/// - pos (int): The column position to analyze (0-indexed).
/// - alphabet-config (dictionary): Canonical alphabet configuration.
/// -> dictionary with keys:
///   - counts (dictionary): Counts of valid characters at the column.
///   - total-non-gap (int): Total count of valid non-gap characters.
#let _get-column-stats(sequences, pos, alphabet-config) = {
  let counts = (:)
  let total-non-gap = 0
  for seq in sequences {
    if pos < seq.len() {
      let char = upper(seq.at(pos))
      if char in alphabet-config.char-set {
        counts.insert(char, counts.at(char, default: 0) + 1)
        total-non-gap += 1
      }
    }
  }
  (counts: counts, total-non-gap: total-non-gap)
}

/// Collects column statistics for a contiguous alignment window.
///
/// - sequences (array): Array of sequence strings.
/// - start (int): Window start position (0-indexed, inclusive).
/// - end (int): Window end position (0-indexed, exclusive).
/// - alphabet-config (dictionary): Canonical alphabet configuration.
/// - sampling-correction (bool): Apply small sample correction.
/// -> array of dictionaries with keys:
///   - counts (dictionary): Counts of valid characters at each column.
///   - total-non-gap (int): Total count of valid non-gap characters at each column.
///   - conservation (float): Occupancy-scaled information content for each column.
#let _collect-window-column-stats(
  sequences,
  start,
  end,
  alphabet-config,
  sampling-correction,
) = {
  let num-sequences = sequences.len()
  range(start, end).map(pos => {
    let stats = _get-column-stats(sequences, pos, alphabet-config)
    (
      counts: stats.counts,
      total-non-gap: stats.total-non-gap,
      conservation: _compute-sequence-conservation(
        stats.counts,
        stats.total-non-gap,
        num-sequences,
        sampling-correction,
        alphabet-config.size,
      ),
    )
  })
}

/// Checks whether a prepared palette covers the observed residues in a sequence
/// list using case-insensitive matching.
///
/// Returns a dictionary with an `ok` flag and a `missing` array containing
/// observed non-gap residues whose canonical uppercase keys are not present in
/// the palette.
///
/// - palette (dictionary): Prepared palette with canonical uppercase keys.
/// - sequences (array): Array of sequence strings.
/// -> dictionary with keys:
///   - ok (bool): Whether the palette covers all residues in the sequences.
///   - missing (array): Residues not found in the palette.
#let _check-palette-coverage(palette, sequences) = {
  assert(
    type(palette) == dictionary,
    message: "palette must be a dictionary mapping residues to colors.",
  )
  assert(type(sequences) == array, message: "sequences must be an array.")

  let observed = (:)
  for seq in sequences {
    for char in seq.clusters() {
      if char in ("-", ".") { continue }
      observed.insert(upper(char), true)
    }
  }

  let missing = ()
  for key in observed.keys() {
    if not (key in palette) { missing.push(key) }
  }

  (ok: missing.len() == 0, missing: missing.sorted())
}

/// Validates that all sequences in the MSA have the same length.
///
/// Ensures that all sequences in a multiple sequence alignment have identical
/// lengths. Throws an error if sequences have different lengths.
///
/// - alignment (dictionary): Dictionary mapping sequence identifiers to aligned sequences.
/// -> none
#let _validate-alignment(alignment) = {
  let sequences = alignment.values()
  if sequences.len() > 0 {
    let expected-len = sequences.first().len()
    assert(
      sequences.all(s => s.len() == expected-len),
      message: "All sequences must be of equal length.",
    )
  }
}
