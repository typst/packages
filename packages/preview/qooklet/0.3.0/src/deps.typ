// styles
#import "@preview/hydra:0.6.1": hydra
#import "@preview/codly:1.3.0": codly-init, codly
#import "@preview/codly-languages:0.1.8": codly-languages
// utils
#import "@preview/theorion:0.3.3": *
#import "@preview/physica:0.9.5": *

#let default-names = toml("config/names.toml")
#let default-layout = toml("config/layout.toml")
#let default-info = toml("config/info.toml").global
