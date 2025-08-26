#import "../src/lib.typ": *

#show raw.where(lang: "graph"): enable-graph-in-raw(tree-render)

```graph
#ed-bd: 100deg;
#scl: 0.8;
1-2, 3, 4;
5-6, 7, 8;
2- 3, 4;
6 - 7, 8;
3 > 7;
4- 8;
```

```graph
#ed-bd: -30deg;
A.F: $|_name|$;
A - B;
B - C;
C -[from $|_from|$ to $|_to|$]- D, E;
D -E, F;
```

```graph
  A.F: [#circle(radius: 2pt,  fill: black)];
  A-[a]-B.D;
  B-E;
  C-F;
```
```graph
@multi-edge;
A-B;
A-bend:30deg-B;
```
