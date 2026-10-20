# Meliora

An MLA-style student paper template for Typst. Features double-spaced body text, one-inch margins, first-line paragraph indentation, student-paper headings, running headers with the author's surname and page number, and MLA-style figures, tables, and Works Cited pages.

## Usage

```typst
#import "@preview/meliora:0.1.0"

#show: meliora.report.with(
  title: "The Cultural Life of Whales",
  author: "Alex Morgan",
  professor: "Professor Jane Wilson",
  course: "ENGL101: Introduction to Literature",
  date: datetime(year: 2026, month: 10, day: 6),
  bibliography: "refs.bib",
)

= Heading

Your content here.

== Subsection

More content here.

#figure(
  image("whale.jpg"),
  caption: [Humpback whale in the Pacific Ocean.],
)
```

## Parameters

| Parameter       | Default             | Description                                                                                                             |
| --------------- | ------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `title`         | `none`              | Paper title. Appears centered at the beginning of the paper.                                                            |
| `author`        | `none`              | Author name. Used in the heading block and running header.                                                              |
| `professor`     | `none`              | Instructor's name. Appears in the heading block.                                                                        |
| `course`        | `none`              | Course name or number. Appears in the heading block.                                                                    |
| `date`          | `none`              | Submission date. Pass a `datetime` value, e.g. `datetime.today()` or `datetime(year: 2026, month: 10, day: 6)`.         |
| `paper-size`    | `"us-letter"`       | Paper size. Any Typst paper size string, e.g. `"us-letter"` or `"a4"`.                                                  |
| `language`      | `"en"`              | Document language. Any ISO 639-1 code, e.g. `"en"`, `"de"`, or `"fr"`.                                                  |
| `font-face`     | `Liberation Serif`              | Base font face.                                                                                                         |
| `font-size`     | `12pt`              | Base font size.                                                                                                         |
| `line-height-ratio` | `1.6`                 | Line height.                                          |

## Bibliography

Insert a bibliography using the standard Typst function call

```typst
#bibliography("refs.bib")
```

The template automatically formats the bibliography using Typst's MLA bibliography style and labels the section **Works Cited**.

Citations can then be made using Typst's normal citation syntax:

```typst
Whales have played an important role in human culture. @carter2019[42--44]
```

## Figures

Figures follow MLA conventions, with the figure displayed first and its label and caption below it:

```typst
#figure(
  image("whale.jpg"),
  caption: [Humpback whale in the Pacific Ocean.],
)
```

This produces a figure in the form:

```text
[image]

Fig. 1. Humpback whale in the Pacific Ocean.
```

Captionless figures are also supported.

## Tables

Tables follow MLA conventions, with the table number and title appearing above the table:

```typst
#figure(
  table(
    columns: 2,
    [Species], [Average length],
    [Humpback whale], [12–16 m],
    [Blue whale], [24–30 m],
  ),
  caption: [Average length of selected whale species.],
)
```

The resulting table places the Table label and caption above the table.

## Block Quotations

Long quotations are formatted as block quotations, with the appropriate indentation and spacing:

```typst
#quote[
  Your quotation goes here. Longer quotations can be
  presented as a separate block without quotation marks.
]
```

## Headings

The template supports Typst's normal heading syntax:

```typst
= First Section

== Subsection

=== Subsection
```

## Running Header

The template automatically places the author's surname and page number in the upper-right corner of each page, following MLA student-paper conventions.

For authors with multiple surnames, surname particles, or suffixes, the template handles the name formatting used in the running header separately from the author's full name in the heading block.

## Default Font

By default, the template uses Liberation Serif.

To use a different font, pass it as a parameter:

```typst
#show: meliora.report.with(
  title: "My Paper",
  font-face: "Times New Roman",
)
```

The selected font must be installed and available to Typst.

## License

Copyright © 2026 Haydn Trowell.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.
