#import "@preview/trompet:0.1.0": *
#set page(height: auto, width: 2in)

#tromp(
  labels: (a) => text($italic(#a)$, blue),
  mode: "line",
  style: (thickness: 2pt),
  "\\f.\\n.f (f (f n))",
)
