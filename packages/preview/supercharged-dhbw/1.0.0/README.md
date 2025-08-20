# Supercharged DHBW

Unofficial [Typst](https://typst.app/) template for DHBW students.

The template is currently only available in English.

You can see an example PDF [here](https://github.com/DannySeidel/typst-dhbw-template/blob/main/example.pdf).

## Usage

You can use this template in the Typst web app by clicking "Start from template" on the dashboard and searching for `supercharged-dhbw`.

Alternatively, you can use the CLI to kick this project off using the command

```shell
typst init @preview/supercharged-dhbw
```

Typst will create a new directory with all the files needed to get you started.

## Fonts

This template uses the following fonts:
- [Montserrat](https://fonts.google.com/specimen/Montserrat)
- [Open Sans](https://fonts.google.com/specimen/Open+Sans)

If you want to use typst locally, you can download the fonts from the links above and install them on your system.
Otherwise, when using the web version add the fonts to your project.

For further information on how to add fonts to your project, please refer to the [Typst documentation](https://typst.app/docs/reference/text/text/#parameters-font).

## Contents

- Title page
- Confidentiality Statement
- Declaration of Authorship
- List of figures
- List of tables
- Code snippets
- Table of contents
- Abstract
- Bibliography
- Appendix

A more detailed explanation of the features can be found in the `main.typ` file.

## Configuration
This template exports the `supercharged-dhbw` function with the following named arguments:

`title`: Title of the document

`authors`: List of authors with the following named arguments:
    
    - name: Name of the author
    - student-id: Student ID of the author
    - course: Course of the author
    - course-of-studies: Course of studies of the author
    - company: Company of the author

`at-dhbw`: Whether the document is written at the DHBW or not, default is false

`show-confidentiality-statement`: Whether the confidentiality statement should be shown, default is true

`show-declaration-of-authorship`: Whether the declaration of authorship should be shown, default is true

`show-table-of-contents`: Whether the table of contents should be shown, default is true

`show-acronyms`: Whether the list of acronyms should be shown, default 
is true

`show-list-of-figures`: Whether the list of figures should be shown, default is true

`show-list-of-tables`: Whether the list of tables should be shown, default is true

`show-code-snippets`: Whether the code snippets should be shown, default is true

`show-appendix`: Whether the appendix should be shown, default is false

`show-abstract`: Whether the abstract should be shown, default is true
`abstract`: Content of the abstract

`university`: Name of the university

`university-location`: Campus or city of the university

`supervisor`: Name of the supervisor at the university or company

`date`: Date of the document

`logo-left`: Path to the logo on the left side of the title page

`logo-right`: Path to the logo on the right side of the title page

`bibliography`: path to the bibliography file

If you want to change an existing project to use this template, you can add a show rule like this at the top of your file:

```typst
#import "@preview/supercharged-dhbw:1.0.0": *

#show: supercharged-dhbw.with(
  title: "Exploration of Typst for the Composition of a University Thesis",
  authors: (
    (name: "Juan Pérez", student-id: "1234567", course: "TIM21", course-of-studies: "Mobile Computer Science", company: (
      (name: "ABC AG", post-code: "08005", city: "Barcelona", country: "Spain")
    )),
    (name: "Max Mustermann", student-id: "7654321", course: "TIS21", course-of-studies: "IT-Security", company: (
      (name: "YXZ GmbH", post-code: "70435", city: "Stuttgart", country: "")
    )),
  ),
  at-dhbw: false, // if true the company name on the title page and the confidentiality statement are hidden
  show-confidentiality-statement: true,
  show-declaration-of-authorship: true,
  show-table-of-contents: true,
  show-acronyms: true,
  show-list-of-figures: true,
  show-list-of-tables: true,
  show-code-snippets: true,
  show-bibliography: true,
  show-appendix: false,
  show-abstract: true,
  abstract: abstract, // displays the abstract defined above
  university: "Cooperative State University Baden-Württemberg",
  university-location: "Ravensburg Campus Friedrichshafen",
  supervisor: "John Appleseed",
  date: datetime.today(),
  logo-left: image("assets/logos/dhbw.svg"),
  // logo-right: image("assets/logos/company.svg")
)

// Your content goes here
```