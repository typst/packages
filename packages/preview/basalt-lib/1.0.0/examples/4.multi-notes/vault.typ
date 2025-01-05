// Notice the new as-branch import.
#import "@preview/basalt-lib:1.0.0": new-vault, xlink, as-branch

#let vault = new-vault(
  note-paths: csv("note-list.csv").flatten(),
  include-from-vault: path => include path,
  formatters: (
    (body, root: true, ..rest) => {
      if not root {
        return body
      }
      set page("us-letter")
      body
    },
    (body, ..rest) => {
      set text(12pt)
      body
    },
  )
)
