// Should fail: ref() would otherwise resolve duplicate names ambiguously.
#import "/src/lib.typ" as typ
#typ.diagram({
  typ.node(0, 0, name: "same")
  typ.box(1, 0, name: "same")
})
