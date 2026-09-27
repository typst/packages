#import "./residue_palette.typ": _canonical-residue-palette

#let _aa-residues = (
  "A",
  "C",
  "D",
  "E",
  "F",
  "G",
  "H",
  "I",
  "K",
  "L",
  "M",
  "N",
  "P",
  "Q",
  "R",
  "S",
  "T",
  "V",
  "W",
  "Y",
)
#let _dna-residues = ("A", "T", "G", "C")
#let _rna-residues = ("A", "U", "G", "C")

#let _make-membership-set(values) = {
  let membership = (:)
  for value in values {
    membership.insert(value, true)
  }
  membership
}

#let _aa-config = (
  size: 20,
  max-bits: calc.log(20, base: 2.0),
  chars: _aa-residues,
  char-set: _make-membership-set(_aa-residues),
  palette: _canonical-residue-palette.aa.default,
)
#let _dna-config = (
  size: 4,
  max-bits: calc.log(4, base: 2.0),
  chars: _dna-residues,
  char-set: _make-membership-set(_dna-residues),
  palette: _canonical-residue-palette.nt.default,
)
#let _rna-config = (
  size: 4,
  max-bits: calc.log(4, base: 2.0),
  chars: _rna-residues,
  char-set: _make-membership-set(_rna-residues),
  palette: _canonical-residue-palette.nt.default,
)
#let _nt-set = _make-membership-set(_dna-residues + _rna-residues)
#let _all-known-set = _make-membership-set(
  _aa-residues + _dna-residues + _rna-residues,
)

/// Gap symbols, excluded from every observed-residue set.
#let _gap-symbols = ("-", ".")

/// Collects the distinct uppercase residues observed in a set of sequences.
///
/// Gap symbols are skipped. Consumers may therefore assume the set holds only
/// residues, which is what makes it safe to reuse for both alphabet detection
/// and palette coverage; it also requires that no alphabet membership table
/// (`_all-known-set`, `_aa-config.char-set`, `_nt-set`) ever admit a gap.
///
/// - sequences (array): Array of sequence strings.
/// -> dictionary: Membership map keyed by canonical uppercase residue.
#let _observed-residue-set(sequences) = {
  let observed = (:)
  for seq in sequences {
    for char in seq.clusters() {
      if char in _gap-symbols { continue }
      observed.insert(upper(char), true)
    }
  }
  observed
}

/// Guesses the sequence alphabet based on the characters present in the sequences.
///
/// Analyzes the sequences to determine whether they are amino acids ("aa"),
/// DNA ("dna"), or RNA ("rna"). Returns "dna" if U is not present,
/// "rna" if U is present, and "aa" if amino acid specific characters
/// are found. Detection is case-insensitive and ignores unknown symbols unless
/// no known residues are present.
///
/// - sequences (dictionary, array): A dictionary mapping identifiers to sequences, or an array of sequences.
/// - observed (dictionary, none): Precomputed observed-residue set, to avoid
///   rescanning every residue when the caller already built one.
/// -> str
#let _guess-seq-alphabet(sequences, observed: none) = {
  let sequences = if type(sequences) == dictionary { sequences.values() } else {
    sequences
  }
  let observed-keys = if observed == none {
    _observed-residue-set(sequences).keys()
  } else {
    observed.keys()
  }

  assert(
    observed-keys.any(char => char in _all-known-set),
    message: "Could not guess sequence alphabet. Please set alphabet to 'aa', 'dna', or 'rna'.",
  )

  if observed-keys.any(char => (
    char in _aa-config.char-set and char not in _nt-set
  )) {
    "aa"
  } else if "U" in observed-keys {
    "rna"
  } else {
    "dna"
  }
}

/// Resolves alphabet configuration based on the specified alphabet or auto-detection.
///
/// Returns a configuration dictionary containing the alphabet size, character set,
/// and color palette. If alphabet is auto, automatically detects the
/// sequence alphabet.
///
/// - alphabet (auto, str): Sequence alphabet: auto, "aa", "dna", or "rna".
/// - sequences (array): Array of sequence strings for auto-detection.
/// - observed (dictionary, none): Precomputed observed-residue set.
/// -> dictionary with keys:
///   - size (int): Alphabet size (20 for amino acids, 4 for DNA/RNA).
///   - max-bits (float): Maximum possible information content (log2 of alphabet size).
///   - chars (array): Array of canonical uppercase alphabet characters.
///   - char-set (dictionary): Membership map for canonical uppercase alphabet characters.
///   - palette (dictionary): Color mapping for characters.
#let _resolve-alphabet-config(alphabet, sequences, observed: none) = {
  assert(
    alphabet == auto or alphabet in ("aa", "dna", "rna"),
    message: "alphabet must be auto, 'aa', 'dna', or 'rna'.",
  )

  let type = if alphabet == auto {
    _guess-seq-alphabet(sequences, observed: observed)
  } else {
    alphabet
  }

  if type == "aa" {
    _aa-config
  } else if type == "dna" {
    _dna-config
  } else if type == "rna" {
    _rna-config
  }
}
