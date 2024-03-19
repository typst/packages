# INSA - Typst Template
Typst Template for full documents and reports for the french engineering school INSA.

## Examples
### Report
By default, the template initializes with the `insa-report` show rule, with parameters that you must fill in by yourself.

Here is an example of filled template:
```typst
#import "@preview/silky-report-insa:0.1.0": *
#show: doc => insa-report(
  id: 3,
  pre-title: "STPI 2",
  title: "Interférences et diffraction",
  authors: [
    *LE JEUNE Youenn*

    *MAUVY Eva*
    
    Groupe D

    Binôme 5
  ],
  date: "11/04/2023",
  doc)

= Introduction
Le but de ce TP est d’interpréter les figures de diffraction observées avec différents objets diffractants
et d’en déduire les dimensions de ces objets.

= Partie théorique - Phénomène d'interférence
== Diffraction par une fente double
Lors du passage de la lumière par une fente double de largeur $a$ et de distance $b$ entre les centres
des fentes...
```

### Blank template
If you do not want the preformatted output with "TP x", the title and date in the header, etc. you can simply use
the `insa-full` show rule and customize all by yourself.

Here is an example:
```typst
#import "@preview/silky-report-insa:0.1.0": *
#show: doc => insa-full(
  cover-top-left: [*Document important*],
  cover-middle-left: [
    NOM Prénom

    Département INFO
  ],
  cover-bottom-right: "uwu",
  page-header: "En-tête au pif",
  doc
)
```

## Notes
This template is being developed by Youenn LE JEUNE from the INSA de Rennes in [this repostiory](https://github.com/SkytAsul/INSA-Typst-Template).

For now it includes assets from the INSA de Rennes graphic charter, but users from other INSAs can open an issue on the repository with the correct assets for their INSA.

If you have any other feature request, open an issue on the repository as well.

## License
This package is licensed with the [MIT license](https://github.com/SkytAsul/INSA-Typst-Template/blob/main/LICENSE).