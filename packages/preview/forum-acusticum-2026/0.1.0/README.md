# FA26 Official Typst Template

**Latest build:** [![pipeline status](https://img.shields.io/badge/Download-PDF-green)](https://git.iem.at/fa26-templates/fa26-typst-template/-/jobs/artifacts/main/file/template/FA2026_template.pdf?job=build)

[**zipped template**](https://git.iem.at/fa26-templates/fa26-typst-template/-/jobs/artifacts/main/file/fa2026_template_Typst.zip?job=zip_repo)


This is the official Typst paper template for the [Forum Acusticum 2026 conference](https://forum-acusticum.org/fa2026) to be held in Graz, Austria, from September 6 to September 10, 2026.
Note that at the conference there will be two submission formats
1. *Full Paper Peer-Reviewed Submission*
  Authors submit a complete paper for peer review. This paper will undergo peer review by two anonymous reviewers. Accepted and accordingly revised contributions are going to be published in _Proceedings of Forum Acusticum 2026_.
1. *Abstract/Title Submission (no peer review)*
  Authors initially submit an abstract and title only. Topic Chairs review whether this submission is of sufficient quality and fits the conference. On acceptance, authors have the option to submit a final paper to be published in _Documenta of Forum Acusticum 2026_.

## Usage

You can use this template in the Typst web app by clicking “Start from template” on the dashboard and searching for `forum-acusticum-2026`.

Alternatively, you can use the CLI to kick this project off using the command

```
typst init @preview/forum-acusticum-2026
```

It imports the `fa2026` function from the `lib.typ` file located in the `package` folder.

## Configuration

The following named arguments can be passed to the `fa2026` function:

- `title`: The paper's title as content
- `authors`: An array of author dictionaries. Each of the entries in `authors` must contain the keys `name` and `affiliation`, both of these keys being strings. The _corresponding author_ is indicated by adding the key `corresponding: true` and their email as a string to the respective author's dictionary.
- `abstract`: The paper's abstract as content
- `keywords`: An array of keywords as strings
- `peer-review`: A boolean indicating whether the paper is a peer-reviewed submission, defaults to `false`
- `bibliography`: A call to the `bibliography` function with the path to the `.bib` file as an argument


## Basic Example

```typst
#import "@preview/forum-acusticum-2026:0.1.0": fa2026

#show: fa2026.with(
  title: [Paper Title],
  authors: (
    (
      name: "First Author",
      corresponding: true,
      email: "first.author@email.ad",
      affiliations: (
        "Department of Computer Science, University, Country"
      ),
    ),
    (
      name: "Second Author",
      affiliations: (
        "Department of Computer Science, University, Country"
      ),
    ),
  ),
  abstract: lorem(120),
  keywords: ("acoustics", "audio", "signal processing"),
  peer-review: true,
  bibliography: bibliography("fa2026_template.bib"),
)
```

## License

This package & template is licensed under the MIT License.
The supplied Latin Modern fonts for the template are licensed under the [GUST Font License](https://www.gust.org.pl/projects/e-foundry/licenses).
