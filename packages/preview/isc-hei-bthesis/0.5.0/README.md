![GitHub Repo stars](https://img.shields.io/github/stars/ISC-HEI/isc-hei-report)
![GitHub Release](https://img.shields.io/github/v/release/ISC-HEI/isc-hei-report?include_prereleases)
![License](https://img.shields.io/badge/license-MIT-brightgreen")
  
<p align="center">
  <a href="https://hevs.ch/isc">    
  <img src="https://github.com/ISC-HEI/isc_logos/blob/4f8d335f7f4b99d3d83ee579ef334c201a15166a/ISC%20Logo%20inline%20v1.png?raw=true" width="50%"/>        
</p>

# ISC templates :scroll:

This is the official templates for reports and bachelors thesis for the [ISC degree programme](https://isc.hevs.ch/) at the School of engineering in Sion. 

An example of a generated report can be [accessed here](https://github.com/ISC-HEI/isc-hei-report/blob/master/examples/report.pdf?raw=true).
An example of a generated bachelor theis can be [accessed here](https://github.com/ISC-HEI/isc-hei-report/blob/master/examples/bachelor_thesis.pdf?raw=true).

## Using the template, on the Web

In the `Typst` web application, start with the `isc-hei-report` and voilà ! 

## Using the template in your shell
First start by installing `Typst` on your machine. You can then initialize the project with the command :

```bash
typst init @preview/isc-hei-report
```

This template will initialize an sample report with sensible default values.

For the latest template for a bachelor thesis, use: 

```bash
typst init @preview/isc-hei-bthesis
```

or if you need a specific version, use:

```bash
typst init @preview/isc-hei-bthesis:0.5.0

## Installing fonts locally

If you are running `typst` locally, you might miss some of the required fonts. For your convenience, a font download script is included in this repos. As all the fonts are released under the [SIL Open Font License](https://openfontlicense.org/), there are no file inclusion issues here.

To the install the fonts locally in a Linux environment, simply type

```bash
source install_fonts.sh
```

from within the `fonts` directory.

## PDF images inclusion

Unfortunately, `typst` does not support PDF file types inclusion at the time of writing this documentation. As a temporary workaround, PDF files can be converted to SVG via `pdf2svg`.

# Usage

When used locally, creating a PDF is straightforward with the command

```bash
typst compile report.typ
```

Even nicer, the following command compiles the report every time the file is modified.

```bash
typst watch report.typ
```

Another nice possibility is of course to use VScod(e | ium) via the `Typst LSP` plugin which enables direct compilation.

# Future changes

In the future, several things _might_ be updated, such as :

- [x] Cleaning-up of user experience when writing a thesis or a report
- [x] Master thesis version of this template
- [x] Glossary inclusion
- [x] Themes for code
- [x] Appendix
- [x] Acronyms inclusion
- [x] Basic support for including code files

# Questions and help

If you need any help for installing or running those tools, do not hesitate to get in touch with its maintainer [pmudry](https://github.com/pmudry).

You can of course also propose changes using PR or raise issues if something is not clear. Have fun writing reports!
