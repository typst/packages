// The deck-record channel and internal logical-slide numbering.
//
// Typst gives a show-rule package exactly two channels between `setup` and the
// slide commands a user authors outside its lexical scope: `state` or metadata
// plus `query`. Mosaic uses one state value for everything `setup` declares,
// and this module is that channel: the state itself, the guard that keeps it
// written once, and the counters and small states the slide runtime steps as
// it renders.
//
// The record's shape, its defaults, and its single validating writer live in
// deck-record.typ; that file is the reference for what the record contains.
// The split is deliberate. This module imports nothing but `shared.typ`, so
// any subsystem may read the channel, including the subsystems whose
// validators the record's writer depends on.
//
// The record is written exactly once, by `setup`, and never mutated afterward;
// `write-deck-record` enforces that, so the record behaves as declared
// configuration rather than evolving hidden state. Readers that can run
// outside a deck (components, cell insets) treat `none` as "no deck" and fall
// back to library defaults.
#import "shared.typ": fail, key

#let deck-state = state(key("deck"), none)

// The settings half of the record, or `none` outside a deck. The canonical
// accessor for readers that treat "no deck" as a fallback case; call inside
// `context`.
#let deck-settings() = {
  let record = deck-state.get()
  if record == none { none } else { record.settings }
}

#let write-deck-record(record) = deck-state.update(current => {
  if current != none {
    fail("setup already configured this deck; apply setup exactly once")
  }
  record
})

#let logical-slide = counter(key("logical-slide"))
#let logical-slide-id = counter(key("logical-slide-id"))
#let logical-section = counter(key("logical-section"))

// Whether the slide currently rendering is numbered. The slide runtime writes
// it once per slide, before the planes render, so deck furniture (a folio, a
// statusline, a progress ring) can quiet itself on unnumbered pages such as
// titles and sections:
//
//   context if slide-numbered.get() { .. }
#let slide-numbered = state(key("slide-numbered"), true)

// The inverted palette of the slide currently rendering, or `none` when that
// slide is not inverted. The slide runtime writes it once per slide, before
// the frames render, so readers that resolve colors at layout time — the
// components, and the cell renderer restating ink inside cell labels — follow
// `slide(invert: true)` without the write-once record changing.
#let inverted-slide-colors = state(key("inverted-slide-colors"), none)

// The current section's own text, written by the slide runtime on every
// section slide. The counter above numbers the sections; this names the one
// being presented, so chrome can print it without querying the document. The
// toc section variant still queries: it draws every section, not this one.
#let section-title = state(key("section-title"), none)

// Where the rendering slide sits in the deck, in the two shapes `info()`
// publishes and the progress component counts with. One definition each, so
// the public answer and the built-in chrome cannot disagree. Both are
// contextual, and both answer outside a deck as well as inside one: the
// counters simply read zero.
#let slide-position() = (
  number: logical-slide.get().first(),
  total: logical-slide.final().first(),
  numbered: slide-numbered.get(),
)

#let section-position() = (
  number: logical-section.get().first(),
  total: logical-section.final().first(),
  title: section-title.get(),
)
