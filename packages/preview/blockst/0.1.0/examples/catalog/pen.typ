#import "@preview/blockst:0.1.0": scratch, set-blockst
#set page(width: auto, height: auto, margin: (x: 3mm, y: 3mm), fill: none)
#import scratch.en: *
#set-blockst(scale: 82%)

#let c(s) = raw(lang: "typst", s)

#table(
  columns: (auto, auto),
  align: (left + horizon, left + horizon),
  row-gutter: 4pt,
  inset: (x: 6pt, y: 5pt),
  stroke: (x, y) => (top: if y > 0 { 0.4pt + luma(215) } else { none }, bottom: none, left: none, right: none),
  c("#erase-all()"),                                erase-all(),
  c("#stamp()"),                                    stamp(),
  c("#pen-down()"),                                 pen-down(),
  c("#pen-up()"),                                   pen-up(),
  c("#set-pen-color-to(blue)"),                     set-pen-color-to(blue),
  c("#change-pen-param-by(\"color\", value: 10)"),  change-pen-param-by("color", value: 10),
  c("#set-pen-param-to(\"color\", value: 50)"),     set-pen-param-to("color", value: 50),
  c("#change-pen-size-by(size: 1)"),                change-pen-size-by(size: 1),
  c("#set-pen-size-to(size: 1)"),                   set-pen-size-to(size: 1),
)
