#let std-state = state
#let std-numbering = numbering

/// Stateful array that tracks table notes that are yet to be displayed
/// -> state
#let state = std-state("_dining-table:notes", ())

/// Stateful string that represents the numbering format to be used when rendering table notes. It is assumed that this does not change when there are as-of-yet undisplayed notes that are pending. Defaults of lowercase alphabetical numbering.
/// -> state
#let numbering = std-state("_dining-table:notes:numbering", "a")

/// Explcitly empties the stateful array tracking pending notes. Called prior to showing the table to ensure that previous notes that were forgotten about aren't accidentally absorbed into this table.
#let clear() = state.update(())

/// Helper function to update the numbering style of table notes.
/// -> content
#let set-numbering(new) = numbering.update(new)

/// Helper functions to render the numbering of a note (either in the table body, or underneath)
/// -> content
#let make-numbering() = context std-numbering(numbering.get(), state.get().len() + 1)

/// This function replicates the behviour of `#footnote`: It is called within the table body, and stores the content until the table notes are being rendered. It is not possible to make a hyperlink between the table body's number and the associated note.
/// - body (content): Content to be rended under the table.
#let make(body) =  {
  h(0em, weak: true) + sym.space.narrow + super(make-numbering())
  state.update(it=>{it.push(body);it})
}

/// Helper function to display the numbering for a specific table note
/// - key (int): 0-indexed position of note inside stateful array
/// -> content
#let display-numbering(key) = super(context std-numbering(numbering.get(), key + 1))

/// Renders pending table notes in a grid-like manner (auto, 1fr), after which it empties the list of pending footnotes
/// -> content
#let display = context {
  grid(
    columns: (auto, 1fr),
    inset: 0.15em,
    ..(for (key, value) in state.get().enumerate() {
      (display-numbering(key), value)
    })
  )
} + clear()

/// Renders pending table notes in a list-like manner. Each note is boxed.
/// -> content
#let display-list = context {
  state.get()
   .enumerate()
   .map( ((key, value)) => box[#display-numbering(key) #value])
   .join(", ", last: ", and ")
}

#let display-style(notes) = {
  v(-0.5em)
  set text(0.888em)
  set block(spacing: 0.5em)
  set par(leading: 0.5em)
  align(start, notes)
}