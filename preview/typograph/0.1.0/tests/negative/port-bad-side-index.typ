// Should fail: gate only has 1 port on "left", index 3 is out of range.
#import "/src/lib.typ" as typ
#typ.diagram({
  let g = typ.gate(0, 0, [U])
  typ.edge((-1, 0), typ.port(g, "left", index: 3))
})
