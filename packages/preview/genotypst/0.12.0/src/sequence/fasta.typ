#import "../common/fixed_grid.typ": _fixed-width-grid, _measure-monospace-width

/// Rejects a FASTA identifier that has already been parsed.
///
/// - sequences (dictionary): Parsed FASTA records.
/// - seq-id (str): Sequence identifier.
/// -> none
#let _assert-unique-fasta-id(sequences, seq-id) = {
  // `assert`'s message is evaluated eagerly, so build it only after failing;
  // this check runs once per record.
  if seq-id in sequences {
    assert(
      false,
      message: "Duplicate FASTA identifier '"
        + seq-id
        + "'. FASTA identifiers must be unique.",
    )
  }
}

/// Parses FASTA-formatted sequence data into a dictionary mapping unique
/// sequence identifiers to sequence strings.
///
/// Duplicate identifiers are rejected.
///
/// - data (str): A string containing the FASTA data.
/// -> dictionary with keys:
///   - sequence-id (str): Sequence string keyed by each unique FASTA identifier.
#let parse-fasta(data) = {
  let sequences = (:)
  let current-id = none
  let current-seq = ()

  for line in data.split("\n") {
    let line = line.trim()
    if line.len() == 0 { continue }
    if line.starts-with(">") {
      if current-id != none {
        _assert-unique-fasta-id(sequences, current-id)
        sequences.insert(current-id, current-seq.join("", default: ""))
      }
      current-id = line.slice(1).trim()
      current-seq = ()
    } else {
      current-seq.push(line)
    }
  }

  if current-id != none {
    _assert-unique-fasta-id(sequences, current-id)
    sequences.insert(current-id, current-seq.join("", default: ""))
  }

  sequences
}

/// Renders a dictionary of sequences in FASTA format for display.
/// Sequences are wrapped after `max-line-length` residues.
///
/// - sequences (dictionary): Dictionary mapping sequence identifiers to sequences.
/// - max-line-length (int): Maximum number of residues per rendered line (default: 60).
/// - bold-header (bool): Whether to render sequence headers in bold (default: false).
/// - entry-spacing (length, none): Vertical spacing between entries. Defaults to line spacing when `none` (default: none).
/// -> content
#let render-fasta(
  sequences,
  max-line-length: 60,
  bold-header: false,
  entry-spacing: none,
) = {
  context {
    let leading = par.leading
    let lines = ()
    let spacing = if entry-spacing == none { leading } else { entry-spacing }
    // Measured once here rather than inside every wrapped line's grid.
    let char-width = _measure-monospace-width()
    let render-segment = segment => _fixed-width-grid(
      (segment.clusters(),),
      char-width,
    )

    for (acc, seq) in sequences.pairs() {
      let header = if bold-header {
        text(weight: "bold", ">" + acc)
      } else {
        ">" + acc
      }
      lines.push(header)

      if seq.len() == 0 { continue }

      for i in range(0, seq.len(), step: max-line-length) {
        let segment = seq.slice(i, calc.min(i + max-line-length, seq.len()))
        lines.push(render-segment(segment))
      }

      lines.push(v(spacing, weak: true))
    }

    align(left, stack(spacing: 0.65em, ..lines))
  }
}
