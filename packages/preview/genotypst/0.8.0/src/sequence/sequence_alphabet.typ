#import "./residue_palette.typ": (
  _aa-characters, _dna-characters, _rna-characters, residue-palette,
)

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

  assert(
    observed-keys.any(char => char in all-known),
    message: "Could not guess sequence alphabet. Please set alphabet to 'aa', 'dna', or 'rna'.",
  )

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
  for seq in sequences {
    if pos < seq.len() {
      let char = upper(seq.at(pos))
      if char in alphabet-characters {
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
/// sequence alphabet.
///
/// - alphabet (auto, str): Sequence alphabet: auto, "aa", "dna", or "rna".
/// - sequences (array): Array of sequence strings for auto-detection.
/// -> dictionary with keys:
///   - size: int, size of the alphabet (20 for amino acids, 4 for DNA/RNA)
///   - chars: array, array of valid characters
///   - palette: dictionary, color mapping for characters
#let _resolve-alphabet-config(alphabet, sequences) = {
  assert(
    alphabet == auto or alphabet in ("aa", "dna", "rna"),
    message: "alphabet must be auto, 'aa', 'dna', or 'rna'.",
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
/// -> dictionary with keys:
///   - ok: bool
///   - missing: array
#let _check-palette-coverage(palette, sequences) = {
  assert(
    type(palette) == dictionary,
    message: "palette must be a dictionary mapping residues to colors.",
  )
  assert(type(sequences) == array, message: "sequences must be an array.")

  let gap-chars = ("-", ".")
  let observed = (:)
  for seq in sequences {
    for char in seq.clusters() {
      if char in gap-chars { continue }
      observed.insert(char, true)
    }
  }

  let palette-keys = (:)
  for key in palette.keys() {
    palette-keys.insert(key, true)
  }

  let missing = ()
  for key in observed.keys() {
    if not (key in palette-keys) { missing.push(key) }
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
