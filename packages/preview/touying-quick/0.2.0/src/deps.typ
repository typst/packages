#import "@preview/touying:0.6.1": *
#import themes.metropolis: *
// styles
#import "@preview/codly:1.3.0": codly-init, codly
#import "@preview/codly-languages:0.1.8": codly-languages
// utils
#import "@preview/theorion:0.3.3": *
#import "@preview/physica:0.9.5": *

#let default-info = toml("config/info.toml").global
#let default-names = toml("config/names.toml")
#let default-styles = toml("config/styles.toml")
