# ITU Typst Template for Academic Documents
An unofficial [Typst](https://typst.app/) template for [IT University of Copenhagen](https://itu.dk/).

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Typst Universe](https://img.shields.io/badge/typst-universe-239DAD)](https://typst.app/universe/package/itu-academic-document)

<p align="center">
   <a href="main.pdf">
      <img src="docs/example-page-01.png" width="250" alt="thumbnail" />
      <img src="docs/example-page-09.png" width="250" alt="thumbnail" />
      <img src="docs/example-page-13.png" width="250" alt="thumbnail" />
   </a>
</p>
<p align="center" style="margin-top:0px;">
   <a href="docs/example.pdf">View example PDF output</a>
</p>

## Features
- **Title page** with department, course, document type, authors, and advisers
- **Abstract page** with Roman numeral page numbering
- **Table of contents** (up to 3 levels deep)
- **Dynamic page headers** that reflect the current section and subsection
- **Footer** with total-page count (e.g. `1 / 12`) and ITU logo
- **Bibliography** via `bib.yaml` — IEEE style, supports articles, books, proceedings, and more
- **Glossary** via `glossary.yaml` — automatic first-use expansion with short/long forms
- **PDF metadata** — author names and title embedded in the output PDF
- **Automatic section page breaks**
- **Dark mode**

## Getting Started

1. **Font Installation (optional)**
   - The template uses Open Sans (ITU's logo font) for the title page
   - The template will fall back to system fonts if Open Sans isn't installed
   - Download from [Google Fonts](https://fonts.google.com/specimen/Open+Sans) if needed

2. **Configure your document**
   - Edit the project parameters in `main.typ` to set your details:
     ```typst
     #show: academic-document.with(
       department: "Department of Computer Science",
       course_name: "Course Name",
       course_code: "Course Code",
       document_type: "Document Type",
       title: "Your Document Title",
       authors: (
         (name: "Jane Doe", email: "jado@itu.dk"),
         (name: "John Smith", email: "josm@itu.dk"),
       ),
       author_columns: 2,
       advisers: (
         (name: "Dr. John Smith", email: "jsmi@itu.dk"),
       ),
       adviser_columns: 3,
     )
     ```

3. **Write your content**
   - The sections are split into files for organization (see the `sections` folder)
   - you can include new sections by adding them to the `main.typ` file

4. **Compile your document**
     ```bash
     typst compile main.typ
     ```
   - Or watch for changes and recompile automatically:
     ```bash
     typst watch main.typ
     ```

> **Note:** You can enable dark mode in `main.typ` if you prefer while you're working.

## Get Started with Typst

### Resources
- [Typst for LaTeX users](https://typst.app/docs/guides/guide-for-latex-users/)
- [Official Typst Documentation](https://typst.app/docs)
- [Typst Examples Book](https://sitandr.github.io/typst-examples-book/book/)
- [Awesome Typst](https://github.com/qjcg/awesome-typst)

### Installation
> **Note:** There is also an online editor for Typst at [typst.app](https://typst.app/)

1. **Install Typst**
   - [Typst GitHub Repository](https://github.com/typst/typst?tab=readme-ov-file#installation)
   
2. **Editor Integration**
   - [TinyMist Extension](https://github.com/Myriad-Dreamin/tinymist?tab=readme-ov-file#installation) for VSCode, NeoVim, etc.

## Working with References

### Bibliography
- Add references to `bib.yaml`
- Reference in text using `@citation_key` or `#ref(<citation_key>)`
- Bibliography generated automatically at document end
- Supports articles, books, proceedings, web resources, and more

### Glossary
- Define terms in `glossary.yaml` with short/long forms and descriptions
- Reference terms using `@term_key` syntax
- First usage shows full form, subsequent uses show short form
- Force full form with `#gls("term_key", long: true)`
- Use plural forms with `@term_key:pl` or `#glspl("term_key")`


## Credits
This template is built on the foundation provided by [Simple Typst Thesis](https://github.com/zagoli/simple-typst-thesis/) by Zagoli. 
The original work has been expanded with additional features, and ITU-specific styling.


