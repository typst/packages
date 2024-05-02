# Structured-UiB - A lab report template for the course PHYS114 at UiB

Report template to be used for laboratory reports in the course PHYS114 - Basic Measurement Science and Experimental Physics, at the University of Bergen (https://www.uib.no/en/courses/PHYS114). The template is in Norwegian only as of now. English support may be added in the future.

The first part of the packages name is arbitrary, such that it follows the naming guidelines of Typst. 

**Note:** The template uses the fonts **STIX Two Text** and **STIX Two Math** (https://github.com/stipub/stixfonts/tree/master/fonts). If running Typst locally on your computer, make sure you have these fonts installed. There should be no font problems if you are using Typst via https://typst.app however.

Usage:
```typ
// IMPORTS
#import "@preview/structured-uib:0.1.0": *

// TEMPLATE SETTINGS
#show: report.with(
  task-no: "1",
  task-name: "Måling og behandling av måledata",
  authors: (
    "Student Enersen",
    "Student Toersen", 
    "Student Treersen"
  ),
  mails: (
    "student.enersen@student.uib.no", 
    "student.toersen@student.uib.no", 
    "student.treersen@student.uib.no"
  ),
  group: "1-1",
  date: "29. Apr. 2024",
  supervisor: "Professor Professorsen",
)

// CONTENT HERE...
```

Front page:
![thumbnail](https://github.com/AugustinWinther/structured-uib/assets/30674646/a93718d8-362d-453b-8047-3c3c4388d442)


## Licenses
`lib.typ` is licensed under MIT. The contents of the `template/` directory are licensed under MIT-0. The logo/emblem of the University of Bergen (located at `media/uib-emblem.svg`) is owned by their respective owners.
