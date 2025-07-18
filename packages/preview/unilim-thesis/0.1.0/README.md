# Typst Template for Unilim thesis

## Key Features
- **Two versions**: french and english
- **Cover (+ footer)** of the University of Limoges
- **Standard document structure** (cover, epigraphy, Acknowledgements, tables, body, conclusion, bibliography, appendix)
- **Titles** in University of Limoges format
- **Examples** (image, table, pseudocode, math formula, bibliography)

## Demo

<img src="https://raw.githubusercontent.com/kawiluca/unilim-thesis/refs/heads/main/0.1.0/asset/thumbail.png" width="50%">


See [french version](./preview/preview_fr.pdf)

See [english version](./preview/preview_en.pdf)

## Installation

### From typst univers

In your project directory, initialize the project
```sh
$ typst init @preview/unilim-thesis:0.1.0 my_manuscript
$ typst compile my_manuscript/main.typ
```

### From local version 

---
LINUX - Installing the template
```sh
~$ mkdir -p ".local/share/typst/packages/local"
~$ git clone https://github.com/kawiluca/unilim-thesis.git ./local/share/typst/local
```

In your project directory, initialize the project
```sh
$ cd <your project directory>
$ typst init @local/unilim-thesis:0.1.0 my_manuscript
$ typst compile my_manuscript/main.typ
```
---
Windows - Installing the template
```sh
~$ mkdir "%LOCALAPPDATA%/typst/packages/local"
~$ git clone https://github.com/kawiluca/unilim-thesis.git "%LOCALAPPDATA%/typst/packages/local"
```

In your project directory, initialize the project
```sh
$ cd <your project directory>
$ typst init @local/unilim-thesis:0.1.0 my_manuscript
$ typst compile my_manuscript/main.typ
```

## Usage

To modify the template, you need to edit the `template.yml` file. The epigraphy, glossary, and appendix can be disabled (in the `template.yml` file). The epigraphy can be modified in the `main.typ` file.

## Tips for generating a bibliography
Use the free tool Zotero during your literature review to collect and organize your sources. Once your library is ready, you can export it in BibLaTeX format (.bib), which can be easily included in your Typst file.

## Resources

[Official MS Word & Latex Templates](https://support.unilim.fr/publications-et-redaction/depot-et-modeles-de-documents/telecharger-un-modele-de-document/) from the Limoges' University

## Contributing

If you would like to contribute to this project, I appreciate bug reports as issues, and I am happy to review pull requests, especially for new layout types. **If you use this template for your manuscript, please add a star to this github repository.**