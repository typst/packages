# ost-ifs-thesis

A thesis template for the
[IFS Institute for Software](https://www.ost.ch/en/research-and-consulting-services/computer-science/ifs-institute-for-software)
at OST Eastern Switzerland University of Applied Sciences, using the OST visual
style. It provides a styled title page, running headers, automatic numbering, a
table of contents, helper functions for tables, and ready-made chapter and
appendix scaffolding.

This is an IFS template, not an official OST-wide template. It is endorsed and
maintained by the IFS Institute for Software.

## Usage

Create a new project from the template:

```sh
typst init @preview/ost-ifs-thesis
```

Then edit `meta.typ` to set your title, authors, and advisors, and write your
content in `chapters/`.

## Structure

| File / folder | Purpose                                         |
| ------------- | ----------------------------------------------- |
| `main.typ`    | Entry point that wires everything together      |
| `meta.typ`    | Title, subtitle, authors, advisors, thesis type |
| `chapters/`   | One file per chapter and appendix               |
| `refs.yaml`   | Bibliography in Hayagriva format                |
| `figures/`    | Your own images and figures                     |

## Languages

Set the document language in `main.typ` via the `lang` argument (`"en"` or
`"de"`). Role labels on the title page are translated automatically.

## Fonts

The template uses **Roboto** and falls back to the built-in _Libertinus Serif_
if Roboto is unavailable. Font files are **not** bundled (typst/packages does
not allow it), so download Roboto first — paste both commands at once:

```sh
curl -L --create-dirs -o .fonts/Roboto/Roboto.ttf \
  "https://raw.githubusercontent.com/google/fonts/main/ofl/roboto/Roboto%5Bwdth%2Cwght%5D.ttf"
curl -L --create-dirs -o .fonts/Roboto/Roboto-Italic.ttf \
  "https://raw.githubusercontent.com/google/fonts/main/ofl/roboto/Roboto-Italic%5Bwdth%2Cwght%5D.ttf"
```

These are the official Roboto variable fonts (SIL Open Font License): two files
that together cover every weight plus true italics. (The first line alone is
enough if you don't need italics.)

- **Typst web app:** fonts placed in the project are picked up automatically.
- **Command line:** the Typst CLI does not auto-load project fonts, so point it
  at the folder:

  ```sh
  typst compile --font-path .fonts main.typ
  ```

  Alternatively, install Roboto system-wide. Without it, the template falls back
  to Libertinus Serif.

## License

MIT
