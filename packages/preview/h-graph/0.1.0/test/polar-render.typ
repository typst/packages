#import "../src/lib.typ": *
#show raw.where(lang: "graph"): enable-graph-in-raw(polar-render)

#let infos = h-graph-parser("A.C; B-A;")
#let (nodes, edges, render_args) = infos
#tree-render(
  ..render_args,
)(nodes: nodes, edges: edges)
```graph
#scl: 0.8;
1-2, 3, 4;
5-6, 7, 8;
2- 3, 4;
6 - 7, 8;
3 > 7;
4- 8;
```

```graph
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
@noloop;
A-A;
```
