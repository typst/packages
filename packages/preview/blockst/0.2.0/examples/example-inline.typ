#import "@preview/blockst:0.2.0": scratch

#set page(width: 10cm, height: auto, margin: 5mm, fill: white)

#grid(
  columns: (1fr, auto),
  gutter: 6mm,
  [*Step 1*\
  Trigger the script and walk forward.],
  [#scratch("when green flag clicked\nmove (20) steps")],
  [*Step 2*\
  Repeat a square movement.],
  [#scratch("repeat (4)\nmove (40) steps\nturn cw (90) degrees\nend")],
)
