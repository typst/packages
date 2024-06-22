# Supercharged DHBW

Unofficial [Typst](https://typst.app/) template for DHBW students.

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

## Used Packages

This template uses the following packages:

- [codelst](https://typst.app/universe/package/codelst): To create code snippets

A more detailed explanation of the features can be found in the `main.typ` file.

## Configuration
This template exports the `supercharged-dhbw` function with the following named arguments:

`title (str*)`: Title of the document

`authors (dictionary*)`: List of authors with the following named arguments (max. 6 authors when in the company or 8 authors when at DHBW):
    
    - name (str*): Name of the author
    - student-id (str*): Student ID of the author
    - course (str*): Course of the author
    - course-of-studies (str*): Course of studies of the author
    - company (dictionary): Company of the author
        - name (str*): Name of the company
        - post-code (str): Post code of the company
        - city (str*): City of the company
        - country (str): Country of the company

`abstract (content)`: Content of the abstract, it is recommended that you pass a variable containing the content or a function that returns the content

`acronym-spacing (length)`: Spacing between the acronym and its long form (check the [Typst documentation](https://typst.app/docs/reference/layout/length/) for examples on how to provide parameters of type length), default is `5em`

`acronyms (dictionary)`: Pass a dictionary containing the acronyms and their long forms (See the example in the `acronyms.typ` file)

`appendix (content)`: Content of the appendix, it is recommended that you pass a variable containing the content or a function that returns the content

`at-dhbw* (bool)`: Whether the document is written at the DHBW or not, default is `false`

`bibliography (content)`: Path to the bibliography file

`date (datetime* | array*)`: Provide a datetime object to display one date (e.g. submission date) or a array containing two datetime objects to display a date range (e.g. start and end date of the project), default is `datetime.today()`

`date-format (str)`: Format of the displayed dates, default is `"[day].[month].[year]"` (for more information on possible formats check the [Typst documentation](https://typst.app/docs/reference/foundations/datetime/#format))

`language (str*)`: Language of the document which is either `en` or `de`, default is `en`

`logo-left (content)`: Path to the logo on the left side of the title page (usage: image("path/to/image.png")), default is the `DHBW logo`

`logo-right (content)`: Path to the logo on the right side of the title page (usage: image("path/to/image.png")), default is `no logo`

`logo-size-ratio (str)`: Ratio between the right logo and the left logo height (left-logo:right-logo), default is `"1:1"`

`numbering-alignment (alignment)`: Alignment of the page numbering (for possible options check the [Typst documentation](https://typst.app/docs/reference/layout/alignment/)), default is `center`

`show-abstract (bool)`: Whether the abstract should be shown, default is `true`

`show-acronyms (bool)`: Whether the list of acronyms should be shown, default is `true`

`show-appendix (bool)`: Whether the appendix should be shown, default is `false`

`show-code-snippets (bool)`: Whether the code snippets should be shown, default is `true`

`show-confidentiality-statement (bool)`: Whether the confidentiality statement should be shown, default is `true`

`show-declaration-of-authorship (bool)`: Whether the declaration of authorship should be shown, default is `true`

`show-header (bool)`: Whether the header should be shown, default is `true`

`show-list-of-figures (bool)`: Whether the list of figures should be shown, default is `true`

`show-list-of-tables (bool)`: Whether the list of tables should be shown, default is `true`

`show-table-of-contents (bool)`: Whether the table of contents should be shown, default is `true`

`supervisor (str*)`: Name of the supervisor at the university or company

`toc-depth (int)`: Depth of the table of contents, default is `3`

`type-of-thesis (str)`: Type of the thesis, default is `none` (using this option reduces the maximum number of authors by 2 to 4 authors when in the company or 6 authors when at DHBW)

`type-of-degree (str)`: Type of the degree, default is `none` (using this option reduces the maximum number of authors by 2 to 4 authors when in the company or 6 authors when at DHBW)

`university (str*)`: Name of the university

`university-location (str*)`: Campus or city of the university

Behind the arguments the type of the value is given in parentheses. All arguments marked with `*` are required. 

## Acronyms

### Functions

This template provides the following functions to reference acronyms:

`acr`: Reference an acronym in the text

`acrpl`: Reference an acronym in the text in plural form

`acrs`: Reference an acronym in the text in short form (e.g. `acr("API")` -> `API`)

`acrspl`: Reference an acronym in the text in short form in plural form (e.g. `acrpl("API")` -> `APIs`)

`acrl`: Reference an acronym in the text in long form (e.g. `acrl("API")` -> `Application Programming Interface`)

`acrlpl`: Reference an acronym in the text in long form in plural form (e.g. `acrlpl("API")` -> `Application Programming Interfaces`)

`acrf`: Reference an acronym in the text in full form (e.g. `acrf("API")` -> `Application Programming Interface (API)`)

`acrfpl`: Reference an acronym in the text in full form in plural form (e.g. `acrfpl("API")` -> `Application Programming Interfaces (API)`)

### Definition

To define acronyms use a dictionary and pass it to the acronyms attribute of the template. The dictionary should contain the acronyms as keys and their long forms as values.

```typst
#let acronyms = (
  API: "Application Programming Interface",
  HTTP: "Hypertext Transfer Protocol",
  REST: "Representational State Transfer",
)
```

To define the plural form of an acronym use a array as value with the first element being the singular form and the second element being the plural form. If you don't define the plural form, the template will automatically add an "s" to the singular form.

```typst
#let acronyms = (
  API: ("Application Programming Interface", "Application Programming Interfaces"),
  HTTP: ("Hypertext Transfer Protocol", "Hypertext Transfer Protocols"),
  REST: ("Representational State Transfer", "Representational State Transfers"),
)
```

## Example

If you want to change an existing project to use this template, you can add a show rule like this at the top of your file:

```typst
#import "@preview/supercharged-dhbw:1.5.0": *

#show: supercharged-dhbw.with(
  title: "Exploration of Typst for the Composition of a University Thesis",
  authors: (
    (name: "Max Mustermann", student-id: "7654321", course: "TIS21", course-of-studies: "IT-Security", company: (
      (name: "YXZ GmbH", post-code: "70435", city: "Stuttgart")
    )),
    (name: "Juan Pérez", student-id: "1234567", course: "TIM21", course-of-studies: "Mobile Computer Science", company: (
      (name: "ABC S.L.", post-code: "08005", city: "Barcelona", country: "Spain")
    )),
  ),
  acronyms: acronyms, // displays the acronyms defined in the acronyms dictionary
  at-dhbw: false, // if true the company name on the title page and the confidentiality statement are hidden
  bibliography: bibliography("sources.bib"),
  date: datetime.today(),
  language: "en", // en, de
  supervisor: "John Appleseed",
  university: "Cooperative State University Baden-Württemberg",
  university-location: "Ravensburg Campus Friedrichshafen",
  // for more options check the package documentation (https://typst.app/universe/package/supercharged-dhbw)
)

// Your content goes here
```