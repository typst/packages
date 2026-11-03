#import "../common/fixed_grid.typ": _fixed-width-grid

/// Resolves a FASTA record's sequence and validates identifier uniqueness.
///
/// - sequences (dictionary): Parsed FASTA records.
/// - seq-id (str): Sequence identifier.
/// - seq-parts (array): Sequence fragments collected for the record.
/// -> str
#let _resolve-fasta-record-sequence(sequences, seq-id, seq-parts) = {
  let sequence = seq-parts.join()
  assert(
    not (seq-id in sequences),
    message: "Duplicate FASTA identifier '"
      + seq-id
      + "'. FASTA identifiers must be unique.",
  )
  sequence
}

/// Parses a FASTA string into a dictionary.
///
/// Parses a string containing FASTA-formatted sequence data and returns
/// a dictionary mapping unique sequence identifiers to their corresponding
/// sequences as strings. Duplicate identifiers are rejected.
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
        sequences.insert(
          current-id,
          _resolve-fasta-record-sequence(sequences, current-id, current-seq),
        )
      }
      current-id = line.slice(1).trim()
      current-seq = ()
    } else {
      current-seq.push(line)
    }
  }

  if current-id != none {
    sequences.insert(
      current-id,
      _resolve-fasta-record-sequence(sequences, current-id, current-seq),
    )
  }

  sequences
}

/// Formats a dictionary of sequences in FASTA format for display.
/// Each character is rendered in a fixed-width box to prevent line wrapping.
///
/// - sequences (dictionary): A dictionary mapping sequence identifiers to sequences.
/// - max-width (int): Maximum characters per line (default: 60).
/// - bold-header (bool): Render sequence headers in bold (default: false).
/// - entry-spacing (length, none): Vertical spacing between entries; defaults to line spacing if none (default: none).
/// -> content
#let render-fasta(
  sequences,
  max-width: 60,
  bold-header: false,
  entry-spacing: none,
) = {
  context {
    let leading = par.leading
    let char-width = calc.max(
      measure(text("W")).width,
      measure(text("M")).width,
    )
    let lines = ()
    let spacing = if entry-spacing == none { leading } else { entry-spacing }
    let render-segment = segment => _fixed-width-grid(
      (segment.clusters(),),
      cell-width: char-width,
    )

    for (acc, seq) in sequences.pairs() {
      let header = if bold-header {
        text(weight: "bold", ">" + acc)
      } else {
        ">" + acc
      }
      lines.push(header)

      if seq.len() == 0 { continue }

      for i in range(0, seq.len(), step: max-width) {
        let segment = seq.slice(i, calc.min(i + max-width, seq.len()))
        lines.push(render-segment(segment))
      }

      lines.push(v(spacing, weak: true))
    }

    align(left, stack(spacing: 0.65em, ..lines))
  }
}
