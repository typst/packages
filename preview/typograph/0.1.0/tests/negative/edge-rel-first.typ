// Should fail: rel() is an offset from the previous waypoint, so it cannot
// be the first one — there is nothing to offset from.
#import "/src/lib.typ" as typ
#typ.diagram({
  import typ: *
  edge(rel(1, 0), node(1, 0))
})
