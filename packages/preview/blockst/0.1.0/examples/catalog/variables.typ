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
  c("#set-variable-to(\"score\", 0)"),                     set-variable-to("score", 0),
  c("#change-variable-by(\"score\", 1)"),                  change-variable-by("score", 1),
  c("#show-variable(\"score\")"),                          show-variable("score"),
  c("#hide-variable(\"score\")"),                          hide-variable("score"),
  c("#variable-display(name: \"score\", value: 42)"),      variable-display(name: "score", value: 42),
)
