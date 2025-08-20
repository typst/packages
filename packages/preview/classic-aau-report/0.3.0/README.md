# Classic AAU Report

Unofficial Typst template for project reports at Aalborg University (AAU).
This is based on the LaTeX template [https://github.com/jkjaer/aauLatexTemplates](https://github.com/jkjaer/aauLatexTemplates).

The template is generic to any field of study, but defaults to Computer Science.

## Usage

Click "Create project in app".

Or via the CLI

```bash
typst init @preview/classic-aau-report
```

**NOTE:**
The template tries to use the `Palatino Linotype` font, which is *not* available in Typst.
It is available [here](https://github.com/Tinggaard/classic-aau-report/releases/tag/fonts) ([direct download](https://github.com/Tinggaard/classic-aau-report/releases/download/fonts/PalatinoLinotype.zip))

To use it in the *web-app*, put the `.ttf` files anywhere in the project tree.

To use it *locally* specify the `--font-path` flag (or see the [docs](https://typst.app/docs/reference/text/text/#parameters-font)).

## Confugiration

The `project` function takes the following (optional) arguments:

- `meta`: Metadata about the project
  - `project-group`: The project group name
  - `participants`: A list of participants
  - `supervisors`: A list of supervisors
  - `field-of-study`: The field of study
  - `project-type`: The type of project

- `en`: English project info
  - `title`: The title of the project
  - `theme`: The theme of the project
  - `abstract`: The English abstract of the project
  - `department`: The department name
  - `department-url`: The department URL

- `dk`: Danish project info
  - `title`: The Danish title of the project
  - `theme`: The theme of the project in Danish
  - `abstract`: The Danish abstract of the project
  - `department`: The department name in Danish
  - `department-url`: The Danish department URL

The defaults are as follows:

```typ
#let defaults = (
  meta: (
    project-group: "No group name provided",
    participants: (),
    supervisors: (),
    field-of-study: "Computer Science",
    project-type: "Semester Project"
  ),
  en: (
    title: "Untitled",
    theme: "",
    abstract: [],
    department: "Department of Computer Science",
    department-url: "https://www.cs.aau.dk",
  ),
  dk: (
    title: "Uden titel",
    theme: "",
    abstract: [],
    department: "Institut for Datalogi",
    department-url: "https://www.dat.aau.dk",
  ),
)
```

Furthermore, the template exports the show rules

- `mainmatter`: Sets the page numbering to arabic and chapter numbering to none
- `chapters`: Sets the chapter numbering `Chapter` followed by a number.
- `backmatter`: Sets the chapter numbering back to none
- `appendix`: Sets the chapter numbering to `Appendix` followed by a letter.

To use it in an existing project, add the following show rule.

```typ
#import "@preview/classic-aau-report:0.3.0": project, mainmatter, chapters, backmatter, appendix

// Any of the below can be omitted, the defaults are either empty values or CS specific
#show: project.with(
  meta: (
    project-group: "CS-xx-DAT-y-zz",
    participants: (
      "Alice",
      "Bob",
      "Chad",
    ),
    supervisors: "John McClane"
  ),
  en: (
    title: "An Awesome Project",
    theme: "Writing a project in Typst",
    abstract: [],
  ),
  // omit the `dk` option completely to remove the Danish titlepage
  dk: (
    title: "Et Fantastisk Projekt",
    theme: "Et projekt i Typst",
    abstract: [],
  ),
)

#show: mainmatter
#include "chapters/introduction.typ"

#show: chapters
#include "chapters/problem-analysis.typ"

#show: backmatter
#include "chapters/conclusion.typ"
#bibliography("references.bib", title: "References")

#show: appendix
#include "appendices/some-appendix.typ"
```
