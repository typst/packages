#import "@preview/upb-corporate-design-slides:0.1.0": *

#show: upb-theme.with(
  footer: self => self.info.title-short,
  config-info(
    title: [Touying Theme \ im Corporate Design der UPB],
    title-short: [Titel der Präsentation],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    lang: "de",
  ),
)

#title-slide[
#lorem(40)
]

= Trennseite mit Nummerierung oben rechts, sollte ausschließlich für Hauptkapitel verwendet werden.

== Überschrift für eine Inhaltsfolie \ maximal zwei Zeilen

#lorem(25)

- Tabellen
- Diagramme
- SmartArts
- Videos & Grafiken

#lorem(20)

== Folie mit zwei Spalten

#grid(columns: 2, gutter: 2em, [

=== Beschreibung

- Dieser Folientyp ist ideal für die Gegenüberstellung von Inhalten.
- Beispielsweise kann eine Spalte ein Bild oder Diagramm enthalten.
- Dank Touying's Package Integration können wir beispielsweise Fletcher-Diagramme Stück für Stück aufdecken.
#only("2-")[- So wie in diesem Graphen nun Knoten "d" aufgedeckt wurde.]

], [

=== Fletcher-Diagramm

#{
  import "@preview/fletcher:0.5.2" as fletcher: node, edge
  let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

  let nodes = ("a", "e", "f", "g")
  let coords = ((1, 0), (2, 1), (0, 2), (3, 2))
  let edges = (
    ("a", "e"),
    ("a", "f"),
    ("f", "e"),
    ("f", "g"),
    ("e", "g"),
  )
  fletcher-diagram({
    for (i, n) in nodes.enumerate() {
      node(coords.at(i), n, name: n, stroke: 0.5pt, shape: "circle")
    }
    for (from, to) in edges {
      edge(label(from), label(to), "-")
    }}, pause, {
    node((1, 1), "d", name: "d", stroke: 0.5pt, shape: "circle" , fill: upb-colors.himmelblau-40)
    edge(label("a"), label("d"), "-")
    edge(label("d"), label("e"), "-")
  })
}

])

== Verfügbare Farben
#{
  import table: cell

  let cells = ()
  for (name, color) in upb-colors {
    cells.push(cell(
      fill: color,
      text(fill: if color.components().sum() > 280% {black} else {white}, name)
    ))
  }

  block(
    width: 92%,
    height: 82%,
    table(
      columns: (1fr, 1fr, 1fr, 1fr, 1fr,),
      rows: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr,),
      align: center+horizon,
      ..cells,
    )
  )
}
