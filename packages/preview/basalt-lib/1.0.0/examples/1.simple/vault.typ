#import "@preview/basalt-lib:1.0.0": new-vault, xlink

#let vault = new-vault(
  // Both of these arguments are required because
  // of current limitations in how Typst handles
  // paths and includes.
  note-paths: (
    "note1.typ",
    "note2.typ",
  ),
  include-from-vault: path => include path,
)
