#import "../utils/style.typ": 字号

#let algorithm-figure = figure.where(kind: "algorithm")

#let algorithm-label(number, loc) = context {
  let heading-number = counter(heading).at(loc).first()
  let is-appendix = query(selector(<appendix-start>).before(loc)).len() > query(selector(<appendix-end>).before(loc)).len()
  let appendix-count = query(
    selector(heading.where(level: 1)).after(selector(<appendix-start>)).before(selector(<appendix-end>)),
  ).len()
  if is-appendix {
    let appendix-prefix = if appendix-count > 1 {
      numbering("A", heading-number)
    } else {
      numbering("A", 1)
    }
    [#appendix-prefix-#numbering("1", number)]
  } else {
    numbering("1-1", heading-number, number)
  }
}

#let reset-algorithm-counter = it => {
  counter(algorithm-figure).update(0)
  it
}

#let algorithm-numbering(number) = context algorithm-label(number, here())

#let algorithm-step-rows(steps) = {
  let rows = ()
  for (index, step) in steps.enumerate() {
    rows.push([#(index + 1)])
    rows.push(step)
  }
  rows
}

#let algorithm-ref(label) = context {
  let element = query(label).first()
  link(
    element.location(),
    [算法 #algorithm-label(counter(algorithm-figure).at(element.location()).first(), element.location())],
  )
}

#let algorithm(title: none, input: none, output: none, steps: ()) = figure(
  kind: "algorithm",
  supplement: [算法],
  numbering: algorithm-numbering,
  outlined: false,
  caption: none,
  table(
    columns: (2.8em, 1fr),
    stroke: none,
    inset: (x: 0.3em, y: 0.4em),
    align: (right, left),

    table.hline(y: 0, stroke: 1.5pt),
    table.cell(colspan: 2, align: left)[
      #set text(size: 字号.五号)
      #strong[算法 #context algorithm-numbering(counter(algorithm-figure).get().first())] #title
    ],
    table.hline(y: 1, stroke: 0.5pt),
    table.cell(colspan: 2, align: left)[
      #set text(size: 字号.五号)
      *输入：* #input
    ],
    table.cell(colspan: 2, align: left)[
      #set text(size: 字号.五号)
      *输出：* #output
    ],
    ..algorithm-step-rows(steps),
    table.hline(y: 3 + steps.len(), stroke: 1.5pt),
  ),
)
