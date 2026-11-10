# Book template

[![Generic badge](https://img.shields.io/badge/Version-1.1.1-cornflowerblue.svg)]()
[![MIT License](https://img.shields.io/badge/License-MIT-forestgreen)](https://github.com/maucejo/book_template/blob/main/LICENSE)
[![User Manual](https://img.shields.io/badge/doc-.pdf-mediumpurple)](https://github.com/maucejo/book_template/blob/main/docs/manual.pdf)


The `bookly` template is a Typst package designed for writing academic documents such as theses, French habilitations, or scientific books. It provides a structured format that adheres to academic standards, making it easier for authors to focus on content rather than formatting.

## Basic usage

This section provides the minimal amount of information to get started with the template. For more detailed information, see the [manual](https://github.com/maucejo/book_template/blob/main/docs/manual.pdf).

To use the `bookly` template, you need to include the following line at the beginning of your typ file:

```typ
#import "@preview/bookly:1.1.1": *
```

### Initializing the template

After importing `bookly`, you have to initialize the template by a show rule with the `#bookly()` command. This function takes a set of argument to customize the document.

* `title`: Title of the book
* `author`: Author of the book
* `book-config`: The dictionary allows you to customize various aspects of the book

**Example**
```typ
#show: bookly.with(
  author: "Author Name",
  fonts: (
    body: "Lato",
    math: "Lete Sans Math"
  ),
  theme: modern,
  lang: "en",
  title-page: book-title-page(
    series: "Typst book series",
    institution: "Typst community",
    logo: image("images/typst-logo.svg"),
    cover: image("images/book-cover.jpg", width: 45%)
  )
)
```

### Main features

* Themes: `classic`, `modern`, `fancy`, `orly`
* Layout: "standard" and "tufte"
* Language support: English and French
* Font customization: Body and math fonts can be customized
* Environments: `front-matter`, `main-matter`, `appendix`, `back-matter`
* Outlines: `tableofcontents`, `listoffigures`, `listoftables`, `minitoc`
* Part and chapter definition: `part`, `chapter`, `chapter-nonum`

> **_Note:_**  The chapters can be also written using the Typst standard markup syntax.

### Helper functions

* Subfigures - based on the `subpar` package
    ```typ
    #subfigure(
        figure(image("image1.png"), caption: []),
        figure(image("image2.png"), caption: []), <b>,
        columns: (1fr, 1fr),
        caption: [Figure title],
        label: <fig:subfig>,
    )
    ```

* Equations
    * Boxed equations
        ```typ
        $
            #boxeq[$p(A|B) prop p(B|A) space p(A)$]
        $
        ```

    * Unnumbered equations
        ```typ
        #nonumeq[$integral_0^1 f(x) dif x = F(1) - F(0)$]
        ```

    * Subequation numbering based on the `equate` package

* Information boxes
    * `#info-box` for remarks
    * `#tip-box` for tips
    * `#important-box` for important notes
    * `proof-box` for proofs
    * `question-box` for questions
    * `custom-box` for user defined boxes

* `book-title-page` for defining the title page of a book

* `thesis-title-page` for defining the title page of a thesis

* `back-cover` for defining the back cover of a book


For more information, please refer to the [manual](https://github.com/maucejo/book_template/blob/main/docs/manual.pdf).

## Roadmap

The template is under development. Here is the list of features that are implemented or will be in a future version.

*Themes*

- `fancy` (default)
- `modern`
- `classic`
- `orly` (O'Reilly style)
- `pretty`

*Layout*

- Standard layout
- Tufte layout

*Cover pages*

- Title page
- Back cover

*Environments*

- Creation of the `front-matter` environment
- Creation of the `main-matter` environment
- Creation of the `appendix` environment

*Parts and chapters*
- Creation of a document `part`
- Creation of a document `chapter`
- Creation of an unnumbered `chapter`

*Tables of contents*

- Creation of the table of contents
- Creation of the list of figures
- Creation of the list of tables
- Creation of a mini table of contents at the beginning of chapters using the `suboutline` package
- Customization of entries (appearance, hyperlink) by modifying the `outline.entry` element
- Localization of the different tables

*Figures and tables*

- Customization of the appearance of figure and table captions depending on the context (chapter or appendix)
- Short titles for the lists of figures and tables
- Creation of the `subfigure` function for subfigures via the `subpar` package

*Equations*

- Adaptation of equation numbering depending on the context (chapter or appendix)
- Creation of a function to highlight important equations
- Creation of a function to define equations without numbering
- Use of the `equate` package to number equations in a system like (1.1a)

*Boxes*

- Creation of information boxes to highlight important content

*Bibliography*

- Verification of the reference list via `bibtex`
- Same for `hayagriva`

## Licence

MIT licensed

Copyright © 2025 Mathieu AUCEJO (maucejo)



