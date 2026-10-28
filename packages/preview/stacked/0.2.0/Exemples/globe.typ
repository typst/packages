// #import "../polysection.typ": polysection
// #import "../solidvertices.typ": regpolyhedron

#import "../solidsection.typ": globe, globe-view

#set page(height: auto,margin:4mm, width: auto)
#grid(columns: 3, gutter: 8mm, align: center+horizon,
globe(..globe-view(lon: 30, lat: 25), radius: 2.6, show-axis: true, show-tropics: true, graticule: 30, points: ("Paris", "Le Caire", "Dakar"), point-labels: (n: $N$)),
globe(..globe-view(lon: 60, lat: 20), radius: 2.6, show-axis: true,
      points: (("city": "Tokyo", angles: true),), point-labels: (o: $O$, g: $G$), show-centers: true),
globe(..globe-view(lon: -30, lat: 15), radius: 2.6, 0,1,0,-1.7, graticule: 30,
      points: (("city": "New York", angles:true), "Rio de Janeiro"), lat-label: $40.7$, lon-label: $-74$)
)