// 2024-01-19

#set page(width: auto, height: auto, margin: 1cm, fill: rgb("#D4E2E8"))

#import "@preview/cetz:0.4.2"
#import "@preview/dati-basati:0.1.0"

#set text(font: "Manrope")

#show: dati-basati.dati-basati.with(
  ..dati-basati.themes.polimi,
)

#let entities = (
  "formato": (
    coordinates: (0, -6),
    attributes: (
      "west": ("isbn", "orezzo_vendita", "numero_pagine").rev(),
    ),
    primary-key: "isbn",
    label: "formato",
    name: "formato",
  ),
  "vendite_mensili": (
    coordinates: (0, 0),
    attributes: (
      "west": ("numero_copie", "importo_mensile"),
      "south": ("mese", "anno"),
    ),
    weak-entity: ("mese", "formato"),
    label: "vendite\nmensili",
    name: "vendite_mensili",
  ),
  "pregio": (
    coordinates: (0, -10),
    attributes: (
      "south": ("costo_produzione",),
    ),
    label: "pregio",
    name: "pregio",
  ),
  "economico": (
    coordinates: (5, -10),
    attributes: (
      "south": ("costo_produzione",),
    ),
    label: "economico",
    name: "economico",
  ),
  "ebook": (
    coordinates: (10, -10),
    label: "ebook",
    name: "ebook",
  ),
  "manoscritto": (
    coordinates: (10, -6),
    attributes: (
      "north": ("codice_interno", "titolo", "genere"),
    ),
    primary-key: "codice_interno",
    label: "manoscritto",
    name: "manoscritto",
  ),
  "autore": (
    coordinates: (10, 0),
    attributes: (
      "north": ("cf", "nome", "cognome", "pseudonimo"),
    ),
    primary-key: "cf",
    label: "autore",
    name: "autore",
  ),
  "riferimento_bancario": (
    coordinates: (20, 0),
    attributes: (
      "north": ("iban", "intestazione", "banca", "filiale"),
    ),
    primary-key: "iban",
    label: "riferimento\nbancario",
    name: "riferimento_bancario",
  ),
  "bonifico": (
    coordinates: (5, -3),
    attributes: (
      "west": ("data", "num"),
      "east": ("importo",),
    ),
    weak-entity: ("data", "north"),
    label: "bonifico",
    name: "bonifico",
  ),
  "versione_tradotta": (
    coordinates: (20, -6),
    attributes: (
      "north": ("%fissa", "lingua"),
    ),
    label: "versione\ntradotta",
    name: "versione_tradotta",
  ),
  "vendite_annuali": (
    coordinates: (15, -10),
    attributes: (
      "north": ("anno", "numero_copie", "cambio_concordato (0,1)"),
    ),
    label: "vendite\nannuali",
    name: "vendite_annuali",
  ),
  "editore_internazionale": (
    coordinates: (15, -3),
    attributes: (
      "north": ("nome", "valuta"),
    ),
    primary-key: "nome",
    label: "editore\ninternazionale",
    name: "editore_internazionale",
  ),
)

#let relations = (
  "vendite_mensili-formato": (
    entities: ("vendite_mensili", "formato"),
    name: "vendite_mensili-formato",
    cardinality: ("(1,1)", "(1,n)"),
  ),
  "manoscritto-formato": (
    entities: ("manoscritto", "formato"),
    name: "manoscritto-formato",
    cardinality: ("(1,n)", "(0,n)"),
  ),
  "manoscritto-versione_tradotta": (
    entities: ("manoscritto", "versione_tradotta"),
    name: "manoscritto-versione_tradotta",
    cardinality: ("(0,n)", "(1,1)"),
  ),
  "vendite_annuali-versione_tradotta": (
    coordinates: (20, -10),
    entities: ("vendite_annuali", "versione_tradotta"),
    name: "vendite_annuali-versione_tradotta",
    cardinality: ("(1,1)", "(0,n)"),
  ),
  "editore_internazionale-versione_tradotta": (
    coordinates: (20, -3),
    entities: ("editore_internazionale", "versione_tradotta"),
    name: "editore_internazionale-versione_tradotta",
    cardinality: ("(0,n)", "(1,1)"),
  ),
  "manoscritto-autore": (
    entities: ("manoscritto", "autore"),
    name: "manoscritto-autore",
    cardinality: ("(1,n)", "(1,n)"),
  ),
  "bonifico-autore": (
    coordinates: (5, 0),
    entities: ("bonifico", "autore"),
    name: "bonifico-autore",
    cardinality: ("(1,1)", "(0,n)"),
  ),
  "riferimento_bancario-autore": (
    entities: ("riferimento_bancario", "autore"),
    name: "riferimento_bancario-autore",
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
    hierarchy: "(t,s)",
    entity: "formato",
    subentities: ("pregio", "economico", "ebook"),
  )
})
