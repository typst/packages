#let todo(info: "", it) = {
  box(
    figure(
      kind: "todo",
      supplement: info.slice(0, count: calc.min(30, info.len())) // first 30 letters
        + if info.len() > 30 [...] else [], // add "..." if string was longer than 30 chars
      //supplement: "TODO: " + info,
      block(
        fill: rgb(255, 0, 0, 20),
        inset: (top: if (info != "") { 8pt } else { 2pt }, bottom: 2pt, left: 2pt, right: 2pt),
        radius: 4pt,
        stroke: (right: 2pt + red),
        it,
      )
        + place(
          left + top,
          dx: 2pt,
          dy: 2pt,
          text(
            fill: red,
            size: 8pt,
            info,
          ),
        ),
    ),
  )
}

