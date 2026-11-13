// Turn the `coord` a spec carries into one the renderer can call. Kept apart
// from `contract.typ` because it builds the default `coord-cartesian()`, which
// itself imports the contract.

#import "../utils/errors.typ": fail
#import "cartesian.typ": coord-cartesian
#import "contract.typ": coord-base

// The keys of `coord-base` the coord lacks, or carries with a value that is
// not a function where the base has one.
#let _missing-keys(coord) = {
  let base = coord-base("")
  if type(coord) != dictionary { return base.keys() }
  base
    .keys()
    .filter(key => {
      if key not in coord { return true }
      type(base.at(key)) == function and type(coord.at(key)) != function
    })
}

// Panic unless `coord` is `none` or carries every key of `coord-base`.
#let check-coord(coord) = {
  if coord == none { return }
  let missing = _missing-keys(coord)
  if missing.len() > 0 {
    fail(
      "plot",
      "coord must carry a callable `train` and the other `coord-base` keys; missing "
        + missing.map(key => "`" + key + "`").join(", ")
        + "; got "
        + repr(coord),
      hint: "Build it with a `coord-*()` constructor, such as `coord-cartesian()`.",
    )
  }
}

#let resolve-coord(coord) = {
  check-coord(coord)
  if coord == none { coord-cartesian() } else { coord }
}
