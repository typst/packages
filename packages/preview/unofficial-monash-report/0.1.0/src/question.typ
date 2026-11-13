#import "design.typ": *
#import "options.typ": require, valid-text, present
#import "page.typ": current-config
#import "labels.typ": labelled
#let question(marks: none, title: none, number: auto, ..args) = {
  for key in args.named().keys() { panic("unknown argument `" + key + "`") }
  require("body", args.pos().len() <= 1, "at most one statement")
  let body = args.pos().at(0, default: none)
  require(
    "marks", marks == none or type(marks) in (int, float, str, content),
    "none, number, str, or content",
  )
  require("title", valid-text(title), "none, str, or content")
  require("number", number == auto or type(number) == int and number > 0,
    "auto or a positive integer")
  require("body", valid-text(body), "none, str, or content")
  if number != auto { counter(figure.where(kind: "question")).update(number - 1) }
  figure(
    metadata((title: title, marks: marks, statement: body)),
    kind: "question", numbering: "1",
    supplement: _ => context current-config().labels.question,
  )
}
#let show-question(it) = context {
  let o = current-config()
  set align(left)
  set text(top-edge: body-top-edge, bottom-edge: body-bottom-edge)
  let data = it.body.value
  let number = counter(figure.where(kind: "question")).display(it.numbering)
  let title = if present(data.title) { [: #data.title] }
  let marks = if type(data.marks) in (int, float) {
    let unit = if data.marks == 1 { o.labels.mark } else { o.labels.marks }
    labelled(data.marks, unit, separator: if present(unit) { [ ] } else { [] })
  } else { data.marks }
  block(above: question-above, below: question-heading-gap, sticky: true,
    grid(
      columns: (1fr, auto),
      text(
        top-edge: body-top-edge, bottom-edge: zero, font: o.heading-font,
        size: section-size, weight: "bold", fill: o.accent,
      )[
        #labelled(o.labels.question, number, separator: [ ])#title
      ],
      if o.show-marks and present(data.marks) {
        text(size: label-size, style: "italic", fill: monash-grey-dark, marks)
      },
    ))
  if present(data.statement) {
    block(
      width: full, breakable: true,
      fill: if o.question-box { monash-grey-light },
      inset: if o.question-box { box-inset } else { zero },
      above: zero, below: question-gap,
      if o.question-box { pad(bottom: line-tail-space, data.statement) } else { data.statement },
    )
  }
}
