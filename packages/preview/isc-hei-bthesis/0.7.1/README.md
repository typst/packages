<p align="right">
    <img src="https://github.com/ISC-HEI/isc_logos/blob/ab8c41c12930c787f590183baa229a22709c81f9/black/ISC%20Logo%20inline%20black%20v3%20-%20large.webp?raw=true" align="right" alt="ISC Logo" height="50"/>
</p>

![GitHub Repo stars](https://img.shields.io/github/stars/ISC-HEI/isc-hei-report)
![GitHub Release](https://img.shields.io/github/v/release/ISC-HEI/isc-hei-report?include_prereleases)
![License](https://img.shields.io/badge/license-MIT-brightgreen")

# Bachelor Thesis Template for ISC Students

This is the official template for bachelor theses for the [ISC degree programme](https://isc.hevs.ch/) at the School of Engineering in Sion. It is part of the official templates repository, which also include templates for reports (`isc-hei-report`) and executive summaries (`isc-hei-exec-summary`).

<p align="center">
   <a href="https://github.com/ISC-HEI/isc-hei-typst-templates/blob/cf3c46b8f4dad96d6c023110f7fa7dd4ea90da13/examples/bachelor_thesis.pdf?raw=true"><img src="bachelor_thesis_thumb.png" alt="Bachelor Thesis" height="300"></a>  
</p>

## Using the Template on the Web

In the `Typst` web application, start a new project with the `isc-hei-bthesis` template and voilà!

## Using the Template in Your Shell

First, install `Typst` on your machine by following the [official instructions](https://github.com/typst/typst).

### Installing Fonts Locally

If you are running `typst` locally, you might be missing some required fonts. For your convenience, a font download script is included in the repository. All fonts are released under the [SIL Open Font License](https://openfontlicense.org/), so there are no file inclusion issues.

To install the fonts locally on a Linux environment, simply type:

```bash
source install_fonts.sh
```

from within the `fonts` directory.

### Project Initialization and Compilation

You can initialize the project with the command:

```bash
typst init @preview/isc-hei-bthesis
```

If you need a specific template version, use:

```bash
typst init @preview/isc-hei-bthesis:0.5.0
```

## Including PDF Images

Unfortunately, `typst` does not support PDF file inclusion at the time of writing this documentation. As a temporary workaround, PDF files can be converted to SVG using `pdf2svg`.

# Usage

When used locally, creating a PDF is straightforward with the command:

```bash
typst compile bachelor_thesis.typ
```

Even better, the following command compiles the report every time the file is modified:

```bash
typst watch bachelor_thesis.typ
```

You can also use `VSCode` or `VSCodium` with the `Typst LSP` plugin, which enables direct compilation.

# Questions and Help

If you need any help installing or running these tools, do not hesitate to contact the maintainer [pmudry](https://github.com/pmudry).

You can also propose changes using pull requests or raise issues if something is unclear. Have fun writing your reports!
