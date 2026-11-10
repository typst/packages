#import "@preview/cetz:0.4.2"
#import cetz.draw: *

/// Given a value from an array, find its key.
/// -> content
#let find-side(x, dict) = {
  for (k, v) in dict {
    if v.contains(x) {
      return k
    }
  }
  return false
}

#let cardinal-points = ("north", "east", "south", "west")

/// Returns the index of `x` in `arr`.
/// -> int
#let get-idx(
  /// Element to search
  /// -> str
  x,
  /// The array from which to search.
  /// -> arrayay
  arr: cardinal-points,
) = {
  let result = arr.enumerate().find(e => e.at(1) == x)
  if result != none {
    result.first()
  } else {
    return 0
  }
}

/// Gets the next cardinal point (e.g. "north" -> "east").
/// -> str
#let get-next-cardinal(pt) = {
  let next = get-idx(pt) + 1
  if next > 3 {
    return cardinal-points.at(0)
  }
  return cardinal-points.at(next)
}

/// Gets the previous cardinal point (e.g. "north" -> "west").
/// -> str
#let get-prev-cardinal(pt) = {
  let prev = get-idx(pt) - 1
  if prev > 3 {
    return cardinal-points.at(0)
  }
  return cardinal-points.at(prev)
}

/// Gets the opposite cardinal point (e.g. "north" -> "south").
/// -> str
#let get-opp-cardinal(pt) = {
  let opp = get-idx(pt) + 2
  if opp > 3 {
    return cardinal-points.at(opp - 4)
  }
  return cardinal-points.at(opp)
}

/// Get the corrected coordinates. For instance top-left != north-west, because there is a
/// little horizontal spacing to be added.
/// -> array
#let get-aligned-coordinate(
  entity,
  side,
  aligned,
  in-between,
  attributes-len,
) = {
  let coordinate = entity + "." + side
  if aligned != center {
    if aligned == left {
      coordinate = entity + "." + get-prev-cardinal(side) + "-" + side
      if side == "north" or side == "south" {
        coordinate = entity + "." + side + "-west"
      }
    }
    if aligned == right {
      coordinate = entity + "." + get-next-cardinal(side) + "-" + side
      if side == "north" or side == "south" {
        coordinate = entity + "." + side + "-east"
      }
    }
    if (side == "north" and aligned == left) or (side == "south" and aligned == left) {
      coordinate = (
        rel: (in-between.y * attributes-len, 0),
        to: coordinate,
      )
    } else if (side == "north" and aligned == right) or (side == "south" and aligned == right) {
      coordinate = (
        rel: (-in-between.y * attributes-len, 0),
        to: coordinate,
      )
    } else if (side == "east" and aligned == left) or (side == "west" and aligned == right) {
      coordinate = (
        rel: (0, -in-between.x * attributes-len),
        to: coordinate,
      )
    } else if (side == "east" and aligned == right) or (side == "west" and aligned == left) {
      coordinate = (
        rel: (0, in-between.x * attributes-len),
        to: coordinate,
      )
    } else {
      panic("Questo non può capitare.")
    }
  }
  return coordinate
}

/// Update a dictionary.
/// -> dictionary
#let update-dict(
  old-dict,
  new-dict,
  /// Whether the dictionaries have values that are themselves dictionaries.
  /// -> bool
  are-val-dict: false,
) = {
  if new-dict == none {
    return old-dict
  }
  let updated-dict = old-dict
  for (k, v) in old-dict {
    if new-dict.keys().contains(k) {
      if are-val-dict and type(new-dict.at(k)) == dictionary {
        updated-dict.insert(
          k,
          update-dict(old-dict.at(k), new-dict.at(k)),
        )
      } else {
        updated-dict.insert(k, new-dict.at(k))
      }
    }
  }
  return updated-dict
}

#let handle-auto(default, value) = {
  if default == auto { value } else { default }
}

/// Return where is *center with respects to other*.
/// -> arrayay
#let get-rel-position(center, other, ctx) = {
  let (.., a1) = cetz.coordinate.resolve(ctx, center)
  let (.., a2) = cetz.coordinate.resolve(ctx, other)

  let (x1, y1) = a1.slice(0, 2)
  let (x2, y2) = a2.slice(0, 2)

  if (x1, y1) == (x2, y2) {
    panic("The two cannot coincide.")
  }

  if (x2 < x1) {
    "east"
  } else if (x2 == x1) {
    if (y2 > y1) {
      "south"
    } else {
      "north"
    }
  } else {
    "west"
  }
}

/// Return where is *other with respects to center*, in CW direction.
/// -> arrayay
#let get-rel-position-diagonal(center, other, ctx) = {
  let (.., a1) = cetz.coordinate.resolve(ctx, center)
  let (.., a2) = cetz.coordinate.resolve(ctx, other)

  let (x1, y1) = a1.slice(0, 2)
  let (x2, y2) = a2.slice(0, 2)

  if (x1, y1) == (x2, y2) {
    panic("The two cannot coincide.")
  }

  if (x1 == x2 or y1 == y2) {
    (get-rel-position(other, center, ctx),)
    return
  }

  if (x2 > x1) {
    if (y2 > y1) {
      ("north", "east")
    } else {
      ("east", "south")
    }
  } else {
    if (y2 > y1) {
      ("west", "north")
    } else {
      ("south", "west")
    }
  }
}


/// Return where *center is with respects to first- and last-sub*.
/// -> str
#let get-rel-subentity(center, subentities, ctx) = {
  let (x, y) = cetz.coordinate.resolve(ctx, center).at(1).slice(0, 2)
  let (x1, y1) = cetz.coordinate.resolve(ctx, subentities.first()).at(1).slice(0, 2)

  if subentities.len() > 1 {
    let (x2, y2) = cetz.coordinate.resolve(ctx, subentities.last()).at(1).slice(0, 2)

    return if (x2 == x1) {
      if x1 > x {
        "west"
      } else {
        "east"
      }
    } else {
      // if (y2 == y1) {
      if y1 > y {
        "south"
      } else {
        "north"
      }
    }
  } else {
    return if (x == x1) {
      if y1 > y {
        "south"
      } else {
        "north"
      }
    } else {
      if x1 > x {
        "west"
      } else {
        "east"
      }
    }
  }
}

/// Apply ```typ #cetz.draw.hide()``` to `path` and add an anchor `intersection.0` which
/// is the intersection between `path` and the line drawn from `line-coord`. Used for
/// unorthodox relation positions.
/// -> content
#let add-intersect-anchor(path, line-coord) = {
  intersections("intersection", {
    hide(
      merge-path(
        path,
        join: false,
      ),
    )
    hide({ line(..line-coord) })
  })
}

/// Draw the diagonal anchors.
/// -> none
#let draw-anchors(name, padding) = {
  let card-pts = ("north-west", "north-east") //, "south-east", "south-west") not needed

  for i in range(0, card-pts.len()) {
    anchor(
      name + "-diagonal-" + card-pts.at(i),
      (
        rel: (padding * calc.sin(-45deg + (i * 90deg)), padding * calc.cos(-45deg + (i * 90deg))),
        to: name + "." + card-pts.at(i),
      ),
    )
  }
}

/// Retrieve the side based on diagonal anchors.
/// -> str
#let get-diagonal-side(coord, name, ctx) = {
  let (ctx, f) = cetz.coordinate.resolve(ctx, coord)
  let (ctx, nw) = cetz.coordinate.resolve(ctx, name + "-diagonal-north-west")
  let (ctx, ne) = cetz.coordinate.resolve(ctx, name + "-diagonal-north-east")

  let (f_x, f_y) = f.slice(0, 2)
  let (nw_x, nw_y) = nw.slice(0, 2)
  let (ne_x, ne_y) = ne.slice(0, 2)

  return if f_x >= nw_x and f_x <= ne_x {
    if f_y >= nw_y {
      "north"
    } else {
      "south"
    }
  } else {
    if f_x <= nw_x {
      "west"
    } else {
      "east"
    }
  }
}
