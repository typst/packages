#let cv(
  name: "John Smith",
  motto: "Hello! I am John Smith.",
  body,
) = {
  show heading.where(level: 2): it => block(
    inset: (bottom: 0.3em),
    stroke: (bottom: 0.5pt),
    width: 100%,
    text(fill: rgb("#26428b"), smallcaps(it.body)),
  )

  show link: set text(fill: blue)

  align(center, {
    heading(level: 1, name)
    motto
  })
  body
}

#let entry(
  title: [],
  interval: (
    start: "Once upon a time",
    end: "Present",
  ),
  title-note: [],
  interval-note: [],
) = block({
  let start = interval.at("start", default: "Once upon a time")
  if type(start) == datetime { start = start.display() }

  let end = interval.at("end", default: "Present")
  if type(end) == datetime { end = end.display() }

  strong(title) + h(0.5em) + box(width: 1fr, repeat[·]) + h(0.5em) + start + [ -- ] + end

  linebreak()

  if title-note != [] or interval-note != [] {
    emph(title-note + h(1fr) + interval-note)
  }
})
