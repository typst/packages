#set page(width: auto, height: auto, margin: 0em)
#import "@preview/modern-tud-thesis:1.0.0": *

#grid(
  columns: 6,
  ..for (name, color) in colors {
    (
      box(
        fill: color,
        height: 1cm,
        width: 4cm,
        place(
          center + horizon,
          box(
            fill: white,
            inset: 4pt,
            radius: 4pt,
            name
          )
        )
      ),
    )
  }
)
