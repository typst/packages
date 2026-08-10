// Should fail: from:/to: are only valid on a simple 2-waypoint edge.
#import "/src/lib.typ" as typ
#typ.diagram({
  import typ: *
  edge(node(0, 0), node(1, 0), node(2, 0), from: right)
})
