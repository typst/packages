#import "@preview/cetz:0.4.2"
#import cetz.draw: *
#import "custom-marks.typ"
#import "utils.typ"

/// Retrieve the path needed to draw the weak entity.
/// -> array
#let _weak-entity-path(
  /// Starting coordinate (key, weak entity).
  /// -> str
  start,
  /// Ending side.
  /// -> "north" | "east" | "south" | "west"
  end,
  /// Direction: can be clockwise or counterclockwise.
  /// -> "CW" | "CCW" | "cw" | "ccw"
  dir: "CW",
) = {
  let dir = upper(dir)
  assert(
    utils.cardinal-points.contains(end),
    message: "The end be either: \"north\", \"east\", \"south\" or \"west\".",
  )
  assert(
    ("CW", "CCW").contains(dir),
    message: "The direcion must be either: CW, CCW.",
  )

  // clockwise coordinates from NORTH
  let coordinates = (
    "north",
    ("north", "east", "v"),
    ("north", "east", "h"),
    "east",
    ("south", "east", "h"),
    ("south", "east", "v"),
    "south",
    ("south", "west", "v"),
    ("south", "west", "h"),
    "west",
    ("north", "west", "h"),
    ("north", "west", "v"),
  )

  if start != end {
    let start = utils.get-idx(start, arr: coordinates)
    let end = utils.get-idx(end, arr: coordinates)
    let added = 1

    let arr = if dir == "CW" {
      if start < end {
        range(start, end + added, step: 1)
      } else {
        (range(start, coordinates.len()) + range(0, end + added))
      }
    } else {
      if start > end {
        range(start, end - added, step: -1)
      } else {
        (range(start, -1, step: -1) + range(coordinates.len() - 1, end - added, step: -1))
      }
    }

    return arr.map(e => coordinates.at(e)).filter(e => not utils.cardinal-points.contains(e))
  } else {
    let mid-dict = (
      "north-CW": "east",
      "south-CCW": "east",
      "north-CCW": "west",
      "south-CW": "west",
      "east-CW": "south",
      "west-CCW": "south",
      "east-CCW": "north",
      "west-CW": "north",
    )

    let mid = mid-dict.at(start + "-" + dir)
    let s = if ("north", "south").contains(start) { "v" } else { h }

    return ((start, mid, s),)
  }
}

/// Given a weak entity path, return the traversed angles.
/// -> array
#let get-angles(
  /// Weak entity path.
  /// -> array
  path,
) = return path.map(e => e.slice(0, 2)).dedup()

// TESTING

// #_weak-entity-path("north", "north", dir: "CW")

// #_weak-entity-path("east", "west", dir: "CCW")

// #_weak-entity-path("west", "east", dir: "CW")

// #_weak-entity-path("west", "east", dir: "CCW")

// #get-angles(_weak-entity-path("east", "west", dir: "CW"))

// #get-angles(_weak-entity-path("east", "west", dir: "CCW"))

// #get-angles(_weak-entity-path("west", "east", dir: "CW"))

// #get-angles(_weak-entity-path("west", "east", dir: "CCW"))

/// Draw the weak entity path.
/// -> content
#let _draw-we-path(
  /// Name of the entity.
  /// -> str
  name,
  /// Weak entity in the following format: (attribute, end side, direction).
  /// -> array
  weak-entity,
  /// Entity attributes.
  /// -> dictionary
  attributes,
  /// Distance from the entity to the label(s) of the attributes (```typ #spacing.padding``` dictionary).
  /// -> length
  spacing,
  /// Specific final coordinate.
  /// -> array
  intersection: none,
) = {
  let wk-mark-length = if ("north", "south").contains(weak-entity.at(1)) {
    1.35em
  } else {
    1em
  }
  get-ctx(ctx => {
    custom-marks.filled-circle-wk(
      fill: utils.handle-auto(
        ctx.settings.fill.weak-entity,
        ctx.settings.fill.primary-key,
      ),
      wk-mark-length,
    )
    set-style(
      line: (
        stroke: utils.handle-auto(
          ctx.settings.stroke.weak-entity,
          ctx.settings.stroke.primary-key,
        ),
      ),
      angle: (
        stroke: utils.handle-auto(
          ctx.settings.stroke.weak-entity,
          ctx.settings.stroke.primary-key,
        ),
      ),
    )
  })

  let starting-side = utils.find-side(weak-entity.at(0), attributes)
  let wk-dir = weak-entity.at(2, default: "CW")

  let is-same-side = starting-side == weak-entity.at(1)
  let are-two-sides = (
    utils.cardinal-points.contains(weak-entity.at(0)) and utils.cardinal-points.contains(weak-entity.at(1))
  )

  let start = none // the first segment of path, from the attr
  let mid = none // the middle part: horizontal segments and angle
  let end = none // the end segment: to the relation

  if is-same-side {
    start = weak-entity.at(0) + ".mid"
    mid = none
    end = weak-entity.at(1)
  } else if are-two-sides {
    start = weak-entity.at(0)
    mid = _weak-entity-path(
      weak-entity.at(0),
      weak-entity.at(1),
      dir: wk-dir,
    )
    end = weak-entity.at(1)
  } else {
    start = weak-entity.at(0) + ".mid"
    mid = _weak-entity-path(
      starting-side,
      weak-entity.at(1),
      dir: wk-dir,
    )
    end = weak-entity.at(1)
  }

  let dirs = (
    "north": (0, spacing),
    "east": (spacing, 0),
    "south": (0, -spacing),
    "west": (-spacing, 0),
  )

  // draw required hidden lines and angles
  if not is-same-side {
    for coord in mid {
      let (dir_y, dir_x, s) = coord
      let origin = name + "." + dir_y + "-" + dir_x
      let rel = (dirs.at(dir_x), dirs.at(dir_y))
      // this COULD BE an anchor, though merge-path can't accept anchors
      hide({
        line(
          origin,
          (rel: if s == "h" { rel.at(0) } else { rel.at(1) }),
          name: dir_y + "-" + dir_x + "-" + s,
        )
      })
    }
    let angle-radius = 0.5 * spacing
    get-ctx(ctx => {
      for angle in get-angles(mid) {
        let angle = angle.join("-")
        let start-end-angle = (
          angle + "-h",
          angle + "-v",
        )
        if ("north-west", "south-east").contains(angle) {
          start-end-angle = (
            angle + "-v",
            angle + "-h",
          )
        }
        cetz.angle.angle(
          name + "." + angle,
          ..start-end-angle,
          name: "angle-" + angle,
          radius: angle-radius,
          stroke: ctx.settings.stroke.weak-entity,
        )
      }
      for chunk in mid.map(e => e.join("-")).slice(1, mid.len() - 1).chunks(2) {
        line(
          ..chunk,
          stroke: ctx.settings.stroke.weak-entity,
        )
      }
    })
  }

  // draw the final coordinate
  // this too could be just an anchor
  hide({
    for (k, v) in dirs {
      line(
        name + "." + k,
        (rel: (dirs.at(k))),
        name: name + "-" + k + "-wk",
      )
    }
  })

  let end-coordinate = name + "-" + end + "-wk"
  if intersection != none { end-coordinate = intersection }

  get-ctx(ctx => {
    if is-same-side {
      line(
        name + "-" + start,
        end-coordinate,
        mark: (start: "righetta", end: "filled-circle-wk"),
      )
    } else if are-two-sides {
      line(
        name + "-" + start + "-wk",
        mid.at(0).join("-"),
        mark: (start: "righetta"),
      )
      line(
        mid.last().join("-"),
        end-coordinate,
        mark: (end: "filled-circle-wk"),
      )
    } else {
      line(
        name + "-" + start,
        mid.at(0).join("-"),
        mark: (start: "righetta"),
      )
      line(
        mid.last().join("-"),
        end-coordinate,
        mark: (end: "filled-circle-wk"),
      )
    }
  })
}
