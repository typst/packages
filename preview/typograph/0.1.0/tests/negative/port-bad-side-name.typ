// Should fail: a port side must be left/right/top/bottom.
#import "/src/lib.typ" as typ
#typ.diagram({
  import typ: *
  let g = gate(0, 0, [U])
  edge(port(g, "middle"), (1, 0))
})
