#import "@preview/kalt:0.1.2": comp

#set page(width: 100mm, height: auto, margin: 3mm)
#set text(size: 8pt)
#set par(spacing: 1mm)

#let a = $mat(1, 2; 3, 4)$
#let b = $mat(5, 8; 9, 12)$

$ A = #a quad B = #b $
$ A + B = #comp($#a + #b$) $
$ A - B = #comp($#a - #b$) $
$ A * B = #comp($#a * #b$) $
$ B / A = #comp($#b / #a$) $
$ A dot B = #comp($#a dot #b$) $
$ A^T = #comp($#a^T$) $
$ A^2 = #comp($#a^2$) $
