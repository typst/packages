// 2016-09-06

#set page(width: auto, height: auto, margin: 1cm, fill: rgb("#FFF0C3").lighten(80%))

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
)

#let entities = (
  "città": (
    coordinates: (-3, 0),
    attributes: (
      "west": ("nome_città", "regione", "servizio_consegna_domicilio"),
    ),
    primary-key: "nome_città",
    label: "città",
    name: "città",
  ),
  "ristorante": (
    coordinates: (6, 0),
    attributes: (
      "north": ("nome_ristorante", "indirizzo", "capienza", "servizio_asporto"),
    ),
    attributes-position: (north: (alignment: center)),
    primary-key: "nome_ristorante",
    label: "ristorante",
    name: "ristorante",
  ),
  "piatto": (
    coordinates: (9, -4),
    attributes: (
      "north": ("nome_piatto",),
      "east": ("prezzo", "vegano"),
      "south": ("descrizione",),
    ),
    attributes-position: (
      north: (alignment: right, dir: "rtl"),
    ),
    primary-key: "nome_piatto",
    label: "piatto",
    name: "piatto",
  ),
  "bevanda": (
    coordinates: (13, -10.5),
    attributes: (
      "north": ("nome_bevanda", "descrizione"),
      "west": ("prezzo", "alcolica"),
    ),
    primary-key: "nome_bevanda",
    label: "bevanda",
    name: "bevanda",
  ),
  "prenotazione": (
    coordinates: (3, -4),
    attributes: (
      "south": ("timestamp",),
      "east": ("data", "ora"),
    ),
    // workaround adesso
    attributes-position: (south: (alignment: left, dir: "ltr")),
    weak-entity: ("timestamp", "ristorante"),
    // API ideale
    // weak-entity: (("timestamp", "ristorante"), ("timestamp", "cliente")),
    // weak-entity: ("timestamp", "ristorante"),
    label: "prenotazione",
    name: "prenotazione",
  ),
  "cliente": (
    coordinates: (-6, -4),
    attributes: (
      "north": ("cf", "nome", "cognome"),
      "west": ("DDN", "cellulare"),
    ),
    primary-key: "cf",
    label: "cliente",
    name: "cliente",
  ),
  "prenotazione_tavolo": (
    coordinates: (-11, -7),
    attributes: (
      "south": ("numero_posti",),
    ),
    attributes-position: (
      south: (alignment: right, dir: "ltr"),
    ),
    label: "prenotazione\ntavolo",
    name: "prenotazione_tavolo",
  ),
  "prenotazione_pasto": (
    coordinates: (3, -7),
    label: "prenotazione\npasto",
    name: "prenotazione_pasto",
  ),
  "prenotazione_asporto": (
    coordinates: (-4, -7),
    label: "prenotazione\nasporto",
    name: "prenotazione_asporto",
  ),
  "prenotazione_domicilio": (
    coordinates: (-4, -10.5),
    attributes: (
      "north": ("indirizzo_consegna",),
    ),
    attributes-position: (
      north: (alignment: right),
    ),
    label: "prenotazione\ndomicilio",
    name: "prenotazione_domicilio",
  ),
  "veicolo": (
    coordinates: (-13, -10.5),
    attributes: (
      "north": ("targa", "modello", "anno_immatricolazione"),
    ),
    attributes-position: (
      north: (dir: "ltr", start: "from-long"),
    ),
    primary-key: "targa",
    label: "veicolo",
    name: "veicolo",
  ),
)

#let relations = (
  "città-ristorante": (
    // coordinates: (0, -5),
    entities: ("città", "ristorante"),
    // label: "",
    name: "città-ristorante",
    cardinality: ("(1,n)", "(1,1)"),
  ),
  "bevanda-ristorante": (
    coordinates: (13, 0),
    entities: ("bevanda", "ristorante"),
    // label: "",
    name: "bevanda-ristorante",
    cardinality: ("(1,n)", "(1,n)"),
  ),
  "bevanda-prenotazione_pasto": (
    coordinates: (3, -10.5),
    entities: ("bevanda", "prenotazione_pasto"),
    // label: "",
    name: "bevanda-prenotazione_pasto",
    cardinality: ("(1,n)", "(1,1)"),
  ),
  "piatto-ristorante": (
    // coordinates: (0, -5),
    entities: ("piatto", "ristorante"),
    // label: "",
    name: "piatto-ristorante",
    cardinality: ("(1,n)", "(1,n)"),
  ),
  "prenotazione-ristorante": (
    // coordinates: (0, -5),
    entities: ("prenotazione", "ristorante"),
    // label: "",
    name: "prenotazione-ristorante",
    cardinality: ("(1,1)", "(1,n)"),
  ),
  "prenotazione-cliente": (
    // coordinates: (0, -5),
    entities: ("prenotazione", "cliente"),
    // label: "",
    name: "prenotazione-cliente",
    cardinality: ("(1,1)", "(0,n)"),
  ),
  "piatto-prenotazione_pasto": (
    coordinates: (9, -7),
    entities: ("piatto", "prenotazione_pasto"),
    // label: "",
    name: "piatto-prenotazione_pasto",
    cardinality: ("(0,n)", "(0,n)"),
  ),
  "veicolo-prenotazione_domicilio": (
    // coordinates: (0, -5),
    entities: ("veicolo", "prenotazione_domicilio"),
    // label: "",
    name: "veicolo-prenotazione_domicilio",
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
    entity: "prenotazione",
    subentities: ("prenotazione_tavolo", "prenotazione_pasto").rev(),
  )

  dati-basati.subentities(
    entity: "prenotazione_pasto",
    subentities: ("prenotazione_asporto", "prenotazione_domicilio"),
  )
})
