#import "../curryst.typ": rule, prooftree
#set document(date: none)
#set page(width: auto, height: auto, margin: 0.5cm, fill: white)

Consider the following tree:
$
  Pi quad = quad #prooftree(
    rule(
      $phi$,
      $Pi_1$,
      $Pi_2$,
    )
  )
$
$Pi$ constitutes a derivation of $phi$.
