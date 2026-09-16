// 2015-02-10

#set page(width: auto, height: auto, margin: 1cm, fill: rgb("#D4E2E8"))

#import "@preview/dati-basati:0.1.0"

#set text(font: "manrope", size: 10pt)

#show: dati-basati.dati-basati.with(
  ..dati-basati.themes.polimi,
)

#let entities = (
  "canale": (
    coordinates: (0, 0),
    attributes: (north: ("id_canale", "nome")),
    attributes-position: (
      north: (
        dir: "rtl",
        alignment: right,
      ),
    ),
    primary-key: ("id_canale",),
    label: "canale",
    name: "canale",
  ),
  "trasmissione": (
    coordinates: (10, 0),
    attributes: (north: ("data_ora-inizio", "data_ora-fine", "prima_visione (0,1)")),
    attributes-position: (
      north: (
        dir: "ltr",
        alignment: left,
      ),
    ),
    weak-entity: ("data_ora-inizio", "canale", "CCW"),
    label: "trasmissione",
    name: "trasmissione",
  ),
  "programma": (
    coordinates: (20, 0),
    attributes: (north: ("id_programma", "titolo")),
    primary-key: ("id_programma",),
    label: "programma",
    name: "programma",
  ),
  "sottogenere": (
    coordinates: (30, 0),
    attributes: (north: ("nome_sottogenere", "genere")),
    primary-key: ("nome_sottogenere",),
    label: "sottogenere",
    name: "sottogenere",
  ),
  "fascia_oraria": (
    coordinates: (10, -6),
    attributes: (west: ("ora-inizio", "ora-fine", "descrizione")),
    primary-key: ("ora-inizio",),
    label: "fascia\noraria",
    name: "fascia_oraria",
  ),
  "fascia_protetta": (
    coordinates: (10, -10),
    label: "fascia\nprotetta",
    name: "fascia_protetta",
  ),
  "livello_di_protezione": (
    coordinates: (20, -6),
    attributes: (east: ("id_livello_di_protezione", "descrizione")),
    primary-key: ("id_livello_di_protezione",),
    label: "livello di\nprotezione",
    name: "livello_di_protezione",
  ),
  "utente": (
    coordinates: (0, -14),
    attributes: (
      north: ("id_utente",),
      west: ("sesso", "ddn", "professione"),
    ),
    attributes-position: (
      north: (
        dir: "ltr",
        vdir: "btt",
      ),
    ),
    primary-key: ("id_utente",),
    label: "utente",
    name: "utente",
  ),
  "sintonizzazione": (
    coordinates: (0, -6),
    attributes: (west: ("data_ora-inizio", "data_ora-fine").rev()),
    weak-entity: ("data_ora-inizio", "utente", "CCW"),
    label: "sintonizzazione",
    name: "sintonizzazione",
  ),
  "famiglia": (
    coordinates: (10, -14),
    attributes: (east: ("id_famiglia", "classe_socio_economica", "città_residenza")),
    primary-key: ("id_famiglia",),
    label: "famiglia",
    name: "famiglia",
  ),
)

#let relations = (
  "canale-canale": (
    coordinates: (-2.5, 1.5),
    attributes: (west: ("ritardo",)),
    name: "canale-canale",
    entities: (("canale", "north"), ("canale", "west")),
    cardinality: ("(0,1)", "(0,n)"),
  ),
  // "canale-canale": (
  //   coordinates: (-2.5, 0),
  //   attributes: (west: ("ritardo",)),
  //   name: "canale-canale",
  //   entities: ("canale", "canale"),
  //   cardinality: ("(0,1)", "(0,n)"),
  // ),
  "canale-trasmissione": (
    name: "canale-trasmissione",
    entities: ("canale", "trasmissione"),
    cardinality: ("(0,1)", "(0,n)"),
  ),
  "canale-sintonizzazione": (
    name: "canale-sintonizzazione",
    entities: ("canale", "sintonizzazione"),
    cardinality: ("(0,1)", "(0,n)"),
  ),
  "utente-sintonizzazione": (
    name: "utente-sintonizzazione",
    entities: ("utente", "sintonizzazione"),
    cardinality: ("(0,1)", "(0,n)"),
  ),
  "programma-trasmissione": (
    name: "programma-trasmissione",
    entities: ("programma", "trasmissione"),
    cardinality: ("(0,1)", "(0,n)"),
  ),
  "programma-sottogenere": (
    name: "programma-sottogenere",
    entities: ("programma", "sottogenere"),
    cardinality: ("(0,1)", "(0,n)"),
  ),
  "programma-livello_di_protezione": (
    name: "programma-livello_di_protezione",
    entities: ("programma", "livello_di_protezione"),
    cardinality: ("(0,1)", "(0,n)"),
  ),
  "fascia_protetta-livello_di_protezione": (
    coordinates: (20, -10),
    name: "fascia_protetta-livello_di_protezione",
    entities: ("fascia_protetta", "livello_di_protezione"),
    cardinality: ("(0,1)", "(0,n)"),
  ),
  "fascia_oraria-trasmissione": (
    name: "fascia_oraria-trasmissione",
    entities: ("fascia_oraria", "trasmissione"),
    cardinality: ("(0,1)", "(0,n)"),
  ),
  "utente-famiglia": (
    name: "utente-famiglia",
    entities: ("utente", "famiglia"),
    cardinality: ("(0,1)", "(0,n)"),
  ),
)

#dati-basati.er-diagram({
  for entity in entities.values() {
    dati-basati.entity(
      entity.coordinates,
      // label: pad(x: 0.5em, text(
      //   size: 1.1em,
      //   weight: "bold",
      //   upper(entity.label),
      // )),
      label: entity.label,
      name: entity.name,
      attributes: entity.at("attributes", default: none),
      weak-entity: entity.at("weak-entity", default: none),
      attributes-position: entity.at("attributes-position", default: none),
      primary-key: entity.at("primary-key", default: none),
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
    hierarchy: "(p,e)",
    entity: "fascia_oraria",
    subentities: ("fascia_protetta",),
  )
})
