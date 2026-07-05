/// Creates an object.
/// 
/// An object is a collection of anchors with a specified active anchor and some metadata.
/// An object `obj` is represented by a callable function such that:
///  - `obj()` returns the active anchor (equivalent to `obj("anchors").at(obj("active"))`),
///  - `obj("anchor-name")` returns an equivalent object but with the specified anchor as active,
///  - `obj("anchors")` returns the full dictionary of anchors,
///  - `obj("active")` returns the key of the active anchor,
///  - `obj("type")` returns the object type (`"line"`, `"rect"`, `"circle"`, etc),
///  - `obj("data")` returns the carried metadata,
///  - `obj("repr")` returns a dictionary representation of the object meant only for debugging purposes.
/// This constructor takes three positional arguments
///  - `obj-type`: a `str` that labels the kind of object described by the anchors,
///  - `active`: a `str` equal to the name of the active anchor,
///  - `anchors`: a `dictionary` with string valued keys and anchor valued fields that constitutes the named collection of anchors in the object.
/// and one named argument
///   - `data` (default `none`): some metadata. `any` type is allowed but conventionally `none` and `dictionary` are preferred.
/// 
/// Important design choices:
///  - The set of anchors an object carries is not minimal in any sense. The collection of anchors should contain 
///    most of the anchors that the user may find helpful when constructing a diagram. 
///  - The information encoded inside `data` is never touched by transformations of the objects, 
///    e.g. rotations and translations, therefore the payload should not contain information 
///    about properties of the object that change under such transformations. No function defined in this package 
///    scales objects therefore geometrical properties (like angles and lengths) can be part of the information.
///  - The information encoded inside `data` should not be of artistic/cosmetic nature: no colors, strokes or printed 
///    labels. String ids are allowed but for internal use: not meant to be printed text inside the final image. 
///  - Nothing prevents the definition of anchors named "anchors", "active", "type", "data" or "repr", nevertheless they 
///    won't be accessible via the notation `obj("anchor-name")` but rather only via `obj("anchors").at("anchor-name")`.
#let object(obj-type, active, anchors, data: none) = (..args) => {
  let args = args.pos()
  if args.len() == 0 { return anchors.at(active) }
  if args.len() >  1 { panic("Cannot specify more than one key") }
  if not (active in anchors.keys()) { panic("The specified active anchor \"" + repr(active) + "\" is not a valid as it is not part of the specified list of anchors in this object.") }
  
  let key = args.at(0)
  if type(key) == str {
    if key == "anchors" {
      return anchors
    } else if key == "active" {
      return active
    } else if key == "type" {
      return obj-type
    } else if key == "data" {
      return data
    } else if key == "repr" {
      return ("type": obj-type, "active": active, "anchors": anchors, "data": data)
    } else if key in anchors.keys() {
      return object(obj-type, key, anchors, data: data)
    } else {
      panic("Cannot activate anchor \"" + repr(active) + "\" as it is not part of the specified list of anchors in this object. This object contains the following anchors: " + repr(anchors.keys()))
    }
  }

  panic("Unknown argument type '" + repr(type(key)) + "', '" + repr(str) + "' was expected.")
}

/// Turns an object constructor into a new constructor that creates
/// identical objects but with a different type. This is useful when
/// there are two objects that share the same logic but have very
/// different rendering routines. This helps reduce the amount of 
/// styling options passed to renderers.
#let alias(constructor, new-type) = (..args) => {
  let obj = constructor(..args)
  let active = obj("active")
  let anchors = obj("anchors")
  let data = obj("data")
  return object(new-type, active, anchors, data: data)
}


// -----------------------------> TRANSFORM

#import "../anchors.typ" as anchors

/// Applies a given function to all the anchors of an object or all the anchors 
/// of all the objects in a group of objects. The result is the same object or group
/// but with the operation applied. Nested groups are preserved.
/// 
/// _Remark_: a group is just a tuple of groups and objects whose active anchor is the active anchor
/// of the first element of the tuple. 
#let transform(obj, func) = {
  // Transform the anchors of a single object
  let tr = (o, f) => {
    let ancs = o("anchors")
    for anc in ancs.keys() {
      ancs.at(anc) = f(obj(anc)())
    }
    return object(o("type"), o("active"), ancs, data: o("data"))
  }

  return if type(obj) == array { 
    // Group of objects 
    obj.map(o => transform(o, func)) 
  } else { 
    // Single object 
    tr(obj, func) 
  }
}


// -----------------------------> TRANSLATIONS

/// Translates the object in a rotated coordinate system.
/// If `rot` is `none`, the coordinate system is rotated
/// like the active anchor of the object. If `rot` is a 
/// specified angle, it will be used as the reference frame rotation.
#let slide(obj, dx, dy, rot: none) = transform(obj, a => anchors.slide(
  a, dx, dy, rot: if rot == none { anchors.to-anchor(obj).rot } else { rot } 
))


/// Translates the object in global coordinates. Its equivalent to `slide.with(rot: 0deg)`.
#let move = slide.with(rot: 0deg)

/// Translates the object such that its active anchor's location matches the `target`. 
#let place(obj, target) = {
  let delta = anchors.term-by-term-difference(target, obj)
  return move(obj, delta.x, delta.y)
}

// -----------------------------> ROTATIONS

/// Rotates the object around a given anchor by the specified angle. The anchor is taken to be the
/// active anchor of the object if `ref` is `none` otherwise `ref` itself is used as origin.
#let rotate(obj, angle, ref: none) = {
  let origin = if ref == none { anchors.to-anchor(obj) } else { anchors.to-anchor(ref) }
  return transform(obj, a => anchors.pivot(a, origin, angle))
}


// -----------------------------> ROTO-TRANSLATIONS

/// Translates and rotates an object to ensure that the active 
/// anchor of `obj` becomes equal to the `target`ed anchor.
/// The named parameters `x`, `y` and `rot` take boolean values
/// that determine if the corresponding anchor parameter can be 
/// changed or not: `true` is the default and `false` means
/// that the parameter has to remain fixed.
#let match(obj, target, x: true, y: true, rot: true) = {
  let delta = anchors.term-by-term-difference(target, obj)
  return move(rotate(obj, delta.rot, ref: anchors.to-anchor(obj)), delta.x, delta.y)
}

/// Translates and rotates an object to ensure that the active anchor of the object becomes 
/// equal in origin and opposite in direction with respect to the `target`ed anchor.
#let stick(obj, target) = match(obj, anchors.rotate(target, 180deg))