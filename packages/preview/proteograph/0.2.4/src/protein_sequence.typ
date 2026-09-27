

/// Display a protein sequence in a block with amino acid numbering
/// -> content
#let protein-sequence(

  /// The maximum length of amino acid to display in a line. *Optional*.
  line-length: 50,
  
  /// Amino acid sequence (one letter code) of the protein to display
  protein
) = {
  set par.line(numbering: i => { (i - 1)*line-length })

  let arr_prot = ()
  let i=0
  while (i < protein.len()) {
    arr_prot.push(protein.slice(i, calc.min(i+line-length,protein.len())))
    i = i + line-length
  }
  [#block(text(font: "Andale Mono",arr_prot.join("\n")))]
}

