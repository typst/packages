#import "new-plain-template.typ": new-plain-template
#import "../colors.typ": color-schema

#let note = new-plain-template(
  "Note",
  title-color: color-schema.orange.primary,
  title-prefix: emoji.notepad,
  body-text-style: "italic",
)
