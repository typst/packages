# UWA Thesis Template

A [Typst](https://typst.app) template for UWA School of Engineering theses/research project reports.

## Usage

Import the template and pass your document's metadata to `uwa-thesis.with(...)`, then use `#show:` to apply it to the rest of the document:

```typ
#import "@preview/uwa-thesis:0.1.0": uwa-thesis

#show: uwa-thesis.with(
  unit-code: "GENG5512",
  title: "My Long Thesis Title",
  short-title: "My Thesis",
  authors: (
    (
      name: "John Doe",
      email: "123456789@student.uwa.edu.au",
      department: "School of Engineering, The University of Western Australia",
    ),
    (
      name: "Professor Jimbo James",
      email: "jimbo.james@uwa.edu.au",
      department: "School of Engineering, The University of Western Australia",
    ),
  ),
)

= Abstract
Here's my content, already styled by the template.
```

Everything written after the `#show:` line is treated as the body of the thesis and will be automatically formatted (title page, table of contents, headings, page numbering, etc.).

### Parameters

| Parameter    | Type   | Required | Description                                                                 |
| ------------ | ------ | -------- | ----------------------------------------------------------------------------- |
| `unit-code`  | string | Yes      | Unit code shown on the title page (e.g. `"GENG5512"`).                        |
| `title`      | string | Yes      | Full thesis title, shown on the title page.                                   |
| `short-title`| string | Yes      | Shortened title used in the page header of the body.                          |
| `authors`    | array  | Yes      | Array of author dictionaries (see below). Can be empty to omit the section.   |
| `date`       | string | No       | Defaults to today's date, formatted as `"[day] [month], [year]"`.             |

Each entry in `authors` is a dictionary with:

- `name` — author's full name
- `email` — author's email address (optional, set to `none` to omit)
- `department` — author's department/affiliation

### Document structure

The template automatically generates, in order:

1. **Title page** — unit code, title, date, word count, authors, and institution, numbered separately (no visible numbering).
2. **Table of Contents**, **List of Figures**, and **List of Tables** — generated from headings and figures, using lowercase roman numeral page numbers.
3. **Body content** — everything below the `#show:` line, using arabic page numbers starting at 1, with `short-title` shown in the top-right header.

Headings are auto-numbered (e.g. `1`, `1.1`), and the word count (shown on the title page) excludes headings, outlines, tables, and images.

A typical body follows the structure in [main.typ](main.typ):

```typ
= Abstract
...

= Acknowledgements
...

#pagebreak()

= Introduction
= Literature Review
= Project Objectives
= Project Process
= Results and Discussion
= Conclusions and Future Work
= References
= Appendicies
```

### Figures and tables

Use standard Typst `figure` blocks — they're automatically picked up by the List of Figures / List of Tables outlines:

```typ
#figure(
  image("assets/img.jpeg"),
  caption: [This is a picture caption],
)

#figure(
  table(
    columns: 3,
    align: (left, right, left),
    [*Parameter*], [*Value*], [*Unit*],
    [Noise density], [0.8], [mm/s\^2],
  ),
  caption: "A test table",
)
```

Place image assets (e.g. `img.jpeg`) in the [assets/](assets/) folder and reference them with a path like `"assets/img.jpeg"`.

## Compiling

Compile with the Typst CLI:

```sh
typst compile main.typ
```

Or use the Typst preview/watch mode for live editing:

```sh
typst watch main.typ
```
