#import "@preview/kalt:0.1.2": comp

#set page(width: 100mm, height: auto, margin: 3mm)
#set text(size: 8pt)
#set par(spacing: 1mm)

#let a = $vec(1, 2, 3)$
#let b = $vec(4, 5, 6)$
#let cross-product = comp($#a times #b$)

$ a = #a $
$ b = #b $
$ a^T dot b = #comp($#a^T dot #b$) $
$ a times b = #cross-product $
$ abs(a) = #calc.round(comp($abs(#a)$), digits: 3) $
$ abs(a times b) = #calc.round(comp($abs(#cross-product)$), digits: 3) $
