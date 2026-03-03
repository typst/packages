#import "@preview/tdtr:0.5.3": *

#set page(height: auto, width: auto, margin: 1em)
#show: scale.with(125%, reflow: true)

#tidy-tree-graph(yaml("trees/test.yaml"))
