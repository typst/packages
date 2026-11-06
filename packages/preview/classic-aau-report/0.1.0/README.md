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
It is available [here](https://github.com/Tinggaard/classic-aau-report/tree/main/fonts)

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

Furthermore, the template exports the shawrules

- `frontmatter`: Sets the page numbering to arabic and chapter numbering to none
- `mainmatter`: Sets the chapter numbering `Chapter` followed by a number.
- `backmatter`: Sets the chapter numbering back to none
- `appendix`: Sets the chapter numbering to `Appeendix` followed by a letter.

To use it in an existing project, add the following show rule to the top of your file.

```typ
#include "@preview/classic-aau-report:0.1.0": project, frontmatter, mainmatter, backmatter, appendix

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
    title: "An awesome project",
    theme: "Writing a project in Typst",
    abstract: [],
  ),
  dk: (
    title: "Et fantastisk projekt",
    theme: "Et projekt i Typst",
    abstract: [],
  ),
)

// #show-todos()

#show: frontmatter
#include "chapters/introduction.typ"

#show: mainmatter
#include "chapters/problem-analysis.typ"
#include "chapters/conclusion.typ"

#show: backmatter
#bibliography("references.bib", title: "References")

#show: appendix
#include "appendices/code-snippets.typ"
```
