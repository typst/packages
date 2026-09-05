#import "base.typ": theme as base-theme
#import "../palettes/academic.typ": palette

#let theme(..args, body) = base-theme(palette, ..args, body)
