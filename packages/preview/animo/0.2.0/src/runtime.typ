// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// The seam between the resolved plan and the browser runtime.
//
// In the paged outputs a state is a page, and typst applies its display state itself.
// In the HTML target one frame covers every state of the slide, so the display state has
// to travel to the browser as data.
// The browser runtime puts the display state on the groups as CSS.
//
// The channel is one `data-animo-plan` attribute per slide, holding compact JSON.
// The channel is an attribute rather than a `<script>` element, because the HTML parser escapes and
// unescapes an attribute value, so no tag name can break the page,
// and because a browser's element inspector shows it beside the slide it belongs to.
//
// Nothing about a display state travels the other way.
// Every state including state 0 is resolved from the timeline,
// so the plan is complete when it leaves typst and the runtime applies what it is given.
// Typst's `hide()` emits nothing to draw, so a tag that starts hidden is rendered normally
// in the HTML target and hidden by the runtime with `opacity: 0`.
// Only the paged outputs use `hide()`.
//
// Tag sites still report themselves, because a slide checks what its timeline asks against
// the sites its rendering produced, and `query` is what carries a report out of the frame.
// That report is `site-marker` in `canvas.typ`, which both targets emit and which carries
// the site's corner on paper.

#import "anim.typ": default-timing
#import "plan.typ": identity

// A length as a number of typst points, rounded to a tenth of a thousandth.
//
// The numbers that typst writes run to fifteen digits, which no renderer can tell apart and which
// makes the emitted page hard to read and hard to diff.
//
// Must be called in a context, because a length may be relative to the text size,
// which is resolved here at the slide rather than at the tag site.
#let pt-of(value) = calc.round(value.to-absolute().pt(), digits: 4)

// A position in one state, as the browser needs it.
//
// The anchor of a `relto` stays a name, because the HTML target has no position
// introspection and only the browser can read a position off the tag's group.
// Everything else is already arithmetic, because the offset is in typst points and the
// runtime adds the anchors it measured.
//
// A pair whose `relto` names the moved tag is the identity, which a tag the timeline never moved
// carries, so the runtime needs no anchor at all for it.
//
// Must be called in a context.
#let position-of(position) = {
  let axis(value) = (relto: value.relto, offset: pt-of(value.offset))
  (x: axis(position.x), y: axis(position.y))
}

// The display state of every addressed tag in one state, as the browser needs it.
//
// Every state holds every name, even the ones it leaves at the identity.
// The browser keeps a display state as inline style until something overwrites it, so a
// state that said nothing about a tag would leave the previous state's style in place,
// and stepping backwards would not undo what stepping forwards did.
//
// Lengths become numbers of typst points, which are the user units of the frame's SVG,
// so the runtime writes them as CSS lengths and the browser scales them with the slide.
#let tags-of(display, names) = {
  let entries = (:)
  for name in names {
    let current = display.at(name, default: identity(name))
    entries.insert(
      name,
      (hidden: current.hidden, ..position-of(current), scale: current.scale),
    )
  }
  entries
}

// One entry of an emitted record, as a dictionary, or an empty one when the value says
// nothing.
//
// Every optional entry of the plan is written this way, so that what the runtime reads is
// only what a deck actually stated.
// The entry is a dictionary rather than a pair, so that it spreads into a record beside the
// entries that are always there, and adds to another where every entry is optional.
#let entry(key, value) = if value == none { (:) } else { ((key): value) }

// A timing record with every field at its default dropped, or `none` when nothing is left.
//
// A field at its default is left out, and a record whose fields are all at their default
// is left out entirely, because the runtime reads a missing delay as "starts with its
// step" and a missing duration as "takes the `primitive-duration:` of the deck", which is what an
// operation that states no timing asks for.
// A deck that times nothing therefore carries no timing at all.
// The pruning is per field rather than per record because of `auto`, which is the duration
// that lives in the stylesheet and has no number to travel as.
#let pruned-timing(record) = {
  if record == none { return none }
  let kept = (:)
  for (field, value) in record {
    if value != default-timing.at(field) { kept.insert(field, value) }
  }
  if kept.len() != 0 { kept }
}

// The timing of one step, or `none` when it says nothing about when any of its operations
// happen.
#let timings-of(timing) = {
  let tags = (:)
  for (name, properties) in timing.tags {
    let kept = (:)
    for (property, record) in properties {
      let wanted = pruned-timing(record)
      if wanted != none { kept.insert(property, wanted) }
    }
    if kept.len() != 0 { tags.insert(name, kept) }
  }
  let wanted = (
    entry("tags", if tags.len() != 0 { tags })
      + entry("pan", pruned-timing(timing.pan))
  )
  if wanted.len() != 0 { wanted }
}

// How long one step lasts, as the browser needs it, or `none` when it needs nothing.
//
// A step whose every operation starts with it and takes the `primitive-duration:` of the deck
// lasts exactly that duration, which is what the runtime assumes when it finds no span,
// so such a step carries none.
// An `unstated` of zero on its own is that case.
// Beside a `stated`, an `unstated` of zero is a separate statement and travels,
// because it says that some operation of the step takes the `primitive-duration:` of the deck
// where another one runs past it.
#let span-for(span) = {
  let kept = (
    entry("stated", span.stated) + entry("unstated", span.unstated)
  )
  if kept.len() != 0 and kept != (unstated: 0.0) { kept }
}

// What one boundary changes, as the runtime reads it.
// This is every tag whose content the boundary changes, by name,
// with the timing of the operations that changed it and the name of the transition they
// named for it, with its parameters when it has any, both left out for `auto`.
//
// The runtime finds the stacks a boundary crosses by these names, because a stack holds the
// groups of the tags laid out in it.
// The operations on one name agree on both, and so do the operations on the names of one
// stack, because `check-boundaries` refuses the boundary otherwise, so the first operation
// speaks for all of them.
//
// A tag that becomes no group has nothing in a stack to be found by.
// For such a tag, `regions` maps the label of the group of the region that holds its stack
// to the name of the tag whose record that stack takes,
// as `groupless-regions` in `member.typ` reads it from the membership reports.
// `regions` is left out when it is empty,
// which it is in a deck whose every changed tag has a group.
#let boundary-of(epoch, regions) = {
  let changed = (:)
  for name in epoch.changed {
    let transition = epoch.transitions.at(name).first()
    let timing = entry("timing", pruned-timing(epoch.timings.at(name).first()))
    changed.insert(name, if transition == auto { timing } else {
      (
        ..timing,
        transition: transition.name,
        ..entry("args", if transition.args.len() > 0 { transition.args }),
      )
    })
  }
  (changed: changed, ..entry("regions", if regions.len() > 0 { regions }))
}

// The whole plan of a slide, as the runtime reads it.
//
// A state holds the display state of its tags, the position of its viewport, the epoch it
// belongs to and whether the handout keeps a page for it, the first two kept apart as the
// resolver keeps them apart.
// The handout flag is the one the paged outputs resolve, so that a view of the deck that
// shows one state per slide can show the state the handout shows.
// The epoch is which rendering of every epoch stack shows the state, so a step that changes
// it is a step that crosses a boundary.
//
// `epochs` holds, per epoch, what the boundary starting it changes, as `boundary-of` writes
// it from the epoch and from `regions`, which holds the `groupless-regions` of each epoch, or is
// `auto` for a plan that names none.
// The first epoch begins no boundary and changes nothing.
//
// A state also carries the `wait` before it is entered, the `hold` before the state after
// it is, the `timing` of the operations its step performed and the `span` of that
// step, all in seconds, because none of them can be resolved anywhere but at the moment
// the step runs.
// All are left out when they say nothing, and a gap timed by neither of its neighbours is a
// presenter click, which is what a state with neither number gets.
//
// Both numbers travel, rather than one resolved number per gap, because the gap across a
// slide boundary is timed by two slides and the two are emitted by two calls of this
// function.
// The runtime is the first place that sees both sides of that gap.
//
// Must be called in a context.
#let browser-plan(plan, names, regions: auto) = (
  states: plan.states.map(state => (
    tags: tags-of(state.display, names),
    pan: position-of(state.slide.pan),
    epoch: state.epoch,
    handout: state.handout,
    ..entry("wait", state.wait),
    ..entry("hold", state.hold),
    ..entry("timing", timings-of(state.timing)),
    ..entry("span", span-for(state.span)),
  )),
  epochs: plan
    .epochs
    .enumerate()
    .map(((epoch, it)) => boundary-of(
      it,
      if regions == auto { (:) } else { regions.at(epoch) },
    )),
)
