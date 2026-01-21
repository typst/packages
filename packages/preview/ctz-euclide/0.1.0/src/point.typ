// ctz-euclide/src/point.typ
// Point resolution utilities

#import "util.typ"

/// Resolve a point reference to coordinates
/// Accepts: point name (string), coordinate tuple, or cetz coordinate
#let resolve-point(ctx, p, points-dict, cetz-resolve) = {
  if type(p) == str {
    if p in points-dict {
      return points-dict.at(p)
    }
    if p.starts-with("tkz:") {
      let name = p.slice(4)
      if name in points-dict {
        return points-dict.at(name)
      }
    }
    let (_, pt) = cetz-resolve(ctx, p)
    return pt
  } else if type(p) == array {
    if p.len() >= 2 and p.len() <= 3 and p.all(x => type(x) in (int, float)) {
      return if p.len() == 2 { (p.at(0), p.at(1), 0) } else { p }
    }
    let (_, pt) = cetz-resolve(ctx, p)
    return pt
  } else if type(p) == dictionary {
    let (_, pt) = cetz-resolve(ctx, p)
    return pt
  }
  panic("Cannot resolve point: " + repr(p))
}
