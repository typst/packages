// styles
#import "@preview/hydra:0.6.1": hydra
#import "@preview/codly:1.3.0": codly, codly-init
#import "@preview/codly-languages:0.1.8": codly-languages
// environments
#import "@preview/theorion:0.3.3": *
#import "@preview/physica:0.9.5": *

#let default-names = toml("config/names.toml")
#let default-styles = toml("config/styles.toml")
#let default-info = toml("config/info.toml").global

#let ctext(body) = text(body, font: default-styles.fonts.at("zh").math)

#let tip = tip-box
#let note = note-box
#let quote = quote-box
#let warning = warning-box
#let caution = caution-box
