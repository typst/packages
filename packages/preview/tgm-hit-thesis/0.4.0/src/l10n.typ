#import "libs.typ": linguify.set-database as _set_database, linguify.linguify

/// *Internal function.* Initializes Linguify with the template's translation file.
///
/// -> content
#let set-database() = _set_database(toml("l10n.toml"))

#let thesis = linguify("thesis")
#let supervisor = linguify("supervisor")
#let performed-in-year = linguify("performed-in-year")
#let submission-note = linguify("submission-note")
#let approved = linguify("approved")

#let declaration-title = linguify("declaration-title")
// #let declaration-text = linguify("declaration-text")
// #let declaration-ai-clause = linguify("declaration-ai-clause")
#let location-date = linguify("location-date")

#let chapter = linguify("chapter")
#let section = linguify("section")
#let abstract = linguify("abstract")

#let figure = linguify("figure")
#let table = linguify("table")
#let listing = linguify("listing")

#let contents = linguify("contents")
#let bibliography = linguify("bibliography")
#let prompts = linguify("prompts")
#let list-of-figures = linguify("list-of-figures")
#let list-of-tables = linguify("list-of-tables")
#let list-of-listings = linguify("list-of-listings")
#let glossary = linguify("glossary")
