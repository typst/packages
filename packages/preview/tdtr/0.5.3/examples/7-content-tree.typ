#import "@preview/tdtr:0.5.3": *

#set page(height: auto, width: auto, margin: 1em)
#show: scale.with(125%, reflow: true)

#content-tree-graph[
  = Heading 1

  `int main() {}` <code>

  $
    integral_0^infinity e^(-x) dif x
  $
]
