#set page(width: auto, height: auto, margin: 1cm, fill: rgb("#FFE066").lighten(80%))

#import "@preview/cetz:0.4.2"
#import "@preview/dati-basati:0.1.0"

#show: dati-basati.dati-basati.with(
  ..dati-basati.themes.ghibli,
)

#let quality = ("height", "width", "audio", "video")

#let entities = (
  "series": (
    coordinates: (6, 0),
    attributes: (
      "north": (..quality.slice(0, 2),),
      "south": (..quality.slice(2),),
      "east": ("name", "year"),
    ),
    attributes-position: (
      north: (alignment: left, dir: "ltr"),
      south: (alignment: left, dir: "ltr"),
    ),
    primary-key: ("year", "name"),
    label: "series",
    name: "series",
  ),
  "episode": (
    coordinates: (-0.6, 0),
    attributes: (
      "north": (..quality,),
      "west": ("series", "year"),
      "south": ("number",),
    ),
    attributes-position: (
      north: (alignment: center, dir: "ltr"),
      south: (alignment: right, dir: "rtl"),
    ),
    weak-entity: ("number", "series", "CCW"),
    label: "episode",
    name: "episode",
  ),
  "movie": (
    coordinates: (-6, 0),
    attributes: (
      "north": (..quality.slice(0, 2),),
      "south": (..quality.slice(2),),
      "west": ("name", "year"),
    ),
    attributes-position: (
      north: (alignment: right, dir: "rtl"),
      south: (alignment: right, dir: "rtl"),
    ),
    primary-key: ("year", "name").rev(),
    label: "movie ",
    name: "movie",
  ),
  "category": (
    coordinates: (0, 4),
    attributes: (
      "south": ("category", "title", "year").rev(),
    ),
    primary-key: ("title", "year").rev(),
    label: "category",
    name: "category",
  ),
  "status": (
    coordinates: (0, -4),
    attributes: (
      "north": ("status", "title", "year").rev(),
    ),
    attributes-position: (
      north: (alignment: left, dir: "ltr"),
    ),
    primary-key: ("title", "year").rev(),
    label: "status",
    name: "status",
  ),
)

#let relations = (
  "series-episode": (
    entities: ("series", "episode"),
    label: "has",
    name: "series-episode",
    cardinality: ("(1,n)", "(1,1)"),
  ),
  "series-category": (
    coordinates: (6, 4),
    entities: ("series", "category"),
    label: "in",
    name: "series-category",
    cardinality: ("(1,1)", "(1,n)"),
  ),
  "movie-category": (
    coordinates: (-6, 4),
    entities: ("movie", "category"),
    label: "in",
    name: "movie-category",
    cardinality: ("(1,1)", "(1,n)"),
  ),
  "series-status": (
    coordinates: (6, -4),
    entities: ("series", "status"),
    label: "in",
    name: "series-status",
    cardinality: ("(1,1)", "(1,n)"),
  ),
  "movie-status": (
    coordinates: (-6, -4),
    entities: ("movie", "status"),
    label: "in",
    name: "movie-status",
    cardinality: ("(1,1)", "(1,n)"),
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
})
