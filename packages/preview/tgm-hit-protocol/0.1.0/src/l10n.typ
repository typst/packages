#import "@preview/linguify:0.4.0": set-database as _set_database, linguify

/// *Internal function.* Initializes Linguify with the template's translation file.
///
/// -> content
#let set-database() = _set_database(toml("l10n.toml"))

#let supervisor = linguify("supervisor")
#let grade = linguify("grade")
#let version = linguify("version")
#let started = linguify("started")
#let finished = linguify("finished")

#let figure = linguify("figure")
#let table = linguify("table")
#let listing = linguify("listing")

#let contents = linguify("contents")
#let bibliography = linguify("bibliography")
#let list-of-figures = linguify("list-of-figures")
#let list-of-tables = linguify("list-of-tables")
#let list-of-listings = linguify("list-of-listings")
#let glossary = linguify("glossary")
