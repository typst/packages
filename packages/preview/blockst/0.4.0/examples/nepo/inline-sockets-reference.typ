// Compact fixtures matching extra_block_1.svg and extra_block_5.svg.
#import "@preview/blockst:0.4.0": nepo, set-blockst

#set page(width: auto, height: auto, margin: 0pt, fill: none)
#set text(font: "Helvetica Neue", fallback: true)
#set-blockst(font: "Helvetica Neue")

#stack(
  dir: ttb,
  spacing: 18pt,
  nepo("und"),
  nepo("gib Wert ° Temperatursensor ≥ 0 und gib Wert ° Temperatursensor < 10"),
)
