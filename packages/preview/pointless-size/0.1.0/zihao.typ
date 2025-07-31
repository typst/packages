#let size_to_pt = (
  (8, 5pt),
  (7, 5.5pt),
  (-6, 6.5pt),
  (6, 7.5pt),
  (-5, 9pt),
  (5, 10.5pt),
  (-4, 12pt),
  (4, 14pt),
  (-3, 15pt),
  (3, 16pt),
  (-2, 18pt),
  (2, 22pt),
  (-1, 24pt),
  (1, 26pt),
  ("-0", 36pt),
  (0, 42pt),
)

#let zh(size, overrides: ()) = {
  let rules = (..overrides, ..size_to_pt)
  let rule = rules.find(((s, p)) => s == size)
  if rule != none {
    rule.at(1)
  } else {
    panic("expected a valid size (zìhào), found " + repr(size) + ". (All valid sizes: " + rules.map(r => repr(r.at(0))).join(", ") + ".)")
  }
}

#let zihao(size, overrides: ()) = {
  body => {
    set text(size: zh(size, overrides: overrides))
    body
  }
}
