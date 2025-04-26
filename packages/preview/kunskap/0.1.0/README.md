# kunskap

A [Typst](https://typst.app/) template mainly intended for shorter academic
documents such as reports, assignments, course documents, and so on.  Its name,
_"kunskap"_, means _knowledge_ in Swedish.

See [this example
PDF](https://github.com/mbollmann/typst-kunskap/blob/main/example.pdf) for a
longer demonstration of how it looks.

## Usage

You can use this template in the Typst web app by clicking "Start from template"
on the dashboard and searching for `kunskap`.

Alternatively, you can use the CLI to kick this project off using the command

```sh
typst init @preview/kunskap
```

Typst will create a new directory with all the files needed to get you started.

## Configuration

This template exports the `kunskap` function with several arguments.  You will
want to set at least the following, describing the metadata of your document:

| Argument | Description |
| -------- | ----------- |
| `title`  | Title of your document |
| `author` | Author(s) of your document; can be any content, or an array of strings |
| `date`   | Date string to display below the author(s); defaults to a string of today's date, but can take any content.  Set to `none` if you don't use it at all. |
| `header` | Content that appears in the left-hand side of the header on every page; this is intended for e.g. the name of a course or some other contextual information for the document, but can of course also be left empty. |

Additionally, you can configure some aspects of the template's layout with the
following arguments:

| Argument | Description | Default |
| -------- | ----------- | ------- |
| `paper-size` | Paper size of the document | `"a4"` |
| `body-font` | Font for the body text | `"Noto Serif"` |
| `body-font-size` | Font size for the body text | `10pt` |
| `headings-font` | Font for the headings | `("Source Sans Pro", "Source Sans 3")` |
| `raw-font` | Font for raw (i.e. monospaced) text | `("Hack", "Source Code Pro")`[^1] |
| `raw-font-size` | Font size for raw text | `9pt` |
| `link-color` | Color for highlighting [links] | `rgb("#3282b8")` ![Color sample](https://img.shields.io/badge/steel_blue-3282b8) |
| `muted-color` | Color for muted text, such as page numbers and headers after the first page | `luma(160)` |
| `block-bg-color` | Color for the background of raw text | `luma(240)` |


The template will initialize your document with a sample call to the `kunskap` function.  Alternatively, here's a minimal example of how you could use this template in your document:

```typst
#import "@preview/kunskap:0.1.0": *

#show: kunskap.with(
    title: "Your report title",
    author: "Your name",
    date: datetime.today().display(),
    header: "Your course name",
)

#lorem(120)
```

## Missing features

As of now, this template has not yet been particularly optimized for styling related to:

- Bibliographies
- Outlines (e.g. table of contents)
- Tables


## Credits

This template started out by emulating the layout of course documents in [Marco
Kuhlmann](https://liu.se/en/employee/marku61)'s courses at Linköping University.[^2]
On the technical side, this template took a lot of inspiration from [the `ilm`
template](https://github.com/talal/ilm/), even if the design decisions may be
radically different.



[^1]: The [Hack font](https://github.com/source-foundry/Hack) is currently not
    available on the Typst web app, so the fallback is Source Code Pro.
[^2]: If you work at Linköping University, you can set `headings-font:
    "KorolevLiU"` to get a LiU-branded version of this template.

[links]: https://typst.app/docs/reference/model/link/
