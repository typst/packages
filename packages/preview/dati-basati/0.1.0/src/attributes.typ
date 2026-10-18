#import "@preview/cetz:0.4.2"
#import cetz.draw: *
#import "custom-marks.typ"
#import "utils.typ": handle-auto

/// Draw the attributes on a specified side of the entity.
/// -> content
#let _draw-attributes(
  /// Starting coordinate from which the attributes will be actually drawn.
  /// -> array
  start-coordinate,
  /// Unique name of the entity.
  /// -> str
  entity: "bella",
  /// Position of where the attributes will be drawn.
  /// -> "north" | "east" | "south" | "west"
  position: "north",
  /// _All_ attributes of the entity.
  /// -> array
  attributes: none,
  /// A single primary key.
  /// -> str
  primary-key: none,
  /// Direction in which the attributes will be drawn. Can be either `ltr`, left to right, or
  /// `rtl`, right to left.
  /// -> "ltr" | "rtl"
  dir: "ltr",
  /// Whether to draw starting from the smallest or longest attribute. Only applies to
  /// north, south sides: the others have always the same padding.
  /// -> "from-short" | "from-long"
  drawing-mode: "from-short",
  /// Spacing in-between attributes.
  /// -> dictionary
  in-between: (x: 1.2em, y: 1.2em),
  /// Padding from the entity. Note: this CANNOT BE different between `x`,`y` because of the
  /// weak entity path.
  /// -> length
  padding: 1.2em,
  /// Label anchor, the opposite side of there the label will be displayed. It's
  /// automatically calculated based on `position` and `dir`.
  /// -> auto | "north" | "east" | "south" | "west"
  label-anchor: auto,
  /// Whether to align to the center the attributes: they will be drawn as if centered around the
  /// `start-coordinate`.
  /// -> bool
  centered: false,
  /// Attributes stroke.
  /// -> auto | str
  attr-stroke: auto,
) = {
  let attributes-len = attributes.len()
  let h-spacing
  let v-spacing

  if ("north", "south").contains(position) {
    h-spacing = in-between.y
    v-spacing = padding

    if position == "south" { v-spacing = -v-spacing }
    if dir == "rtl" { h-spacing = -h-spacing }
    if label-anchor == auto {
      label-anchor = "east"
      if dir == "rtl" or dir == "ltr" and drawing-mode == "from-long" {
        label-anchor = "west"
      }
      if dir == "rtl" and drawing-mode == "from-long" { label-anchor = "east" }
    }

    for i in range(0, attributes-len) {
      let drawing-coefficient = i + 1
      if drawing-mode == "from-long" {
        drawing-coefficient = attributes-len - i
      }
      let points = (
        (
          rel: (h-spacing * i, 0),
          to: (start-coordinate),
        ),
        (
          rel: (0, v-spacing * drawing-coefficient),
          to: (),
        ),
      )
      if attributes-len > 1 and centered == true {
        points.at(0) = (
          rel: (h-spacing * i - h-spacing * (attributes-len - 1) / 2, 0),
          to: (start-coordinate),
        )
      }
      get-ctx(ctx => {
        let mark = "empty-circle"
        if attributes.at(i) == primary-key {
          mark = "filled-circle-pk"
        }
        line(
          ..points,
          name: entity + "-" + attributes.at(i),
          mark: (end: mark),
          stroke: if attr-stroke == auto {
            if attributes.at(i) == primary-key {
              handle-auto(
                ctx.settings.stroke.primary-key,
                ctx.settings.stroke.attributes,
              )
            } else {
              ctx.settings.stroke.attributes
            }
          } else { attr-stroke },
        )
        content(
          entity + "-" + attributes.at(i) + ".end",
          anchor: label-anchor,
          padding: (left: 0.5em, right: 0.5em),
          attributes.at(i),
        )
      })
    }
  } else {
    h-spacing = padding
    v-spacing = in-between.x

    if position == "east" { h-spacing = -h-spacing }
    if dir == "rtl" { v-spacing = -v-spacing }
    if label-anchor == auto {
      label-anchor = "west"
      if position == "west" { label-anchor = "east" }
    }

    for i in range(0, attributes-len) {
      let points = (
        (
          rel: (0, -v-spacing * i),
          to: (start-coordinate),
        ),
        (
          rel: (-h-spacing, 0),
          to: (),
        ),
      )
      if attributes-len > 1 and centered == true {
        points.at(0) = (
          rel: (0, -v-spacing * i + v-spacing * ((attributes-len - 1) / 2)),
          to: (start-coordinate),
        )
      }
      get-ctx(ctx => {
        let mark = "empty-circle"
        if attributes.at(i) == primary-key {
          mark = "filled-circle-pk"
        }
        line(
          ..points,
          name: entity + "-" + attributes.at(i),
          mark: (end: mark),
          stroke: if attr-stroke == auto {
            if attributes.at(i) == primary-key {
              handle-auto(
                ctx.settings.stroke.primary-key,
                ctx.settings.stroke.attributes,
              )
            } else {
              ctx.settings.stroke.attributes
            }
          } else { attr-stroke },
        )
        content(
          entity + "-" + attributes.at(i) + ".end",
          anchor: label-anchor,
          padding: (left: 0.5em, right: 0.5em),
          attributes.at(i),
        )
      })
    }
  }
}

/// Draw a composite attribute on a specified side.
/// -> content
#let _draw-composite-attribute(
  /// From where the composite attribute will be drawn. Note that it's NOT the ellipse,
  /// rather the line LEADING TO THE CENTER of the ellipse.
  /// -> array
  coordinates,
  /// The corresponding attributes.
  /// -> array
  attributes,
  /// Side of where the composite attribute will be drawn. Note there will not be drawn any other
  /// attributes on this same side.
  /// -> "north" | "east" | "south" | "west"
  position: "west",
  /// Longest radius coefficient.
  /// -> int | float | length
  dimensions: 0.5,
  /// Longest radius coefficient.
  /// -> int | float
  dimensions-coefficient: 5,
  /// Padding of the starting line (distance from the composite attribute and the entity).
  /// -> int | float
  padding-coefficient: 0.5,
  /// Spacing in-between attributes. Same dict as ```typ _draw-attributes()```.
  /// -> dictionary
  in-between: (x: 1.2em, y: 1.2em),
  /// Padding from the ellipse. Same dict as ```typ _draw-attributes()```.
  /// -> length
  padding: 1.5em,
) = {
  let is-y = (position == "north" or position == "south")

  let longest = (
    dimensions
      * attributes.len()
      * (
        if is-y {
          in-between.y
        } else { in-between.x }
      )
  )

  dimensions = (longest / dimensions-coefficient, longest)
  if is-y {
    dimensions = (dimensions.at(1), dimensions.at(0))
  }

  let rel-dict = (
    "north": (0, longest * padding-coefficient),
    "east": (longest * padding-coefficient, 0),
    "south": (0, -longest * padding-coefficient),
    "west": (-longest * padding-coefficient, 0),
  )
  get-ctx(ctx => {
    line(
      coordinates,
      (rel: rel-dict.at(position)),
      name: "comp-attr",
      stroke: handle-auto(
        ctx.settings.stroke.composite-attributes,
        ctx.settings.stroke.attributes,
      ),
    )

    _draw-attributes(
      "comp-attr.end",
      attributes: attributes,
      centered: true,
      position: position,
      in-between: in-between,
      padding: padding,
      attr-stroke: ctx.settings.stroke.composite-attributes,
    )

    circle(
      "comp-attr.end",
      fill: if ctx.settings.fill.composite-attributes == auto {
        handle-auto(page.fill, white)
      } else {
        ctx.settings.fill.composite-attributes
      },
      stroke: handle-auto(
        ctx.settings.stroke.composite-attributes,
        ctx.settings.stroke.attributes,
      ),
      radius: dimensions,
    )
  })
}
