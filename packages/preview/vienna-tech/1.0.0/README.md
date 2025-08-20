# The `vienna-tech` Template
<div align="center">Version 1.0.0</div>

This is a template, modeled after the LaTeX template provided by the Vienna University of Technology for Engineering Students. It is intended to be used as a starting point for writing Bachelor's or Master's theses, but can be adapted for other purposes as well. It shall be noted that this template is not an official template provided by the Vienna University of Technology, but rather a personal effort to provide a similar template in a new typesetting system. If you want to checkout the original templates visit the website of [TU Wien](https://www.tuwien.at/cee/edvlabor/lehre/vorlagen) 


## Getting Started

These instructions will help you set up the template on the typst web app. 

```typ
#import "@preview/vienna-tech:1.0.0": *

// Useing the configuration
#show: tuw-thesis.with(
  header-title: "Instruktionen zur Abfassung der Bachelorarbeit",
)
#maketitle(
  title: [Instruktionen zur Abfassung der Bachelorarbeit],
  thesis-type: [Bachelorarbeit],
  authors: (
    (
      name:"Vorname Nachname",
      email: "email@email.com",
      matrnr: "12345678",
    ),
  ),
)
```

## Options

For a indepth overview of the options have a look at the [documentation].



## Usage

These instructions will get you a copy of the project up and running on the typst web app. 

```bash
typst init @preview/vienna-tech:1.0.0
```

### Template overview

After initializing a project with this template, you will have the following files:

- `main.typ`: the file which is used to compile the document
- `abstract.typ`: a file where you can put your abstract text
- `appendix.typ`: a file where you can put your appendix text
- `sections.typ`: a file which can include all your contents
- `refs.bib`: references

## Contribute to the template

Feel free to contribute to the template by opening a pull request. If you have any questions, feel free to open an issue.

[documentation]: https://github.com/npikall/vienna-tech/tree/main/docs/docs.pdf