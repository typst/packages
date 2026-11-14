#import "@preview/kalt:0.1.2": comp

#set page(width: 100mm, height: auto, margin: 3mm)
#set text(size: 8pt)
#set par(spacing: 1mm)

$ ((2 + 3 * (4^2 - 5)) / (6 - 2)) = #calc.round(comp($((2 + 3 * (4^2 - 5)) / (6 - 2))$), digits: 2) $
$ abs((3 - 4i)^2 + 2 * ln(8) / ln(2)) = #calc.round(comp($abs((3 - 4i)^2 + 2 * ln(8) / ln(2))$), digits: 3) $
$ log_2(2^3 + 8) - ln(e^2) = #comp($log_2(2^3 + 8) - ln(e^2)$) $
$ floor((2^3 + 3^2) / 5) + ceil(7 / 3) = #comp($floor((2^3 + 3^2) / 5) + ceil(7 / 3)$) $
$ (3 + 2)! / (2^3 - 1) = #calc.round(comp($(3 + 2)! / (2^3 - 1)$), digits: 2) $
$ ((12 + 3 * 4) > (2^3 + 2)) ∧ 6 ⊕ 3 ∨ 2 = #comp($((12 + 3 * 4) > (2^3 + 2)) ∧ 6 ⊕ 3 ∨ 2$) $
