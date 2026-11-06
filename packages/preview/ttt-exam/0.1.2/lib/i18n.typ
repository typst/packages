#import "@preview/linguify:0.4.0": *

// load linguify database file
#let ling_db = toml("assets/lang.toml")

#let ling(key) = linguify(key, from: ling_db)
