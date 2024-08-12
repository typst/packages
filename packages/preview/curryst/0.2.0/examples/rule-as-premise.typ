#import "../curryst.typ": rule, proof-tree
#set document(date: none)
#set page(width: auto, height: auto, margin: 0.5cm)

#proof-tree(
  rule(
    name: $R$,
    $C_1 or C_2 or C_3$,
    rule(
      name: $A$,
      $C_1 or C_2 or L$,
      rule(
        $C_1 or L$,
        $Pi_1$,
      ),
    ),
    rule(
      $C_2 or overline(L)$,
      $Pi_2$,
    ),
  )
)
