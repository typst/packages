// 2021-01

#set page(width: auto, height: auto, margin: 1cm, fill: rgb("#D4E2E8"))

#import "@preview/cetz:0.4.2"
#import "@preview/dati-basati:0.1.0"

#set text(font: "Manrope")

#show: dati-basati.dati-basati.with(
  ..dati-basati.themes.polimi,
)

#let entities = (
  "evento": (
    coordinates: (0, 0),
    attributes: (
      "north": ("data_pubblicazione", "ora_pubblicazione", "descrizione"),
      "west": ("id", "titolo", "disciplina"),
    ),
    primary-key: "id",
    label: "evento",
    name: "evento",
  ),
  "partita_di_calcio": (
    coordinates: (8, 0),
    label: "partita di\ncalcio",
    name: "partita_di_calcio",
  ),
  "annotazione": (
    coordinates: (8, -4),
    attributes: (
      "north": ("minuto",),
      "west": ("descrizione",),
    ),
    attributes-position: (
      north: (alignment: right),
    ),
    weak-entity: ("minuto", "partita_di_calcio"),
    label: "annotazione",
    name: "annotazione",
  ),
  "utente": (
    coordinates: (0, -8),
    attributes: (
      "north": ("trimestrale-annuale",),
      "west": ("nome", "cognome", "indirizzo"),
      "south": ("cf", "stato"),
    ),
    attributes-position: (south: (alignment: left, dir: "ltr")),
    primary-key: "cf",
    label: "utente",
    name: "utente",
  ),
  "visione": (
    coordinates: (0, -4),
    attributes: (
      "west": ("data", "ora"),
      "east": ("ip",),
    ),
    weak-entity: ("utente", "evento"),
    label: "visione",
    name: "visione",
  ),
  "con_carta": (
    coordinates: (8, -11),
    attributes: (
      "east": ("banca", "iban"),
    ),
    label: "con carta",
    name: "con_carta",
  ),
  "con_conto": (
    coordinates: (0, -11),
    attributes: (
      "west": ("nome", "numero"),
      "east": ("cvv", "validità"),
    ),
    label: "con conto",
    name: "con_conto",
  ),
  "pagamento": (
    coordinates: (8, -8),
    attributes: (
      "north": ("data",),
      "east": ("importo", "a-buon-fine"),
    ),
    weak-entity: ("data", "utente", "CCW"),
    label: "pagamento",
    name: "pagamento",
  ),
)

#let relations = (
  "partita_di_calcio-annotazione": (
    // coordinates: (0, -5),
    entities: ("partita_di_calcio", "annotazione"),
    label: "ha",
    name: "partita_di_calcio-annotazione",
    cardinality: ("(0,n)", "(1,1)"),
  ),
  "visione-evento": (
    // coordinates: (0, -5),
    entities: ("visione", "evento"),
    // label: "",
    name: "visione-evento",
    cardinality: ("(1,1)", "(0,n)"),
  ),
  "visione-utente": (
    // coordinates: (0, -5),
    entities: ("visione", "utente"),
    // label: "",
    name: "visione-utente",
    cardinality: ("(1,1)", "(0,n)"),
  ),
  "pagamento-utente": (
    // coordinates: (0, -5),
    entities: ("pagamento", "utente"),
    label: ("effettua", "north"),
    name: "pagamento-utente",
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
    )
  }

  for relation in relations.values() {
    dati-basati.relation(
      entities: relation.entities,
      name: relation.name,
      cardinality: relation.cardinality,
      coordinates: relation.at("coordinates", default: none),
      label: relation.at("label", default: none),
      attributes: relation.at("attributes", default: none),
    )
  }

  dati-basati.subentities(
    entity: "evento",
    subentities: ("partita_di_calcio",),
  )

  dati-basati.subentities(
    entity: "utente",
    subentities: ("con_conto", "con_carta"),
  )
})
