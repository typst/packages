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
- Raw/computer code blocks (See `codly` package for better code formatting)
- Mathematical equations
- References
- Quotations (short and block formats based on word count)
- Lists (ordered and unordered)
- Footnotes

#### Figures

The template provides robust support for figures (images, tables, and equations) with:

- General notes
- Specific notes
- Probability notes

For appendix figures, use the `appendix-figure` function (which accepts the same parameters as `apa-figure`).

#### Language Support

- English
- Spanish
- Portuguese
- German
- Italian
- French
- Dutch

#### Appendices

- Figure appendices with independent numbering
- Appendices outline
- Smart appendix numbering (automatically disabled for single appendices)

#### Authoring

- Automatic footnote numbering for author affiliations
- Author notes
- ORCID integration

## Regarding LaTeX

**LaTeX `apa7` class inspiration**: This template draws heavily from the `apa7` class in LaTeX (which itself builds on the `apa6` class). The `journal` and `document` formats are not included due to styling and formatting variations. While technically possible to port these formats from LaTeX, they serve limited use cases beyond academic submission, as most APA-compliant journals implement their own specific styling requirements.

## License

This package is licensed under the MIT License. See the repository for complete license information.
