// multi-languages
#import "@preview/linguify:0.4.2": linguify, set-database
// header-footer
#import "@preview/hydra:0.6.1": hydra
// physics
#import "@preview/physica:0.9.5": *
// theorems
#import "@preview/ctheorems:1.1.3": thmbox, thmrules
// banners
#import "@preview/gentle-clues:1.2.0": *
// codes
#import "@preview/codly:1.3.0": codly-init, codly
#import "@preview/codly-languages:0.1.8": codly-languages

#let config-sections = toml("../config/sections.toml")
#let config-fonts = toml("../config/fonts.toml")
#let config-layouts = toml("../config/layouts.toml")
