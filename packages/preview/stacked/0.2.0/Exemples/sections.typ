#import "../polysection.typ": polysection
#import "../solidsection.typ":cylsection, doubleconesection, spheresection
#import "../solidvertices.typ": regpolyhedron
#set page(height: auto,margin:4mm, width: auto)
#grid(columns: 4, gutter: 8mm, align: center+horizon,
polysection(0.3, 1, 0.2, 0, vertices: regpolyhedron("dodécaèdre", side: 1.5)),
cylsection((0,0.5,0.5),(1,0.3,-0.2),(-0.6,1.4,0.1), plane-names: ("A","B","C"), height: 2.5),
doubleconesection(1,0,0,-0.4, show-radius: true, show-centers: true, show-apex: true, point-labels: (s: $S$, c1: move($O'$,dx:-1em))),
spheresection(0,1,0,-0.5, center: (0,1,0), show-radius: true, show-centers: true, point-labels: (o: $O$, sc: $I$), radius: 2, radius-label: $2$, )
)