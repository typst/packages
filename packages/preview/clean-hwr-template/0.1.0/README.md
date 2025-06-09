# Typst Template for HWR (Berlin School of Economics and Law)

Welcome! This repository offers two Typst templates (English and German) designed to help you write your papers following the HWR style guidelines.

## Usage
You can use this template in the Typst web app by clicking "Start from template"
on the dashboard and searching for `clean-hwr-template`.

Alternatively, you can use the CLI to kick this project off using the command
```
typst init @preview/clean-hwr-template:0.1.0
```

Typst will create a new directory with all the files needed to get you started.

## Configuration
The `hwr(...)` function is the main entry point to configure and render the **PTB Template**. Below is an overview of the available configuration fields and how to use them:

```typst
#show: hwr.with(
  language: "en",
  main-font: "TeX Gyre Termes",

  metadata: (
    title: ["My Report Title"],
    student_id: "12345678",
    authors: ("Your Name",),
    company: "Example Corp",
    enrollment_year: "2024",
    semester: "2",
    company_supervisor: "Jane Doe",
  ),

  custom_entries: (
    (key: "GitHub", value: "yourhandle", index: 0),
  ),

  word_count: total-words, // Optional: total word count
  custom_declaration_of_authorship: [], // Optional override for default declaration

  abstract: [
    This report analyzes...
  ],

  // Only relevant for `language = "de"`
  note-gender-inclusive-language: (
    enabled: false,
    title: "Hinweis zum sprachlichen Gendern"
  ),

  glossary: (
    title: "Glossary",
    entries: (
      (
        key: "typst",
        short: "Typst",
        long: "Typst Typesetting System",
        description: "A modern alternative to LaTeX."
      ),
    )
  ),

  acronyms: (
    title: "Acronyms",
    entries: (
      "AI": ("Artificial Intelligence", "Artificial Intelligence"),
    )
  ),

  figure-index: (
    enabled: true,
    title: "List of Figures"
  ),

  table-index: (
    enabled: true,
    title: "List of Tables"
  ),

  listing-index: (
    enabled: true,
    title: "List of Listings"
  ),

  bibliography-object: bibliography("refs.bib"),
  citation_style: "template/hwr_citation.csl",

  appendix: (
    enabled: true,
    content: [
      = Appendix
      Additional data and figures here...
    ]
  ),
)
```

### Notes:
* **Fields marked optional** (like `word_count` or `custom_declaration_of_authorship`) may be omitted if not needed.
* `abstract` is shown before the table of contents.
* The `metadata.university` and `metadata.date_of_publication` will be filled automatically unless explicitly overridden.

## How to Create a PDF (locally)
Once you’ve made your changes, you can compile your document into a PDF by running this command in the root folder of the project:

```bash
typst compile main.typ
```

This will generate a `main.pdf` file with your paper ready to go.

> [!NOTE]
> Make sure all needed fonts are installed locally

## Dependencies
This template makes use of two Typst packages to add extra functionality:

* [`wordometer`](https://typst.app/universe/package/wordometer) - for counting the words automatically
* [`glossarium`](https://typst.app/universe/package/glossarium/) – for managing glossaries
* [`acrostiche`](https://typst.app/universe/package/acrostiche/) – for handling acronyms easily

These are fetched automatically when compiling the document, so you don’t need to install them manually.

## Quick Shoutout
Big thanks to [**Patrick O'Brien**](https://github.com/POBrien333) for creating the citation style file used in this template. You can find it at:

```
hwr_citation.csl
```

Original source: [Berlin School of Economics and Law CSL Style](https://github.com/citation-style-language/styles/blob/master/berlin-school-of-economics-and-law-international-marketing-management.csl)

## Need Help or Want to Contribute?
If you run into any issues or have ideas to improve the template, please open an issue or submit a pull request. Your feedback is always welcome!
