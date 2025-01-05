#import "@preview/basalt-lib:1.0.0": new-vault, xlink

#let vault = new-vault(
  // The note list can easily be added to or modified
  // by external tools, shell scripts, etc.
  note-paths: csv("note-list.csv").flatten(),
  // Unfortunately this is still required.
  include-from-vault: path => include path,
)
