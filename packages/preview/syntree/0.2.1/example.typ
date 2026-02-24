#import "@local/syntree:0.2.0": syntree

#figure(
  caption: "Example of a syntax tree.",
  gap: 2em,
  syntree(
    nonterminal: (fill: blue),
    terminal: (style: "italic"),
    "[S [NP [Det the] [Nom [Adj little] [N bear]]] [VP [VP [V saw] [NP [Det the] [Nom [Adj fine] [Adj fat] [N trout]]]] [PP [P in] [^NP the brook]]]]"
  )
)
