# The `vienna-tech` Template
<div align="center">Version 0.1.3</div>

This is a template, modeled after the LaTeX template provided by the Vienna University of Technology for Engineering Students. It is intended to be used as a starting point for writing Bachelor's or Master's theses, but can be adapted for other purposes as well. It shall be noted that this template is not an official template provided by the Vienna University of Technology, but rather a personal effort to provide a similar template in a new typesetting system. If you want to checkout the original templates visit the website of [TU Wien](https://www.tuwien.at/cee/edvlabor/lehre/vorlagen) 


## Getting Started

These instructions will help you set up the template on the typst web app. 

```typ
#import "@preview/vienna-tech:0.1.3": *

// Useing the configuration
#show: tuw-thesis.with(
  title: [Titel of the Thesis],
  thesis-type: [Bachelorthesis],
  lang: "de",
  authors: (
    (
      name: "Firstname Lastname", 
      email: "email@email.com",
      matrnr: "12345678",
      date: datetime.today().display("[day] [month repr:long] [year]"),
    ),
  ),
  abstract: [The Abstract of the Thesis],
  bibliography: bibliography("bibliography.bib"), 
  appendix: [The Appendix of the Thesis], 
)
```

## Options

All the available options that are available for the template are listed below.

| Parameter           | Type                                   | Description                                                                                           |
|---------------------|----------------------------------------|-------------------------------------------------------------------------------------------------------|
| `title`             | `content`                              | Title of the thesis.                                                                                  |
| `thesis-type`       | `content`                              | Type of thesis (e.g., Bachelor's thesis, Master's thesis).                                            |
| `authors`           | `content`; `string`; `array`           | Name of the author(s) as text or array.                                                               |
| `abstract`          | `content`                              | Abstract of the thesis.                                                                               |
| `papersize`         | `string`                               | Paper size (e.g., A4, Letter).                                                                        |
| `bibliography`      | `bibliography`                         | Bibliography section.                                                                                 |
| `lang`              | `string`                               | Language of the thesis (e.g., "en" for English, "de" for German).                                     |
| `appendix`          | `content`                              | Appendix of the thesis.                                                                               |
| `toc`               | `bool`                                 | Show table of contents (`true` or `false`).                                                           |
| `font-size`         | `length`                               | Font size for the main text.                                                                          |
| `main-font`         | `string`; `array`                      | Main font as a name or an array of font names.                                                        |
| `title-font`        | `string`; `array`                      | Font for the title as a name or an array of font names.                                               |
| `raw-font`          | `string`; `array`                      | Font for specific text as a name or an array of font names.                                           |
| `title-page`        | `content`                              | Content of the title page.                                                                            |
| `paper-margins`     | `auto`; `relative`; `dictionary`       | Margins of the document. Can be set as automatic, relative, or defined by a dictionary.               |
| `title-hyphenation` | `auto`; `bool`                         | Title hyphenation, either automatic (`auto`) or manual (`true` or `false`).                           |


## Usage

These instructions will get you a copy of the project up and running on the typst web app. 

```bash
typst init @preview/vienna-tech:0.1.3
```

### Template overview

After setting up the template, you will have the following files:

- `main.typ`: the file which is used to compile the document
- `abstract.typ`: a file where you can put your abstract text
- `appendix.typ`: a file where you can put your appendix text
- `sections.typ`: a file which can include all your contents
- `refs.bib`: references

## Contribute to the template

Feel free to contribute to the template by opening a pull request. If you have any questions, feel free to open an issue.