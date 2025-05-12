# Typst Templates for Students @ UPB CN

The Computer Networks Group at Paderborn University has a set of document templates prepared for students who participate in the teaching activities of the group.
This repository contains all templates in Typst.
For those who prefer LaTeX, please check [this repository](https://github.com/upb-cn/student-templates-latex).

Currently, the following templates are provided:

- Template for seminar report and review
- Template for BSc/MSc thesis proposal
- Template for BSc/MSc thesis

## How to Use the Templates

You can use the templates either via Typst's [web app](https://typst.app/universe/package/upb-cn-templates) ("Create project in app") or via its CLI (`typst init @preview/upb-cn-templates:0.1.0`).
If you are using Typst via the CLI, make sure that the ["Linux Biolinum"](https://www.dafont.com/linux-biolinum.font) font is installed on your machine.

For each type of document (seminar report/review, thesis proposal, thesis) there is a dedicated `typ` file that contains detailed instructions regarding how to fill in the document.
Please follow the instructions closely.

## API

The `@preview/upb-cn-templates` package exposes `upb-cn-report` and `upb-cn-thesis` show rule functions, as well as a `code` function for highlighted inline code.

The `upb-cn-report` show rule function is intended for seminar reports, seminar reviews, and thesis proposals. It is defined as follows:

```typst
#let upb-cn-report(
  title: "Title",
  author: none,
  matriculation-number: none,
  left-header: none, // defaults to title
  right-header: none, // defaults to author
  meta: none, // e.g. (([key1], [value1]), ([key2], [value2]))
  body,
) = ...
```

The `upb-cn-thesis` function is intended for Bachelor's and Master's theses. It is defined as follows:

```typst
#let upb-cn-thesis(
  title: "The Title",
  author: "The Author",
  degree: "Master of Sciences",
  submission-date: datetime.today().display("[month repr:long] [day], [year]"),
  second-reviewer: "The Second Reviewer",
  supervisors: ("Supervisor 1",),
  acknowledgement: lorem(100), // or `none`
  abstract: lorem(100),
  body,
) = ...
```

The `code` function is a simple wrapper around Typst's `raw` function that adds a gray background to inline source code.
