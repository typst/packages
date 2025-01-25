![GitHub Repo stars](https://img.shields.io/github/stars/ISC-HEI/isc-hei-report)
![GitHub Release](https://img.shields.io/github/v/release/ISC-HEI/isc-hei-report?include_prereleases)

<p align="center">
  <a href="https://hevs.ch/isc">
  <img src="https://user-images.githubusercontent.com/4624112/214764929-89aa8609-c540-4cc0-9905-23886814772e.png"/>    
  </a>
</p>

# ISC report template :scroll:

This is an official template for students reports for the [ISC degree programme](https://isc.hevs.ch/) at the School of engineering in Sion. 

## Using the template

In the Typst web application, start with the `isc-hei-report` and voilà ! Using the CLI, you can initialize the project with the command :

```bash
typst init @preview/isc-hei-report:0.1.0
```

This template will initialize an sample report with sensible default values.

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

Another nice possibility is of course to use a VScod[e | ium] via the `Typst LSP` plugin which enables direct compilation.

# Future changes

In the future, several things _might_ be updated, such as :

- [x] Acronyms inclusion
- [ ] Multiple languages (FR/EN)
- [ ] Nice tables examples
- [ ] State diagrams and UML diagrams examples
- [ ] Appendix
- [ ] Glossary inclusion
- [ ] Master thesis version of this template
- [ ] Themes for code
- [ ] Other nice things

# Questions and help

If you need any help for installing or running those tools, do not hesitate to get in touch with its maintainer [pmudry](https://github.com/pmudry).

You can of course also propose changes using PR or raise issues if something is not clear. Have fun writing reports!
