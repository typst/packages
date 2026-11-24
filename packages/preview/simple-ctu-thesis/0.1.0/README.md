# Typst CTU Thesis

A Typst template for academic theses and reports at the Czech Technical University in Prague (CTU).

It is meant for semester projects, bachelor's theses, master's theses and similar assignments. It was written with the [FEE CTU regulations](https://intranet.fel.cvut.cz/cz/rozvoj/smerniceSZZ.pdf) and [CTUstyle](https://petr.olsak.net/ctustyle.html) in mind.

> This is an unofficial template. Check the requirements of your faculty and/or supervisor(s).

## Usage

```typst
#import "@preview/simple-ctu-thesis:0.1.0": thesis
```

A complete example is in [template/main.typ](./template/main.typ).

## Parameters

All parameters of `thesis()` are optional unless stated otherwise.

### General

| Parameter  | Type                     | Default | Notes                                                      |
| ---------- | ------------------------ | ------- | ---------------------------------------------------------- |
| `language` | `"cs"`, `"sk"` or `"en"` | `"en"`  | Sets text language, labels, and which abstract comes first |

### Title page

| Parameter       | Type                              | Default                | Notes                                                                                                                                               |
| --------------- | --------------------------------- | ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `thesis-type`   | `str`, `content`                  | `"Thesis type"`        |                                                                                                                                                     |
| `title`         | `dictionary` of `str`, `content`  | `(:)`                  | Keyed by language code, e.g. `(cs: "Název", en: "Title")`. Translations are printed under the matching abstract                                     |
| `author`        | `str`, `content`                  | `"Name of the author"` | Also used as PDF metadata                                                                                                                           |
| `faculty`       | `str`, `content`                  | `none`                 |                                                                                                                                                     |
| `department`    | `str`, `content`                  | `none`                 |                                                                                                                                                     |
| `study-program` | `str`, `content`                  | `none`                 |                                                                                                                                                     |
| `supervisors`   | `array` of `str`, or `str`        | `()`                   | Label is singular or plural automatically                                                                                                           |
| `logo`          | `content`                         | `none`                 | E.g. `image("logo.svg", width: 5cm)`                                                                                                                |
| `date`          | `auto`, `datetime`, `str`, `none` | `auto`                 | `auto` is today (changes on every compile). A `datetime` is shown as "Month Year" in the document language. A `str` is shown as is. `none` hides it |

### Front matter

| Parameter               | Type                             | Default | Notes                                                        |
| ----------------------- | -------------------------------- | ------- | ------------------------------------------------------------ |
| `assignment`            | `content`                        | `none`  | Inserted on its own page, e.g. as an image of the assignment |
| `declaration`           | `content`                        | `none`  | Inserted on its own page                                     |
| `abstract`              | `dictionary` of `content`        | `(:)`   | Keyed by language code, e.g. `(cs: [...], en: [...])`        |
| `keywords`              | `dictionary` of `array` of `str` | `(:)`   | Keyed by language code. Printed under the matching abstract  |
| `acknowledgements`      | `str`, `content`                 | `none`  |                                                              |
| `show-toc`              | `bool`                           | `true`  | Table of contents                                            |
| `list-of-figures`       | `bool`                           | `false` |                                                              |
| `list-of-tables`        | `bool`                           | `false` |                                                              |
| `list-of-abbreviations` | `array` of pairs                 | `()`    | E.g. `(("CTU", "Czech Technical University"),)`              |

### Main matter and back matter

| Parameter      | Type      | Default  | Notes                                                                                                     |
| -------------- | --------- | -------- | --------------------------------------------------------------------------------------------------------- |
| `body`         | `content` | required | Main text. Headings are numbered `1.1`, figures, tables and equations per chapter                         |
| `bibliography` | `content` | `none`   | A bibliography element, e.g. `bibliography("refs.bib")`. Pass `style:` to it to change the citation style |
| `appendices`   | `content` | `none`   | Headings are numbered `A.1`                                                                               |

## Notes

- **Figures, tables and listings** are numbered per chapter (`Figure 1.1`). If you render a figure and the autodetect doesn't recognize it, you may force the kind via `kind: image` to be numbered and listed:

  ```typst
  #figure(cetz.canvas(...), kind: image, caption: [...])
  ```

- **Listings** (`raw` figures) can break across pages. They do not appear in any list.

- **The assignment and declaration** can be passed as a PDF. `image()` embeds one page at a time, so for a multi-page PDF use a helper loop and pass the page count:

  ```typst
  #let pdf-pages(path, count) = for p in range(1, count + 1) {
    page(margin: 0pt, image(path, page: p, width: 100%))
  }

  #show: thesis.with(
    assignment: pdf-pages("assignment.pdf", 2),
    ...
  )
  ```

## Recipes

### Custom figure kind (for example, graphs)

Custom kinds are not handled by the template. Add the wiring on your own:

```typst
#show figure.where(kind: "graph"): set figure(supplement: [Graph])
#show heading.where(level: 1): it => {
  counter(figure.where(kind: "graph")).update(0)
  it
}
#outline(title: [List of Graphs], target: figure.where(kind: "graph"))
```

### Moving table caption above the table

```typst
#show figure.where(kind: table): set figure.caption(position: top)
```

### Boxed code blocks

```typst
#show raw.where(block: true): it => block(
  width: 100%,
  fill: luma(245),
  stroke: 0.5pt + luma(210),
  inset: 8pt,
  radius: 2pt,
  it,
)
```

### Shift heading levels of an included file

```typst
#[
  #set heading(offset: 1)
  #include "chapters/appendix-pinmap.typ"
]
```
