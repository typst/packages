#import "../utils/global.typ": *
#import "../utils/symbols.typ": *

This chapter shows how to start a thesis and how this example is organized. The file structure is a recommended starting point, not a requirement.

== Getting Started <subsec:getting_started>
+ Install Typst 0.15.0 or newer, or open the Typst web app.
+ Create a thesis from the template: pick `earthrise-thesis` in the web app, or run this command:
  ```bash
  typst init @preview/earthrise-thesis:0.1.0 my-thesis
  ```
+ Replace the placeholders in `thesis.typ`, the source of this document, and write your chapters.
+ Compile it: `typst watch --font-path fonts thesis.typ` recompiles whenever you save a change.

`thesis.typ` applies the template by calling the function `thesis`. Its arguments fill in the content, such as the title, abstract or glossary, and adjust the style, such as the `accent` color or a logo on the cover. `thesis.typ` shows the usual arguments; the README of the template #footnote[see #link("https://github.com/AndrejOrsula/earthrise_thesis_template")] explains all of them.

The template is set in EB Garamond, with Monaspace Argon for code. Without these fonts, Typst warns and uses its own. The README shows where to get them, and how `tools/build.py` builds both editions with the same fonts on every machine.

== Template Structure <subsec:template_structure>
Each chapter has its own file in `chapters/`, which `thesis.typ` includes, so that no single file grows too long. @raw:file_structure shows the files of this example:

- `chapters/` holds the chapters;
- `figures/` holds your `.svg`, `.png` or `.jpg` files and the data behind them, such as `table.csv`; a large thesis can instead use one directory per chapter for both text and figures;
- `figures/artwork/` holds the drawings beside the chapter numbers, chosen in `utils/chapter-opener.typ`;
- `bibliography.bib` holds the #BibTeX entries of the bibliography, as with #LaTeX.

#[
  #figure(caption: [File structure tree view])[
    #local(zebra-fill: none, number-format: none)[
      ```
      my-thesis
      ├── bibliography.bib
      ├── chapters
      │   ├── appendix.typ
      │   ├── basic-usage.typ
      │   ├── figures.typ
      │   ├── introduction.typ
      │   ├── typst-basics.typ
      │   └── utilities.typ
      ├── code-snippets
      │   └── unit_testing.rs
      ├── figures
      │   ├── artwork/01_earthrise.svg, …
      │   ├── earthrise.jpg
      │   ├── table.csv
      │   └── wondering_robot.svg
      ├── thesis.typ
      └── utils
          ├── caption.typ
          ├── chapter-opener.typ
          ├── feedback.typ
          ├── form.typ
          ├── global.typ
          ├── subfigure.typ
          ├── symbols.typ
          └── todo.typ
      ```
    ]
  ] <raw:file_structure>
]
