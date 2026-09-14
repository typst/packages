// 2012-09

#set page(width: auto, height: auto, margin: 1cm)

#import "@preview/dati-basati:0.1.0"

#import "@preview/catppuccin:1.0.1": *
#show: catppuccin.with(flavors.latte)

#let palette = flavors.latte.colors

#set text(font: "Fira Sans")

#show: dati-basati.dati-basati.with(
  fill: (
    cardinality: palette.flamingo.rgb,
    entities: palette.red.rgb,
    relations: palette.red.rgb,
    attributes: palette.red.rgb,
    primary-key: palette.maroon.rgb,
    weak-entity: palette.red.rgb,
  ),
  stroke: (
    cardinality: palette.surface0.rgb + 0.1pt,
    entities: black,
    relations: black,
    attributes: palette.rosewater.rgb,
    weak-entity: orange,
  ),
  text: (
    entities: l => text(
      fill: palette.surface0.rgb,
      weight: 500,
      size: 1.2em,
      smallcaps(l),
    ),
    cardinality: l => text(
      top-edge: "bounds",
      bottom-edge: "bounds",
      fill: palette.surface0.rgb,
      l,
    ),
  ),
  radius: (
    entities: 6pt,
    cardinality: 6pt,
  ),
)

#let entities = (
  "piscina": (
    coordinates: (5, 12),
    attributes: (
      "south": ("nome", "indirizzo", "telefono", "fax"),
    ),
    attributes-position: (
      "south": (alignment: center),
    ),
    primary-key: ("nome",),
    label: "piscina",
    name: "piscina",
  ),
  "vasca": (
    coordinates: (0, 8),
    attributes: (
      "east": ("codice", "p_max", "p_min"),
    ),
    weak-entity: ("codice", "piscina", "CCW"),
    label: "vasca",
    name: "vasca",
    misc: (
      weak-entity-intersection: "|-",
    ),
  ),
  "corsi": (
    coordinates: (10, 8),
    attributes: (
      "west": ("nome", "descrizione", "codice"),
    ),
    primary-key: ("codice",),
    label: "corsi",
    name: "corsi",
  ),
  "turno": (
    coordinates: (16, 4),
    attributes: (
      "north": ("ora_inizio", "numero").rev(),
      "east": ("durata", "tipologia"),
    ),
    weak-entity: ("numero", "west", "ccw"),
    label: "turno",
    name: "turno",
  ),
  "iscrizione": (
    coordinates: (25.5, 4),
    attributes: (
      "south": ("codice", "data", "prezzo"),
    ),
    primary-key: ("codice",),
    label: "iscrizione",
    name: "iscrizione",
  ),
  "lezione": (
    coordinates: (22, 0),
    attributes: (
      "south": ("numero", "data").rev(),
    ),
    attributes-position: (
      south: (
        dir: "ltr",
        alignment: left,
        start: "from-short",
      ),
    ),
    weak-entity: ("numero", "west"),
    label: "lezione",
    name: "lezione",
  ),
  "iscritto": (
    coordinates: (30, 0),
    attributes: (
      "south": ("cf", "nome", "cognome", "DDN"),
    ),
    primary-key: ("cf",),
    label: "iscritto",
    name: "iscritto",
  ),
  "giorno": (
    coordinates: (10, 0),
    attributes: (
      "south": ("nome",),
    ),
    primary-key: ("nome",),
    label: "giorno",
    name: "giorno",
  ),
  "nuoto_libero": (
    coordinates: (0, 0),
    attributes: (
      "north": ("ora_inizio",),
      "south": ("ora_fine",),
    ),
    attributes-position: (
      "north": (alignment: right, dir: "rtl"),
    ),
    weak-entity: ("vasca", "giorno"),
    label: "nuoto libero",
    name: "nuoto_libero",
  ),
  "insegnante": (
    coordinates: (16, 12),
    attributes: (
      "west": ("matricola", "telefono", "DDN"),
      "south": ("data_assunzione", "cognome", "nome").rev(),
    ),
    attributes-position: (
      south: (
        dir: "rtl",
        start: "from-short",
      ),
    ),
    primary-key: ("matricola",),
    label: "insegnante",
    name: "insegnante",
  ),
  "nuoto": (
    coordinates: (23.5, 8),
    attributes: (
      "south": ("nome",),
    ),
    attributes-position: (south: (alignment: left)),
    primary-key: ("nome",),
    label: "nuoto",
    name: "nuoto",
  ),
  "fitness": (
    coordinates: (23.5, 12),
    label: "fitness",
    name: "fitness",
  ),
  "disciplina": (
    coordinates: (30, 8),
    attributes: (
      "south": ("nome",),
    ),
    attributes-position: (south: (alignment: left)),
    primary-key: ("nome",),
    label: "disciplina",
    name: "disciplina",
  ),
)

#let relations = (
  "vasca-nuoto_libero": (
    // coordinates: (10.5, 0),
    entities: ("vasca", "nuoto_libero"),
    // label: ("acquista", "south"),
    name: "vasca-nuoto_libero",
    cardinality: ("(1,n)", "(1,1)"),
  ),
  "vasca-piscina": (
    coordinates: (0, 12),
    entities: ("vasca", "piscina"),
    // label: ("acquista", "south"),
    name: "vasca-piscina",
    cardinality: ("(1,1)", "(1,n)"),
  ),
  "corsi-piscina": (
    coordinates: (10, 12),
    entities: ("corsi", "piscina"),
    // label: ("acquista", "south"),
    name: "corsi-piscina",
    cardinality: ("(1,1)", "(1,n)"),
  ),
  "corsi-turno": (
    coordinates: (10, 4),
    entities: ("corsi", "turno"),
    // label: ("acquista", "south"),
    name: "corsi-turno",
    cardinality: ("(1,n)", "(1,1)"),
  ),
  "insegnante-turno": (
    entities: ("insegnante", "turno"),
    // label: ("acquista", "south"),
    name: "insegnante-turno",
    cardinality: ("(1,n)", "(1.1)"),
  ),
  "iscrizione-turno": (
    coordinates: (21, 4),
    entities: ("iscrizione", "turno"),
    // label: ("acquista", "south"),
    name: "iscrizione-turno",
    cardinality: ("(1,1)", "(0,n)"),
  ),
  "turno-giorno": (
    coordinates: (13.98, 0),
    entities: ("turno", "giorno"),
    // label: ("acquista", "south"),
    name: "turno-giorno",
    cardinality: ("(1,n)", "(1,n)"),
  ),
  "lezione-turno": (
    coordinates: (18.02, 0),
    entities: ("lezione", "turno"),
    // label: ("acquista", "south"),
    name: "lezione-turno",
    cardinality: ("(1,1)", "(1,n)"),
  ),
  "nuoto_libero-giorno": (
    entities: ("nuoto_libero", "giorno"),
    // label: ("acquista", "south"),
    name: "nuoto_libero-giorno",
    cardinality: ("(1,1)", "(1,n)"),
  ),
  "lezione-iscritto": (
    entities: ("lezione", "iscritto"),
    // label: ("acquista", "south"),
    name: "lezione-iscritto",
    cardinality: ("(0,n)", "(0,n)"),
  ),
  "iscrizione-iscritto": (
    coordinates: (30, 4),
    entities: ("iscrizione", "iscritto"),
    // label: ("acquista", "south"),
    name: "iscrizione-iscritto",
    cardinality: ("(1,1)", "(1,n)"),
  ),
  "fitness-disciplina": (
    coordinates: (30, 12),
    entities: ("fitness", "disciplina"),
    // label: ("acquista", "south"),
    name: "fitness-disciplina",
    cardinality: ("(1,n)", "(1,n)"),
  ),
)

#dati-basati.er-diagram({
  for entity in entities.values() {
    dati-basati.entity(
      entity.coordinates,
      label: entity.label,
      name: entity.name,
      attributes: entity.at("attributes", default: none),
      weak-entity: entity.at("weak-entity", default: none),
      attributes-position: entity.at("attributes-position", default: none),
      primary-key: entity.at("primary-key", default: none),
      misc: entity.at("misc", default: none),
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
    hierarchy: "(t,s)",
    entity: "insegnante",
    subentities: ("nuoto", "fitness"),
  )
})
