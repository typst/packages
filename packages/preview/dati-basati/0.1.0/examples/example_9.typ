// 2023-01

#set page(width: auto, height: auto, margin: 1cm)

#import "@preview/cetz:0.4.2"
#import "@preview/dati-basati:0.1.0"

#show: dati-basati.dati-basati.with(
  ..dati-basati.themes.C62-50,
)

#let entities = (
  "partecipante": (
    coordinates: (-10, -5),
    attributes: (
      "south": ("passaporto", "nome", "cognome", "data_emissione"),
      "west": ("luogo_di_nascita", "data_di_nascita"),
    ),
    attributes-position: (
      south: (alignment: center),
    ),
    primary-key: ("passaporto",),
    label: "partecipante",
    name: "partecipante",
  ),
  "viaggio": (
    coordinates: (0, -5),
    attributes: (
      "north": ("id",),
    ),
    primary-key: ("id",),
    label: "viaggio",
    name: "viaggio",
  ),
  "meta": (
    coordinates: (0, -10),
    attributes: (
      "west": ("inizio", "fine"),
    ),
    weak-entity: ("inizio", "viaggio", "CW"),
    label: "meta",
    name: "meta",
  ),
  "guida": (
    coordinates: (8, -5),
    attributes: (
      "south": ("nome", "telefono", "lingue (1,n)"),
    ),
    attributes-position: (
      south: (alignment: center),
    ),
    primary-key: ("telefono",),
    label: "guida",
    name: "guida",
  ),
  "katmandu": (
    coordinates: (0, -15),
    label: "katmandu",
    name: "katmandu",
  ),
  "montagne": (
    coordinates: (-16, -15),
    label: "montagne",
    name: "montagne",
  ),
  "riserva": (
    coordinates: (16, -15),
    label: "riserva",
    name: "riserva",
  ),
  "albergo": (
    coordinates: (-8, -15),
    attributes: (
      "south": ("telefono", "indirizzo", "nome"),
    ),
    attributes-position: (
      south: (alignment: center),
    ),
    primary-key: ("nome",),
    label: "albergo",
    name: "albergo",
  ),
  "tempio": (
    coordinates: (0, -20),
    attributes: (
      "east": ("nome", "anno_edificazione"),
      "west": ("culto", "descrizione"),
    ),
    primary-key: ("nome",),
    label: "tempio",
    name: "tempio",
  ),
  "montagna": (
    coordinates: (-16, -20),
    attributes: (
      "north": ("nome",),
      "east": ("difficoltà", "altitudine"),
    ),
    primary-key: ("nome",),
    label: "montagna",
    name: "montagna",
  ),
  "canoa": (
    coordinates: (16, -20),
    attributes: (
      "west": ("rematore",),
    ),
    weak-entity: ("rematore", "riserva", "CW"),
    label: "canoa",
    name: "canoa",
  ),
  "trasporto": (
    coordinates: (8, -15),
    attributes: (
      "south": ("posti", "targa", "autista", "tipo"),
    ),
    attributes-position: (
      south: (alignment: center),
    ),
    primary-key: ("targa",),
    label: "trasporto",
    name: "trasporto",
  ),
)

#let relations = (
  "partecipante-viaggio": (
    coordinates: (-4.5, -5),
    entities: ("partecipante", "viaggio"),
    label: "partecipa",
    name: "partecipante-viaggio",
    cardinality: ("(1,n)", "(1,n)"),
  ),
  "viaggio-guida": (
    coordinates: (4, -5),
    entities: ("viaggio", "guida"),
    label: "guida",
    name: "viaggio-guida",
    cardinality: ("(1,1)", "(0,n)"),
  ),
  "viaggio-meta": (
    coordinates: (0, -7.5),
    entities: ("viaggio", "meta"),
    label: "consiste",
    name: "viaggio-meta",
    cardinality: ("(1,n)", "(1,1)"),
  ),
  "katmandu-albergo": (
    coordinates: (-4.2, -15),
    entities: ("katmandu", "albergo"),
    label: "in",
    name: "katmandu-albergo",
    cardinality: ("(1,1)", "(0,n)"),
  ),
  "katmandu-tempio": (
    coordinates: (0, -17.5),
    entities: ("katmandu", "tempio"),
    attributes: ("west": ("giorno",)),
    label: "visita",
    name: "katmandu-tempio",
    cardinality: ("(1,n)", "(0,n)"),
  ),
  "montagne-montagna": (
    coordinates: (-16, -17.5),
    entities: ("montagne", "montagna"),
    attributes: ("east": ("giorno",)),
    label: "scala",
    name: "montagne-montagna",
    cardinality: ("(1,n)", "(0,n)"),
  ),
  "riserva-canoa": (
    coordinates: (16, -17.5),
    entities: ("riserva", "canoa"),
    label: "gita",
    name: "riserva-canoa",
    cardinality: ("(0,n)", "(1,1)"),
  ),
  "riserva-trasporto": (
    coordinates: (12, -15),
    entities: ("riserva", "trasporto"),
    label: "usa",
    name: "riserva-trasporto",
    cardinality: ("(0,n)", "(1,1)"),
  ),
  "katmandu-trasporto": (
    coordinates: (4, -15),
    entities: ("katmandu", "trasporto"),
    label: "usa",
    name: "katmandu-trasporto",
    cardinality: ("(0,n)", "(1,1)"),
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
    entity: "meta",
    subentities: ("montagne", "katmandu", "riserva"),
  )
})
