# Versatile APA 7th Edition Template for Typst

A comprehensive Typst template following the official APA 7th Edition style guidelines. This template includes all necessary components for academic research papers, essays, theses, and dissertations.

## Usage

You can use this template through the Typst Universe page via the `typst` command locally or directly through the Typst Web App.

Alternatively, clone this repository as a git submodule. For detailed instructions, refer to this repository's main README.

### Features

This template supports, mainly, both student and professional versions of APA 7th Edition papers with:

- Title page
- Abstract
- Headings (levels 1-5, further levels will be formatted as level 5)
- Raw or computer code blocks (See `codly` package for better code formatting)
- Mathematical equations
- References (the template comes with an `apa.csl` file given that Typst has some issues with the indent length)
- Quotations (short and block formats based on word count)
- Lists (ordered and unordered)
- Footnotes

#### Figures

The template provides an APA-style figure (`apa-figure`, which accepts the same parameters as `figure` with an extra `label` parameter) with:

- General notes
- Specific notes
- Probability notes

For appendix figures, use the same `apa-figure`.

#### Language support

- English
- Spanish
- Portuguese
- German
- Italian
- French
- Dutch
- Serbian

##### Unsupported languages

In the cases where the language is not supported in the template, you can either make a PR or file an issue in the repository, so it can be added and updated in the next template version. Otherwise you can use the `custom-terms` parameter, which expects a dictionary mapping English terms to their translations. For example for Japanese, the expected format is:

```typ
#let custom-terms: (
  "and": "と",
  "Author Note": "著者注",
  "Abstract": "要旨",
  "Keywords": "キーワード",
  "Appendix": "付録",
  "Annex": "付録",
  "Addendum": "補遺",
  "Note": "注",
)
```

#### Appendices

- Figure appendices with independent numbering
- Appendices outline
- Smart appendix numbering (automatically disabled for single appendices)

#### Authoring

- Automatic footnote numbering for author affiliations
  - Or you can simply use `custom-authors` or `custom-affiliations` which expects `content` instead of `dict`
- Author notes
- ORCID integration

##### Authors and affiliations dictionary schema

Authors and affiliations dictionaries expect the following schema (both expecting an array of dictionaries).

For authors, is an array of dictionaries, where each dictionary has a `name` field with a content, and an `affiliations` field with an array of strings, each string being the ID of the affiliation.

```typ
#let authors = (
  (
    name: [Author Name],
    affiliations: ("ID-1", "ID-2")
  ),
  (
    name: [Author Name 2],
    affiliations: ("ID-3", "ID-4")
  ),
)
```

For affiliations, is an array of dictionaries, where each dictionary has an `id` field with a string (the ID of the affiliation), and a `name` field with a content (the name of the affiliation).

```typ
#let affiliations = (
  (
    id: "ID-1",
    name: [Affiliation Name]
  ),
  (
    id: "ID-2",
    name: [Affiliation Name 2]
  )
)
```

## Regarding LaTeX

**LaTeX `apa7` class inspiration**: This template draws heavily from the `apa7` class in LaTeX (which itself builds on the `apa6` class). The `journal` and `document` formats are not included due to styling and formatting variations. While technically possible to port these formats from LaTeX, they serve limited use cases beyond academic submission, as most APA-compliant journals implement their own specific styling requirements.

> If you happen to need it and want to contribute or have information about how to, please open an issue or a PR.

## License

This package is licensed under the MIT License. See the repository for complete license information.
