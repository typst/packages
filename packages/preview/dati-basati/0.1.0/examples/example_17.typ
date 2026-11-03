#set page(width: auto, height: auto, margin: 1cm, fill: rgb("#fffcf3"))

#import "@preview/cetz:0.4.2"
#import "@preview/dati-basati:0.1.0"

#set text(font: "Barlow")

#show: dati-basati.dati-basati.with(
  ..dati-basati.themes.tiramisu,
)

#let entities = (
  "enrolled": (
    coordinates: (8, 0),
    attributes: (
      "north": ("enrolled_id", "name"),
      "east": ("surname", "size"),
      "south": ("birth_place", "birth_date"),
      "west": ("team", "frequency"),
    ),
    primary-key: "enrolled_id",
    label: "enrolled",
    name: "enrolled",
  ),
  "underage": (
    coordinates: (4, -4),
    attributes: (
      "north": ("companion",),
      "west": ("pre", "canteen", "post"),
    ),
    label: "underage",
    name: "underage",
  ),
  "assistant": (
    coordinates: (20, -4),
    attributes: (
      "east": ("age_interval", "cellphone", "sanitary_number"),
    ),
    label: "assistant",
    name: "assistant",
  ),
  "parents": (
    coordinates: (-3, 0),
    attributes: (
      "north": ("parents_id", "name", "surname", "cellphone", "emergency_phone"),
    ),
    primary-key: "parents_id",
    label: "parents",
    name: "parents",
  ),
  "residency": (
    coordinates: (-3, -7),
    attributes: (
      "north": ("residency_id",),
      "east": (("street", "number", "cap", "city", "province"),),
    ),
    primary-key: "residency_id",
    label: "residency",
    name: "residency",
  ),
  "allergies": (
    coordinates: (20, 4),
    attributes: (
      "north": ("allergies_id",),
      "east": ("allergies",),
    ),
    weak-entity: ("allergies_id", "west", "CCW"),
    label: "allergies",
    name: "allergies",
  ),
  "private_info": (
    coordinates: (20, 0),
    attributes: (
      "north": ("private_info_id",),
      "east": ("private_info",),
    ),
    weak-entity: ("private_info_id", "enrolled", "CCW"),
    label: "private\ninfo",
    name: "private_info",
  ),
  "initiative": (
    coordinates: (8, 5),
    attributes: (
      "west": ("initiative_id", "name", "date").rev(),
      "east": ("place", "price", "description"),
    ),
    primary-key: "initiative_id",
    label: "initiative",
    name: "initiative",
  ),
  "trip": (
    coordinates: (-6, 10),
    label: "trip",
    name: "trip",
  ),
  "swimming_pool": (
    coordinates: (-1, 10),
    label: "swimming\npool",
    name: "swimming_pool",
  ),
  "extratime": (
    coordinates: (5, 10),
    label: "extratime",
    name: "extratime",
  ),
  "serata_anim": (
    coordinates: (10, 10),
    label: "hangout",
    name: "serata_anim",
  ),
  "laboratory": (
    coordinates: (15.5, 10),
    attributes: (
      south: ("representative",),
    ),
    label: "laboratory",
    name: "laboratory",
  ),
  "summercamp": (
    coordinates: (22, 10),
    attributes: (
      "south": ("deposit", "balance"),
    ),
    label: "summercamp",
    name: "summercamp",
  ),
  "week": (
    coordinates: (12, -4),
    attributes: (
      "south": ("week_id", "start-date", "end-date", "other"),
    ),
    primary-key: "week_id",
    label: "week",
    name: "week",
  ),
  // "weekly-representative": (
  //   coordinates: (0, 0),
  //   attributes: (
  //     "west": ("weekly-representative_id", "category", "week_number"),
  //   ),
  //   label: "weekly-representative",
  //   name: "weekly-representative",
  // ),
  "shift": (
    coordinates: (20, -9),
    attributes: (
      "east": ("shift_id", "day", "time_slot"),
    ),
    primary-key: "shift_id",
    label: "shift",
    name: "shift",
  ),
  "activity": (
    coordinates: (12, -10),
    attributes: (
      "south": ("place", "teams", "outcome"),
    ),
    label: "activity",
    name: "activity",
  ),
  "service": (
    coordinates: (12, -8),
    attributes: (
      "west": ("category",),
    ),
    label: "service",
    name: "service",
  ),
  "game": (
    coordinates: (4, -10),
    attributes: (
      "west": ("game_id", "name", "materials").rev(),
    ),
    primary-key: "game_id",
    label: "game",
    name: "game",
  ),
  "coordinator": (
    coordinates: (20, -14),
    attributes: (
      "west": ("coordinator_id", "name", "surname"),
    ),
    primary-key: "coordinator_id",
    label: "coordinator",
    name: "coordinator",
  ),
  // "adult": (
  //   coordinates: (0, 0),
  //   attributes: (
  //     "west": ("adult_id", "name", "surname", "cellphone", "role"),
  //   ),
  //   primary-key: "adult_id",
  //   label: "adult",
  //   name: "adult",
  // ),
)

#let relations = (
  "parents-enrolled": (
    // coordinates: (0, -8),
    entities: ("parents", "enrolled"),
    label: "has",
    name: "parents-enrolled",
    cardinality: ("(1,n)", "(1,n)"),
  ),
  "parents-residency": (
    // coordinates: (0, -8),
    entities: ("parents", "residency"),
    label: ("live in", "east"),
    name: "parents-residency",
    cardinality: ("(1,1)", "(1,1)"),
  ),
  "private_info-enrolled": (
    // coordinates: (0, -8),
    entities: ("private_info", "enrolled"),
    label: "has",
    name: "private_info-enrolled",
    cardinality: ("(1,1)", "(0,1)"),
  ),
  "allergies-enrolled": (
    coordinates: (14.2, 4),
    entities: ("allergies", "enrolled"),
    label: "has",
    name: "allergies-enrolled",
    cardinality: ("(1,1)", "(0,1)"),
  ),
  "initiative-enrolled": (
    entities: ("initiative", "enrolled"),
    attributes: (
      "east": ("payment",),
    ),
    label: "choose",
    name: "initiative-enrolled",
    cardinality: ("(1,n)", "(0,n)"),
  ),
  "underage-week": (
    entities: ("underage", "week"),
    // label: "",
    attributes: (
      "north": ("m_voucher",),
      "south": ("payment",),
    ),
    name: "underage-week",
    cardinality: ("(1,n)", "(n,n)"),
  ),
  "assistant-week": (
    entities: ("assistant", "week"),
    // label: "",
    attributes: (
      "north": ("category",),
    ),
    name: "assistant-week",
    cardinality: ("(1,1)", "(1,n)"),
  ),
  "assistant-shift": (
    entities: ("assistant", "shift"),
    label: "has",
    name: "assistant-shift",
    cardinality: ("(1,n)", "(1,n)"),
  ),
  "shift-coordinator": (
    entities: ("shift", "coordinator"),
    label: "has",
    name: "shift-coordinator",
    cardinality: ("(1,n)", "(1,n)"),
  ),
  "game-activity": (
    entities: ("game", "activity"),
    label: "in",
    name: "game-activity",
    cardinality: ("(0,n)", "(1,n)"),
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
    entity: "enrolled",
    subentities: ("underage", "assistant"),
  )

  dati-basati.subentities(
    entity: "shift",
    // entity-position: "east",
    subentities: ("activity", "service"),
  )

  dati-basati.subentities(
    entity: "initiative",
    // entity-position: "south",
    subentities: ("trip", "swimming_pool", "extratime", "serata_anim", "laboratory", "summercamp"),
  )
})
