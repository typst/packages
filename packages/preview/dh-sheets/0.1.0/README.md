# DH Sheets

DH Sheets is a Typst template for generate answer sheets for exams in which questions are stored separately. This template was purpose-built for Carnegie Mellon Science Olympiad, but is generally applicable to exams.

## Configuration

A sample configuration for an academic exam, after importing the package, could look similar to the following:

```typst
#show: dh-sheets.with(
  institute: "CMU Science Olympiad",
  author: "Name Here",
  exam-name: "Answer Sheet",
  date: [1 Jan 2027],
  show-per-page-points: false,
  student-fields: [
    *Name* #box(stroke: (bottom: 0.4pt), width: 1fr)
    #v(1em)
    *Student ID* #box(stroke: (bottom: 0.4pt), width: 1fr)
  ],
  instructions: [It may be beneficial to use pencil, in the case you must edit any answers. Extra scrap paper is available, however it will not be graded and your final answers must be marked here.
    #v(0.7em)
    Please make sure to clearly mark your final answer by, for example, boxing it.]
)

// Questions here.
```

A more detailed example and documentation is available in `example.typ`.

## Credit

This template is originally based on [https://typst.app/universe/package/examify](https://typst.app/universe/package/examify), MIT License. All props to them for the foundation of this template.

## Contact

This template was created by Alex Seltzer. He may be reached for any quesions or concerns at alexseltzer@cmu.edu.
