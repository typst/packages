#import "@preview/fontawesome:0.6.1": *

#let colorize(svg, color) = {
  let blk = black.to-hex()
  if svg.contains(blk) {
    svg.replace(blk, color.to-hex())
  } else {
    svg.replace("<svg ", "<svg fill=\"" + color.to-hex() + "\" ")
  }
}

#let color-svg-path(
  path,
  color,
  ..args,
) = {
  let data = colorize(read(path), color)
  return image(bytes(data), ..args)
}

#let admon-blk(
  color: black,
  icon-fa: none,
  icon-svg: none,
  icon: none,
  icon-fa-solid: true,
  title: "",
  content,
) = {
  stack(
    block(
      width: 100%,
      fill: color,
      stroke: color,
      outset: (x: 1em),
      inset: (x: 0pt, top: 3pt, bottom: 4pt),
      radius: (top: 0.4em, bottom: 0em),

      if (icon-fa != none) {
        place(bottom + left, dx: -1.4em, dy: -0.1em, circle(fill: white, stroke: color, inset: 0.03em)[#set align(
            center + horizon,
          )
          #text(color, baseline: -0.15em, size: 0.8em)[#fa-icon(icon-fa, solid: icon-fa-solid)]
        ])
      } else if (icon-svg != none) {
        place(bottom + left, dx: -1.4em, dy: -0.1em, circle(fill: white, stroke: color, inset: 0.03em)[#set align(
            center + horizon,
          )
          #color-svg-path(icon-svg, color, width: 0.8em, height: 0.8em)
        ])
      } else if (icon != none) {
        place(bottom + left, dx: -1.4em, dy: -0.1em, circle(fill: white, stroke: color, inset: 0.03em)[#set align(
            center + horizon,
          )
          #text(color, size: 0.65em)[#icon]
        ])
      }
        + text(
          white,
        )[#strong(
          title,
        )],
    ),
    block(
      width: 100%,
      fill: color.lighten(80%),
      stroke: color,
      outset: (x: 1em),
      radius: (top: 0em, bottom: 0.4em),
      inset: (x: 0pt, top: 5pt, bottom: 5pt),
      content,
    ),
  )
}

#let note-blk(title: "Note", content) = {
  admon-blk(title: title, color: rgb("#0969DA"), icon-fa: "pen-to-square", content)
}

#let tip-blk(title: "Tip", content) = {
  admon-blk(title: title, color: rgb("#1F883D"), icon-fa: "lightbulb", content)
}

#let question-blk(title: "Question", content) = {
  admon-blk(title: title, color: rgb("#007F7F"), icon-fa: "clipboard-question", content)
}

#let important-blk(title: "Important", content) = {
  admon-blk(title: title, color: rgb("#8250DF"), icon-fa: "exclamation", content)
}

#let warm-blk(title: "Warning", content) = {
  admon-blk(title: title, color: rgb("#9A6700"), icon-fa: "triangle-exclamation", content)
}

#let caution-blk(title: "Caution", content) = {
  admon-blk(title: title, color: rgb("#BF0000"), icon-fa: "fire", content)
}
