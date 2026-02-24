#set page(margin: 1cm, width: auto, height: auto)
#set text(2cm)
#import "lib.typ": symbol, symbolx-rule

#let (map, tensor) = symbol("⊗", ("r", $times.circle_RR$), ("c", $times.circle_CC$))
#let (map, subset) = symbol(map, "⊂", ("c", $class("binary", subset subset)$))
#show: symbolx-rule(map)

$ (CC^2)^(tensor n) = (CC^2)^(tensor.c n) != (CC^2)^(tensor.r n) $

#pagebreak()

$ A subset.c B $
