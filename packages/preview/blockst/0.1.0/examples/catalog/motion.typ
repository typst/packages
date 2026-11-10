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
  c("#move(steps: 10)"),                               move(steps: 10),
  c("#turn-right(degrees: 15)"),                       turn-right(degrees: 15),
  c("#turn-left(degrees: 15)"),                        turn-left(degrees: 15),
  c("#goto(\"random position\")"),                     goto("random position"),
  c("#goto-xy(x: 0, y: 0)"),                          goto-xy(x: 0, y: 0),
  c("#glide(secs: 1, \"random position\")"),           glide(secs: 1, "random position"),
  c("#glide-to-xy(secs: 1, x: 0, y: 0)"),             glide-to-xy(secs: 1, x: 0, y: 0),
  c("#point-in-direction(direction: 90)"),             point-in-direction(direction: 90),
  c("#point-towards(\"mouse-pointer\")"),              point-towards("mouse-pointer"),
  c("#change-x(dx: 10)"),                             change-x(dx: 10),
  c("#set-x(x: 0)"),                                  set-x(x: 0),
  c("#change-y(dy: 10)"),                             change-y(dy: 10),
  c("#set-y(y: 0)"),                                  set-y(y: 0),
  c("#if-on-edge-bounce()"),                          if-on-edge-bounce(),
  c("#set-rotation-style(\"left-right\")"),           set-rotation-style("left-right"),
  c("#x-position()"),                                 x-position(),
  c("#y-position()"),                                 y-position(),
  c("#direction()"),                                  direction(),
)
