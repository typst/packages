#import "@preview/blockst:0.1.0": scratch, set-blockst
#set page(width: auto, height: auto, margin: (x: 3mm, y: 3mm), fill: none)
#import scratch.en: *
#set-blockst(scale: 82%)

#let c(s) = raw(lang: "typst", s)
#let jump = custom-block("jump ", (name: "h"), " px")

#table(
  columns: (auto, auto),
  align: (left + horizon, left + horizon),
  row-gutter: 4pt,
  inset: (x: 6pt, y: 5pt),
  stroke: (x, y) => (top: if y > 0 { 0.4pt + luma(215) } else { none }, bottom: none, left: none, right: none),
  c("#let jump = custom-block(\"jump \", (name: \"h\"), \" px\")"),   jump(40),
  c("#define(jump, body)"),                                            define(jump, change-y(dy: parameter("h"))),
  c("#jump(40)"),                                                      jump(40),
  c("#parameter(\"h\")"),                                              parameter("h"),
  c("#custom-input(\"text\")"),                                        custom-input("Score"),
)
