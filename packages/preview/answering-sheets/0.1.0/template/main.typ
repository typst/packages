#import "@preview/answering-sheets:0.1.0": *

#show: answer-sheet.with(
  paper-size: "us-letter",
  institute: "CMU Science Olympiad",
  author: "Name here",
  exam-name: "Answer Sheet",
  date: [20 Feb 2027],
  instructions: [It may be beneficial to use pencil, in the case you must edit any answers. Extra scrap paper is available, however it will not be graded and your final answers must be marked here.
    #v(0.7em)
    Please make sure to clearly mark your final answer by, for example, boxing it.],
  student-fields: [
    *Competitor Names* #box(stroke: (bottom: 0.4pt), width: 1fr)
    #v(1em)
    *Team Name* #box(stroke: (bottom: 0.4pt), width: 1fr)
    #v(1em)
    *Team Number* #box(stroke: (bottom: 0.4pt), width: (20%))
  ],
)

