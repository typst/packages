# ost-thesis

A thesis template in the visual style of the OST Eastern Switzerland
University of Applied Sciences. It provides a styled title page, running
headers, automatic numbering, a table of contents, helper functions for tables,
and ready-made chapter and appendix scaffolding.

## Usage

Create a new project from the template:

```sh
typst init @preview/ost-thesis
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
| `.fonts/`     | Bundled Roboto font (see below)                 |

## Languages

Set the document language in `main.typ` via the `lang` argument (`"en"` or
`"de"`). Role labels on the title page are translated automatically.

## Fonts

The template uses **Roboto**, bundled in `.fonts/`, and falls back to the
built-in _Libertinus Serif_ if Roboto is unavailable.

- **Typst web app:** fonts in the project are picked up automatically.
- **Command line:** the Typst CLI does not auto-load project fonts. To get the
  exact look, point it at the bundled fonts:

  ```sh
  typst compile --font-path .fonts main.typ
  ```

  Alternatively, install Roboto system-wide.

## License

MIT
