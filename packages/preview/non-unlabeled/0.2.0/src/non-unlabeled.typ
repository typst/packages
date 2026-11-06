#let dont-number-unlabeled(object) = {
  it => {
    if object == math.equation{
      if it.block and not it.has("label") [
        #counter(object).update(v => v - 1)
        #object(
          it.body, 
          block: true, 
          numbering: none)#label("no_label")
      ] else {
        it
      }     
    } else if object == figure{
      if not it.has("label") [
        #counter(object).update(v => v - 1)
        #object(
          it.body, 
          caption:it.caption, 
          numbering: none,
          placement: it.placement,
          scope:it.scope,
          kind:it.kind,
          supplement:it.supplement,
          gap:it.gap,
          outlined:it.outlined
        )#label("no_label")
      ] else {
        it
      } 
    } else [
      \=== Error ===
      
      unsupported object "#repr(object)"
    ]

  }
}