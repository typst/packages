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
  c("#wait(duration: 1)"),                                    wait(duration: 1),
  c("#repeat(times: 10)[...]"),                               repeat(times: 10, []),
  c("#forever[...]"),                                         forever([]),
  c("#if-then(condition)[...]"),                              if-then([], []),
  c("#if-then-else(condition, [...], [...])"),                 if-then-else([], [], []),
  c("#wait-until(condition)"),                                wait-until([]),
  c("#repeat-until(condition)[...]"),                          repeat-until([], []),
  c("#stop(\"all\")"),                                        stop("all"),
  c("#when-i-start-as-clone[...]"),                           when-i-start-as-clone([]),
  c("#create-clone-of(\"myself\")"),                          create-clone-of("myself"),
  c("#delete-this-clone()"),                                  delete-this-clone(),
)
