#import "vault.typ": *
#show: vault.new-note.with(
  // All note metadata is optional, but for
  // cross-note linking there needs to be a
  // way to distinguish between notes.
  name: "note1",
)

Insightful notes go here...

Hey look, a #xlink(name: "note2")[link]!
