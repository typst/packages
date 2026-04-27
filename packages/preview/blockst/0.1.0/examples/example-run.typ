// Example – Scratch-run (turtle graphics)
#import "@preview/blockst:0.1.0": blockst, scratch, scratch-run, set-scratch-run

#set page(width: auto, height: auto, margin: 3mm, fill: white)

#import scratch.exec.en: *

// Simple square
#scratch-run(
  pen-down(),
  square(size: 70),
)

#v(4mm)

// Coloured square spiral — each side grows by 5 units
#set-scratch-run(show-grid: true, show-axes: true, show-cursor: false)

#scratch-run(
  set-pen-color(color: rgb("#4C97FF")),
  set-pen-size(size: 1),
  pen-down(),
  ..for i in range(1, 20) {
    (move(steps: i * 5), turn-right(degrees: 90))
  },
)

#set-scratch-run(show-grid: false, show-axes: false)
