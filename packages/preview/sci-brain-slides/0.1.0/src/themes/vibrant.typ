#import "base.typ": theme as base-theme
#import "../palettes/vibrant.typ": palette

#let theme(..args, body) = base-theme(palette, ..args, body)
