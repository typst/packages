#import "base.typ": theme as base-theme
#import "../palettes/minimal.typ": palette

#let theme(..args, body) = base-theme(palette, ..args, body)
