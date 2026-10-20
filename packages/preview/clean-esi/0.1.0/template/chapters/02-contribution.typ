#import "@preview/clean-esi:0.1.0": thesis-algorithm, thesis-code-block, warning-box

= Contribution <ch:contribution>

== Architecture
@fig:architecture shows the architecture. Figure captions render below the figure.

#figure(
  // e.g. image("figures/architecture.png", width: 80%)
  rect(width: 70%, height: 4cm, stroke: 0.5pt)[#align(center + horizon)[Replace this box with an image]],
  caption: [Overall architecture.],
) <fig:architecture>

== Algorithm

#thesis-algorithm(caption: [Example procedure.])[
  + *Input:* a list $L$
  + *for each* $x in L$ *do*
    + process $x$
  + *return* result
]

== Implementation

#thesis-code-block(numbering: true)[
```python
def main():
    print("Hello, ESI")
```
]

#warning-box[Note][
  Keep evaluation claims backed by the results you report.
]
