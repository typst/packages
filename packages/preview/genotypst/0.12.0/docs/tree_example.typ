#import "../src/lib.typ": *

#set page(
  fill: none,
  height: auto,
  width: 200mm,
  margin: 0cm,
)

#let theme = sys.inputs.at("theme", default: "light")
#let text-color = if theme == "dark" { rgb("#f0f6fc") } else { rgb("#000000") }
#set text(font: "Source Sans 3", fill: text-color)
#set align(center)
#show raw: set text(font: "Source Code Pro", size: 9pt)

#let tree = parse-newick(
  "(('Leaf A':0.2,'Leaf B':0.1)'Internal node':0.3,'Leaf C':0.6)Root;",
)

#render-rectangular-tree(
  tree,
  width: 110mm,
  height: 35mm,
  align-tip-labels: true,
  branch-stroke: stroke(thickness: 1pt, paint: text-color, cap: "square"),
)
