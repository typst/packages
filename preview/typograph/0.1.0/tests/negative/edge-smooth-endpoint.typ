// Should fail: smooth() can only mark an interior waypoint.
#import "/src/lib.typ" as typ
#typ.diagram({
  import typ: *
  edge(smooth(node(0, 0)), node(1, 0))
})
