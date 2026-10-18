#set page(width: auto, height: auto, margin: 1cm)

#import "@preview/cetz:0.4.2"
#import "@preview/dati-basati:0.1.0"

#set text(font: "Titillium Web")

#show: dati-basati.dati-basati.with(
  ..dati-basati.themes.snow,
  text: (
    entities: l => text(size: 1.2em, weight: "bold", upper(l)),
  ),
)

#let entities = (
  "student": (
    coordinates: (0, 0),
    attributes: (
      "south": ("id", "name", "surname", "mail", "school_class"),
    ),
    primary-key: "id",
    label: "student",
    name: "student",
  ),
  "buyer": (
    coordinates: (6, -4),
    attributes: (
      "north": ("reputation",),
    ),
    attributes-position: (
      north: (alignment: right),
    ),
    label: "buyer",
    name: "buyer",
  ),
  "seller": (
    coordinates: (6, 0),
    attributes: (
      "south": ("reputation",),
    ),
    attributes-position: (
      south: (alignment: left),
    ),
    label: "seller",
    name: "seller",
  ),
  "posting": (
    coordinates: (15, 0),
    attributes: (
      "west": ("id", "desc").rev(),
      "east": ("price",),
      "south": ("date", "status"),
    ),
    attributes-position: (
      east: (alignment: left),
    ),
    primary-key: "id",
    label: "posting",
    name: "posting",
  ),
  "transaction": (
    coordinates: (15, -4),
    attributes: (
      "east": ("id", "price", "date"),
    ),
    primary-key: "id",
    label: "transaction",
    name: "transaction",
  ),
  "book": (
    coordinates: (22, 0),
    attributes: (
      "east": ("id", "photos_path", "has_digital_version").rev(),
      "south": ("title", "pages", "author"),
    ),
    primary-key: "id",
    label: "book",
    name: "book",
  ),
)

#let relations = (
  "buyer-transaction": (
    // coordinates: (0, -5),
    entities: ("buyer", "transaction"),
    label: "has",
    name: "buyer-transaction",
    cardinality: ("(0,n)", "(1,1)"),
  ),
  "posting-transaction": (
    // coordinates: (0, -5),
    entities: ("posting", "transaction"),
    label: "in",
    name: "posting-transaction",
    cardinality: ("(0,n)", "(1,1)"),
  ),
  "posting-seller": (
    // coordinates: (0, -5),
    entities: ("posting", "seller"),
    label: "creates",
    name: "posting-seller",
    cardinality: ("(0,n)", "(1,1)"),
  ),
  "posting-book": (
    // coordinates: (0, -5),
    entities: ("posting", "book"),
    label: "has",
    name: "posting-book",
    cardinality: ("(1,1)", "(1,n)"),
  ),
)

#dati-basati.er-diagram({
  for entity in entities.values() {
    dati-basati.entity(
      entity.coordinates,
      label: entity.at("label", default: none),
      name: entity.name,
      attributes: entity.attributes,
      attributes-position: entity.at("attributes-position", default: none),
      primary-key: entity.at("primary-key", default: none),
      weak-entity: entity.at("weak-entity", default: none),
    )
  }

  for relation in relations.values() {
    dati-basati.relation(
      coordinates: relation.at("coordinates", default: none),
      entities: relation.entities,
      label: relation.at("label", default: none),
      name: relation.name,
      cardinality: relation.cardinality,
      attributes: relation.at("attributes", default: none),
    )
  }

  dati-basati.subentities(
    entity: "student",
    hierarchy: "(p,o)",
    subentities: ("seller", "buyer"),
  )
})
