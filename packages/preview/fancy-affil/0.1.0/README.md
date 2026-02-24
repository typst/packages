# fancy-affil

An auto affiliation function for Typst. This library provides a single function, `get-affiliations`, which aims to do one thing and (hopefully) do one thing well: extract authors' information from a given dictionary and output two contents:
1. Authors' names with superscripted affiliation indices and an email symbol if contact information is provided.
2. A list of sorted affiliations.

<!-- ## Example
![Example Output](assets/tests-light.png#gh-light-mode-only)
![Example Output](assets/tests-dark.png#gh-dark-mode-only) -->

## `get-affiliations`
Extracts and formats authors' names and affiliations. The function is highly customizable:

### Parameters
- authors: array of strings or dictionaries
    * An array containing authors' information. Each element can be a string (author's name) or a dictionary with detailed information.
- authors-join: string (default: ", ")
    * The string used to join multiple authors' names.
- authors-join-2: string (default: " and ")
    * The string used to join two authors' names.
- authors-func: function (default: default-authors-func)
    * A function to style the authors' block.
- authors-numbering: string (default: "1")
    * The numbering style for affiliation indices in authors.
- orcid-logo-size: length (default: 9.5pt)
    * The size of the ORCID logo.
- email-symbol: string (default: "🖂")
    * The symbol used to denote email addresses.
- authors-order: array (default: ("name", "orcid", "email", "affil-index"))
    * The order of elements within each author box.
- name-style: function (default: x => x)
    * A function to style the author's name.
- orcid-style: function (default: x => link(x, orcid-logo))
    * A function to style the ORCID link.
- email-style: function (default: x => link(x, email-symbol))
    * A function to style the email link.
- affil-indices-style: function (default: x => super(x))
    * A function to style the affiliation indices.
- authors-box-join: string (default: " ")
    * The string used to join elements within each author box.
- affil-label-numbering: string (default: "1.")
    * The numbering style for affiliations.
- affil-label-style: function (default: x => super(x))
    * A function to style the affiliation labels.
- affil-join: string (default: ", ")
    * The string used to join multiple affiliations.
- affil-func: function (default: default-affil-func)
    * A function to style the affiliations' block.
- affil-style: function (default: x => x)
    * A function to style each affiliation.
- affil-box-join: string (default: " ")
    * The string used to join elements within each affiliation box.
- affil-order: tuple (default: ("number", "affil"))
    * The order of elements within each affiliation box.

### Return
- array of two blocks
    * An array containing two blocks: the authors' block and the affiliations' block.

### Default functions
```typst
/* Default author function */
#let default-authors-func(authors-text) = {
  set align(center)
  block(text(size: 12pt, authors-text))
}

/* Default affiliation function */
#let default-affil-func(affil-text) = {
  set align(center)
  set par(justify: false)
  set block(width: 85%)
  block(text(size: 10pt, affil-text))
}
```

## Tests

To run the test, use the following command:

```bash
typst watch ./tests/tests.typ --root .