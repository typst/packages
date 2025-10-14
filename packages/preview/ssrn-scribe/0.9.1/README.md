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

Additional layout controls (all optional):
- `author-columns`, `author-alignment` *(both modes)*: enforce a fixed column count and per-column alignment for the author grid (defaults auto-detect reasonable settings).
- `cover-title-size`, `cover-subtitle-size`, `cover-author-name-size` *(maketitle=true only)*: change the typography of the cover title block directly from the `paper.with` call.
- `cover-spacing` *(maketitle=true only)*: main vertical spacing unit between stacked elements (title → subtitle → authors → meta).
- `cover-author-gutter`, `cover-author-row-gap` *(maketitle=true only)*: adjust horizontal and vertical spacing between author blocks on the cover.
- `cover-text-width`, `cover-line-leading`, `cover-paragraph-spacing` *(maketitle=true only)*: control the width, line height, and paragraph spacing of the abstract/keywords/JEL block.
- `frontmatter-gap` *(both modes)*: extra spacing between abstract, keywords, and JEL sections.
- `inline-title-size`, `inline-subtitle-size`, `inline-author-name-size` *(maketitle=false only)*: mirror the cover typography when the title stays on the first page.
- `inline-author-gutter`, `inline-author-row-gap` *(maketitle=false only)*: tweak spacing for inline author lists.
- `body-line-leading`, `body-paragraph-spacing`, `body-text-spacing` *(both modes)*: fine-tune the main text’s readability globally.

Author notes and acknowledgments on the cover are rendered as left-aligned footnotes with consistent marker spacing.

Full configuration example with inline comments:

```typst
#import "@preview/ssrn-scribe:0.9.0": *

#show: paper.with(
  // Core typography (applies to body in both modes)
  font: "PT Serif",                 // main document font family
  fontsize: 11pt,                   // main document font size
  body-text-spacing: 106%,          // character width spacing in main text
  body-line-leading: 1.32em,        // line height in the main text
  body-paragraph-spacing: 0.7em,    // space between paragraphs in main text

  // Title-page switch
  maketitle: true,                  // true → dedicated cover page, false → inline title

  // Metadata & title block
  title: [Your Title Here],         // document title
  subtitle: "Optional subtitle",    // optional subtitle
  date: "February 2025",            // version/date line
  acknowledgments: "Funding note.", // rendered as a footnote on the title

  // Cover-page only styling (ignored when maketitle=false)
  cover-title-size: 20pt,           // cover title font size
  cover-subtitle-size: 13pt,        // cover subtitle font size
  cover-spacing: 24pt,              // vertical space between cover sections
  cover-text-width: 90%,            // width of abstract/keywords block on the cover
  cover-line-leading: 1.32em,       // line height for cover/front matter paragraphs
  cover-paragraph-spacing: 0.7em,   // spacing between cover paragraphs
  cover-author-name-size: 14pt,     // author name size on the cover
  cover-author-name-size: 14pt,     // author name size on the cover
  cover-author-gutter: 24pt,        // horizontal gap between cover author columns
  cover-author-row-gap: 16pt,       // vertical gap between cover author rows

  // Inline-title styling (used only when maketitle=false)
  inline-title-size: 18pt,          // inline title size
  inline-subtitle-size: 12pt,       // inline subtitle size
  inline-author-name-size: 12pt,    // inline author name size
  inline-author-gutter: 18pt,       // horizontal gap between inline author columns
  inline-author-row-gap: 12pt,      // vertical gap between inline author rows

  // Author block layout (applies to both modes)
  author-columns: 2,                // force two columns; omit to auto-detect
  author-alignment: center,         // column alignment for author details
  authors: (
    (
      name: "Author One",
      affiliation: "Affiliation One",
      email: "author.one@example.com",
      note: "Contact author",
    ),
    (
      name: "Author Two",
      affiliation: "Affiliation Two",
      email: "author.two@example.com",
    ),
  ),

  // Front matter (rendered on cover or inline depending on maketitle)
  abstract: [Summarize your contribution here.], // optional abstract content
  keywords: [Keyword 1, Keyword 2, Keyword 3],   // keyword list
  JEL: [G11, G12],                               // optional JEL codes
  frontmatter-gap: 12pt,                         // gap between abstract/keywords/JEL

  // bibliography: bibliography("bib.bib", title: "References", style: "apa"),
)
```

When you attach `paper.with(...)` via `#show: paper.with(...)`, Typst passes the remaining document content (`doc`) automatically, so no additional argument is required at the end of the call.


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
#import "@preview/ssrn-scribe:0.9.0": *

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
![Example](https://img.pengjiaxin.com/2024/03/63ce084e2a43bc2e7e31bd79315a0fb5.png)

### Example-brief with `maketitle=true`

![example-brief-true](https://img.pengjiaxin.com/2024/06/8d203bd7f2fbf20b39b33334f0ee4a36.png)

### Example-brief with `maketitle=false`

![example-brief-false](https://img.pengjiaxin.com/2024/06/83dd5821409031ce0a2c2a15e014cc60.png)