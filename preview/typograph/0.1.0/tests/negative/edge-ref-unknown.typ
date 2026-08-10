// Should fail: ref() names a node that is not in this diagram.
#import "/src/lib.typ" as typ
#typ.diagram({
  import typ: *
  node(0, 0, name: "a")
  edge(ref("nope"), (1, 0))
})
