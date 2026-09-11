#import "./sequence_alphabet.typ": (
  _observed-residue-set, _resolve-alphabet-config,
)

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
  for (key, value) in palette.pairs() {
    assert(type(key) == str, message: "palette keys must be strings.")
    // Rejected here rather than where the fill is derived, so an unusable
    // entry is reported even when its residue never reaches the renderer.
    assert(type(value) == color, message: "palette values must be colors.")
    let canonical-key = upper(key)
    if canonical-key in prepared {
      assert(
        prepared.at(canonical-key) == value,
        message: "Palette defines conflicting colors for residues that normalize to '"
          + canonical-key
          + "'.",
      )
      continue
    }
    prepared.insert(canonical-key, value)
  }
  prepared
}

/// Looks up a residue entry using case-insensitive palette matching.
///
/// The entry type is whatever the caller keyed the palette by: a raw color for
/// the sequence logo, a derived fill pair for the MSA renderer.
///
/// - palette (dictionary): Residue-keyed map with canonical uppercase keys.
/// - residue (str): Residue symbol to match.
/// -> any, none
#let _lookup-palette-entry(palette, residue) = palette.at(
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
/// - max-bits (float): Maximum information content (`log2(alphabet-size)`).
/// - alphabet-size (int): Size of the alphabet.
/// -> float
#let _compute-sequence-conservation(
  counts,
  total-non-gap,
  num-sequences,
  sampling-correction,
  max-bits,
  alphabet-size,
) = {
  if total-non-gap == 0 { return 0.0 }

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
/// Counts are keyed in first-seen sequence order, which Typst dictionaries
/// preserve.
///
/// - sequences (array): Array of sequence strings.
/// - pos (int): The column position to analyze (0-indexed).
/// - alphabet-config (dictionary): Canonical alphabet configuration.
/// - seq-len (int): Shared length of every sequence in the alignment.
/// -> dictionary with keys:
///   - counts (dictionary): Counts of valid characters at the column.
///   - total-non-gap (int): Total count of valid non-gap characters.
#let _get-column-stats(sequences, pos, alphabet-config, seq-len) = {
  let counts = (:)
  let total-non-gap = 0
  if pos < seq-len {
    for seq in sequences {
      let char = upper(seq.at(pos))
      if char in alphabet-config.char-set {
        counts.insert(char, counts.at(char, default: 0) + 1)
        total-non-gap += 1
      }
    }
  }
  (counts: counts, total-non-gap: total-non-gap)
}

/// Computes the consensus sequence from pre-computed column statistics.
///
/// For each column, selects the most frequent valid residue. Ties are resolved
/// by the first-seen residue order captured in the column statistics. Columns
/// without valid residues are represented as gaps (`-`). The input is assumed
/// to come from a validated MSA.
///
/// - column-stats (array): Prepared per-column statistics.
/// -> str
#let _compute-consensus-sequence(column-stats) = {
  let consensus = ()
  for stats in column-stats {
    let best-char = "-"
    let best-count = 0
    for (char, count) in stats.counts.pairs() {
      if count > best-count {
        best-char = char
        best-count = count
      }
    }
    consensus.push(best-char)
  }
  consensus.join("", default: "")
}

/// Collects column statistics for a contiguous alignment window.
///
/// Every sequence must already be the same length; callers reach this through
/// `_validate-alignment`, which enforces that.
///
/// - sequences (array): Array of sequence strings.
/// - start (int): Window start position (0-indexed, inclusive).
/// - end (int): Window end position (0-indexed, exclusive).
/// - alphabet-config (dictionary): Canonical alphabet configuration.
/// - sampling-correction (bool): Apply small sample correction.
/// - compute-conservation (bool): Compute conservation values.
/// -> array of dictionaries with keys:
///   - counts (dictionary): Counts of valid characters at each column.
///   - total-non-gap (int): Total count of valid non-gap characters at each column.
///   - conservation (float, none): Occupancy-scaled information content for
///     each column, or `none` when `compute-conservation` is `false`.
#let _collect-window-column-stats(
  sequences,
  start,
  end,
  alphabet-config,
  sampling-correction,
  compute-conservation: true,
) = {
  let num-sequences = sequences.len()
  // One shared length replaces the per-sequence bound check, which the
  // equal-length precondition makes redundant.
  let seq-len = if num-sequences == 0 { 0 } else { sequences.first().len() }
  range(start, end).map(pos => {
    let stats = _get-column-stats(sequences, pos, alphabet-config, seq-len)
    (
      counts: stats.counts,
      total-non-gap: stats.total-non-gap,
      conservation: if compute-conservation {
        _compute-sequence-conservation(
          stats.counts,
          stats.total-non-gap,
          num-sequences,
          sampling-correction,
          alphabet-config.max-bits,
          alphabet-config.size,
        )
      } else {
        none
      },
    )
  })
}

/// Asserts that a prepared palette covers every observed non-gap residue,
/// using case-insensitive matching.
///
/// - palette (dictionary): Prepared palette with canonical uppercase keys.
/// - sequences (array): Array of sequence strings.
/// - observed (dictionary, none): Precomputed observed-residue set.
/// -> none
#let _assert-palette-coverage(palette, sequences, observed: none) = {
  assert(
    type(palette) == dictionary,
    message: "palette must be a dictionary mapping residues to colors.",
  )
  assert(type(sequences) == array, message: "sequences must be an array.")

  let observed = if observed == none {
    _observed-residue-set(sequences)
  } else {
    observed
  }
  let missing = observed.keys().filter(key => key not in palette)
  if missing.len() != 0 {
    assert(
      false,
      message: "Palette missing residues: " + missing.sorted().join(", "),
    )
  }
}

/// Resolves the palette to use for coloring and validates residue coverage.
///
/// Returns an empty palette when `enabled` is `false`. Otherwise resolves to the
/// alphabet's default palette when `palette` is `auto`, or a prepared custom
/// palette. A custom palette is asserted to cover every observed residue.
///
/// - palette (auto, dictionary): Requested palette or `auto` for the default.
/// - config (dictionary): Canonical alphabet configuration with a `palette` field.
/// - sequences (array): Array of sequence strings.
/// - enabled (bool): Whether coloring is enabled.
/// - observed (dictionary, none): Precomputed observed-residue set.
/// -> dictionary
#let _resolve-palette(
  palette,
  config,
  sequences,
  enabled: true,
  observed: none,
) = {
  if not enabled { return (:) }
  if palette == auto { return config.palette }

  let resolved = _prepare-palette(palette)
  _assert-palette-coverage(resolved, sequences, observed: observed)
  resolved
}

/// Resolves the alphabet configuration and the palette from one residue scan.
///
/// Owning both calls is what lets the observed-residue set be shared safely:
/// the set is built here, from the same `sequences`, and is only built when at
/// least one of the two resolvers would otherwise build it itself.
///
/// - alphabet (auto, str): Sequence alphabet: auto, "aa", "dna", or "rna".
/// - palette (auto, dictionary): Requested palette or `auto` for the default.
/// - sequences (array): Array of sequence strings.
/// - enabled (bool): Whether coloring is enabled.
/// -> dictionary with keys:
///   - config (dictionary): Canonical alphabet configuration.
///   - palette (dictionary): Resolved palette.
#let _resolve-alphabet-and-palette(
  alphabet,
  palette,
  sequences,
  enabled: true,
) = {
  let needs-observed = alphabet == auto or (enabled and palette != auto)
  let observed = if needs-observed { _observed-residue-set(sequences) }
  let config = _resolve-alphabet-config(alphabet, sequences, observed: observed)
  (
    config: config,
    palette: _resolve-palette(
      palette,
      config,
      sequences,
      enabled: enabled,
      observed: observed,
    ),
  )
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
