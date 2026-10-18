#import "@preview/cetz:0.4.2"
#import cetz.draw: *
#import "entity.typ": *
#import "attributes.typ": *
#import "weak-entity.typ": *
#import "cardinality.typ": *
#import "custom-marks.typ"
#import "utils.typ": *
#import "themes.typ": themes

#let default-settings = (
  fill: (
    entities: none,
    relations: none,
    composite-attributes: auto,
    primary-key: black,
    weak-entity: auto,
    cardinality: auto,
    hierarchy: auto,
  ),
  stroke: (
    entities: black,
    relations: black,
    attributes: black,
    composite-attributes: auto,
    primary-key: auto,
    weak-entity: auto,
    cardinality: none,
    hierarchy: auto,
    lines: auto,
  ),
  radius: (
    entities: 0pt,
    cardinality: 0pt,
    hierarchy: auto,
  ),
  spacing: (
    in-between: (x: 1.2em, y: 1.2em),
    padding: 1.2em,
  ),
  text: (
    entities: l => {
      set par(leading: 0.35em)
      text(
        top-edge: "bounds",
        size: 1.5em,
        weight: "bold",
        smallcaps(lower(l)),
      )
    },
    relations: l => l,
    attributes: l => l,
    cardinality: l => text(top-edge: "bounds", bottom-edge: "bounds", l),
    hierarchy: auto,
  ),
  attributes-position: (
    "north": (
      alignment: left,
      dir: "ltr",
      start: "from-short",
    ),
    "east": (
      alignment: center,
      dir: "ltr",
    ),
    "south": (
      alignment: right,
      dir: "rtl",
      start: "from-short",
    ),
    "west": (
      alignment: center,
      dir: "rtl",
    ),
  ),
  misc: (
    weak-entities-stroke: false,
    relations-intersection: "|-",
  ),
)

#let default-settings-state = state(
  "default settings",
  default-settings,
)

/// Default global settings.
/// -> dictionary
#let dati-basati(
  /// The fill of each element.
  /// -> dictionary
  fill: (:),
  /// The stroke of each element.
  /// -> dictionary
  stroke: (:),
  /// The radius of entities, cardinality and hierarchy.
  /// -> dictionary
  radius: (:),
  /// The spacing of attributes.
  /// -> dictionary
  spacing: (:),
  /// Text formatting of each element.
  /// -> dictionary
  text: (:),
  /// The position and direction of attributes.
  /// -> dictionary
  attributes-position: (:),
  /// Miscellanous options.
  /// -> dictionary
  misc: (:),
  body,
) = {
  default-settings-state.update(s => {
    let old = s

    let new-fill = update-dict(default-settings.fill, fill)
    old.insert("fill", new-fill)

    let new-stroke = update-dict(default-settings.stroke, stroke)
    old.insert("stroke", new-stroke)

    let new-radius = update-dict(default-settings.radius, radius)
    old.insert("radius", new-radius)

    let new-spacing = update-dict(default-settings.spacing, spacing)
    old.insert("spacing", new-spacing)

    let new-text = update-dict(default-settings.text, text)
    old.insert("text", new-text)

    let new-attributes-position = update-dict(
      default-settings.attributes-position,
      attributes-position,
      are-val-dict: true,
    )
    old.insert("attributes-position", new-attributes-position)

    let new-misc = update-dict(default-settings.misc, misc)
    old.insert("misc", new-misc)

    return old
  })

  body
}

/// Draw an Entity-Relation Diagram. This is the function that wraps all the
/// diagrams.
/// -> content
#let er-diagram(
  /// The theme of this diagram.
  /// -> dictionary
  theme: (:),
  /// Arguments directly passed to ```typ #cetz.canvas()```.
  /// -> dictionary
  ..args,
  /// Body of the diagram.
  /// -> content
  body,
) = context {
  let default-settings = default-settings-state.get()
  cetz.canvas(
    ..args,
    {
      set-ctx(ctx => ctx + (settings: default-settings))

      custom-marks.subentity-mark
      custom-marks.righetta
      custom-marks.empty-circle

      get-ctx(ctx => {
        custom-marks.filled-circle-mpk(fill: ctx.settings.fill.primary-key)
        custom-marks.filled-circle-pk(fill: ctx.settings.fill.primary-key)
      })

      body
    },
  )
}

/// Draw an entity.
/// -> content
#let entity(
  /// Coordinates of the entity.
  /// -> array
  coordinates,
  /// Unique name of the entity.
  /// -> str
  name: "",
  /// Label for the entity (e.g. Person, Book, Employee...).
  /// -> str | content
  label: "Entity",
  /// Attributes of the entity (e.g. id, name, surname, address...).
  /// -> dictionary
  attributes: (),
  /// Fine tune positioning of attributes.
  /// -> dictionary
  attributes-position: (:),
  /// Primary key(s).
  /// -> str | array
  primary-key: none,
  /// Whether this entity is weak and the corresponding attribute. The format is as follows:
  /// - SQL mirror: `(attribute, strong entity, direction)`
  /// - With cardinal points: `(cardinal pt, cardinal pt, direction)`
  /// They can be mixed.
  /// -> array
  weak-entity: none,
  /// Miscellanous options:
  /// - weak-entity-intersection
  /// -> dictionary
  misc: none,
  /// Arguments passed to ```typ #std.rect()```.
  /// -> args
  ..args,
) = {
  let is-multiple-pk = type(primary-key) == array and primary-key.len() > 1
  let is-single-array = type(primary-key) == array and primary-key.len() == 1

  _draw-entity-box(coordinates, label, name, weak-entity != none, args)

  // draw attributes and single primary key
  if attributes != none {
    get-ctx(ctx => {
      let merged-attributes-position = update-dict(
        ctx.settings.attributes-position,
        attributes-position,
        are-val-dict: true,
      )

      let is-there-an-array(x) = x.filter(e => type(e) == array).len() > 0

      for (side, attr) in attributes {
        if is-there-an-array(attr) {
          _draw-composite-attribute(
            name + "." + side,
            attr.at(0),
            position: side,
            in-between: ctx.settings.spacing.in-between,
            padding: ctx.settings.spacing.padding,
          )
          continue
        }

        let starting-coordinate = get-aligned-coordinate(
          name,
          side,
          merged-attributes-position.at(side).alignment,
          ctx.settings.spacing.in-between,
          1,
        )

        let pk = if is-single-array { primary-key.at(0) } else if not is-multiple-pk { primary-key }

        let draw-mode = if ("north", "south").contains(side) { merged-attributes-position.at(side).start }

        _draw-attributes(
          starting-coordinate,
          entity: name,
          attributes: attr,
          position: side,
          primary-key: pk,
          dir: merged-attributes-position.at(side).dir,
          drawing-mode: draw-mode,
          centered: merged-attributes-position.at(side).alignment == center,
          in-between: ctx.settings.spacing.in-between,
          padding: ctx.settings.spacing.padding,
        )
      }
    })
  }

  if is-multiple-pk {
    get-ctx(ctx => {
      let intersection = if ("north", "south").contains(find-side(primary-key.first(), attributes)) { "-|" } else {
        "|-"
      }

      let marks = if ("north", "south").contains(find-side(primary-key.first(), attributes)) {
        (end: "righetta", start: "filled-circle-mpk")
      } else { (start: "righetta", end: "filled-circle-mpk") }

      line(
        name + "-" + primary-key.first() + ".mid",
        ((), intersection, name + "-" + primary-key.last()),
        mark: marks,
        stroke: ctx.settings.stroke.primary-key,
      )
    })
  }

  if weak-entity != none {
    get-ctx(ctx => {
      let old-api = cardinal-points.contains(weak-entity.at(1))
      let direction = weak-entity.at(2, default: "CW")
      if old-api {
        _draw-we-path(
          name,
          (weak-entity.at(0), weak-entity.at(1), direction),
          attributes,
          ctx.settings.spacing.padding,
        )
        return
      }

      let normal = find-side(weak-entity.at(0), attributes) != false
      let strong-entity-position = get-rel-position-diagonal(name, weak-entity.at(1), ctx)

      if normal {
        if strong-entity-position.len() != 1 {
          if misc != none and misc.at("weak-entity-intersection", default: none) != none {
            anchor(
              name + "-" + weak-entity.at(1),
              (name, misc.weak-entity-intersection, weak-entity.at(1)),
            )
          }
          get-ctx(ctx => {
            add-intersect-anchor(
              _draw-we-path(
                name,
                strong-entity-position,
                attributes,
                ctx.settings.spacing.padding,
              ),
              if misc != none and misc.at("weak-entity-intersection", default: none) != none {
                (name, name + "-" + weak-entity.at(1))
              } else {
                (name, weak-entity.at(1))
              },
            )
            utils.draw-anchors(name, ctx.settings.spacing.padding / 2)
          })
          get-ctx(ctx => {
            let final-side = utils.get-diagonal-side("intersection.0", name, ctx)
            let intersection = cetz.coordinate.resolve(ctx, "intersection.0").at(1).slice(0, 2)
            // circle("intersection.0", radius: 0.05, fill: red)
            _draw-we-path(
              name,
              (weak-entity.at(0), final-side, direction),
              attributes,
              ctx.settings.spacing.padding,
              intersection: intersection,
            )
          })
        } else {
          _draw-we-path(
            name,
            (weak-entity.at(0), strong-entity-position.first(), direction),
            attributes,
            ctx.settings.spacing.padding,
          )
        }
      } else {
        let other-strong-entity-position = get-rel-position-diagonal(name, weak-entity.at(0), ctx)
        if strong-entity-position.len() != 1 and other-strong-entity-position.len() != 1 {
          panic("Not implemented yet. Line up strong entities on the axis.")
        } else {
          _draw-we-path(
            name,
            (
              other-strong-entity-position.first(),
              strong-entity-position.first(),
              direction,
            ),
            attributes,
            ctx.settings.spacing.padding,
          )
        }
      }
    })
  }
}

/// Connect subentities to the superentity.
/// -> content
#let subentities(
  /// The hierarchy of the subentities:
  /// - (t,e) = (total, exclusive)
  /// - (p,e) = (partial, exclusive)
  /// - (p,o) = (partial, overlapping)
  /// -> "(t,e)" | "(p,e)" | "(p,o)"
  hierarchy: "(t,e)",
  /// The superentity, the one to which the subentities will connect.
  /// -> str
  entity: "",
  /// The subentities. Can be just one.
  /// -> array
  subentities: ("",),
) = {
  let entity-position-dict = (
    // (to get meeting point, lines from subentities)
    "north": ("-|", "|-"),
    "east": ("|-", "-|"),
    "south": ("-|", "|-"),
    "west": ("|-", "-|"),
  )

  get-ctx(ctx => {
    let entity-position = utils.get-rel-subentity(entity, subentities, ctx)
    let opposite-cardinal = get-opp-cardinal(entity-position)
    let intersection-array = entity-position-dict.at(entity-position)

    _draw-cardinality-box(
      entity + "." + opposite-cardinal,
      label: hierarchy,
      name: "hierarchy-box",
      hierarchy: true,
    )

    // hide({
    //   line(
    //     (
    //       subentities.at(0) + "." + entity-position,
    //       intersection-array.at(0),
    //       "hierarchy-box" + "." + opposite-cardinal,
    //     ),
    //     "hierarchy-box" + "." + opposite-cardinal,
    //     name: "tmp",
    //   )
    // })
    // let meeting-point = "tmp.mid"
    anchor(
      "tmp",
      (
        (
          subentities.at(0) + "." + entity-position,
          intersection-array.at(0),
          "hierarchy-box" + "." + opposite-cardinal,
        ),
        50%,
        "hierarchy-box" + "." + opposite-cardinal,
      ),
    )

    let meeting-point = "tmp"

    // "shared" line between subentities
    line(
      (subentities.first(), intersection-array.at(1), meeting-point),
      meeting-point,
    )
    line(
      meeting-point,
      (subentities.last(), intersection-array.at(1), meeting-point),
    )
    for subentity in subentities {
      line(
        subentity,
        (
          subentity,
          intersection-array.at(1),
          meeting-point,
        ),
        // stroke: ctx.settings.stroke.subentities,
      )
    }

    // hide(line(meeting-point, entity, name: "cardinality-position"))
    line(
      meeting-point,
      "hierarchy-box",
      mark: (end: "subentity-mark"),
      name: "line-subentities",
      // stroke: ctx.settings.stroke.subentities,
    )
  })
}

/// Draw a relation between (sub)entities.
/// -> content
#let relation(
  /// The specific coordinates of this relation. If left empty, they will the middle point
  /// between the two entities.
  /// -> array
  coordinates: none,
  /// Entities that are tied by this relation.
  /// -> array
  entities: (),
  /// Unique name of relation.
  /// -> str
  name: "",
  /// Label for the relation (e.g. "occupies", "relates", "is part of"...).
  /// -> str
  label: "",
  /// Attributes of the relation (e.g. id, name, surname, address...).
  /// -> dictionary
  attributes: (:),
  /// Cardinality of the given relation:
  /// -> array
  cardinality: (),
) = {
  assert(cardinality.len() == 2, message: "You need to specify the cardinality.")

  if coordinates == none {
    hide({ line(..entities, name: "tmp") })
    coordinates = "tmp.mid"
  }

  let is-entities-array = (
    type(entities.at(0)) == array,
    type(entities.at(1)) == array,
  )

  let is-same-entity = (
    entities.at(0) == entities.at(1)
      or (
        is-entities-array.at(0) and is-entities-array.at(1) and entities.at(0).at(0) == entities.at(1).at(0) // first element of each array
      )
      or (
        is-entities-array.at(0) and entities.at(0).at(0) == entities.at(0) // first element of first array
      )
      or (
        is-entities-array.at(1) == array and entities.at(0) == entities.at(1).at(0) // first element of second array
      )
  )

  let is-array = type(label) == array

  get-ctx(ctx => {
    polygon(
      coordinates,
      4,
      radius: if not is-array and label != none { measure(label).width * 0.5 + measure(label).height } else { 0.5 },
      name: name,
      fill: handle-auto(
        ctx.settings.fill.relations,
        ctx.settings.fill.entities,
      ),
      stroke: handle-auto(
        ctx.settings.stroke.relations,
        ctx.settings.stroke.entities,
      ),
    )
    if is-array {
      content(
        (),
        anchor: label.at(1),
        padding: 1.7em,
        label.at(0),
      )
    } else {
      content(
        (),
        padding: 1.7em,
        align(center, (ctx.settings.text.relations)(label)),
      )
    }

    set-style(
      line: (
        stroke: handle-auto(
          ctx.settings.stroke.lines,
          ctx.settings.stroke.entities,
        ),
      ),
    )

    if not is-same-entity {
      for i in range(0, entities.len()) {
        let coordinate-start = if is-array { label.at(0) } else { label }
        line(
          entities.at(i),
          name,
          name: coordinate-start + "-" + entities.at(i),
        )
        _draw-cardinality-box(
          coordinate-start + "-" + entities.at(i) + ".start",
          label: cardinality.at(i),
        )
      }
    } else {
      let from-entity = if is-entities-array.at(0) {
        (
          entities.at(0).at(0) + "." + entities.at(0).at(1),
          ((), "|-", name),
        )
      } else {
        (
          entities.at(0) + ".north",
          (rel: (0, 1)),
          ((), "-|", name),
        )
      }
      let to-entity = (
        if is-entities-array.at(1) {
          (
            entities.at(1).at(0) + "." + entities.at(1).at(1),
          )
        } else {
          (
            entities.at(1) + ".south",
            (rel: (0, -1)),
          )
        }
          + (((), "-|", name),)
      )
      line(
        ..from-entity,
        name,
        name: name + "-from-entity",
      )
      line(
        ..to-entity,
        name,
        name: name + "-to-entity",
      )
      _draw-cardinality-box(
        name + "-from-entity" + ".start",
        label: cardinality.at(0),
      )
      _draw-cardinality-box(
        name + "-to-entity" + ".start",
        label: cardinality.at(1),
      )
    }
  })

  if attributes != none {
    for (side, attr) in attributes {
      _draw-attributes(
        name + "." + side,
        entity: name,
        attributes: attr,
        position: side,
      )
    }
  }
}
