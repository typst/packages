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
  c("#when-flag-clicked[...]"),                          when-flag-clicked([]),
  c("#when-key-pressed(\"space\")[...]"),                when-key-pressed("space", []),
  c("#when-sprite-clicked[...]"),                        when-sprite-clicked([]),
  c("#when-backdrop-switches(\"backdrop\")[...]"),        when-backdrop-switches("backdrop", []),
  c("#when-exceeds(\"timer\", 5)[...]"),                 when-exceeds("timer", 5, []),
  c("#when-message-received(\"start\")[...]"),           when-message-received("start", []),
  c("#broadcast(\"message\")"),                          broadcast("message"),
  c("#broadcast-and-wait(\"message\")"),                 broadcast-and-wait("message"),
)
