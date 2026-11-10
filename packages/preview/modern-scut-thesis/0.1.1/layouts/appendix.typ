// SCUT 附录：独立标题及图表编号
#import "@preview/i-figured:0.2.4"
#import "../utils/custom-numbering.typ": custom-numbering

#let appendix(
  numbering: custom-numbering.with(first-level: "", depth: 4, "1.1 "),
  show-figure: i-figured.show-figure.with(numbering: "1.1"),
  show-equation: i-figured.show-equation.with(numbering: "(1.1)"),
  reset-counter: false,
  it,
) = {
  set heading(numbering: numbering)
  if reset-counter {
    counter(heading).update(0)
  }
  show figure: show-figure
  show math.equation.where(block: true): show-equation
  it
}
