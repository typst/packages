#import "/pages/note_on_gender_inclusive_language.typ": _render-note-on-gender-inclusive-lang

#include "/tests/helper/set-l10n-db.typ"

#let settings = (
  enabled: true,
)

#_render-note-on-gender-inclusive-lang(note-gender-inclusive-language: settings)

#set text(lang: "de")

#_render-note-on-gender-inclusive-lang(note-gender-inclusive-language: (enabled: false))

#_render-note-on-gender-inclusive-lang(note-gender-inclusive-language: settings)

#_render-note-on-gender-inclusive-lang(note-gender-inclusive-language: (title: "Custom title", ..settings))
