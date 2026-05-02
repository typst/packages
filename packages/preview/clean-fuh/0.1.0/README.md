# FUH Typst Template

A clean [Typst](https://typst.app/) template for theses at FernUni Hagen (Bachelor and Master).
It is tailored to FernUni structure and wording, but can also be used for similar academic reports.

## Quick Start

As I do not have the approval to publish the logo of the FernUniversitaet in Hagen, I used an empty image as logo in the template. You can replace it with the actual logo by adding it to your project and passing it as `logo`-parameter to `clean-fuh.with(...)`.

### Typst web app


You can use this template in the Typst web app by clicking "Start from template" on the dashboard and searching for `clean-fuh`.

### Typst CLI

Alternatively (if you use Typst on your local computer), you can use the CLI to kick this project off using the command

```sh
typst init @preview/clean-fuh MyThesis
```

If you work directly from this repository, start with `template/main.typ`.

## Minimal Usage

The template exports `clean-fuh` and is typically applied with `#show: clean-fuh.with(...)`:

```typst
#import "@preview/clean-fuh:0.1.0": *
#import "glossary.typ": glossary-entries

#show: clean-fuh.with(
  title: "Evaluation of Typst for Thesis Writing",
  authors: (
    (
      name: "Max Mustermann",
      student-id: "1234567",
      degree: "M.Sc.",
      course-of-studies: "Praktische Informatik",
    ),
  ),
  language: "de", // "de" or "en"
  type-of-thesis: "Masterarbeit",
  university: "FernUniversitaet in Hagen",
  faculty: "Mathematik und Informatik",
  supervisor: (first: "Dr. Jane Doe", second: "Prof. Dr. John Doe"),
  date: datetime.today(),
  bibliography: bibliography("sources.bib"),
  glossary: glossary-entries,
)

= Introduction
#lorem(80)
```

## Configuration (Short)

Required arguments:

- `title`: string
- `authors`: array of dictionaries (each needs `name`, `student-id`, and `course-of-studies`)
- `language`: `"de"` or `"en"`
- `university`: string
- `faculty`: string
- `supervisor`: dictionary with at least `first` or `second`
- `date`: a `datetime` or an array with two `datetime` values

Common optional arguments:

- `type-of-thesis`
- `bibliography` and `bib-style`
- `glossary`
- `show-gender-notice` (default: `true`)
- `show-confidentiality-statement`, `show-declaration-of-authorship`, `show-table-of-contents`, `show-abstract`
- `startdate` and `enddate` (time frame on title page)
- `companies` (needed for the generated confidentiality statement)
- `logo` (custom title-page logo)

For a complete runnable example, see [`template/main.typ`](template/main.typ).

## Glossary

Glossary support is provided by
[glossarium](https://typst.app/universe/package/glossarium/).
Define your glossary entries in a separate file and pass them to `glossary`.

```typst
#let glossary-entries = (
  (key: "API", description: "Application Programming Interface"),
  (key: "HTTP", description: "Hypertext Transfer Protocol"),
)
```

## Fonts

This template uses the following fonts (from Google fonts):

- [Source Serif 4](https://fonts.google.com/specimen/Source+Serif+4)
- [Source Sans 3](https://fonts.google.com/specimen/Source+Sans+3)

If you want to use typst locally, you can download the fonts from the links above and install them on your system (_Hint_: You need the TTF-files located within the `static` subfolders of both font-distributions). Otherwise, when using the web version, add the fonts to your project.

For further information on how to add fonts to your project, please refer to the [Typst documentation](https://typst.app/docs/reference/text/text/#parameters-font).

[**Source Serif 4**](https://fonts.google.com/specimen/Source+Serif+4) (formerly known as *Source Serif Pro*) has been chosen for the **body text** as it is a high-quality font especially made for on-screen use and the reading of larger quantities of text. It was designed in 2014 by [Frank Grießhammer](https://fonts.adobe.com/designers/frank-griesshammer) for Adobe as a companion to *Source Sans Pro*, thus expanding their selection of Open Source fonts. It belongs to the category of transitional style fonts. Its relatively large x-height is typical for on-screen fonts and adds to the legibility even at small sizes. The font ist constantly being further developed. In the meantime there are special variants available e.g. for small print (*Source Serif Caption*, *Source Serif Small Text*) or large titles (*Source Serif Display*) and headings (*Source Serif Headings*). For people with a Computer Science background, the font might be familiar as it is used for the online documentation of the Rust programming language.

For the **headlines** as well as for **other guiding elements** of the document, the font [**Source Sans 3**](https://fonts.google.com/specimen/Source+Sans+3) has been chosen. It comes as a natural choice since *Source Serif 4* has been especially designed for this combination. But it has its virtues of its own, e.g. its reduced run length which permits more characters per line. This helps to avoid line-breaks within headings in our use case. *Source Sans 3* (originally named *Source Sans Pro*) has been designed by [Paul D. Hunt](https://blog.typekit.com/2013/11/20/interview-paul-hunt/) in 2012 as Adobes first Open Source font. It has its roots in the family of Gothic fonts thus belonging to a different category than *Source Serif 4*. But under [Robert Slimbachs](https://de.wikipedia.org/wiki/Robert_Slimbach) supervision, both designers succeeded to create a combination that fits well and at the same time the different rootings make the pairing not too "boring".

## Packages Used

This template uses the following packages:

- [codelst](https://typst.app/universe/package/codelst): To create code snippets
- [hydra](https://github.com/tingerrr/hydra): To display the current heading within the header.
- [glossarium](https://github.com/typst-community/glossarium): For the glossary of the document.

## Local Development

For local package testing in this repository:

```sh
./tools/local-deployment
```

Compile with local Typst:

```sh
typst compile template/main.typ main.pdf
```

Or with Docker:

```sh
docker run --rm -v "$PWD":/work -v "$HOME/.local/share/typst":/root/.local/share/typst -w /work ghcr.io/typst/typst:latest compile --root /work template/main.typ /work/main.pdf
```

## Support

If you find a bug or want to propose an improvement, open an issue in this repository.
For general Typst questions, see the [Typst docs](https://typst.app/docs/) and the [Typst forum](https://forum.typst.app/).

## Credit

This template is based on the [clean-dhbw-template](https://github.com/roland-KA/clean-dhbw-typst-template).  
I have adapted the template with the aim to make it suitable for FernUni Hagen.

# License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.