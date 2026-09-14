#import "@preview/lambdabe:0.1.0": *

#show raw.where(block: true): set block(
  fill: luma(244),
  inset: 6pt,
  radius: 3pt,
  width: 100%,
)

= binary

```typ
#encode("/xyz.zxy")
```
#encode("/xyz.zxy")

```typ
#display(decode("00 00 00 01 01 10 1110 110")) // space is ignored
```
#display(decode("00 00 00 01 01 10 1110 110"))
