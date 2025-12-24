// -----------------------------> INDEX
// Sections:
//  - ANCHORS CREATION
//  - ANCHORS ALGEBRA
//  - TAKING MEASUREMENTS
//  - TRANSLATIONS
//  - ROTATIONS
//  - ROTO-TRANSLATIONS
//
// This file contains all the logic for anchors.


// -----------------------------> ANCHORS CREATION

/// Every anchor represents a coordinate system
/// where (`x`,`y`) is the origin of the local coordinate system and
/// `rot` is the angle between the paper left-to-right axis and the anchor's x-axis.
/// The local y-axis is always directed 90deg anticlockwise with respect to local x-axis.
/// Most often, anchors are use to describe points on surfaces. In that case, the local x-axis
/// is the tangent to the surface and the local y-axis is the outgoing normal to the surface.
#let anchor(x, y, rot) = (x: x, y: y, rot: rot)

/// Tries to convert anything to an anchor. By default,
/// the function panics if `thing` cannot be converted to an anchor,
/// but if the named parameter `panic` is set to `false` it will
/// silently return `none`, instead of panicking.
#let to-anchor(thing, panic: true) = {
  if type(thing) == function {
    // THIS IS AN OBJECT
    return thing()
  } else if type(thing) == array {
    let first = thing.flatten().at(0)
    if type(first) == function { 
      // THIS IS A GROUP OF OBJECTS
      // Take active anchor of the first object in the group 
      // considering that we may have groups of groups
      return first()
    } else if type(thing.at(0)) in (float, int) {
      // THIS ARRAY IS AN ANCHOR
      if thing.len() == 3 {
        return anchor(thing.at(0), thing.at(1), thing.at(2))
      } else if thing.len() == 2 {
        return anchor(thing.at(0), thing.at(1), 0deg)
      } else { panic("Cannot convert to anchor: '" + repr(thing) + "'") }
    } else { panic("Cannot convert to anchor: '" + repr(thing) + "'") }
  } else if type(thing) == dictionary { 
    if "x" in thing and "y" in thing {
      if "rot" in thing {
        return anchor(thing.x, thing.y, thing.rot) 
      } else {
        return anchor(thing.x, thing.y, 0deg)
      }
    }
  } else if not panic {
    return none
  } else {
    panic("Cannot convert to anchor: '" + repr(thing) + "' of type " + str(type(thing)))
  }
}


// -----------------------------> ANCHORS ALGEBRA

/// Returns the term by term sum of two anchors. 
/// Named arguments lock one coordinate to the first anchor's value.
#let term-by-term-sum(anchor1, anchor2) = {
  let a1 = to-anchor(anchor1)
  let a2 = to-anchor(anchor2)

  anchor(a1.x + a2.x, a1.y + a2.y, a1.rot + a2.rot)
}

/// Returns the term by term difference `anchor1 - anchor2`. 
/// Named arguments lock one coordinate to the first anchor's value.
#let term-by-term-difference(anchor1, anchor2) = {
  let a1 = to-anchor(anchor1)
  let a2 = to-anchor(anchor2)

  anchor(a1.x - a2.x, a1.y - a2.y, a1.rot - a2.rot)
}


// -----------------------------> TAKING MEASUREMENTS

/// Returns the distance between two anchors
#let distance(anchor1, anchor2) = {
  let a1 = to-anchor(anchor1)
  let a2 = to-anchor(anchor2)

  let diff = term-by-term-difference(anchor2, anchor1)
  return calc.sqrt(diff.x*diff.x + diff.y*diff.y)
}


// -----------------------------> TRANSLATIONS

/// Moves an anchor in the global coordinate system
#let move(anchor1, dx, dy) = term-by-term-sum(anchor1, (dx, dy, 0deg))

/// Moves an anchor in its own rotated coordinate system
#let slide(target, dx, dy, rot: none) = {
  let target = to-anchor(target)

  let angle = if rot == none { target.rot } else { rot }
  let x = dx * calc.cos(angle) + dy * calc.cos(angle + 90deg)
  let y = dx * calc.sin(angle) + dy * calc.sin(angle + 90deg)
  return move(target, x, y)
}

/// Computes the intersection between two anchors' tangent lines. 
/// The output orientation is the first anchor's orientation.
/// This function is effectively translating the first anchor along its tangent 
/// line to meet the second anchor's tangent line. The result is `none` if
/// there's no intersection, otherwise the result is an anchor.
/// Named arguments lock one coordinate to `anchor1`'s value.
#let x-inter-x(anchor1, anchor2) = {
  let a1 = to-anchor(anchor1)
  let a2 = to-anchor(anchor2)

  let cos1 = calc.cos(a1.rot)
  let sin1 = calc.sin(a1.rot)

  let cos2 = calc.cos(a2.rot)
  let sin2 = calc.sin(a2.rot)

  // (x1, y1) + t*(cos1, sin1) = (x2, y2) + u*(cos2, sin2)
  // t*(cos1, sin1) - u*(cos2, sin2) = (x2, y2) - (x1, y1)
  // (cos1, -cos2)(t) = (x2 - x1)
  // (sin1, -sin2)(u) = (y2 - y1)
  // det = -cos1*sin2 + sin1*cos2
  // (t) = (-sin2, cos2)(x2 - x1) / det
  // (u) = (-sin1, cos1)(y2 - y1) /
  
  let det = (-cos1)*sin2 + sin1*cos2
  if det == 0 { panic("Cannot intersect parallel lines") }
  let t = ((a2.x - a1.x) * (-sin2) + (a2.y - a1.y) * cos2) / det

  return anchor(
    a1.x + t * cos1,
    a1.y + t * sin1,
    a1.rot,
  )
}

/// Computes the intersection between the first anchors' tangent
/// line and the second anchors' normal line. 
/// The output orientation is the first anchor's orientation.
/// This function is effectively translating the first anchor along its tangent 
/// line to meet the second anchor's normal line. The result is `none` if
/// there's no intersection, otherwise the result is an anchor.
/// Named arguments lock one coordinate to `anchor1`'s value.
#let x-inter-y(anchor1, anchor2) = {
  let a1 = to-anchor(anchor1)
  let a2 = to-anchor(anchor2)

  // Reduce the problem to x-inter-x
  let xx = x-inter-x(a1, anchor(a2.x, a2.y, a2.rot + 90deg))
  return anchor(
    xx.x, 
    xx.y, 
    a1.rot
  )
}

/// Computes the intersection between the first anchors' normal
/// line and the second anchors' tangent line. 
/// The output orientation is the first anchor's orientation.
/// This function is effectively translating the first anchor along its normal 
/// line to meet the second anchor's tangent line. The result is `none` if
/// there's no intersection, otherwise the result is an anchor.
/// Named arguments lock one coordinate to `anchor1`'s value.
#let y-inter-x(anchor1, anchor2) = {
  let a1 = to-anchor(anchor1)
  let a2 = to-anchor(anchor2)

  // Reduce the problem to x-inter-x
  let xx = x-inter-x(anchor(a1.x, a1.y, a1.rot + 90deg), a2)
  return anchor(
    xx.x, 
    xx.y, 
    a1.rot
  )
}

/// Computes the intersection between two anchors' normal lines. 
/// The output orientation is the first anchor's orientation.
/// This function is effectively translating the first anchor along its normal 
/// line to meet the second anchor's normal line. The result is `none` if
/// there's no intersection, otherwise the result is an anchor.
/// Named arguments lock one coordinate to `anchor1`'s value.
#let y-inter-y(anchor1, anchor2) = {
  let a1 = to-anchor(anchor1)
  let a2 = to-anchor(anchor2)

  // Reduce the problem to x-inter-x
  let xx = x-inter-x(
    anchor(a1.x, a1.y, a1.rot + 90deg),
    anchor(a2.x, a2.y, a2.rot + 90deg)
  )
  return anchor(
    xx.x, 
    xx.y, 
    a1.rot
  )
}


// -----------------------------> ROTATIONS

/// Rotates an anchor by some angle
#let rotate(target, angle) = {
  let anc = to-anchor(target)
  return term-by-term-sum(anc, (anc.x*0, anc.y*0, angle))
}

/// Rotates the first anchor such that its x axis points towards the second anchor
#let x-look-at(anchor1, anchor2) = {
  let a1 = to-anchor(anchor1)
  let a2 = to-anchor(anchor2)
  
  return anchor(a1.x, a1.y, calc.atan2(a2.x - a1.x, a2.y - a1.y))
}
/// Rotates the first anchor such that its y axis points opposite to the second anchor
#let y-look-from(anchor1, anchor2) = rotate(x-look-at(anchor1, anchor2), 90deg)
/// Rotates the first anchor such that its x axis points opposite to the second anchor
#let x-look-from(anchor1, anchor2) = rotate(x-look-at(anchor1, anchor2), 180deg)
/// Rotates the first anchor such that its y axis points towards to the second anchor
#let y-look-at(anchor1, anchor2) = rotate(x-look-at(anchor1, anchor2), -90deg)


// -----------------------------> ROTO-TRANSLATIONS

/// The `pivot` function returns the anchor you get if you take the `target` anchor and rotate it around the `origin` location by `angle`. If `rot` is set to `false` the anchor's rotation
/// is fixed to the rotation of `target`.
#let pivot(target, origin, angle, rot: true) = {
  let target = to-anchor(target)
  let origin = to-anchor(origin)

  let diff = term-by-term-difference(target, origin)
  return anchor(
    origin.x + diff.x*calc.cos(angle) - diff.y*calc.sin(angle),
    origin.y + diff.x*calc.sin(angle) + diff.y*calc.cos(angle),
    if rot { target.rot + angle } else { target.rot }
  )
}

/// Linear interpolation between anchors. The field `by` is a `ratio`.
/// If `rot` is set to `false` the result's rotation is fixed to the first
/// anchor's rotation.
#let lerp(anchor1, anchor2, by, rot: true) = {
  let a1 = to-anchor(anchor1)
  let a2 = to-anchor(anchor2)

  let diff = term-by-term-difference(a2, a1)
  let dist = distance(a2, a1)

  let travel = float(by)
  if type(by) == ratio { travel *= dist }

  let delta = anchor(
    travel * diff.x / dist, 
    travel * diff.y / dist, 
    if rot { travel/dist * diff.rot } else { anchor1.rot }
  )

  return term-by-term-sum(a1, delta)
}
