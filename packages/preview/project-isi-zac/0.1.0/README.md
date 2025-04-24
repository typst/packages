# project-isi-zac

A Typst template for writing reports and theses, with sensible defaults and examples.

---

## Getting Started

### Web App

You can start a new project in the Typst web app using the HIT thesis template: https://typst.app/?template=project-isi-zac&version=latest

##### To work locally, use the following command:

```bash
typst init @preview/project-isi-zac
```

### Basic usage:

```typst
#import "@preview/project-isi-zac": config

#show: config.with(
  display : ("titlepage", "toc"), // pass the arguments you want to dispaly  horizon
  title: [Crazy Good Thesis Title],
  // Add affiliations to the authors
  authors: (
    "Author 1",
    "Author 2",
  ),
  uni_info : (
    department: [Some Department],
    university: [University name],
    faculty: [Faculty Name],
    academic_year: "2024/2025"
  ),
  date: datetime.today().display("[day] [month repr:long] [year]"),
  // This is to make the template more general
  img: rect(width: 20em, height: 10em, fill: luma(240))[
    #align(center + horizon)[      #text(size: 2em, weight: "black")[Image]
    ]
  ],
)

// Example Usa
#include "chapters/chapter-1.typ"
#include "chapters/chapter-2.typ"
#include "chapters/conclusions.typ"

// ------------- Display Bibliography ------------- 

#bibliography("refs.bib", style: "apa")
```

### Acknowledgments

- [modern-report-umfds](https://typst.app/universe/package/modern-report-umfds/)
- [tgm-hit-thesis](https://typst.app/universe/package/tgm-hit-thesis/)
