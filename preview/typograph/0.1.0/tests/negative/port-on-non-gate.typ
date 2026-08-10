// Should fail: port() only works on gate() nodes.
#import "/src/lib.typ" as typ
#typ.diagram({
  let a = typ.node(0, 0)
  typ.edge((-1, 0), typ.port(a, "left"))
})
