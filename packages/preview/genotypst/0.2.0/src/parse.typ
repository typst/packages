#let newick_plugin = plugin("newick.wasm")

/// Parses a FASTA string into a dictionary.
///
/// Parses a string containing FASTA-formatted sequence data and returns
/// a dictionary mapping sequence identifiers to their corresponding sequences
/// as strings.
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
        sequences.insert(current-id, current-seq.join())
      }
      current-id = line.slice(1).trim()
      current-seq = ()
    } else {
      current-seq.push(line)
    }
  }
  if current-id != none {
    sequences.insert(current-id, current-seq.join())
  }
  sequences
}

/// Parses a Newick string into a tree structure.
///
/// Parses a string containing Newick-formatted phylogenetic tree data
/// into a dictionary structure suitable for rendering.
///
/// - data (str): A string containing the Newick data.
/// - trim-quotes (bool): Trim quotes from tip labels (default: true)
/// -> dictionary
#let parse-newick(data, trim-quotes: true) = {
  let trim-quotes-bytes = bytes(if trim-quotes { (1,) } else { (0,) })
  let result = newick_plugin.parse_newick(bytes(data.trim()), trim-quotes-bytes)
  json(result)
}
