#import "/src/lib.typ": *
#import "./my-tidy.typ"

#set page(width: auto, height: auto, margin: 0.5em)

#set raw(lang: "typc")
#set table(stroke: none)

#fancy-units-configure((uncertainty-mode: "conserve"))
#my-tidy.show-example-table(
  scope: (num: num, unit: unit, qty: qty),
  "num[0.9]",
  "num[-0.9 (*1*)]",
  "num[0.9 +-#text(red)[0.1] e1]",
  "unit[kg m^2 / s]",
  "unit[#math.cancel[μg]]",
  "unit[_E_#sub[rec]]",
  "unit[#sym.planck Hz]",
  "qty[0.9][g]",
  "qty[27][_E_#sub[rec]]",
)
