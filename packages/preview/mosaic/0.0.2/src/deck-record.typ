// The deck record: its shape, its one writer, and its reader.
//
// `deck-state.typ` owns the channel (one Typst `state` value plus the guard
// that keeps it written once). This module owns what travels through it. The
// two are separate files because the channel is a leaf that anything may
// import, while the record's shape depends on the validators of the subsystems
// it carries, and those subsystems read the channel themselves.
//
// The record is a flat dictionary of exactly seven fields. Nothing else may be
// added to it without a reason that survives the write-once rule: a field here
// is configuration `setup` declared, not a place to accumulate state during a
// compilation.
//
//   settings         dictionary | none   Everything a slide renders against:
//                                        colors, roles, spacing, notes
//                                        geometry, content defaults, deck
//                                        metadata, and the overflow policy.
//                                        `none` only in the no-deck fallback
//                                        below. Built and validated by
//                                        settings.typ.
//   layouts          dictionary          The configured layouts, by name, that
//                                        heading slides and named `slide`
//                                        commands resolve through. `(:)`
//                                        deliberately means "outside a deck",
//                                        so it is the one field whose fallback
//                                        differs from what `setup` writes.
//   frozen-counters  array of counter    Counters held still across the frames
//   frozen-states    array of state      and states likewise, so an
//                                        incremental slide's chrome does not
//                                        advance once per frame.
//   handout          bool                Whether every slide collapses to its
//                                        final frame.
//   output           str                 "slides", "speaker", "notes", or
//                                        "split": the rendering target, which
//                                        decides page geometry and whether
//                                        notes print.
//   paper            dictionary          Resolved slide dimensions, never a
//                                        preset name, because the printed
//                                        outputs scale a thumbnail of this
//                                        size onto a page of another.
//
// Readers that can run outside a deck (components, cell insets) take
// `default-deck-record` instead of failing, so a component rendered in a plain
// Typst document still has library defaults to paint from.
#import "shared.typ": fail
#import "deck-state.typ": deck-state, write-deck-record
#import "paper.typ": default-paper, paper-aliases
#import "settings.typ": validate-settings
#import "layout/config.typ": standard-layouts, validate-layouts

// The record a reader assumes when no deck wrote one.
#let default-deck-record = (
  settings: none,
  layouts: (:),
  frozen-counters: (),
  frozen-states: (),
  handout: false,
  output: "slides",
  paper: paper-aliases.at(default-paper),
)

#let read-deck-record() = {
  let record = deck-state.get()
  if record == none { default-deck-record } else { record }
}

#let validate-frozen(values, expected, name) = {
  if type(values) != array {
    fail(name + " must be an array")
  }
  if not values.all(value => type(value) == expected) {
    fail(name + " must contain only " + repr(expected) + " values")
  }
  values
}

// The single write of the deck record. Every field validates here, at the one
// place a value can enter the record; `write-deck-record` rejects a second
// write, which is what makes the record immutable declared configuration
// rather than mutable state.
// The named defaults are unreachable in practice: `setup`, the sole caller,
// passes every argument. They mirror `default-deck-record`, except `layouts`,
// whose record value of `(:)` deliberately means "outside a deck".
#let configure-deck(
  settings: default-deck-record.settings,
  layouts: standard-layouts,
  frozen-counters: default-deck-record.frozen-counters,
  frozen-states: default-deck-record.frozen-states,
  handout: default-deck-record.handout,
  output: default-deck-record.output,
  paper: default-deck-record.paper,
) = {
  if type(handout) != bool {
    fail("setup handout must be a boolean")
  }
  // `output` and `paper` are validated by `setup`, the only caller.
  write-deck-record((
    settings: validate-settings(settings),
    layouts: validate-layouts(layouts),
    frozen-counters: validate-frozen(
      frozen-counters,
      counter,
      "frozen-counters",
    ),
    frozen-states: validate-frozen(frozen-states, state, "frozen-states"),
    handout: handout,
    output: output,
    paper: paper,
  ))
}
