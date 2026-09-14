// Raw Algorithms
#import "../helpers.typ": *

= Raw Algorithms

For direct computation without the point registry, use the `raw` dictionary:

```typst
// Direct centroid calculation
let center = raw.ctz-def-centroid((0,0,0), (3,0,0), (1.5,2.5,0))

// Distance between points
let d = raw.dist((0,0,0), (3,4,0))  // Returns 5

// Line-line intersection
let pt = raw.line-line((0,0,0), (1,1,0), (0,1,0), (1,0,0), ray: true)
```

Available raw functions:
- *Intersections*: `line-line`, `line-circle`, `circle-circle`
- *Triangle centers*: `ctz-def-centroid`, `ctz-def-circumcenter`, `ctz-def-incenter`, `ctz-def-orthocenter`, `euler-center`, `ctz-def-lemoine`, etc.
- *Transformations*: `ctz-def-rotation`, `reflection`, `translation`, `ctz-def-homothety`, `projection`, `ctz-def-inversion`
- *Utilities*: `ctz-def-midpoint`, `dist`, `angle-at-vertex`, `triangle-area`, etc.

#pagebreak()

