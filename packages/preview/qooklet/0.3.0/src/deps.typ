// styles
#import "@preview/hydra:0.6.1": hydra
#import "@preview/codly:1.3.0": codly-init, codly
#import "@preview/codly-languages:0.1.8": codly-languages
// utils
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.3.3": *
#import "@preview/physica:0.9.5": *

#let config-sections = toml("config/sections.toml")
#let config-fonts = toml("config/fonts.toml")
#let info-default = toml("config/info.toml").global
