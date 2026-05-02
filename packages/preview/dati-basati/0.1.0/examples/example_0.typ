// tiw

#set page(width: auto, height: auto, margin: 1cm)

#import "@preview/dati-basati:0.1.0" as db

#set text(font: "Barlow")

#show: db.dati-basati.with(..db.themes.tiw)

#let entities = (
  "user": (
    coordinates: (0, 0),
    attributes: (
      "north": ("user_id", "nickname", "password"),
      "west": ("name", "surname"),
    ),
    attributes-position: (
      north: (alignment: center),
    ),
    primary-key: "user_id",
    label: "user",
    name: "user",
  ),
  "playlist": (
    coordinates: (5, -5),
    attributes: (
      "south": ("title",),
      "north": ("creation_date",),
    ),
    attributes-position: (
      "north": (alignment: right),
      "south": (alignment: left),
    ),
    weak-entity: ("title", "west"),
    label: "playlist",
    name: "playlist",
  ),
  "track": (
    coordinates: (10, 0),
    attributes: (
      "north": ("track_id", "title", "artist", "album").rev(),
      "east": ("year", "image_path", "song_path"),
    ),
    attributes-position: (
      "north": (
        alignment: center,
        dir: "ltr",
      ),
    ),
    primary-key: "track_id",
    label: "track",
    name: "track",
  ),
)

#let relations = (
  "user-playlist": (
    coordinates: (0, -5),
    entities: ("user", "playlist"),
    label: "creates",
    name: "user-playlist",
    cardinality: ("(0,n)", "(1,1)"),
  ),
  "user-track": (
    entities: ("user", "track"),
    label: "uploads",
    name: "user-track",
    cardinality: ("(0,n)", "(1,1)"),
  ),
  "playlist-track": (
    coordinates: (10, -5),
    entities: ("playlist", "track"),
    label: "contains",
    name: "playlist-track",
    cardinality: ("(0,n)", "(0,n)"),
    attributes: ("east": ("custom_order",)),
  ),
)

#db.er-diagram({
  for entity in entities.values() {
    db.entity(
      entity.coordinates,
      label: entity.label,
      name: entity.name,
      attributes: entity.attributes,
      attributes-position: entity.at("attributes-position", default: none),
      primary-key: entity.at("primary-key", default: none),
      weak-entity: entity.at("weak-entity", default: none),
      misc: entity.at("misc", default: none),
    )
  }

  for relation in relations.values() {
    db.relation(
      coordinates: relation.at("coordinates", default: none),
      entities: relation.entities,
      label: relation.at("label", default: none),
      name: relation.name,
      cardinality: relation.cardinality,
      attributes: relation.at("attributes", default: none),
    )
  }
})
