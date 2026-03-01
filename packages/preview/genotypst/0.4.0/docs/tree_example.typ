#import "../src/lib.typ": *

#set page(
  fill: none,
  height: auto,
  width: 200mm,
  margin: 0cm,
)

#set align(center)
#set text(font: "Source Sans 3")
#show raw: set text(font: "Source Code Pro", size: 9pt)

#let tree = parse-newick(
  "(('Leaf A':0.2,'Leaf B':0.1)'Internal node':0.3,'Leaf C':0.6)Root;",
)

#render-tree(tree)
