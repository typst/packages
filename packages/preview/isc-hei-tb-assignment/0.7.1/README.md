<p align="right">
    <img src="https://github.com/ISC-HEI/isc_logos/blob/ab8c41c12930c787f590183baa229a22709c81f9/black/ISC%20Logo%20inline%20black%20v3%20-%20large.webp?raw=true" align="right" alt="ISC Logo" height="50"/>
</p>

![GitHub Repo stars](https://img.shields.io/github/stars/ISC-HEI/isc-hei-report)
![GitHub Release](https://img.shields.io/github/v/release/ISC-HEI/isc-hei-report?include_prereleases)
![License](https://img.shields.io/badge/license-MIT-brightgreen")

# TB Assignment Sheet Template for ISC

This is the official template for the bachelor thesis assignment sheet (*Donnée du travail de bachelor*) for the [ISC degree programme](https://isc.hevs.ch/) at the School of Engineering in Sion. It is part of the official templates repository, which also includes templates for bachelor theses (`isc-hei-bthesis`), reports (`isc-hei-report`) and executive summaries (`isc-hei-exec-summary`).

This document is **filled in by the professor**, not by the student. Once compiled to PDF, it should be included in the student's bachelor thesis document.

<p align="center">
  <a href="https://github.com/ISC-HEI/isc-hei-student-templates/blob/b9c87c26cf53548c2a6a7a1656751b3546ca3db7/examples/tb_assignment.pdf?raw=true"><img src="tb_assignment_thumb.png" alt="Thesis assignment" height="300"></a>
</p>

## Using the Template in Your Shell

First, install `Typst` on your machine by following the [official instructions](https://github.com/typst/typst).

### Installing Fonts Locally

If you are running `typst` locally, you might be missing some required fonts. For your convenience, a font download script is included in the repository. All fonts are released under the [SIL Open Font License](https://openfontlicense.org/), so there are no file inclusion issues.

To install the fonts locally on a Linux environment, simply type:

```bash
./fonts/install_fonts.sh
```

### Compiling

```bash
typst compile tb_assignment.typ
```

## Embedding in the Bachelor Thesis

Once the professor has compiled `tb_assignment.typ` to `tb_assignment.pdf`, the student includes it in their `bachelor_thesis.typ` using:

```typst
#cleardoublepage()
#image("pages/tb_assignment.pdf")
```