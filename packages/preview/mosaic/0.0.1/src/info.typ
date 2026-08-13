// Public read access to everything a deck knows about itself: the metadata
// declared on setup, and where the rendering slide sits in the deck.
// Dependencies are imported under private aliases so `info` is this module's
// only export.
#import "shared.typ" as _shared
#import "deck-state.typ" as _state

/// Reads what the deck knows about itself: the metadata declared on `setup`,
/// and the position of the slide being rendered. This is what a custom
/// composition reads instead of restating the deck, and what deck chrome reads
/// instead of counting for itself.
///
/// Returns a dictionary with six fields. Four are the deck metadata, exactly
/// as `setup` received it:
///
/// - `title`: the deck title.
/// - `subtitle`: the deck subtitle.
/// - `authors`: always an array of resolved author records, whether the deck
///   wrote a bare name or a full `layouts.author` record. Every entry carries
///   `name`, `affiliations`, `email`, `orcid`, and `corresponding`.
/// - `date`: the deck date.
///
/// Two are the position of the slide being rendered, which is what makes the
/// reader contextual:
///
/// - `slide`: a dictionary of `number`, `total`, and `numbered`. The count is
///   of logical slides rather than pages, so one incremental slide is one
///   number however many frames it prints. Unnumbered slides (titles and
///   sections, by default) are passed over by the count and report
///   `numbered: false`, which is the signal deck furniture uses to quiet
///   itself on those pages.
/// - `section`: a dictionary of `number`, `total`, and `title`. The number is
///   the current section's, counting slides that use the `section` layout, and
///   the title is that section's own text with any heading stripped. Before the
///   deck's first section slide the number is `0` and the title is `none`.
///
/// Call it inside a `context` block (slide bodies, planes, and show rules
/// already are one):
///
/// ```typ
/// #mosaic.slide(
///   background: mosaic.components.image("cover.webp", scrim: black.transparentize(45%)),
/// )[
///   #context {
///     let deck = mosaic.info()
///     place(top + left, text(size: 2.2em, weight: "bold", deck.title))
///     place(bottom + left, deck.authors.map(author => author.name).join([, ]))
///   }
/// ]
/// ```
///
/// The metadata half is the escape hatch for title pages the built-in variants
/// do not draw: declare the information once on `setup`, and a hand-built
/// cover reads it back instead of duplicating it. The position half is what a
/// footline or a headline is made of, and it is the same reading
/// `components.progress` does, so a theme drawing its own chrome keeps no
/// counters of its own:
///
/// ```typ
/// #let footline = context {
///   let deck = mosaic.info()
///   grid(
///     columns: (1fr, 1fr),
///     deck.section.title,
///     align(right)[#deck.slide.number\/#deck.slide.total],
///   )
/// }
/// ```
///
/// -> dictionary
#let info() = {
  let record = _state.deck-state.get()
  if record == none or record.settings == none {
    _shared.fail("info() requires a deck; apply setup before reading it")
  }
  // The declared metadata and the live position, in one record. The position
  // readers are the ones the progress component draws from, so the public
  // answer and the built-in chrome cannot drift.
  record.settings.deck + (
    slide: _state.slide-position(),
    section: _state.section-position(),
  )
}
