// 2022-06

#set page(width: auto, height: auto, margin: 1cm, fill: rgb("#fffcf3"))

#import "@preview/cetz:0.4.2"
#import "@preview/dati-basati:0.1.0"

#set text(font: "IBM Plex Sans")

#show: dati-basati.dati-basati.with(
  ..dati-basati.themes.tiramisu,
  text: (
    entities: l => pad(x: 0.1em, (
      text(
        weight: "bold",
        upper(l),
      )
    )),
  ),
  spacing: (in-between: (x: 1.3em, y: 1.2em)),
  misc: (weak-entities-stroke: true),
)

#let entities = (
  "modello": (
    coordinates: (0, 0),
    attributes: (
      "north": ("id", "nome", "descrizione", "tipo"),
      "west": ("u/d",),
    ),
    attributes-position: (
      north: (alignment: center),
    ),
    primary-key: ("id",),
    label: "modello",
    name: "modello",
  ),
  "tessuto": (
    coordinates: (8, 0),
    attributes: (
      "north": ("codice", "nome"),
    ),
    attributes-position: (
      north: (alignment: center),
    ),
    primary-key: ("codice",),
    label: "tessuto",
    name: "tessuto",
  ),
  "colore": (
    coordinates: (16, 0),
    attributes: (
      "north": ("id", "descrizione"),
    ),
    attributes-position: (
      north: (alignment: center),
    ),
    primary-key: ("id",),
    label: "colore",
    name: "colore",
  ),
  "capo": (
    coordinates: (8, -5),
    attributes: (
      "north": ("num",),
      "south": ("circ_vita", "circ_fianco", "lunghezza"),
    ),
    attributes-position: (
      south: (alignment: left, dir: "ltr"),
    ),
    weak-entity: ("num", "modello", "CCW"),
    label: "capo\nd'abbligliamento",
    name: "capo",
    misc: (
      weak-entity-intersection: "-|",
    ),
  ),
  "ordine": (
    coordinates: (8, -10),
    attributes: (
      "west": ("id", "data", "ora"),
    ),
    primary-key: ("id",),
    label: "ordine",
    name: "ordine",
  ),
  "corriere": (
    coordinates: (0, -14),
    attributes: (
      "north": ("nome", "telefono", "città"),
    ),
    attributes-position: (
      north: (alignment: center),
    ),
    primary-key: ("nome",),
    label: "corriere",
    name: "corriere",
  ),
  "processato": (
    coordinates: (8, -14),
    attributes: (
      "south": ("ritiro|spedizione", "data"),
    ),
    attributes-position: (
      south: (alignment: center, dir: "rtl"),
    ),
    label: "processato",
    name: "processato",
  ),
  "non_processato": (
    coordinates: (16, -14),
    attributes: (
      "south": ("data_consegna_prevista",),
    ),
    attributes-position: (
      south: (alignment: left, dir: "rtl"),
    ),
    label: "non\nprocessato",
    name: "non_processato",
  ),
  "cliente": (
    coordinates: (16, -10),
    attributes: (
      "north": ("cf", "data", "telefono", "indirizzo"),
    ),
    attributes-position: (
      north: (alignment: center),
    ),
    primary-key: ("cf",),
    label: "cliente",
    name: "cliente",
  ),
)

#let relations = (
  "modello-tessuto": (
    coordinates: (4, 0),
    entities: ("modello", "tessuto"),
    label: "con",
    name: "modello-tessuto",
    cardinality: ("(1,n)", "(0,n)"),
  ),
  "modello-capo": (
    coordinates: (0, -5),
    entities: ("modello", "capo"),
    label: "in",
    name: "modello-capo",
    cardinality: ("(0,n)", "(1,1)"),
  ),
  "colore-tessuto": (
    coordinates: (12, 0),
    entities: ("colore", "tessuto"),
    label: "di",
    name: "colore-tessuto",
    cardinality: ("(0,n)", "(1,n)"),
  ),
  "capo-ordine": (
    coordinates: (8, -7.6),
    entities: ("capo", "ordine"),
    label: "in",
    name: "capo-ordine",
    cardinality: ("(1,1)", "(1,n)"),
  ),
  "capo-tessuto": (
    coordinates: (8, -2.2),
    entities: ("capo", "tessuto"),
    label: "scelta",
    name: "capo-tessuto",
    cardinality: ("(1,1)", "(0,n)"),
  ),
  "capo-colore": (
    coordinates: (16, -5),
    entities: ("capo", "colore"),
    label: "scelta",
    name: "capo-colore",
    cardinality: ("(1,1)", "(0,n)"),
  ),
  "corriere-processato": (
    coordinates: (4, -14),
    entities: ("corriere", "processato"),
    label: "consegna",
    name: "corriere-processato",
    cardinality: ("(0,n)", "(0,1)"),
  ),
  "ordine-cliente": (
    coordinates: (12, -10),
    entities: ("ordine", "cliente"),
    label: "di",
    name: "ordine-cliente",
    cardinality: ("(1,1)", "(0,n)"),
  ),
)

#dati-basati.er-diagram({
  for entity in entities.values() {
    dati-basati.entity(
      entity.coordinates,
      label: entity.label,
      name: entity.name,
      attributes: entity.at("attributes", default: none),
      attributes-position: entity.at("attributes-position", default: none),
      primary-key: entity.at("primary-key", default: none),
      weak-entity: entity.at("weak-entity", default: none),
      misc: entity.at("misc", default: none),
    )
  }

  for relation in relations.values() {
    dati-basati.relation(
      coordinates: relation.coordinates,
      entities: relation.entities,
      label: relation.at("label", default: none),
      name: relation.name,
      cardinality: relation.cardinality,
      attributes: relation.at("attributes", default: none),
    )
  }

  dati-basati.subentities(
    hierarchy: "(t,e)",
    entity: "ordine",
    subentities: ("processato", "non_processato"),
  )
})
