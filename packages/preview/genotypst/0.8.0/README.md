# genotypst

[![Typst package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fapcamargo%2Fgenotypst%2Fmain%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239DAD)](https://typst.app/universe/package/genotypst)
[![GitHub repository](https://img.shields.io/badge/GitHub-Repository-black?logo=github)](https://github.com/apcamargo/genotypst)
[![Manual](https://img.shields.io/badge/User_manual-blue)](./docs/manual.pdf)

`genotypst` is a bioinformatics package for Typst that enables analysis and visualization of biological data. It provides functionality for parsing FASTA and Newick files and generating publication-ready visualizations, including multiple sequence alignments, sequence logos, genome maps, and phylogenetic trees.

## Documentation

Refer to the [manual](./docs/manual.pdf) for a comprehensive guide containing examples illustrating how to use `genotypst`.

## Quickstart

A minimal example illustrating the use of `genotypst` is shown below. To reproduce it, download the example multiple sequence alignment file [`msa.afa`](./docs/data/msa.afa).

In a Typst document, import the `genotypst` package:

```typst
#import "@preview/genotypst:0.8.0": *
```

You can perform a simple pairwise alignments and visualize both the alignment and its dynamic programming matrix:

```typst
// Perform a local alignment of two DNA sequences
#let dna_alignment = align-seq-pair(
  "AAT",
  "AACTTG",
  match-score: 3,
  mismatch-score: -1,
  gap-penalty: -1,
  mode: "local",
)

// Render the alignment
#render-pair-alignment(
  dna_alignment.seq-1,
  dna_alignment.seq-2,
  dna_alignment.traceback-paths.at(0),
)
```

![Local alignment of a pair of DNA sequences](./docs/pair_alignment_example.svg)

```typst
// Render the dynamic programming matrix
#render-dp-matrix(
  dna_alignment.seq-1,
  dna_alignment.seq-2,
  scores: dna_alignment.dp-matrix.scores,
  path: dna_alignment.traceback-paths.at(0),
  arrows: dna_alignment.dp-matrix.arrows,
)
```

![Dynamic programming matrix for a local DNA sequence alignment](./docs/dp_matrix_example.svg)

Read a FASTA file containing a multiple sequence alignment:

```typst
// Load sequences
#let sequences = parse-fasta(read("msa.afa"))

// Display the `sequences` variable
#repr(sequences)
```

```
(
  "gi|503891280": "MIQRSLRDKQIIKVLTGVRRCGKSTILQMFINFEDLAYEKYDYYELYQYL…",
  "gi|502172365": "TRPRVLRRVMGAVLIDGPKAVGKTQTTTRVLRLDVDVARAALVPEQLFE-…",
  "gi|504805136": "IYPRMDILPNFALVVSGIRRSGKSTLLTQFLNFDTPQLFNFEDFALLDEI…",
  "gi|502700462": "----MLETDLPALLIVGPRASGKTTTAARTVRLDVPAQAAAFDPDAALRN…",
  …
)
```

A region of the multiple sequence alignment can be rendered with `render-msa`:

```typst
// Render a multiple sequence alignment between positions 100 and 135
#context {
  set text(size: 0.85em)
  render-msa(protein_msa, start: 100, end: 135, colors: true, conservation: true)
}
```

![Protein multiple sequence alignment with residue coloring and conservation](./docs/msa_example.svg)

The same region of the alignment can also be visualized as a sequence logo using `render-sequence-logo`:

```typst
// Render a sequence logo between positions 100 and 135
#render-sequence-logo(sequences, start: 100, end: 135)
```

![Sequence logo for a protein multiple sequence alignment](./docs/logo_example.svg)

To render a genomic locus, you can pass an array of genomic features to the `render-genome-map` function:

```typst
// Render a genome map containing five features
#let locus = (
  (start: 400, end: 1260, strand: 1, label: [A], color: rgb("#56B4E9")),
  (start: 1300, end: 2200, strand: 1, label: [B]),
  (start: 2250, end: 3460, strand: -1, label: [C], color: rgb("#E69F00")),
  (start: 3500, end: 3800, label: [D]),
  (start: 3850, end: 5400, strand: 1, label: [E]),
)

#render-genome-map(
  locus,
  coordinate-axis: true,
  width: 80%,
)
```

![Genome map showing five labeled features and the coordinate axis](./docs/genome_map_example.svg)

You can also use `genotypst` to parse Newick data and visualize phylogenetic trees:

```typst
// Parse Newick data
#let tree = parse-newick(
  "(('Leaf A':0.2,'Leaf B':0.1)'Internal node':0.3,'Leaf C':0.6)Root;"
)
// Render the phylogenetic tree
#render-rectangular-tree(tree)
```

![Phylogenetic tree with three leaves and a root](./docs/tree_example.svg)
