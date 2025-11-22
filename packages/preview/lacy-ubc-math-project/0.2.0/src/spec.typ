#let impl = (
  components: (
    "flat",
    "question",
    "solution",
    "feeder",
    "mark",
    "marker",
    "pin",
  ),
)

#let spec = (
  magic: "lacy",
  class: "ubc-math-project",
  flat: (:),
  feeder: (:),
  question: (
    label-head: "qs:",
  ),
  solution: (
    label-head: "sn:",
  ),
  mark: (
    label-head: "mk:",
  ),
  marker: (:),
  pin: (:),
)

#for comp in impl.components {
  spec.at(comp).insert("name", comp)
  spec.at(comp).insert("kind", spec.magic + "-" + comp)
}

/// Cast a magic of lacy dict.
///
/// - impl (dictionary): Implementation of component identifiers.
/// - type (str): Type of the component.
///
/// -> dictionary
#let spell(type, ..args) = {
  return (magic: spec.magic, class: spec.class, type: type, ..args.named())
}

#let component-type(comp) = {
  if type(comp) == dictionary {
    if comp.at("magic", default: none) == spec.magic and comp.at("class", default: none) == spec.class {
      return comp.type
    }
  }
  return spec.flat.name
}
