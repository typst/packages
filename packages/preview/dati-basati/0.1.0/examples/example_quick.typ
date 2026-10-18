#set page(height: auto, width: auto, margin: 1cm, fill: rgb("#fff9df"))

#import "@preview/dati-basati:0.1.0" as db

#show: db.dati-basati.with(..db.themes.C62-50)

#db.er-diagram({
  import db: *
  entity(
    (0, 0),
    label: "parent",
    name: "e1",
  )
  entity(
    (7, 0),
    label: "child",
    name: "e2",
  )
  relation(
    label: "has",
    entities: ("e1", "e2"),
    cardinality: ("(0,n)", "(1,1)"),
  )
})
