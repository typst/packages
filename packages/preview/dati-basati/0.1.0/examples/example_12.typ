// 2025-01

#set page(width: auto, height: auto, margin: 1cm, fill: rgb("#002E62").lighten(80%))

#import "@preview/cetz:0.4.2"
#import "@preview/dati-basati:0.1.0"

#show: dati-basati.dati-basati.with(
  ..dati-basati.themes.C62-48,
)

#let entities = (
  "cliente": (
    coordinates: (11, 0),
    attributes: (
      "west": ("nome", "cognome", "telefono"),
      "east": ("cf",),
    ),
    attributes-position: (
      east: (alignment: right),
    ),
    primary-key: ("cf",),
    label: "cliente",
    name: "cliente",
  ),
  "ingresso": (
    coordinates: (20, 0),
    attributes: (
      "north": ("numero_biglietto",),
    ),
    attributes-position: (
      north: (alignment: right),
    ),
    primary-key: ("numero_biglietto",),
    label: "ingresso",
    name: "ingresso",
  ),
  "biglietto_evento": (
    coordinates: (6, -4),
    attributes: (
      "east": ("prezzo",),
    ),
    label: "biglietto\nevento",
    name: "biglietto_evento",
  ),
  "biglietto_giornaliero": (
    coordinates: (15, -4),
    attributes: (
      "east": ("prezzo", "ora (0,1)"),
    ),
    label: "biglietto\ngiornaliero",
    name: "biglietto_giornaliero",
  ),
  "abbonamento": (
    coordinates: (24, -4),
    attributes: (
      "north": ("prezzo",),
      "south": ("inizio", "fine"),
    ),
    attributes-position: (
      "north": (
        dir: "rtl",
      ),
    ),
    label: "abbonamento",
    name: "abbonamento",
  ),
  "senza_evento": (
    coordinates: (31, -2),
    label: "senza\nevento",
    name: "senza_evento",
  ),
  "con_evento": (
    coordinates: (31, -6),
    label: "con\nevento",
    name: "con_evento",
  ),
  "visite": (
    coordinates: (24, -10),
    attributes: (
      "east": ("data", "ora"),
    ),
    weak-entity: ("data", "abbonamento", "CCW"),
    label: "visite",
    name: "visite",
  ),
  "attrazione": (
    coordinates: (15, -10),
    attributes: (
      "north": ("nome", "età_min", "età_max"),
      "west": ("apertura", "chiusura"),
      "east": ("stato", "capacità"),
      "south": ("h_min", "descrizione"),
    ),
    attributes-position: (
      "north": (
        dir: "ltr",
      ),
      "south": (
        dir: "rtl",
      ),
    ),
    primary-key: "nome",
    label: "attrazione",
    name: "attrazione",
  ),
  "categoria": (
    coordinates: (10, -15),
    attributes: (
      "south": ("nome",),
    ),
    primary-key: ("nome",),
    label: "categoria",
    name: "categoria",
  ),
  "intervento": (
    coordinates: (20, -15),
    attributes: (
      "north": ("codice", "data", "durata", "tipo"),
    ),
    attributes-position: (
      "north": (
        dir: "rtl",
        alignment: right,
      ),
    ),
    primary-key: ("codice",),
    label: "intervento",
    name: "intervento",
  ),
  "relazione": (
    coordinates: (28, -15),
    attributes: (
      "north": ("id", "descrizione"),
    ),
    primary-key: ("id",),
    label: "relazione",
    name: "relazione",
  ),
  "evento": (
    coordinates: (20, -20),
    attributes: (
      "north": ("cf", "nome", "cognome", "telefono"),
    ),
    attributes-position: (
      north: (alignment: center),
    ),
    primary-key: ("cf", "nome", "cognome"),
    label: "evento",
    name: "evento",
  ),
)

#let relations = (
  "biglietto_evento-evento": (
    coordinates: (6, -20),
    entities: ("biglietto_evento", "evento"),
    label: "valido",
    name: "biglietto_evento-evento",
    cardinality: ("(1,1)", "(0,n)"),
  ),
  "con_evento-evento": (
    coordinates: (31, -20),
    entities: ("con_evento", "evento"),
    // label: "a v",
    name: "con_evento-evento",
    cardinality: ("(0,n)", "(0,n)"),
  ),
  "intervento-relazione": (
    // coordinates: (24.1, -15),
    entities: ("intervento", "relazione"),
    // label: "emed",
    name: "intervento-relazione",
    cardinality: ("(0,1)", "(1,1)"),
  ),
  "intervento-attrazione": (
    coordinates: (15, -15),
    entities: ("intervento", "attrazione"),
    name: "intervento-attrazione",
    cardinality: ("(1,1)", "(0,1)"),
  ),
  "categoria-attrazione": (
    coordinates: (10, -10),
    label: "in",
    entities: ("categoria", "attrazione"),
    name: "categoria-attrazione",
    // cardinality: ("(1,1)", std.square(height: 0.2cm)),
    cardinality: ("(1,1)", "(0,n)"),
  ),
  "visite-attrazione": (
    // coordinates: (20, -10),
    entities: ("visite", "attrazione"),
    name: "visite-attrazione",
    cardinality: ("(1,1)", "(0,n)"),
  ),
  "biglietto_giornaliero-attrazione": (
    // coordinates: (15, -7),
    entities: ("biglietto_giornaliero", "attrazione"),
    name: "biglietto_giornaliero-attrazione",
    cardinality: ("(1,1)", "(0,n)"),
  ),
  "visite-abbonamento": (
    // coordinates: (24, -6.8),
    entities: ("visite", "abbonamento"),
    name: "visite-abbonamento",
    cardinality: ("(1,1)", "(0,n)"),
  ),
  "cliente-ingresso": (
    // coordinates: (10.5, 0),
    entities: ("cliente", "ingresso"),
    label: ("acquista", "south"),
    name: "cliente-ingresso",
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
      coordinates: relation.at("coordinates", default: none),
      entities: relation.entities,
      label: relation.at("label", default: none),
      name: relation.name,
      cardinality: relation.cardinality,
      attributes: relation.at("attributes", default: none),
    )
  }

  dati-basati.subentities(
    entity: "ingresso",
    subentities: ("biglietto_evento", "biglietto_giornaliero", "abbonamento"),
  )
  dati-basati.subentities(
    entity: "abbonamento",
    subentities: ("senza_evento", "con_evento"),
  )
})
