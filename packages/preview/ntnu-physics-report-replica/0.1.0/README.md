# ntnu-physics-report-replica
A Typst template for physics lab reports at NTNU (Norwegian University of Science and Technology). Based on the LaTeX elsarticle template traditionally used at NTNU's Department of Physics.

## Usage
You can use this template in the Typst web app by clicking "Start from template" on the dashboard and searching for `ntnu-physics-report-replica`.

Alternatively, you can use the CLI to kick this project off using the command
```
typst init @preview/ntnu-physics-report-replica
```

Typst will create a new directory with all the files needed to get you started.

## Configuration
This template exports the `ntnu-report` function with the following named arguments:

- `title`: The report's title as content.
- `authors`: An array of author dictionaries. Each author dictionary must have a `name` key and an `affiliations` key (array of affiliation indices, 1-indexed).
- `affiliations`: An array of affiliation strings.
- `supervisor`: The name of the supervisor or `none`.
- `abstract`: The content of the abstract ("Sammendrag") section.
- `bibliography-file`: Path to a `.bib` file or `none`.
- `two-column`: Whether to use two-column layout. Defaults to `true`.

The template also provides table helper functions:
- `toprule`: Thick horizontal line for table headers
- `midrule`: Thin horizontal line for separating header from content
- `bottomrule`: Thick horizontal line for table footer

### Example
```typ
#import "@preview/ntnu-physics-report-replica:0.1.0": *

#show: ntnu-report.with(
  title: "Tittel på rapporten",
  authors: (
    (name: "Ditt Navn", affiliations: (1,)),
    (name: "Medstudent", affiliations: (1,)),
  ),
  affiliations: (
    "Institutt for fysikk, NTNU, N-7491 Trondheim, Norway.",
  ),
  supervisor: "Veileders Navn",
  abstract: [
    Her skriver du et sammendrag av rapporten.
  ],
  two-column: true,
)

= Innledning
Her begynner rapporten...

= Teori
Svingetiden til en pendel:
$ T = 2 pi sqrt(l / g) $ <svingetid>

= Metode og apparatur
// ...

= Resultat og diskusjon
#figure(
  table(
    columns: 3,
    align: center,
    toprule,
    [$l$ (m)], [$T$ (s)], [$g$ (m/s²)],
    midrule,
    [0,50], [1,42], [9,80],
    bottomrule,
  ),
  caption: [Måleresultater.],
  kind: table,
)

= Konklusjon
// ...
```

## License
MIT License
