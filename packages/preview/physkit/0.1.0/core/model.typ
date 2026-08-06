/// Validate and return a PhysKit identifier.
#let id(value) = {
  assert(type(value) == str, message: "PhysKit object identifiers must be strings")
  assert(value.len() > 0, message: "PhysKit object identifiers cannot be empty")
  value
}

/// Find an object by identifier.
#let find-object(objects, object-id) = {
  let matches = objects.filter(object => object.id == object-id)
  assert(matches.len() == 1, message: "Expected exactly one object with id `" + object-id + "`")
  matches.first()
}

/// Replace one object in an array by identifier.
#let replace-object(objects, replacement) = objects.map(
  object => if object.id == replacement.id { replacement } else { object }
)

/// Ensure that every object identifier is unique.
#let validate-objects(objects) = {
  let ids = objects.map(object => object.id)
  for object-id in ids {
    assert(ids.filter(value => value == object-id).len() == 1,
      message: "Duplicate PhysKit object id: `" + object-id + "`")
  }
  objects
}
