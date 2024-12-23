# ieee-slovak
Typst Template for IEEE papers (two-column style) for use in Slovak language.
This is updated version of the 1st party [Typst template](https://github.com/typst/templates/tree/main/charged-ieee) for IEEE papers.

## Usage
You can download this template as `.typ` file or chose it as template in [Typst Universe](https://typst.app/universe).

## Configuration
You can use following arguments:

- `title`: The paper's title as content.
- `authors`: An array of author dictionaries. Each of the author dictionaries
  must have a `name` key and can have the keys `department`, `organization`,
  `location`, and `email`. All keys accept content.
- `abstract`: The content of a brief summary of the paper or `none`. Appears at
  the top of the first column in boldface.
- `abstract-name-slovak`: If `true`, the abstract will be labeled `"Abstrakt"` (default behaviour).
- `index-terms`: Array of index terms to display after the abstract. Shall be
  `content`.
- `index-terms-name-slovak`: If `true`, the index terms will be labeled `"Kľúčové slová"` (default behaviour).
- `paper-size`: Defaults to `us-letter`. Specify a [paper size
  string](https://typst.app/docs/reference/layout/page/#parameters-paper) to
  change the page format.
- `bibliography`: The result of a call to the `bibliography` function or `none`.
  Specifying this will configure numeric, IEEE-style citations.
- `bib-name`: The name of the bibliography section (default `"Literatúra"`).
- `figure-reference-supplement`: How figures are referred to from within the text (default `Obr.`).
- `table-reference-supplement`: How tables are referred to from within the text (default `Tabuľka`).
- `section-reference-supplement`: How sections are referred to from within the text (default `Sekcia`).
- `underline_links`: How links are displayed (default `2`).
    - `0` - underline no links
    - `1` - underline all links except for email of the authors and abstract / index terms
    - `2` - underline all links except for email of the authors
    - `3` - underline all links
