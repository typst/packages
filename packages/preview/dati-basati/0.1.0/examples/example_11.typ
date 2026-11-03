// 2024-02

#set page(width: auto, height: auto, margin: 1cm, fill: rgb("#5E0606").lighten(80%))

#import "@preview/cetz:0.4.2"
#import "@preview/dati-basati:0.1.0"

#show: dati-basati.dati-basati.with(
  ..dati-basati.themes.futurama,
)

#let entities = (
  "residenza": (
    coordinates: (20, 0),
    attributes: (
      "north": (
        "Ubicazione",
        "#locali",
        "#posti-letto",
        "DistanzaDalMare",
        "VistaSulMare",
        "Tipo",
        "ImportoCauzione",
      ).rev(),
      "east": ("URL", "Foto", "Descrizione"),
    ),
    attributes-position: (
      north: (alignment: center, dir: "rtl"),
    ),
    primary-key: ("Ubicazione",),
    label: "residenza",
    name: "residenza",
  ),
  "servizi_aggiuntivi": (
    coordinates: (10, 0),
    attributes: (
      "north": ("Tipo",),
      "south": ("Costo",),
    ),
    attributes-position: (
      north: (alignment: right),
      south: (alignment: left),
    ),
    weak-entity: ("Tipo", "residenza", "CW"),
    label: "Servizi\naggiuntivi",
    name: "servizi_aggiuntivi",
  ),
  "settimana": (
    coordinates: (20, -5),
    attributes: (
      "north": ("DataInizio",),
      "south": ("CostoSettimana",),
    ),
    attributes-position: (
      "north": (
        dir: "rtl",
        alignment: right,
      ),
      "south": (
        alignment: right,
      ),
    ),
    weak-entity: ("DataInizio", "residenza", "CCW"),
    label: "settimana",
    name: "settimana",
  ),
  "cliente": (
    coordinates: (10, -10),
    attributes: (
      "west": ("Email", "Telefono"),
      "east": ("Nome", "Cognome"),
    ),
    primary-key: ("Email",),
    label: "cliente",
    name: "cliente",
  ),
  "prenotazione": (
    coordinates: (10, -5),
    attributes: (
      "south": ("Data_Saldo", "Data_Cauzione", "Data_Anticipo"),
    ),
    weak-entity: ("south", "east", "CCW"),
    label: "prenotazione",
    name: "prenotazione",
  ),
  "danno": (
    coordinates: (0, -5),
    attributes: (
      "south": ("ImportoTotale", "Descrizione").rev(),
    ),
    weak-entity: ("Descrizione", "prenotazione", "CCW"),
    label: "danno",
    name: "danno",
  ),
)

#let relations = (
  "danno-prenotazione": (
    coordinates: (4.5, -5),
    entities: ("danno", "prenotazione"),
    label: ("da pagare", "south"),
    name: "danno-prenotazione",
    cardinality: ("(1,1)", "(0,1)"),
  ),
  "servizi_aggiuntivi-residenza": (
    coordinates: (15, 0),
    entities: ("servizi_aggiuntivi", "residenza"),
    label: ("offerto da", "south"),
    name: "servizi_aggiuntivi-residenza",
    cardinality: ("(1,1)", "(0,n)"),
  ),
  "servizi_aggiuntivi-prenotazione": (
    coordinates: (10, -2.5),
    entities: ("servizi_aggiuntivi", "prenotazione"),
    label: ("include", "west"),
    name: "servizi_aggiuntivi-prenotazione",
    cardinality: ("(0,n)", "(0,n)"),
  ),
  "residenza-settimana": (
    coordinates: (20, -2.5),
    entities: ("residenza", "settimana"),
    label: "in",
    name: "residenza-settimana",
    cardinality: ("(0,n)", "(1,1)"),
  ),
  "settimana-prenotazione": (
    coordinates: (15, -5),
    entities: ("settimana", "prenotazione"),
    label: "per",
    name: "settimana-prenotazione",
    cardinality: ("(0,1)", "(1,1)"),
  ),
  "prenotazione-cliente": (
    coordinates: (10, -7.5),
    entities: ("prenotazione", "cliente"),
    label: ("effettua", "east"),
    name: "prenotazione-cliente",
    cardinality: ("(1,1)", "(1,n)"),
  ),
)

#dati-basati.er-diagram({
  for entity in entities.values() {
    dati-basati.entity(
      entity.coordinates,
      label: entity.label,
      name: entity.name,
      attributes: entity.attributes,
      attributes-position: entity.at("attributes-position", default: none),
      primary-key: entity.at("primary-key", default: none),
      weak-entity: entity.at("weak-entity", default: none),
    )
  }

  for relation in relations.values() {
    dati-basati.relation(
      coordinates: relation.coordinates,
      entities: relation.entities,
      label: relation.label,
      name: relation.name,
      cardinality: relation.cardinality,
      attributes: relation.at("attributes", default: none),
    )
  }
})
