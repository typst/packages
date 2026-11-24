#import "base.typ": theme as base-theme
#import "../palettes/brand.typ": build

#let theme(primary: rgb("#2f2f7f"), ..args, body) = base-theme(build(primary), ..args, body)
