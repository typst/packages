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
  c("#add-to-list(\"thing\", \"list\")"),                  add-to-list("thing", "list"),
  c("#delete-of-list(1, \"list\")"),                       delete-of-list(1, "list"),
  c("#delete-all-of-list(\"list\")"),                      delete-all-of-list("list"),
  c("#insert-at-list(\"thing\", 1, \"list\")"),            insert-at-list("thing", 1, "list"),
  c("#replace-item-of-list(1, \"list\", \"thing\")"),      replace-item-of-list(1, "list", "thing"),
  c("#item-of-list(1, \"list\")"),                         item-of-list(1, "list"),
  c("#item-number-of-list(\"thing\", \"list\")"),          item-number-of-list("thing", "list"),
  c("#length-of-list(\"list\")"),                          length-of-list("list"),
  c("#list-contains-item(\"list\", \"thing\")"),           list-contains-item("list", "thing"),
  c("#show-list(\"list\")"),                               show-list("list"),
  c("#hide-list(\"list\")"),                               hide-list("list"),
)
