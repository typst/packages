#import "/src/lib.typ" as typ

// `auto` is a constructor sentinel, not a concrete clipping policy.
#typ.edge((0, 0), (1, 0), style: (clip: auto))
