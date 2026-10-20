#import "defs.typ": accent-color, smaller-font-size

#let star(
  size: 0.65em,
  arms: 8,
  tip-radius: 1.2,
  waist-radius: 0.30,
  rotation: -90deg,
  fill: black,
  stroke: none,
) = {
  let vertices = range(arms * 2).map(i => {
    let angle = rotation + i * 360deg / (arms * 2)
    let radius = if calc.even(i) {
      tip-radius
    } else {
      waist-radius
    }

    (
      50% + 50% * radius * calc.cos(angle),
      50% + 50% * radius * calc.sin(angle),
    )
  })

  box(
    width: size,
    height: size,
    polygon(
      fill: fill,
      stroke: stroke,
      ..vertices,
    ),
  )
}

#let arrowhead(
  size: 0.6em,
  baseline: +0.3em,
  fill: accent-color,
) = text(
  size: size,
  baseline: baseline,
  fill: fill,
  "➤",
)

#let dotted-line(
  width: 1fr,
  length: 99%, // HACK: prevent extra dot at the end
  stroke: (dash: "loosely-dotted"),
  baseline: -0.3em,
) = box(
  width: width,
  line(length: length, stroke: stroke),
  baseline: baseline,
)


#let draft-pattern = {
  let element = text(size: 2em, fill: gray.opacify(-90%))[*DRAFT*]
  let pattern = tiling(size: (90pt, 40pt), element)
  rotate(-25deg, rect(width: 150%, height: 150%, fill: pattern))
}

#let detail-stack(..items) = {
  let entries = items.pos().filter(item => item != none)
  if entries.len() == 0 {
    return none
  }

  entries.join(linebreak())
}

#let inline-heading(size: smaller-font-size, delimiter: true, body) = text(
  size: size,
  weight: "bold",
  fill: accent-color,
  strong(body) + if delimiter { " " } else { none },
)
