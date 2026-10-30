// These callbacks resolve paths in the project.
#let manifest() = toml("/.zettypst/source.toml")
#let note(path) = include ("/" + path)
