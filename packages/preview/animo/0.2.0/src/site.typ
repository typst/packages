// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// What every addressable site shares, where a site is a tag or a region with a name.
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
// beside the names that the author chose, and the runtime crossfades what it finds there, so the
// two cannot be allowed to collide.
// Reserving one prefix keeps them apart, and the same prefix covers the labels animo emits
// for its introspection.
#let reserved = "animo-"

// Check that the name of a site is a string
// that stays out of the label namespace that animo reserves.
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

// What a site shows when nothing has addressed it, which is the site where the body put it,
// at its unscaled size.
//
// The view hands a tag site two lengths rather than the anchor and the offset the resolver
// keeps, because only the rendering knows where an anchor is.
// A site the timeline never addressed is absent from the view and takes this state.
//
// `placed` says, per axis, whether a `move` has put the tag at a position with `x`, `y` or
// `relto`, which decides the point a `scale` grows the tag about. See `displayed`.
#let at-rest = (
  x: 0pt,
  y: 0pt,
  placed: (x: false, y: false),
  scale: (x: 1.0, y: 1.0),
  hidden: false,
)

// What a site is in one rendering, which is the display state its name has in that state.
//
// A name the timeline never addressed is absent from the state and is at rest.
// Every name is at rest in the HTML target as well, where one frame covers every state of
// the slide and the browser owns the display state.
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
  // There is one factor per axis, because CSS `scale` takes two values.
  // Typst's `scale` sets the factors it is given and leaves the other axis alone,
  // so the two axes stay independent.
  //
  // An axis on which the tag was placed grows from the anchor, so that the corner the
  // timeline put on a target stays there at any factor.
  // Any other axis grows about the centre, which leaves the tag where it is.
  scale(
    x: current.scale.x * 100%,
    y: current.scale.y * 100%,
    origin: (
      (if current.placed.x { left } else { center })
        + (if current.placed.y { top } else { horizon })
    ),
    reflow: false,
    if current.hidden { hide(payload) } else { payload },
  ),
)

// What a container resolves from its direct children.
//
// A grid, a table, a list, an enum and a terms list read their direct children and keep the
// ones that are `cell` or `item` elements.
// Every other child becomes the body of a cell or an item with default settings.
// A tag site and a region are a `context` block, which is one of those other children, so
// the element the author wrote stops being the container's child
// (measured on typst 0.15.0; see *Findings*).
//
// `body` names the field that holds the content of the child, for a child whose settings are
// the whole of the loss.
// Such a child that sets nothing beside its body lays out the same either way and is left
// alone.
// `body: none` marks a child the container drops whatever it carries.
//
// `article` is the article the child's element function takes, for the diagnosis.
//
// `fill` marks a child whose container paints the fill, which is where the second way out
// of the refusal applies.
#let container-children = (
  (
    func: grid.cell,
    container: "a grid",
    call: "grid.cell",
    article: "a",
    dropped: "its fill, its colspan and the other cell settings",
    body: "body",
    fill: true,
  ),
  (
    func: table.cell,
    container: "a table",
    call: "table.cell",
    article: "a",
    dropped: "its fill, its colspan and the other cell settings",
    body: "body",
    fill: true,
  ),
  (
    func: list.item,
    container: "a list",
    call: "list.item",
    article: "a",
    dropped: "its place in the list, which becomes a nested list under the item above it",
    body: none,
    fill: false,
  ),
  (
    func: enum.item,
    container: "an enum",
    call: "enum.item",
    article: "an",
    dropped: "its place in the enum, which becomes a nested enum under the item above it",
    body: none,
    fill: false,
  ),
  (
    func: terms.item,
    container: "a terms list",
    call: "terms.item",
    article: "a",
    dropped: "its place in the terms list, which typst refuses outright",
    body: none,
    fill: false,
  ),
)

// Refuse a body that a container would resolve, naming the ways to write it instead.
//
// `inside` is the site written inside the child, which is what keeps the child's settings.
// `holding` is the site written around a block that carries the fill, which a timeline that
// moves, scales, reveals or hides the filled box needs.
// The second way is named only for a cell, because a grid and a table paint the fill in
// a separate frame, outside every group a site produces, so a site inside a cell never
// covers that fill (measured; see *Findings*).
//
// A label on the child does not stop the container from reading it, so the key a label adds
// is not one of the settings that would be lost.
#let check-container-child(what, body, inside, holding) = {
  let child = container-children.find(it => it.func == body.func())
  if child == none { return }
  if child.body != none {
    let settings = body.fields().keys().filter(key => key != "label")
    if settings == (child.body,) { return }
  }
  let message = (
    "the body of "
      + what
      + " is "
      + child.article
      + " "
      + child.call
      + ", and "
      + child.container
      + " reads that element from its direct children; "
      + "a site is a context block between the two, so the container drops "
      + child.dropped
      + "; write the site inside the element instead, as in "
      + child.call
      + "(.., "
      + inside
      + ")"
  )
  if child.fill {
    message += (
      ". The fill is painted by "
        + child.container
        + " in a separate frame, outside every group a site produces, "
        + "so a site inside a cell does not cover the fill either: "
        + "a timeline that moves, scales, reveals or hides the filled box "
        + "needs the fill on a block the site holds, as in "
        + child.call
        + "("
        + holding
        + ")"
    )
  }
  panic(message)
}
