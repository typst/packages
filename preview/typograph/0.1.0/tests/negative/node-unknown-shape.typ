// Should fail: the removed string registry cannot silently accept old styles.
#import "/src/lib.typ" as typ
#typ.diagram({
  import typ: *
  node(0, 0, label: $x$, style: (shape: "circle", min-size: 10pt, inset: 2pt))
})
