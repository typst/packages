# Supercharged DHBW

Unofficial [Typst](https://typst.app/) template for DHBW students.

You can see an example PDF of how the template looks [here](https://github.com/DannySeidel/typst-dhbw-template/blob/main/examples/example.pdf).

To see an example of how you can use this template, check out the `main.typ` file.
More examples can be found in the [examples directory](https://github.com/DannySeidel/typst-dhbw-template/blob/main/examples) of the GitHub repository.

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

Insert code snippets using the following syntax:

```typ
#figure(caption: "Codeblock Example", sourcecode[```ts
const ReactComponent = () => {
  return (
    <div>
      <h1>Hello World</h1>
    </div>
  );
};

export default ReactComponent;
```])
```

## Configuration

This template exports the `supercharged-dhbw` function with the following named arguments:

`title (str*)`: Title of the document

`authors (dictionary*)`: List of authors with the following named arguments (max. 6 authors when in the company or 8 authors when at university):

- name (str*): Name of the author
- student-id (str*): Student ID of the author
- course (str*): Course of the author
- course-of-studies (str*): Course of studies of the author
- company (dictionary): Company of the author (only needed when `at-university` is `false`) with the following named arguments:
  - name (str*): Name of the company
  - post-code (str): Post code of the company
  - city (str*): City of the company
  - country (str): Country of the company

`abstract (content)`: Content of the abstract, it is recommended that you pass a variable containing the content or a function that returns the content

`acronym-spacing (length)`: Spacing between the acronym and its long form (check the [Typst documentation](https://typst.app/docs/reference/layout/length/) for examples on how to provide parameters of type length), default is `5em`

`acronyms (dictionary)`: Pass a dictionary containing the acronyms and their long forms (See the example in the `acronyms.typ` file)

`appendix (content)`: Content of the appendix, it is recommended that you pass a variable containing the content or a function that returns the content

`at-university (bool*)`: Whether the document is written at university or not, default is `false`

`bibliography (content)`: The bibliography function containing a path to the bibliography file (e.g. `bibliography("path/to/bibliography.bib")`)

`bib-style (str)`: Style of the bibliography, default is `ieee`

`city (str)`: City of the author (only needed when `at-university` is `true`)

`confidentiality-marker: (dictionary)`: Configure the confidentially marker (red or green circle) on the title page (using this option reduces the maximum number of authors by 2 to 4 authors when in the company or 6 authors when at university)

- display (bool*): Whether the confidentiality marker should be shown, default is `false`
- offset-x (length): Horizontal offset of the confidentiality marker, default is `0pt`
- offset-y (length): Vertical offset of the confidentiality marker, default is `0pt`
- size (length): Size of the confidentiality marker, default is `7em`
- title-spacing (length): Adds space below the title to make room for the confidentiality marker, default is `2em`

`confidentiality-statement-content (content)`: Provide a custom confidentiality statement

`date (datetime* | array*)`: Provide a datetime object to display one date (e.g. submission date) or a array containing two datetime objects to display a date range (e.g. start and end date of the project), default is `datetime.today()`

`date-format (str)`: Format of the displayed dates, default is `"[day].[month].[year]"` (for more information on possible formats check the [Typst documentation](https://typst.app/docs/reference/foundations/datetime/#format))

`declaration-of-authorship-content (content)`: Provide a custom declaration of authorship

`glossary (dictionary)`: Pass a dictionary containing the glossary terms and their definitions (See the example in the `glossary.typ` file)

`glossary-spacing (length)`: Spacing between the glossary term and its definition (check the [Typst documentation](https://typst.app/docs/reference/layout/length/) for examples on how to provide parameters of type length), default is `1.5em`

`header (dictionary)`: Configure the header of the document

- display (bool): Whether the header should be shown, default is `true`
- show-chapter (bool): Whether the current chapter should be shown in the header, default is `true`
- show-left-logo (bool): Whether the left logo should be shown in the header, default is `true`
- show-right-logo (bool): Whether the right logo should be shown in the header, default is `true`
- show-divider (bool): Whether the header divider should be shown, default is `true`
- content (content): Content for a custom header, it is recommended that you pass a variable containing the content or a function that returns the content

`heading-numering (str)`: Numbering style of the headings, default is `"1.1"` (for more information on possible numbering formats check the [Typst documentation](https://typst.app/docs/reference/model/numbering))

`ignored-link-label-keys-for-highlighting (array)`: List of keys of labels that should be ignored when highlighting links in the document, default is `()`

`language (str*)`: Language of the document which is either `en` or `de`, default is `en`

`logo-left (content)`: Path to the logo on the left side of the title page (usage: image("path/to/image.png")), default is the `DHBW logo`

`logo-right (content)`: Path to the logo on the right side of the title page (usage: image("path/to/image.png")), default is `no logo`

`logo-size-ratio (str)`: Ratio between the right logo and the left logo height (left-logo:right-logo), default is `"1:1"`

`math-numbering (str)`: Numbering style of the math equations, set to `none` to turn off equation numbering, default is `"(1)"` (for more information on possible numbering formats check the [Typst documentation](https://typst.app/docs/reference/model/numbering))

`numbering-alignment (alignment)`: Alignment of the page numbering (for possible options check the [Typst documentation](https://typst.app/docs/reference/layout/alignment/)), default is `center`

`page-numbering (dictionary)`: Configure the page numbering for the three sections (e.g. `page-numbering: (preface: "I", main: "1 / 1", appendix: "a")`)

- preface (str): Page numbering for the preface, default is `I`
- main (str): Page numbering for the main part, default is `1 / 1`
- appendix (str): Page numbering for the appendix, default is `a`

`show-abstract (bool)`: Whether the abstract should be shown, default is `true`

`show-acronyms (bool)`: Whether the list of acronyms should be shown, default is `true`

`show-code-snippets (bool)`: Whether the code snippets should be shown, default is `true`

`show-confidentiality-statement (bool)`: Whether the confidentiality statement should be shown, default is `true`

`show-declaration-of-authorship (bool)`: Whether the declaration of authorship should be shown, default is `true`

`show-list-of-figures (bool)`: Whether the list of figures should be shown, default is `true`

`show-list-of-tables (bool)`: Whether the list of tables should be shown, default is `true`

`show-table-of-contents (bool)`: Whether the table of contents should be shown, default is `true`

`supervisor (dictionary*)`: Name of the supervisor at the university and/or company (e.g. `supervisor: (company: "John Doe", university: "Jane Doe")`)

- company (str): Name of the supervisor at the company (note while the argument is optional at least one of the two arguments must be provided)
- university (str): Name of the supervisor at the university (note while the argument is optional at least one of the two arguments must be provided)

`titlepage-content (content)`: Provide a custom title page

`toc-depth (int)`: Depth of the table of contents, default is `3`

`type-of-thesis (str)`: Type of the thesis, default is `none` (using this option reduces the maximum number of authors by 2 to 4 authors when in the company or 6 authors when at university)

`type-of-degree (str)`: Type of the degree, default is `none` (using this option reduces the maximum number of authors by 2 to 4 authors when in the company or 6 authors when at university)

`university (str*)`: Name of the university

`university-location (str*)`: Campus or city of the university

`university-short (str*)`: Short name of the university (e.g. `DHBW`), displayed for the university supervisor

Behind the arguments the type of the value is given in parentheses. All arguments marked with `*` are required.

## Acronyms

This template provides functions to reference acronyms in the text. To use these functions, you need to define the acronyms in the `acronyms` attribute of the template.
The acronyms referenced with the functions below will be linked to their definition in the list of acronyms.

### Functions

This template provides the following functions to reference acronyms:

`acr`: Reference an acronym in the text (e.g. `acr("API")` -> `Application Programming Interface (API)` or `API`)

`acrpl`: Reference an acronym in the text in plural form (e.g. `acrpl("API")` -> `Application Programming Interfaces (API)` or `APIs`)

`acrs`: Reference an acronym in the text in short form (e.g. `acrs("API")` -> `API`)

`acrspl`: Reference an acronym in the text in short form in plural form (e.g. `acrpl("API")` -> `APIs`)

`acrl`: Reference an acronym in the text in long form (e.g. `acrl("API")` -> `Application Programming Interface`)

`acrlpl`: Reference an acronym in the text in long form in plural form (e.g. `acrlpl("API")` -> `Application Programming Interfaces`)

`acrf`: Reference an acronym in the text in full form (e.g. `acrf("API")` -> `Application Programming Interface (API)`)

`acrfpl`: Reference an acronym in the text in full form in plural form (e.g. `acrfpl("API")` -> `Application Programming Interfaces (API)`)

### Definition

To define acronyms use a dictionary and pass it to the acronyms attribute of the template.
The dictionary should contain the acronyms as keys and their long forms as values.

```typst
#let acronyms = (
  API: "Application Programming Interface",
  HTTP: "Hypertext Transfer Protocol",
  REST: "Representational State Transfer",
)
```

To define the plural form of an acronym use a array as value with the first element being the singular form and the second element being the plural form.
If you don't define the plural form, the template will automatically add an "s" to the singular form.

```typst
#let acronyms = (
  API: ("Application Programming Interface", "Application Programming Interfaces"),
  HTTP: ("Hypertext Transfer Protocol", "Hypertext Transfer Protocols"),
  REST: ("Representational State Transfer", "Representational State Transfers"),
)
```

## Glossary

Similar to the acronyms, this template provides a function to reference glossary terms in the text. To use the function, you need to define the glossary terms in the `glossary` attribute of the template.
The glossary terms referenced with the function below will be linked to their definition in the list of glossary terms.

### Reference

`gls`: Reference a glossary term in the text (e.g. `gls("Vulnerability")` -> link to the definition of "Vulnerability" in the glossary)

### Definition

The definition works analogously to the acronyms.
Define the glossary terms in a dictionary and pass it to the glossary attribute of the template.
The dictionary should contain the glossary terms as keys and their definitions as values.

```typst
#let glossary = (
  Vulnerability: "A Vulnerability is a flaw in a computer system that weakens the overall security of the system.",
  Patch: "A patch is data that is intended to be used to modify an existing software resource such as a program or a file, often to fix bugs and security vulnerabilities.",
  Exploit: "An exploit is a method or piece of code that takes advantage of vulnerabilities in software, applications, networks, operating systems, or hardware, typically for malicious purposes.",
)
```
