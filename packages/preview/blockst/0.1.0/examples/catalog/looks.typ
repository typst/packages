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
  c("#say-for-secs(\"Hello!\", secs: 2)"),          say-for-secs("Hello!", secs: 2),
  c("#say(\"Hello!\")"),                            say("Hello!"),
  c("#think-for-secs(\"Hmm...\", secs: 2)"),        think-for-secs("Hmm...", secs: 2),
  c("#think(\"Hmm...\")"),                          think("Hmm..."),
  c("#switch-costume-to(\"costume1\")"),             switch-costume-to("costume1"),
  c("#next-costume()"),                             next-costume(),
  c("#switch-backdrop-to(\"backdrop1\")"),           switch-backdrop-to("backdrop1"),
  c("#next-backdrop()"),                            next-backdrop(),
  c("#change-size-by(change: 10)"),                 change-size-by(change: 10),
  c("#set-size-to(size: 100)"),                     set-size-to(size: 100),
  c("#change-effect-by(\"color\", change: 25)"),    change-effect-by("color", change: 25),
  c("#set-effect-to(\"color\", value: 0)"),         set-effect-to("color", value: 0),
  c("#clear-graphic-effects()"),                    clear-graphic-effects(),
  c("#show-sprite()"),                              show-sprite(),
  c("#hide-sprite()"),                              hide-sprite(),
  c("#goto-layer(\"front\")"),                      goto-layer("front"),
  c("#go-layers(num: 1, \"forward\")"),             go-layers(num: 1, "forward"),
  c("#costume-property(\"number\")"),               costume-property("number"),
  c("#backdrop-property(\"number\")"),              backdrop-property("number"),
  c("#size()"),                                     size(),
)
