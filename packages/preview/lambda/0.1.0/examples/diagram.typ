#import "/src/lib.typ": *

#show raw.where(block: true): set block(
  fill: luma(244),
  inset: 6pt,
  radius: 3pt,
  width: 100%,
)

= diagram

```typ
#display(const.omega)
#diagram(const.omega)
```
#display(const.omega)
#diagram(const.omega)

```typ
#let e = func(
  var("a", color: red),
  apply(
    parse("/ab.ab", color: green),
    parse("/cd.cd", color: blue),
    var("a", color: yellow),
    color: purple,
  ),
)
#stack(dir: ltr, spacing: 1em, diagram(e), diagram(beta-first(e)))
```
#let e = func(
  var("a", color: red),
  apply(
    parse("/ab.ab", color: green),
    parse("/cd.cd", color: blue),
    var("a", color: yellow),
    color: purple,
  ),
)
#stack(dir: ltr, spacing: 1em, diagram(e), diagram(beta-first(e)))

```typ
#display(random-color(const.fact))
#diagram(random-color(const.fact))
```
#display(random-color(const.fact))
#diagram(random-color(const.fact))
