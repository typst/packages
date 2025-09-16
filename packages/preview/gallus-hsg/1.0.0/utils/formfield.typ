#let formField(label, content, length: 5cm) = {
  stack(
    text(1em, weight: "bold")[#content],
    v(2mm),
    line(length: length),
    v(1mm),
    text(0.9em, style: "italic")[#label]
  )
}