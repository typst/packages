# solo-lu-df

A Typst template to write qualification papers, bachelor’s theses, and master’s
theses for Latvijas Universitāte (Faculty of Science and Technology).
The package provides university-compliant layout rules, helpers for
title/abstract/attachments, and a ready-to-edit example.

## Usage

Use the template in the Typst web app by clicking "Start from template" and
searching for `solo-lu-df`, or initialize a new project with the CLI:

```sh
typst init @preview/solo-lu-df
```

Typst will create a new directory with the files needed to get started.

## Configuration

This template exports the `ludf` function which accepts named arguments to
configure the whole document and `attachment` helper function. Important arguments:

- `title`: Document title (content).
- `authors`: Array of author dictionaries. Each author must have `name` and
  `code` and may include `location` and `email`.
- `advisors`: Array of advisor dictionaries with `title` and `name`.
- `reviewer`: Reviewer dictionary with `name`.
- `thesis-type`: e.g., `"Bakalaura darbs"`, `"Kvalifikācijas Darbs"`.
- `date`: `datetime(...)` value for the thesis date. Defaults to `today`.
- `place`: Place string (e.g., `"Rīga"`).
- `abstract`: A record with `primary` and `secondary` abstracts. Each has
  `text` (content) and `keywords` (array) as well as `title`, `lang` and `keyword-title`.
- `bibliography`: Result of `bibliography("path/to/file.yml")` or `none`.
- `attachments`: Tuple of `attachment(...)` items (tables, figures).
- Positional argument: the document body follows the `ludf.with(...)` call.

The function also accepts a single, positional argument for the body of the paper.

The template will initialize your package with a sample call to the `ludf`
function in a show rule. If you want to change an existing project to use this
template, you can add a show rule like this at the top of your file:

```typst
#import "@preview/solo-lu-df:0.1.0": *

#show: ludf.with(
  title: "Darba Nosaukums",
  authors: (
    (name: "Jānis Bērziņš", code: "jb12345", email: "jb12345@edu.lu.lv"),
  ),
  advisors: (
    (title: "Mg. dat.", name: "Ivars Ozoliņš"),
  ),
  date: datetime(year: 2025, month: 1, day: 1),
  place: "Rīga",
  bibliography: bibliography("bibliography.yml"),
  abstract: (
    primary: (text: [ Anotācijas teksts... ], keywords: ("Foo", "Bar")),
    secondary: (text: [ Abstract text... ], keywords: ("Foo", "Bar")),
  ),
  attachments: (
    attachment(
      caption: "Attachment table",
      label: <table-1>,
      table(
        columns: (1fr, 1fr),
        [Column 1], [Column 2],
      ),
),
)

// Your content goes below.
```

## Examples

A ready-to-edit qualification thesis example is included in the repository:

View the example on GitHub: <https://github.com/kristoferssolo/LU-DF-Typst-Template/tree/main/examples/qualification-thesis>

The example contains `main.typ`, `bibliography.yml` and small helpers under
    ),
`utils/`. Use it as a starting point or copy it into a new project.

## Tips

- Install the fonts used by the template (Times family, JetBrains Mono) to
  reproduce exact layout, or change font names in `src/lib.typ`. You can
  override font by setting [text font](https://typst.app/docs/reference/text/text#parameters-font) to your desired one.
- Bibliography: use Typst's `bibliography(...)` call with a YAML or Bib file.
- Diagrams: the example imports the fletcher package and includes small
  helpers under `examples/.../utils/`, but you can also use exported
    images from draw.io (diagrams.net) or any other diagram editor.

## License

This project is licensed under the MIT-0 License - see the [LICENSE](./LICENSE) file for details.
