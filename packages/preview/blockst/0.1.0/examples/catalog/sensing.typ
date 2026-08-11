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
  c("#touching-object(\"edge\")"),                         touching-object("edge"),
  c("#touching-color(blue)"),                              touching-color(blue),
  c("#color-is-touching-color(blue, green)"),              color-is-touching-color(blue, green),
  c("#distance-to(\"mouse-pointer\")"),                    distance-to("mouse-pointer"),
  c("#ask-and-wait(\"What's your name?\")"),               ask-and-wait("What's your name?"),
  c("#answer()"),                                          answer(),
  c("#key-pressed(\"space\")"),                            key-pressed("space"),
  c("#mouse-down()"),                                      mouse-down(),
  c("#mouse-x()"),                                         mouse-x(),
  c("#mouse-y()"),                                         mouse-y(),
  c("#set-drag-mode(\"draggable\")"),                      set-drag-mode("draggable"),
  c("#loudness()"),                                        loudness(),
  c("#timer()"),                                           timer(),
  c("#reset-timer()"),                                     reset-timer(),
  c("#property-of(\"x position\", \"Sprite1\")"),          property-of("x position", "Sprite1"),
  c("#current(\"year\")"),                                 current("year"),
  c("#days-since-2000()"),                                 days-since-2000(),
  c("#username()"),                                        username(),
)
