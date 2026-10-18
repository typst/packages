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
  c("#add(5, 3)"),                        add(5, 3),
  c("#subtract(10, 4)"),                  subtract(10, 4),
  c("#multiply(3, 4)"),                   multiply(3, 4),
  c("#divide(10, 2)"),                    divide(10, 2),
  c("#pick-random(from: 1, to: 10)"),     pick-random(from: 1, to: 10),
  c("#greater-than(5, 3)"),               greater-than(5, 3),
  c("#less-than(3, 5)"),                  less-than(3, 5),
  c("#equals(5, 5)"),                     equals(5, 5),
  c("#op-and(operand1, operand2)"),        op-and([], []),
  c("#op-or(operand1, operand2)"),         op-or([], []),
  c("#op-not(operand)"),                   op-not([]),
  c("#join(\"apple\", \"banana\")"),       join("apple", "banana"),
  c("#letter-of(1, \"world\")"),           letter-of(1, "world"),
  c("#length-of(\"world\")"),             length-of("world"),
  c("#contains(\"apple\", \"a\")"),        contains("apple", "a"),
  c("#mod(10, 3)"),                        mod(10, 3),
  c("#round(3.14)"),                       round(3.14),
  c("#mathop(\"sqrt\", 9)"),              mathop("sqrt", 9),
)
