// 2022-01

#set page(width: auto, height: auto, margin: 1cm, fill: rgb("#D4E2E8"))

#import "@preview/cetz:0.4.2"
#import "@preview/dati-basati:0.1.0"

#set text(font: "Manrope")

#show: dati-basati.dati-basati.with(
  ..dati-basati.themes.polimi,
)

#let entities = (
  "persona": (
    coordinates: (0, 0),
    attributes: (
      "west": ("cf", "nome", "cognome"),
    ),
    primary-key: "cf",
    label: "persona",
    name: "persona",
  ),
  "gestore": (
    coordinates: (0, -3),
    attributes: (
      "west": ("ind", "com"),
    ),
    label: "gestore",
    name: "gestore",
  ),
  "cliente": (
    coordinates: (6, -3),
    label: "cliente esterno",
    name: "cliente",
  ),
  "nolo": (
    coordinates: (8, 0),
    attributes: (
      "south": ("id",),
    ),
    primary-key: "id",
    label: "nolo",
    name: "nolo",
  ),
  "noleggio_singolo": (
    coordinates: (16, 0),
    attributes: (
      "east": ("id", "da", "a"),
    ),
    primary-key: "id",
    label: "noleggio\nsingolo",
    name: "noleggio_singolo",
  ),
  "barca": (
    coordinates: (16, -5),
    attributes: (
      "east": (("tipo", "lunghezza"),),
      "north": ("codice",),
    ),
    primary-key: "codice",
    label: "barca",
    name: "barca",
  ),
  "barca_a_motore": (
    coordinates: (10.5, -5),
    attributes: (
      "west": ("cilindrata", "capienza_serbatoio"),
    ),
    attributes-position: (
      west: (alignment: right, dir: "ltr"),
    ),
    label: "barca a\nmotore",
    name: "barca_a_motore",
  ),
  "società_di_noleggio": (
    coordinates: (8, -8),
    attributes: (
      "north": ("p_iva", "anno"),
    ),
    primary-key: "p_iva",
    label: "società di\nnoleggio",
    name: "società_di_noleggio",
  ),
)

#let relations = (
  "gestore-società_di_noleggio": (
    coordinates: (0, -8),
    entities: ("gestore", "società_di_noleggio"),
    // label: "",
    name: "gestore-società_di_noleggio",
    cardinality: ("(1,n)", "(1,1)"),
  ),
  "barca-società_di_noleggio": (
    coordinates: (16, -8),
    entities: ("barca", "società_di_noleggio"),
    // label: "",
    name: "barca-società_di_noleggio",
    cardinality: ("(1,n)", "(1,1)"),
  ),
  "barca-noleggio_singolo": (
    entities: ("barca", "noleggio_singolo"),
    // label: "",
    name: "barca-noleggio_singolo",
    cardinality: ("(1,n)", "(1,1)"),
  ),
  "nolo-noleggio_singolo": (
    entities: ("nolo", "noleggio_singolo"),
    // label: "",
    name: "nolo-noleggio_singolo",
    cardinality: ("(1,n)", "(1,1)"),
  ),
  "nolo-persona": (
    entities: ("nolo", "persona"),
    // label: "",
    name: "nolo-persona",
    cardinality: ("(1,n)", "(1,1)"),
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
    entity: "persona",
    subentities: ("gestore", "cliente"),
  )

  dati-basati.subentities(
    entity: "barca",
    subentities: ("barca_a_motore",),
  )
})
