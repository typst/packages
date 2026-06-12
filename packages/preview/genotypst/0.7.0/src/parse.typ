#let newick_plugin = plugin("newick.wasm")

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
    message: "Duplicate FASTA identifier '" + seq-id
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
/// -> dictionary
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

/// Parses a Newick string into a tree structure.
///
/// Parses a string containing Newick-formatted phylogenetic tree data
/// into a dictionary structure suitable for rendering.
///
/// - data (str): A string containing the Newick data.
/// -> dictionary
#let parse-newick(data) = {
  let result = newick_plugin.parse_newick(bytes(data.trim()))
  json(result)
}
