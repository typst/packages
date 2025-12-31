/// Parses a FASTA file from a file path into a dictionary.
///
/// Reads a FASTA formatted file and returns a dictionary mapping sequence
/// identifiers to their corresponding sequences as strings.
///
/// - file (str): The path to the FASTA file to be read.
/// -> dictionary<str, str>
#let parse-fasta-file(file) = {
  let sequences = (:)
  let current-id = none
  let current-seq = ()

  for line in read(file).split("\n") {
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
