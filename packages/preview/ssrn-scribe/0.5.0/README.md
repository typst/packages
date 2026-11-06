# Typst-Paper-Template

Following the official tutorial, I create a single-column paper template for general use. You can use it for papers published on SSRN etc.

## How to use

### Use as an template package

Typst integrated the template with their official package manager. You can use it as the other third-party packages.

You only need to enter the following command in the terminal to initialize the template.

```
typst init @preview/ssrn-scribe
```

If will generate a subfolder `ssrn-scribe` including the `main.typ` file in the current directory with the latest version of the template.

### Mannully use

1. Download the template or clone the repository.
2. generate your bibliography file using `.biblatex` and store the file in the same directory of the template.
3. modify the `main.typ` file in the subfolder `/template` and compile it.
   ***Note:* You should have `paper_template.typ` and `main.typ` in the same directory.**

In the template, you can modify the following parameters:

* Font: You can choose the font that you like. The default font is `Times New Roman`. You can also use Palatino by uncommenting the line `font: "palatino", // "Times New Roman"`
* Fontsize: You can choose the font size that you like. The default font size is `11pt`. You can also use `12pt` or `10pt` by uncommenting the line `fontsize: 12pt, // 11pt`
* Author: You can add as many authors as you like. But you need to include four parameters for each author: name, affiliation, email, and note within parentheses. If you don't have the information, you can leave it blank.

```
    (
    name: "",
    affiliation: "",
    email: "",
    note: "",
    ),
```

* Abstract: You can add your abstract with `[Your abstract]`.
* Acknowledgment: You can add your acknowledgment with `[Your `acknowledgment `]`.
* Bibliography: You can add your reference BibLaTex:
  ```
  bibliography: bibliography("bib.bib", title: "References", style: "apa"),
  ```

```
#import "@preview/ssrn-scribe:0.5.0": *

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

Here is a screenshot of the template:
![Example](https://minioapi.pjx.ac.cn/img1/2024/03/63ce084e2a43bc2e7e31bd79315a0fb5.png)
