# ratsch-bmim

**ratsch-bmim** is a template for creating exams/practicals/... in [Typst](https://github.com/typst/typst) with the corporate design of [UMIT TIROL](https://www.umit-tirol.at/).

## Features

- **Admonitions** (with localization and plural support).
- Subset of predefined colors (see [colors.typ](src/colors.typ)).
- Variants:
    - exams
    - exercise
    - lab
    - lecture
    - poster
    - report
    - slides
    - workbook

## Example

See [Artifact](https://github.com/umit-iace/typst-umit-tirol-bmim/actions/) of last run for example variants:
- [example/exam.typ](example/exam.typ) for the corresponding exam Typst file,
- [example/exercise.typ](example/exercise.typ) for the corresponding exercise Typst file.
- [example/lab.typ](example/lab.typ) for the corresponding laboratory Typst file.
- [example/lecture.typ](example/lecture.typ) for the corresponding lecture notes Typst file.
- [example/poster.typ](example/poster.typ) for the corresponding poster Typst file.
- [example/report.typ](example/report.typ) for the corresponding report Typst file.
- [example/slides.typ](example/slides.typ) for the corresponding slide Typst file, see [Github Pages](https://umit-iace.github.io/typst-umit-tirol-bmim) for an example output.
- [example/workbook.typ](example/workbook.typ) for the corresponding workbook Typst file.

## Usage

Create a new typst project based on this template locally.

```bash
typst init @preview/ratsch-bmim
cd ratsch-bmim
```

Or create a project on the typst web app based on this template.

### Compile (and watch) example

```bash
typst w ./example/<variant>.typ --root .
```

### Compile (and watch) your typst file

```bash
typst w main.typ
```

This will watch your file and recompile it to a pdf when the file is saved.

### Install locally

- Store the package in `~/.local/share/typst/packages/local/ratsch-bmim/0.2.0`
- Import from it with `#import "@local/ratsch-bmim:0.2.0": *`
