# LTH Master's Thesis Template for Computer Science

This is an unofficial Typst version of the official LaTeX template for Master's Theses in Computer Science at LTH (Lund University). The template follows the department's guidelines and formatting requirements. A complete example is provided together with all typst code for customisation purposes.

## Usage

You can create a new project using this template by running:

```
typst init @preview/uo-lth-msc-cs-thesis
```

This will create a new directory with all the necessary files to get started with your thesis.

## Configuration

The template exports a `template` function with the following named arguments:

- `title`: Your thesis title in English
- `se_title`: Your thesis title in Swedish
- `thesis_number`: Your thesis number (given by the institution)
- `issn`: Thesis ISSN number
- `subtitle`: Additional subtitle (e.g., "Master's Thesis")
- `paper-size`: Paper size (default: "a4")
- `supervisors`: Array of supervisors, each with `name` and `email`
- `examiner`: Array of examiners, each with `name` and `email`
- `students`: Array of students, each with `name` and `email`
- `affiliation`: Dictionary containing:
  - `department`: Department name (default: "Department of Computer Science")
  - `school`: School name (default: "LTH | Lund University")
  - `company`: Company name if applicable
- `lang`: Language code (default: "en")
- `abstract`: Thesis abstract (required)
- `acknowledgements`: Acknowledgements section (optional)
- `keywords`: Keywords for the thesis
- `popular_science_summary`: Popular science summary with:
  - `title`: Title of the summary
  - `abstract`: Abstract of the summary
  - `body`: Main content of the summary

## Minimal Working Example

```typst
#import "@preview/uo-lth-msc-cs-thesis:0.1.0": template, createAppendices

#show: template.with(
  title: "Your Thesis Title",
  se_title: "Din avhandlingstitel på svenska",
  thesis_number: "LU-CS-EX: XXXX-XX",
  issn: "XXXX-XXXX",
  
  subtitle: "Master's Thesis",
  
  students: (
    (
      name: "Your Name",
      email: "your.email@student.lu.se"
    ),
  ),
  
  supervisors: (
    (
      name: "Supervisor Name",
      email: "supervisor@cs.lth.se"
    ),
  ),
  
  examiner: (
    (
      name: "Examiner Name",
      email: "examiner@cs.lth.se"
    )
  ),
  
  affiliation: (
    university: "LTH | Lund University",
    department: "Department of Computer Science",
    company: "the Department of Computer Science, Lund University",
  ),
  
  abstract: [
    Your abstract text goes here (150 words recommended).
  ],
  
  keywords: [keyword1, keyword2, keyword3],
  
  popular_science_summary: (
    title: "Popular Science Title",
    abstract: [Popular science abstract goes here.],
    body: [Popular science content goes here.]
  ),
)

= Introduction

Your thesis content starts here...

#bibliography("references.bib")

#createAppendices([
  = First Appendix
  Your appendix content here...
])
```

## Full Example

See [`main.typ`](https://github.com/theolundqvist/lth-msc-cs-typst-template/blob/main/main.typ) for a complete example with all features demonstrated.

## Features

- Beautiful and modern title page design following LTH's visual identity
- Proper page numbering and headers
- Support for figures, tables, and equations with correct numbering
- Bibliography support using IEEE citation style
- Popular science summary section
- Support for both English and Swedish titles
- Proper margin settings according to university guidelines
- Automatic table of contents generation
- Support for appendices

## Dependencies

- Typst 0.13.0 or later

## License

This Typst template is licensed under the MIT license. The original LaTeX template by Flavius Gruian remains unlicensed and is available at [bitbucket.org/flavius_gruian/msccls](https://bitbucket.org/flavius_gruian/msccls/src/master/).

## Acknowledgments

This template is based on the official LaTeX template by Flavius Gruian and Camilla Lekebjer.