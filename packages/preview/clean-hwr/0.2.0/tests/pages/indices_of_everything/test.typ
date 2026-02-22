#import "/pages/indices_of_everything.typ": _render-indices-of-everything

#include "/tests/helper/set-l10n-db.typ"

#let fig-idx = (
  enabled: true,

)
#let tab-idx = (
  enabled: true,
)
#let lis-idx = (
  enabled: true,
)

#figure()[Fig nr. 1]
#figure()[Fig nr. 2]
#figure()[Fig nr. 3]

#figure(table(columns: 2, [], [], [], []))
#figure(table(columns: 2, [], [], [], []))
#figure(table(columns: 2, [], [], [], []))

#figure[
```bash
sed "s/hello/world/g"
```
]

#figure[
```python
if __name__ == "__main__":
```
]

#figure[
```
Hello world!
```
]

#_render-indices-of-everything(
  figure-index: fig-idx,
  table-index: tab-idx,
  listing-index: lis-idx,
)

#_render-indices-of-everything(
  figure-index: (title: "Custom title figs", ..fig-idx),
  table-index: (title: "Custom title tables", ..tab-idx),
  listing-index: (title: "Custom title listings", ..lis-idx),
)
