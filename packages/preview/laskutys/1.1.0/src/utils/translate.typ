#import "@preview/linguify:0.4.2": linguify, set-database

#let translations = toml("/src/translations.toml")

#let translate(key) = {
  linguify(key, from: translations)
}
