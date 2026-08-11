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
  c("#play-sound-until-done(\"Meow\")"),              play-sound-until-done("Meow"),
  c("#start-sound(\"Meow\")"),                        start-sound("Meow"),
  c("#stop-all-sounds()"),                            stop-all-sounds(),
  c("#change-sound-effect-by(\"pitch\", value: 10)"), change-sound-effect-by("pitch", value: 10),
  c("#set-sound-effect-to(\"pitch\", value: 100)"),   set-sound-effect-to("pitch", value: 100),
  c("#clear-sound-effects()"),                        clear-sound-effects(),
  c("#change-volume-by(volume: -10)"),                change-volume-by(volume: -10),
  c("#set-volume-to(volume: 100)"),                   set-volume-to(volume: 100),
  c("#volume()"),                                     volume(),
)
