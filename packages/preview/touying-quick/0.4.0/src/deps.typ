#import "@preview/touying:0.6.1": *
#import themes.metropolis: *
// styles
#import "@preview/codly:1.3.0": codly, codly-init
#import "@preview/codly-languages:0.1.10": codly-languages
// utils
#import "@preview/theorion:0.4.1": *

#let default-info = toml("config/info.toml").default
#let default-names = toml("config/names.toml")
#let default-styles = toml("config/styles.toml")

#let bgsky = "config/sky.png"
#let bghexagon = "config/hexagon.png"
#let bgbook = "config/book.png"
