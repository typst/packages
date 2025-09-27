# orionotes

Orionotes is a minimal Typst template used take and publish notes of lectures of the astrophysics degree at University of Turin.
It is structured as a book and is thought for a complete course. Its intent is only to provide an appealing layout, so no internal environment is provided leaving to the writer the choice.

## Features

- Customizable document metadata (title, author)
- Customizable (with automatic default) table of contents
- Front page image
- Preface, appendices and bibliography

## Installation

You can use this template in the Typst web app by clicking "Start from template" on the
dashboard and searching for `orionotes`.

Alternatively, you can use the CLI to initialize this project using the command:

```sh
typst init @preview/orionotes
```

## Usage
1. Open the `main.typ` file
2. Customize the configuration
3. Write the content at the bottom of the file
4. Run the Typst compiler:
```sh
typst compile main.typ
```

## Configuration

This template exports the `orionotes` function with the following named arguments:
| Argument | Default Value | Type | Description |
| --- | --- | --- | --- |
| `language` | `en` | [string] | The language code of the work. |
| `title` | `Course title` | [content] | The title of the work. |
| `authors` | `("Student 1", )` | [array] | An array of strings containing the authors' names. |
| `professors` | `("Professor 1", )` | [array] | An array of strings containing the professors' names. |
| `university` | `University of Turin UniTo` | [content] | The university where the course took place. Set to `none` to disable. |
| `degree` | `Master degree in Astrophysics` | [content] | The degree of the course. Set to `none` to disable. |
| `date` | `Academic Year` | [string] | The date string to display. |
| `pre-authors` | `(sing:"Author", plur:"Authors")` | [dictionary] | What to write before the authors. There should be an alternative for just one author (in `sing`) and multiple authors (in `plur`). The semicolon is not needed. |
| `pre-professors` | `(sing:"Professor", plur:"Professors")` | [dictionary] | What to write before the professors. There should be an alternative for just one professor (in `sing`) and multiple professors (in `plur`). The semicolon is not needed. |
| `top-section-name` | `Chapter` | [string] | The typographic name of level 1 section. Used to display the chapters. |
| `front-image` | `none` | [content] | The image to be shown on the first page. Set to `none` to disable. |
| `preface` | `none` | [content] | The preface of the notes. The preface content is shown on its own separate page after the cover. Set to `none` to disable. |
| `table-of-contents` | `outline()` | [content] | The function to show the table of contents. Set to `none` to disable. |
| `appendix` | `(enabled: false, title: "", body: none)` | [dictionary] | Setting `enabled` to `true` and defining your content in `body` will display the appendix after the main body of your document and before the bibliography. |
| `bib` | `none` | [content] | The bibliography. Should be a call to `bibliography` (e.g. `bibliography("example.bib")`) or `none` |
