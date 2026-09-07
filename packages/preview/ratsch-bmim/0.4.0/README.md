# ratsch-bmim

**ratsch-bmim** is a template for creating exams/practicals/... in [Typst](https://github.com/typst/typst) with the corporate design of [UMIT TIROL](https://www.umit-tirol.at/).

## Features

- Subset of predefined colors (see [colors.typ](src/colors.typ)).
- Variants:
    - article
    - exams
    - exercise
    - lecture
    - letter
    - poster
    - report
    - slides
    - workbook

## Example

See [Artifact](https://github.com/umit-iace/typst-umit-tirol-bmim/actions/) of last run for example variants:
- [example/article.typ](example/report.typ) for the corresponding article Typst file.
- [example/exam.typ](example/exam.typ) for the corresponding exam Typst file,
- [example/exercise.typ](example/exercise.typ) for the corresponding exercise Typst file.
- [example/lab.typ](example/lab.typ) for the corresponding report Typst file with self defined title block.
- [example/lecture.typ](example/lecture.typ) for the corresponding lecture notes Typst file.
- [example/letter.typ](example/letter.typ) for the corresponding letter Typst file.
- [example/poster.typ](example/poster.typ) for the corresponding poster Typst file.
- [example/report.typ](example/report.typ) for the corresponding report Typst file.
- [example/slides-longTitle.typ](example/slides-longTitle.typ) for the corresponding slide Typst file using differnt logos, activate progress animation with a huge number of authors and a long title, see [Github Pages](https://umit-iace.github.io/typst-umit-tirol-bmim) for an example output.
- [example/slides-shortTitle.typ](example/slides-shortTitle.typ) for the corresponding slide Typst file.
- [example/workbook.typ](example/workbook.typ) for the corresponding workbook Typst file.

## Usage

Create a new typst project based on this template locally.

```bash
% typst init @preview/ratsch-bmim
% cd ratsch-bmim
```

Or create a project on the typst web app based on this template.

## Fonts

Several fonts are used:
- Source Sans 3 for text in slides
- Source Serif 4 for body text
- Source Code Pro for code
- Bitstream Vera Sans for text in letter

To install these under arch linux:
  ```bash
  % yay -S adobe-source-sans-fonts adobe-source-serif-fonts adobe-source-code-pro-fonts otf-xcharter-math ttf-bitstream-vera
  ```

### Compile (and watch) example

```bash
% typst w ./example/<variant>.typ --root .
```

### Compile (and watch) your typst file

```bash
% typst w main.typ
```

This will watch your file and recompile it to a pdf when the file is saved.

### Install locally

- Store the package in `~/.local/share/typst/packages/local/ratsch-bmim/0.4.0`
- Import from it with `#import "@local/ratsch-bmim:0.4.0": *`

## License

The images logo_iace_\*/logo_umit_\*/background_\*/footer_umit_\* in the `assets` folder are the property of the UMIT TIROL.

The images logo_lfui_\* in the `assets` folder are the property of the University of Innsbruck.

The rest of the project is licensed under the [MIT License](LICENSE).
