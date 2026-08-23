#import "packages.typ": package

#import package("linguify"): set-database as initialize-dictionary, linguify

#let lang-data = toml("lang.toml")
#let use-dictionary() = initialize-dictionary(lang-data)

// Cover sheet
#let txt-cooperation = linguify("co-operation")
#let txt-faculty = linguify("faculty")
#let txt-programme = linguify("programme")
#let txt-semester = linguify("semester")
#let txt-course = linguify("course")
#let txt-examiner = linguify("examiner")
#let txt-second-examiner = linguify("second-examiner")
#let txt-submission-date = linguify("submission-date")

// Declaration on the Final Thesis
#let txt-declaration-on-the-final-thesis = linguify("declaration-on-the-final-thesis")
#let txt-declaration-on-the-final-thesis-first-part = linguify("declaration-on-the-final-thesis-first-part")

// Signing
#let txt-location = linguify("location")
#let txt-date = linguify("date")
#let txt-author-signature = linguify("author-signature")

// Other
#let txt-attachement = linguify("attachement")
#let txt-supplement-formula = linguify("supplement-formula")

// Assets
#let txt-author = linguify("author")
#let txt-authors = linguify("authors")

// Project Management Assets
#let txt-persona-name = linguify("persona-name")
#let txt-persona-age = linguify("persona-age")
#let txt-persona-family = linguify("persona-family")
#let txt-persona-job = linguify("persona-job")
#let txt-persona-do-and-say = linguify("persona-do-and-say")
#let txt-persona-wishes = linguify("persona-wishes")
#let txt-persona-see-and-hear = linguify("persona-see-and-hear")
#let txt-persona-challenges = linguify("persona-challenges")
#let txt-persona-typical-day = linguify("persona-typical-day")
#let txt-persona-goals = linguify("persona-goals")

#let txt-retro = linguify("retro")
#let txt-retro-improvements = linguify("retro-improvements")
#let txt-retro-impediments = linguify("retro-impediments")
#let txt-retro-measures = linguify("retro-measures")

#let txt-user-story-title = linguify("user-story-title")
#let txt-user-story-acceptance-criteria = linguify("user-story-acceptance-criteria")

// Helper to retrieve raw strings for PDF bookmarks (linguify returns content, which breaks bookmarks)
#let get-lang-str(
  lang: "en",
  key
) = {
  let lang-map = lang-data.at("lang")
  let val = lang-map.at(lang, default: none)
  if val == none {
    val = lang-map.at(lang-data.conf.default-lang)
  }
  val.at(key)
}
/*
Used keys for headings:
- abstract
- list-of-figures
- list-of-abbreviations
- list-of-formulas
- list-of-tables
- literature-and-bibliography
- list-of-attachements
*/