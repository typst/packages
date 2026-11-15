///! Style builder, style resolution, and merge order.
///!
///! Styles are resolved once into a dictionary keyed by cell address, then read
///! once per cell. Re-testing every directive against every cell would cost
///! directives times cells on a table where both grow.

#import "locations.typ": expand
#import "utils/errors.typ": fail, fail-type

// Only the properties actually set appear, so merging a later style over an
// earlier one leaves untouched properties alone.
#let style(text: none, fill: none, stroke: none, align: none, inset: none) = {
  let out = (:)
  if text != none { out.insert("text", text) }
  if fill != none { out.insert("fill", fill) }
  if stroke != none { out.insert("stroke", stroke) }
  if align != none { out.insert("align", align) }
  if inset != none { out.insert("inset", inset) }
  out
}

#let table-style(properties, locations: none) = {
  if type(properties) != dictionary {
    fail-type(
      "table-style",
      "style",
      properties,
      "a dictionary built with style()",
      hint: "Write table-style(style(fill: aqua)).",
    )
  }
  (
    kind: "style",
    style: properties,
    locations: locations,
  )
}

// One key per addressable cell. `repr` of the row keeps `none` and an integer
// apart without a second dictionary level.
#let _key(part, row, column) = part + "|" + repr(row) + "|" + repr(column)

#let build-index(spec) = {
  let index = (:)
  for directive in spec.styles {
    // A style with nowhere to go is a mistake worth naming: silently styling
    // nothing would look like the style itself failing.
    if directive.locations == none {
      fail(
        "table-style",
        "no locations given",
        hint: "Name cells with cells-body(), cells-column-labels(), and the rest.",
      )
    }
    for address in expand(directive.locations, spec) {
      let key = _key(address.part, address.row, address.column)
      // Later directives win property by property, which makes "style the
      // column, then override one row" read in the order it is written.
      index.insert(key, index.at(key, default: (:)) + directive.style)
    }
  }
  index
}

#let style-for(index, part, row, column) = {
  index.at(_key(part, row, column), default: (:))
}
