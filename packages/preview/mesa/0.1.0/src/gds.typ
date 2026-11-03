#import "kernel.typ" as _kernel

/// Read boundary polygons from a named GDS cell.
#let gds(data, cell: none, layers: none) = {
  assert(type(data) == bytes, message: "gds data must be bytes")
  assert(type(cell) == str, message: "gds cell must be a string")
  assert(type(layers) == dictionary, message: "gds layers must be a dictionary")
  for (name, layer) in layers {
    assert(
      type(layer) == array
        and layer.len() == 2
        and layer.all(value => type(value) == int),
      message: "gds layer " + name + " must be a (layer, datatype) pair",
    )
  }
  _kernel.gds-layout(data, cell, layers)
}
