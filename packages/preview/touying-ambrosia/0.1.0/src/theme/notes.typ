#import "../touying.typ": touying-notes
#import "../utils.typ" as ambrosia-utils

/// Presenter notes use the deck's branding while Touying owns their layout.
#let notes(self: none, ..args) = touying-notes(
  self: self,
  header: self => pad(x: 1.6em, y: 0.8em, text(
    fill: self.colors.on-accent,
    ambrosia-utils.call-or-display(self, self.store.title),
  )),
  header-fill: self.colors.primary,
  fill: self.colors.surface,
  note-setting: note => pad(x: 2.4em, text(fill: self.colors.foreground, note)),
  ..args,
)
