#import "../curryst.typ": rule, proof-tree
#set document(date: none)
#set page(width: auto, height: auto, margin: 0.5cm, fill: white)

#let tree = rule(
  label: [Label],
  name: [Rule name],
  [Conclusion],
  [Premise 1],
  [Premise 2],
  [Premise 3]
)

#proof-tree(tree)
