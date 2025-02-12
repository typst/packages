# Typst-Paper-Template

Following the official tutorial, I create a single-column paper template for general use. You can use it for papers published on SSRN etc.

## How to use

### Use as a template package

Typst integrated the template with their official package manager. You can use it as the other third-party packages.

You only need to enter the following command in the terminal to initialize the template.

```bash
typst init @preview/ssrn-scribe
```

It will generate a subfolder `ssrn-scribe` including the `main.typ` and `extra.typ` files in the current directory with the latest version of the template.

#### Warning

Before version `0.6.0`, this template has integrated with some other packages for a wide range of use. However, to make the template more flexible, all integrated packages are removed.

**All the integrated packages have been saved in the `extra.typ` file and they have been imported to the `main.typ` file.**

If you do not want to use them, you can comment out the import statement in the `main.typ` file.

```typst
#import "extra.typ": *
#show: great-theorems-init
```

### Mannully use

1. Download the template or clone the repository.
2. generate your bibliography file using `.biblatex` and store the file in the same directory of the template.
3. modify the `main.typ` file in the subfolder `/template` and compile it.
   ***Note:* You should have `paper_template.typ`, `main.typ` and `extra.typ` in the same directory.**

In the template, you can modify the following parameters:

`maketitle` is a boolean (**compulsory**). If `maketitle=true`, the template will generate a new page for the title. Otherwise, the title will be shown on the first page.

- `maketitle=true`:

| Parameter           | Default    | Optional | Description                                                                                                |
| ------------------- | ---------- | -------- | ---------------------------------------------------------------------------------------------------------- |
| `font`            | "PT Serif" | Yes      | The font of the paper. You can choose "Times New Roman" or "Palatino"                                      |
| `fontsize`        | 11pt       | Yes      | The font size of the paper. You can choose 10pt or 12pt                                                    |
| `title`           | "Title"    | No       | The title of the paper                                                                                     |
| `subtitle`        | none       | Yes      | The subtitle of the paper, use "" or []                                                                    |
| `authors`         | none       | No       | The authors of the paper                                                                                   |
| `date`            | none       | Yes      | The date of the paper                                                                                      |
| `abstract`        | none       | Yes      | The abstract of the paper                                                                                  |
| `keywords`        | none       | Yes      | The keywords of the paper                                                                                  |
| `JEL`             | none       | Yes      | The JEL codes of the paper                                                                                 |
| `acknowledgments` | none       | Yes      | The acknowledgment of the paper                                                                            |
| `bibliography`    | none       | Yes      | The bibliography of the paper ``bibliography: bibliography("bib.bib", title: "References", style: "apa")`` |

- `maketitle=false`:

| Parameter        | Default    | Optional | Description                                                                                                |
| ---------------- | ---------- | -------- | ---------------------------------------------------------------------------------------------------------- |
| `font`         | "PT Serif" | Yes      | The font of the paper. You can choose "Times New Roman" or "Palatino"                                      |
| `fontsize`     | 11pt       | Yes      | The font size of the paper. You can choose 10pt or 12pt                                                    |
| `title`        | "Title"    | No       | The title of the paper                                                                                     |
| `subtitle`     | none       | Yes      | The subtitle of the paper, use "" or []                                                                    |
| `authors`      | none       | No       | The authors of the paper                                                                                   |
| `date`         | none       | Yes      | The date of the paper                                                                                      |
| `bibliography` | none       | Yes      | The bibliography of the paper ``bibliography: bibliography("bib.bib", title: "References", style: "apa")`` |

**Note: You need to keep the comma at the end of the first bracket of the author's list, even if you have only one author.**

```typst
    (
    name: "",
    affiliation: "", // optional
    email: "", // optional
    note: "", // optional
    ),
```

```typst
#import "@preview/ssrn-scribe:0.6.0": *

#show: paper.with(
  font: "PT Serif", // "Times New Roman"
  fontsize: 12pt, // 12pt
  maketitle: true, // whether to add new page for title
  title: [#lorem(5)], // title 
  subtitle: "A work in progress", // subtitle
  authors: (
    (
      name: "Theresa Tungsten",
      affiliation: "Artos Institute",
      email: "tung@artos.edu",
      note: "123",
    ),
  ),
  date: "July 2023",
  abstract: lorem(80), // replace lorem(80) with [ Your abstract here. ]
  keywords: [
    Imputation,
    Multiple Imputation,
    Bayesian,],
  JEL: [G11, G12],
  acknowledgments: "This paper is a work in progress. Please do not cite without permission.", 
  // bibliography: bibliography("bib.bib", title: "References", style: "apa"),
)
= Introduction
#lorem(50)

```

## Preview

### Example

Here is a screenshot of the template:
![Example](https://minioapi.pjx.ac.cn/img1/2024/03/63ce084e2a43bc2e7e31bd79315a0fb5.png)

### Example-brief with `maketitle=true`

![example-brief-true](https://minioapi.pjx.ac.cn/img1/2024/06/8d203bd7f2fbf20b39b33334f0ee4a36.png)

### Example-brief with `maketitle=false`

![example-brief-false](https://minioapi.pjx.ac.cn/img1/2024/06/83dd5821409031ce0a2c2a15e014cc60.png)
