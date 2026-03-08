#import "@preview/genotypst:0.1.0": *
#import "template.typ": aa-groups, dna-rna-groups, project, render-palette-group

#show: project.with(
  title: "genotypst: A bioinformatics Typst package for sequence analysis and visualization",
  author: "Antonio Camargo",
)

`genotypst` is a bioinformatics package for Typst that enables analysis and visualization of biological data. It provides functionality for parsing FASTA and Newick files and generating publication-ready visualizations, including multiple sequence alignments, sequence logos, and phylogenetic trees.

#outline()

#pagebreak()

= Working with sequence data

`genotypst` provides functions to parse sequence data and produce different visualizations.

== Loading data

The `parse-fasta-file` function reads FASTA files and returns a dictionary mapping sequence identifiers to their corresponding sequences.

```typ
#let sequences = parse-fasta(read("/docs/data/dna.fna"))
```

#let sequences = parse-fasta(read("/docs/data/dna.fna"))

#raw(repr(sequences), block: true)

== FASTA rendering

Use `render-fasta` to display sequences in the standard FASTA format.

```typ
#render-fasta(sequences, max-width: 50)
```

#align(box(render-fasta(sequences, max-width: 50)), center)

In this example, `max-width` controls how many characters appear per line (default is 60).

== Multiple sequence alignments

The `render-msa` function displays multiple sequence alignments with optional residue coloring and conservation bars.

In the example below:

- `colors: true` enables residue coloring based on biochemical properties.
- `conservation: true` adds conservation bars above the alignment.
- `start: 100` and `end: 160` limit the display to a specific region of interest (residues 100 to 160).

```typ
#let protein_msa = parse-fasta(read("/docs/data/msa.afa"))

#render-msa(
  protein_msa,
  start: 100,
  end: 160,
  colors: true,
  conservation: true,
)
```

#let protein_msa = parse-fasta(read("/docs/data/msa.afa"))

#figure(
  render-msa(
    protein_msa,
    start: 100,
    end: 160,
    colors: true,
    conservation: true,
  ),
  caption: [MSA visualization for positions 100--160, with residue coloring and conservation bars enabled.],
  kind: image,
)

Residue coloring represents amino acid physicochemical properties. The sequence alphabet (amino acid, DNA, or RNA) is determined automatically and a suitable color palette is applied.

The bars above the alignment indicate the degree of conservation at each column.

== Sequence logos

Sequence logos @schneider_sequence_1990 summarize conservation patterns within a sequence alignment and are commonly used to visualize binding sites, motifs, and functional domains. In a sequence logo, the total height of each stack represents the information content (in bits) at that position, while the height of individual letters reflects their relative frequencies.

In the example below, we visualize the same region as the MSA of the previous section (positions 100 to 160).

```typ
#render-sequence-logo(protein_msa, start: 100, end: 160)
```

#figure(
  render-sequence-logo(protein_msa, start: 100, end: 160),
  caption: [Sequence logo for positions 100--160, showing conservation and residue frequency.],
)

Like `render-msa`, `render-sequence-logo` automatically applies the appropriate color palette based on the sequence alphabet.

== Color palettes

`genotypst` uses predefined color palettes to assign colors to sequence residues.

=== Amino acid palette

Amino acids are colored according to their physicochemical properties. Grouping residues by color helps reveal the chemical nature of conserved positions (e.g., whether a position is consistently hydrophobic or charged), which is often important for understanding protein structure, function, and evolution.

#align(center, grid(
  columns: (auto, auto),
  column-gutter: 3em,
  align: left,
  inset: (y: 0.8em),
  stack(spacing: 1.5em, ..aa-groups.slice(0, 3).map(render-palette-group)),
  stack(spacing: 1.5em, ..aa-groups.slice(3).map(render-palette-group)),
))

=== Nucleic acid palettes

The DNA and RNA palettes assign a distinct color to each nucleotide.

#align(center, grid(
  columns: (auto, auto),
  column-gutter: 3em,
  align: left,
  inset: (y: 0.8em),
  ..dna-rna-groups.map(render-palette-group)
))

= Working with phylogenetic trees

`genotypst` includes functions to parse and render phylogenetic trees. Trees can be created by parsing Newick-formatted strings with `parse-newick` or by manually constructing nested dictionary structures.

```typst
#let parsed_newick_tree = parse-newick(
  "(('Leaf A':0.2,'Leaf B':0.1)'Internal node':0.3,'Leaf C':0.6)Root;"
)

#let manual_tree = (
  rooted: true,
  name: "Root",
  length: none,
  children: (
    (
      name: "Internal node",
      length: 0.3,
      children: (
        (name: "Leaf A", length: 0.2, children: none),
        (name: "Leaf B", length: 0.1, children: none),
      ),
    ),
    (name: "Leaf C", length: 0.6, children: none),
  ),
)
```

== Visualizing trees

`genotypst` can produce visualizations of phylogenetic trees. To illustrate this, we will read and render a Newick file containing a phylogeny of the _Hominoidea_ superfamily, which was extracted from the Ensembl Compara species tree @herrero_ensembl_2016.

```typst
#let hominoidea_tree = parse-newick(read("/docs/data/hominoidea.nwk"))
```

#let hominoidea_tree = parse-newick(read("/docs/data/hominoidea.nwk"))

To render the tree, use the `render-tree` function. By default, it produces a horizontal rectangular dendrogram, but a vertical layout can be specified using the `orientation: "vertical"` option.

```typst
#render-tree(hominoidea_tree, tip-label-italics: true, orientation: "horizontal")
#render-tree(hominoidea_tree, tip-label-italics: true, orientation: "vertical")
```

#grid(
  columns: (1fr, 1fr),
  figure(
    render-tree(hominoidea_tree, tip-label-italics: true, width: 1fr, height: 21em),
    caption: [Tree with horizontal orientation],
    supplement: none,
  ),
  figure(
    render-tree(hominoidea_tree, tip-label-italics: true, width: 1fr, height: 21em, orientation: "vertical"),
    caption: [Tree with vertical orientation],
    supplement: none,
  ),

  align: center + bottom,
)

= Customizing visualizations

== Font selection

By default, `render-fasta` and `render-msa` inherit the monospaced font used for raw text in your document. To use a different font, wrap the rendering function in a `context` block with a custom font for raw text.

```typ
#let dna_msa = (
  "seq1": "AGTCTCAAGATAACTTTCGAAACAAACTTC",
  "seq2": "AGTTTCCAAGTGGATTTGGAATTGAACTTT",
  "seq3": "ACTCT-CGGATGGATTCGGATACAAACTTT",
  "seq4": "AGTCT---GATTGATGTGGATACAAACTTC",
  "seq5": "AGTCT--GGGTGGATTTGG-AACAAATTTT",
  "seq6": "CAGTGCTCCCTGGTGGTGG-ACCATCTTAC",
  "seq7": "AGTCTCAAGACGGATACTG--ATGCCCTAT",
)

#context {
  show raw: set text(font: "Maple Mono")
  render-msa(dna_msa)
}
```

#let dna_msa = (
  "seq1": "AGTCTCAAGATAACTTTCGAAACAAACTTC",
  "seq2": "AGTTTCCAAGTGGATTTGGAATTGAACTTT",
  "seq3": "ACTCT-CGGATGGATTCGGATACAAACTTT",
  "seq4": "AGTCT---GATTGATGTGGATACAAACTTC",
  "seq5": "AGTCT--GGGTGGATTTGG-AACAAATTTT",
  "seq6": "CAGTGCTCCCTGGTGGTGG-ACCATCTTAC",
  "seq7": "AGTCTCAAGACGGATACTG--ATGCCCTAT",
)

#grid(
  columns: (1fr, 1fr),
  figure(
    render-msa(dna_msa, breakable: false),
    caption: [Default document font for raw text],
    supplement: none,
  ),
  figure(
    context {
      show raw: set text(font: "Maple Mono", size: 8.5pt)
      render-msa(dna_msa, breakable: false)
    },
    caption: [Custom font (Maple Mono)],
    supplement: none,
  ),

  align: center + bottom,
)

Sequence logos and trees are rendered using the default document font, rather than the monospaced font for raw text. To specify a custom font sequence logos and trees, use a `show text` rule instead.

```typ
#context {
  show text: set text(font: "New Computer Modern")
  render-sequence-logo(dna_msa)
}
```

#grid(
  rows: (auto, auto),
  figure(
    render-sequence-logo(dna_msa),
    caption: [Default document font],
    supplement: none,
  ),
  figure(
    context {
      show text: set text(font: "New Computer Modern")
      render-sequence-logo(dna_msa)
    },
    caption: [Custom font (New Computer Modern)],
    supplement: none,
  ),

  align: center + bottom,
)

```typ
#let hominoidea_tree = parse-newick(read("/docs/data/hominoidea.nwk"))
#context {
  show text: set text(font: "New Computer Modern", size: 0.9em)
  #render-tree(hominoidea_tree, tip-label-italics: true)
}
```

#let hominoidea_tree = parse-newick(read("/docs/data/hominoidea.nwk"))

#grid(
  columns: (1fr, 1fr),
  figure(
    render-tree(hominoidea_tree, tip-label-italics: true, width: 1fr, orientation: "horizontal"),
    caption: [Default document font],
    supplement: none,
  ),
  figure(
    context {
      show text: set text(font: "New Computer Modern", size: 0.9em)
      render-tree(hominoidea_tree, tip-label-italics: true, width: 1fr, orientation: "horizontal")
    },
    caption: [Custom font (New Computer Modern)],
    supplement: none,
  ),

  align: center + bottom,
)

#bibliography("literature.yaml", style: "nature")
