# Bookly

[![Generic badge](https://img.shields.io/badge/Version-0.1.0-cornflowerblue.svg)]()
[![MIT License](https://img.shields.io/badge/License-MIT-forestgreen)](https://github.com/maucejo/bookly/blob/main/LICENSE)
[![User Manual](https://img.shields.io/badge/doc-.pdf-mediumpurple)](https://github.com/maucejo/bookly/blob/main/docs/manual.pdf)


The `bookly` template is a Typst package designed for writing academic documents such as theses, French habilitations, or scientific books. It provides a structured format that adheres to academic standards, making it easier for authors to focus on content rather than formatting.

## Basic usage

This section provides the minimal amount of information to get started with the template. For more detailed information, see the [manual](https://github.com/maucejo/bookly/blob/main/docs/manual.pdf).

To use the `bookly` template, you need to include the following line at the beginning of your typ file:

```typ
#import "@preview/bookly:0.1.0": *
```

### Initializing the template

After importing `bookly`, you have to initialize the template by a show rule with the `#bookly()` command. This function takes a set of argument to customize the document.

* `title`: Title of the book
* `author`: Author of the book
* `book-config`: The dictionary allows you to customize various aspects of the book

**Example**
```typ
#show: book.with(
	author: "Author Name",
	book-config: (
		fonts: (
			body: "Lato",
			math: "Lete Sans Math"
		),
		theme: "modern",
		lang: "en",
		logo: image("path_to_image/image.png")
	)
)
```

### Main features

* Themes: "classic", "modern", "fancy"
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

- [x] `fancy`
- [x] `modern`
- [x] `classic`

*Layout*

- [x] Standard layout
- [ ] Tufte layout

*Cover pages*

- [x] Title page
- [x] Back cover

*Environments*

- [x] Creation of the `front-matter` environment
- [x] Creation of the `main-matter` environment
- [x] Creation of the `appendix` environment

*Parts and chapters*
- [x] Creation of a document `part`
- [x] Creation of a document `chapter`
- [x] Creation of an unnumbered `chapter`

*Tables of contents*

- [x] Creation of the table of contents
- [x] Creation of the list of figures
- [x] Creation of the list of tables
- [x] Creation of a mini table of contents at the beginning of chapters using the `suboutline` package
- [x] Customization of entries (appearance, hyperlink) by modifying the `outline.entry` element
- [x] Localization of the different tables

*Figures and tables*

- [x] Customization of the appearance of figure and table captions depending on the context (chapter or appendix)
- [x] Short titles for the lists of figures and tables
- [x] Creation of the `subfigure` function for subfigures via the `subpar` package

*Equations*

- [x] Adaptation of equation numbering depending on the context (chapter or appendix)
- [x] Creation of a function to highlight important equations
- [x] Creation of a function to define equations without numbering
- [x] Use of the `equate` package to number equations in a system like (1.1a)

*Boxes*

- [x] Creation of information boxes to highlight important content

*Bibliography*

- [x] Verification of the reference list via `bibtex`
- [x] Same for `hayagriva`

## Licence

MIT licensed

Copyright © 2025 Mathieu AUCEJO (maucejo)

