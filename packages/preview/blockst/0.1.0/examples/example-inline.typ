// Inline example – scratch blocks without #blockst wrapper
// #blockst[] only adds scaling; blocks render fine directly in document flow.
// Practical use case: placing blocks in a grid/table layout.
#import "@preview/blockst:0.1.0": scratch

#set page(width: auto, height: auto, margin: 5mm, fill: white)

#import scratch.en: *

*Without `#blockst` — 1:1 scale, place blocks anywhere in layout:*

#v(3mm)

#grid(
  columns: (auto, auto),
  gutter: 4mm,
  // Column 1: description
  [
    *Step 1* \
    Move the sprite forward.
  ],
  // Column 2: block
  when-flag-clicked[
    #move(steps: 10)
  ],

  [
    *Step 2* \
    Repeat and turn.
  ],
  repeat(times: 4)[
    #move(steps: 50)
    #turn-right(degrees: 90)
  ],
)
