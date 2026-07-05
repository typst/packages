// 2022-07

#set page(width: auto, height: auto, margin: 1cm, fill: rgb("#5E0606").lighten(80%))

#import "@preview/cetz:0.4.2"
#import "@preview/dati-basati:0.1.0"

#show: dati-basati.dati-basati.with(
  ..dati-basati.themes.futurama,
)

#let entities = (
  "prodotto": (
    coordinates: (0, 0),
    attributes: (
      "east": ("prezzo", "titolo", "codice"),
    ),
    primary-key: ("codice",),
    label: "prodotto",
    name: "prodotto",
  ),
  "autore": (
    coordinates: (-8, 0),
    attributes: (
      "west": ("nome", "indirizzo", "cf"),
    ),
    primary-key: ("cf",),
    label: "autore",
    name: "autore",
  ),
  "video": (
    coordinates: (-5, -4),
    attributes: (
      "east": ("durata", "formato"),
    ),
    label: "video",
    name: "video",
  ),
  "libro": (
    coordinates: (0, -4),
    label: "libro",
    name: "libro",
  ),
  "digitale": (
    coordinates: (5, -3),
    label: "digitale",
    name: "digitale",
  ),
  "carta": (
    coordinates: (5, -5),
    attributes: (
      "south": ("pagine",),
    ),
    attributes-position: (south: (alignment: left)),
    primary-key: ("codice",),
    label: "carta",
    name: "carta",
  ),
  "capitolo": (
    coordinates: (0, -8),
    attributes: (
      "east": ("numero", "pagine", "titolo"),
    ),
    weak-entity: ("numero", "libro", "CCW"),
    label: "capitolo",
    name: "capitolo",
  ),
  "esercizio": (
    coordinates: (-9, -8),
    attributes: (
      "north": ("numero",),
      "west": ("soluzione", "testo"),
    ),
    attributes-position: (
      "north": (alignment: right, dir: "rtl"),
    ),
    weak-entity: ("numero", "capitolo"),
    label: "esercizio",
    name: "esercizio",
  ),
  "sito": (
    coordinates: (-9, -4),
    attributes: (
      "west": ("URL", "curatore"),
    ),
    primary-key: ("URL",),
    label: "sito",
    name: "sito",
  ),
)

#let relations = (
  "prodotto-autore": (
    entities: ("prodotto", "autore"),
    attributes: ("north": ("%diritti",)),
    name: "prodotto-autore",
    cardinality: ("(1,n)", "(0,n)"),
  ),
  "libro-capitolo": (
    coordinates: (0, -5.9),
    entities: ("libro", "capitolo"),
    name: "libro-capitolo",
    cardinality: ("(1,n)", "(0,n)"),
  ),
  "capitolo-esercizio": (
    entities: ("capitolo", "esercizio"),
    name: "capitolo-esercizio",
    cardinality: ("(1,n)", "(0,n)"),
  ),
  "esercizio-sito": (
    entities: ("esercizio", "sito"),
    name: "esercizio-sito",
    cardinality: ("(1,n)", "(0,n)"),
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
    )
  }

  for relation in relations.values() {
    dati-basati.relation(
      coordinates: relation.at("coordinates", default: none),
      entities: relation.entities,
      name: relation.name,
      cardinality: relation.cardinality,
      label: relation.at("label", default: none),
      attributes: relation.at("attributes", default: none),
    )
  }

  dati-basati.subentities(
    entity: "prodotto",
    subentities: ("video", "libro"),
  )
  dati-basati.subentities(
    entity: "libro",
    subentities: ("digitale", "carta"),
  )

  // import cetz.draw: *

  // hide({
  //   line(
  //     ("digitale.east", "|-", "libro"),
  //     "libro",
  //     name: "bella",
  //   )
  // })

  // line(
  //   "digitale",
  //   ("digitale", "-|", "bella.mid"),
  //   "bella.mid"
  // )
  // line(
  //   "carta",
  //   ("carta", "-|", "bella.mid"),
  //   "bella.mid"
  // )

  // line(
  //   "bella.mid",
  //   "libro",
  //   mark: (end: "subentity-mark")
  // )
})
