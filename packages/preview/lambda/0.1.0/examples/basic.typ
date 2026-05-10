#import "/src/lib.typ": *

#show raw.where(block: true): set block(
  fill: luma(244),
  inset: 6pt,
  radius: 3pt,
  width: 100%,
)

= basic

```typ
#apply(parse("λx.xx"), parse("/y.yy")) // λ can be replaced with /
```
#apply(parse("λx.xx"), parse("/y.yy"))

```typ
#parse("/", "name", ".", "name") // multi char variable name
```
#parse("/", "name", ".", "name")

```typ
#display(simplify("(/x./y.((xy)z))"))
```
#display(simplify("(/x./y.((xy)z))"))

```typ
#display(expand("/xy.xyz"))
```
#display(expand("/xy.xyz"))

```typ
#free-vars("/x.xyz")
```
#free-vars("/x.xyz")

```typ
#display(apply(parse("/x.xx", color: red), parse("/y.yy", color: blue)))
```
#display(apply(parse("/x.xx", color: red), parse("/y.yy", color: blue)))
