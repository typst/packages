// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// What every addressable site shares: a tag, and a region with a name.
//
// Both put the display state of the rendering they are part of on their content with
// typst's own elements, between the two nested slots that make them a group in the output.
// Both also take a name from the single namespace that the labels of the output form.
//
// The two helpers every diagnosis in the package shares live here as well, because a name
// and the value a refusal names are what every message is built out of.

// Say what a value is, in a message a reader can act on.
//
// `repr` of a paragraph of content is the whole paragraph, which makes the message it is
// part of hard to find, and the type alone is what the mistake is about.
#let describe(value) = (
  if type(value) == content { "content" } else {
    str(type(value)) + " " + repr(value)
  }
)

// The prefix of every label animo emits for itself.
//
// The generated label of an unnamed region ends up in the output as a `data-typst-label`
// beside the author's own names, and the runtime crossfades what it finds there, so the
// two cannot be allowed to collide.
// Reserving one prefix keeps them apart, and the same prefix covers the labels animo emits
// for its own introspection.
#let reserved = "animo-"

// Check the name of a site: a string, and one that stays out of animo's own label namespace.
//
// `what` names the site in the diagnosis, such as "a tag" or "a region".
#let check-name(what, name) = {
  assert(
    type(name) == str,
    message: what + " takes its name as a string, got " + repr(name),
  )
  assert(
    not name.starts-with(reserved),
    message: what
      + " is named "
      + name
      + ", and a name may not start with "
      + reserved
      + ": animo labels what it emits for itself with that prefix, "
      + "including the region groups its crossfade addresses",
  )
}

// What a site shows when nothing has addressed it: where the body put it, at its own size.
//
// The view hands a tag site two lengths rather than the anchor and the offset the resolver
// keeps, because only the rendering knows where an anchor is.
// A site the timeline never addressed is absent from the view and takes this state.
#let at-rest = (x: 0pt, y: 0pt, scale: (x: 1.0, y: 1.0), hidden: false)

// What a site is in one rendering: the display state its name has in that state.
//
// A name the timeline never addressed is absent from the state and is at rest.
// So is every name in the HTML target, where a frame covers a whole run of states and the
// browser owns the display state.
#let display-of(name, view) = {
  if view.state == none { at-rest } else {
    view.display.at(name, default: at-rest)
  }
}

// The display state of one rendering, put on the content with typst's own elements.
//
// This goes around the inner slot rather than inside it,
// because a `move` is an inline element
// and a block-level payload inside one is laid out in a paragraph,
// where a filling block no longer fills.
// See `slots` in `wrap.typ`.
#let displayed(current, payload) = move(
  dx: current.x,
  dy: current.y,
  // `move` is outside `scale` because CSS composes its individual properties
  // in that order, and the paged output has to agree with the browser.
  //
  // One factor per axis, because CSS `scale` takes two values.
  // Typst's `scale` sets the factors it is given and leaves the other axis alone,
  // so the two axes stay independent.
  scale(
    x: current.scale.x * 100%,
    y: current.scale.y * 100%,
    reflow: false,
    if current.hidden { hide(payload) } else { payload },
  ),
)
