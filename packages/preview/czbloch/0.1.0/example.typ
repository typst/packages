#import "@preview/czbloch:0.1.0" as czbloch

#set page(margin: 0.1cm, height: auto, width: auto)

#let opts-1 = (angle-labels: false)
#let opts-2 = (angle-labels: false, sphere-style: "sphere")

#let examples = (
  (czbloch.bloch(state-color: red), `czbloch.bloch(state-color: red)`),
  (
    czbloch.bloch(..czbloch.one, sphere-style: "sphere"),
    `czbloch.bloch(.., sphere-style: "sphere")`,
  ),
  (
    czbloch.bloch(..czbloch.plus, ..opts-2, state-color: lime),
    `czbloch.bloch(.., angle-labels: false)`,
  ),
  (
    czbloch.bloch(..czbloch.minus, ..opts-1, state-color: fuchsia),
    none,
  ),
  (
    czbloch.bloch(phi: 50deg, theta: 30deg, ..opts-1, state-color: green),
    none,
  ),
  (
    czbloch.bloch(phi: -10deg, theta: 120deg, ..opts-2, state-color: orange),
    `czbloch.bloch(phi: -100deg, theta: 120deg, ..)`,
  ),
)

#set align(center)

#for pair in examples.chunks(2) {
  let drawings = pair.map(d => d.at(0))
  let code = pair.map(d => d.at(1))
  table(
    stroke: none,
    columns: 2,
    column-gutter: 0.5cm,
    ..drawings,
    ..code
  )
}
