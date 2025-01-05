#import "@preview/basalt-lib:1.0.0": new-vault, xlink

#let vault = new-vault(
  note-paths: csv("note-list.csv").flatten(),
  include-from-vault: path => include path,
  formatters: (
    // Formatters are passed three arguments:
    // `body` has the contents of the note.
    // `meta` contains the arguments passed to new-note.
    // `root` indicates whether the note being formatted
    // is the top level note, or if it's just being
    // included in another note.
    (body, meta: (:), root: true) => {
      // The formatter body can be treated as a show rule.
      if not root {
        return body
      }
      // You may only want to adjust layout options
      // if the note is the root.
      // Otherwise you might get a bunch of whitespace!
      set page("us-letter")

      // Don't forget the body at the end.
      body
    },
    // You can omit the arguments you
    // don't care about with a sink.
    (body, ..rest) => {
      set text(12pt)
      body
    },
  )
)
