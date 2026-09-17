// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// The automatic canvas: how large the rectangle is that a slide body is laid out on.
//
// Typst's own `auto` sizing cannot answer this, because `#place` is out of flow and
// contributes nothing to it, and the HTML target has no position introspection.
// What is available in both targets is a `show place:` rule over the body.
// It fires for every placement and can read `dx`, `dy`, `alignment` and a measurable `body`,
// so the union is computed from content alone and comes out the same in HTML and on paper.
//
// The rule cannot return a value, so each placement is recorded as a `metadata` element
// carrying a label, and the union is taken from `query`.
// That makes the canvas size depend on the layout of the very block it sizes,
// which typst resolves by iterating the document until introspection converges.
// The iteration terminates because the body is always laid out at the same inner size,
// whatever the canvas around it turns out to be.
//
// The recording costs a `context`, a `measure` and a queried element per placement, so a
// slide records only where the canvas can be observed.
// `pan` is the only thing that reads it: the viewport clips in both targets, so a slide
// whose timeline never pans is drawn the same whatever canvas it gets, and takes the
// viewport clamped to its body box.
// A rendering that is measured rather than laid out records nothing either, since a
// `metadata` element inside a `measure` never reaches `query`.

#import "site.typ": describe

// The label every recorded placement carries.
// One label serves the whole document and the slide index in the value does the scoping,
// because a tag name means nothing outside its own slide.
#let place-label = label("animo-place")

// The label a slide's computed canvas carries.
// The canvas is a property of the slide that panning and the tests both have to read,
// and introspection is the only channel that reaches both targets.
#let canvas-label = label("animo-canvas")

// The label of the marker every tag site emits to report itself.
//
// One report serves both targets and both readers: a slide checks what its timeline asks
// against the sites its rendering produced, in the HTML target as on paper, and a paged
// rendering reads the corner of the site out of the same marker.
//
// On paper the marker is placed, and that corner is what a `relto` reads, rather than the
// wrapper's own position, because typst records an element in the middle of a line at the
// line's baseline, not at its top-left corner, while a placement records the corner of the
// container it is placed in, whatever that container is.
// Measured on typst 0.15.1; see *Findings*.
#let site-label = label("animo-site")

// The label that keeps a placement out of the recording below.
//
// A rendering that is measured rather than laid out produces no queryable metadata,
// so recording the placements it holds costs a `context` and a `measure` each for records
// that no `query` can reach.
// A label is how the rendering asks to be passed over.
// Measured on typst 0.15.1, a `show place:` rule inside such a rendering does not keep the
// rule around it from firing, so staying silent is not enough.
// The inner rule does run first, and the outer one is handed the element it produced,
// so a label attached inside is readable outside.
// See *Findings*.
#let unrecorded-label = label("animo-unrecorded")

// Label every placement in `body`, so that the recording below passes over it.
//
// A label on an element changes no layout, so a rendering measures the same with it as
// without it.
#let unrecorded(body) = {
  show place: it => [#it#unrecorded-label]
  body
}

// Record every placement of a slide body, so that the canvas can be sized from it.
//
// The recording has to be invisible to typst's own layout, which rules out `layout(size => ..)`
// inside the rule, because `layout` is block-level and breaks the paragraph the placement
// sits in.
// A `context` block holding nothing but `metadata` is inline and changes no measurement.
// The marker a tag site places for its anchor is animo's own and has no extent to record.
#let record-placements(index, body) = {
  show place: it => {
    if it.body.at("label", default: none) == site-label { return it }
    if it.at("label", default: none) == unrecorded-label { return it }
    context [#metadata((
        slide: index,
        dx: it.dx,
        dy: it.dy,
        alignment: it.alignment,
        size: measure(it.body),
      ))#place-label]
    it
  }
  body
}

// Resolve a `relative` offset against the length its ratio is a fraction of.
#let resolve-relative(offset, full) = offset.length + offset.ratio * full

// The horizontal component of an alignment, or `none` when it has none.
#let x-of(value) = if type(value) == alignment { value.x }

// The vertical component of an alignment, or `none` when it has none.
#let y-of(value) = if type(value) == alignment { value.y }

// How far right a recorded placement reaches, measured from the origin of `container`.
#let x-extent(placement, container) = {
  let dx = resolve-relative(placement.dx, container.width)
  let width = placement.size.width
  let align = x-of(placement.alignment)
  if align == center {
    (container.width + width) / 2 + dx
  } else if align == right or align == end {
    container.width + dx
  } else {
    dx + width
  }
}

// How far down a recorded placement reaches, measured from the origin of `container`.
#let y-extent(placement, container) = {
  let dy = resolve-relative(placement.dy, container.height)
  let height = placement.size.height
  let align = y-of(placement.alignment)
  if align == horizon {
    (container.height + height) / 2 + dy
  } else if align == bottom {
    container.height + dy
  } else {
    dy + height
  }
}

// The box a slide body is laid out in, as a dictionary with `width` and `height`.
//
// The width is the viewport's inner width, and the height is that of the viewport unless the
// body's own flow is taller, because a taller body needs a taller box.
// Measured on typst 0.15.1, every block-level element that does not fit a fixed-height
// container is stacked at the container's bottom edge rather than overflowing past it, so a
// derivation that runs off the viewport comes out as a pile of overlapping blocks.
// See *Findings* in the design document.
//
// The height comes from an unbounded measurement of the body alone, which `#place` contributes
// nothing to, so the box does not depend on the canvas it ends up on and the introspection that
// sizes that canvas still converges.
//
// Must be called in a context.
#let body-box(body, inner) = (
  width: inner.width,
  height: calc.max(inner.height, measure(body, width: inner.width).height),
)

// The canvas of a slide whose placements were not recorded, with `width` and `height`.
//
// It covers the body's in-flow extent, offset by the deck's margin, and is clamped to at
// least the viewport.
// This is the canvas of a slide that never pans, where a `#place` outside the viewport is
// clipped in every state and the size of the canvas around it changes nothing that is drawn.
//
// `container` is the box the body is laid out in, which `body-box` above answers.
#let body-extent(container, viewport, margin) = (
  width: calc.max(viewport.width, margin + container.width),
  height: calc.max(viewport.height, margin + container.height),
)

// The canvas of one slide that pans, as a dictionary with `width` and `height`.
//
// The union covers the body's in-flow extent and every placement animo saw,
// each offset by the deck's margin, and is clamped to at least the viewport.
// It is an approximation rather than an exact bounding box, and it errs in both
// directions, so `canvas:` is the override either way.
//
// A placement nested inside another container reports its offsets against *that*
// container, which the rule cannot tell apart from the slide body. An offset alone is
// then counted short by wherever the container sits, while an *alignment* is counted from
// the body box, so a placement aligned to the right edge of a narrow box is counted from
// the right edge of the body instead, which is long.
//
// A ratio-sized body is counted short as well, at the top level too.
// `measure` here has no container to resolve a ratio against, so a placed
// `rect(width: 100%, height: 100%)` reports nothing and adds nothing.
//
// Measured on typst 0.15.1; see *Findings* and the tier-1 canvas tests.
//
// `container` is the box the body is laid out in, which `body-box` above answers.
//
// Must be called in a context, and only after `record-placements` has run over the same
// body, which is what puts the placements in reach of `query`.
#let auto-extent(index, container, viewport, margin) = {
  let placements = query(place-label)
    .map(it => it.value)
    .filter(it => it.slide == index)
  let bound = body-extent(container, viewport, margin)
  (
    width: calc.max(
      bound.width,
      ..placements.map(it => margin + x-extent(it, container)),
    ),
    height: calc.max(
      bound.height,
      ..placements.map(it => margin + y-extent(it, container)),
    ),
  )
}

// The label of the marker each paged rendering of a slide puts at its canvas origin.
//
// `query` hands back a position on the page, and a panned page shows the canvas shifted
// by the pan, so a tag's position on the canvas is its position less the position of this
// marker on the same page.
// Both come out of the same introspection pass, so the answer is independent of the pan it
// decides.
#let origin-label = label("animo-origin")

// The label a slide's resolved geometry carries in the paged outputs.
//
// `pans` is where the viewport sits in each state, and `displays` is each state's display
// state with every position resolved to the translation the rendering applied.
// The browser resolves the same numbers itself, because the HTML target has no position
// introspection, so a test compares the two targets through these numbers as well.
#let geometry-label = label("animo-geometry")

// The marker above, for one slide, to be put at the origin of its canvas.
#let origin-marker(index) = place(
  top + left,
  [#metadata((slide: index))#origin-label],
)

// What a tag site reports about itself, which the slide reads back to check its tag sites.
//
// Unplaced, this is the report of a site that has no corner to give, which is every site in
// the HTML target, where positions cannot be read, and a site on paper that lays nothing out.
// A `metadata` element is layout-neutral wherever it sits, so a tag that is removed in an
// epoch can still be checked against the other sites of its name.
// `corner` says whether the marker sits at a corner, which only a placed one does.
#let site-marker(view, name, corner: false) = [#metadata((
    slide: view.slide,
    name: name,
    within: view.within,
    corner: corner,
  ))#site-label]

// The same report, placed at the corner of a tag site's outer wrapper, for the paged outputs.
//
// Placed, so that it takes no room, and a page with the marker rasterises identically to the
// same page without it.
// The HTML target, which cannot read positions, emits the unplaced form instead, so the
// groups the browser addresses are untouched.
#let anchor-marker(view, name) = place(top + left, site-marker(
  view,
  name,
  corner: true,
))

// The report of every tag site of one slide, as `(slide:, name:, within:, corner:)`.
//
// One label serves the whole document and the slide index in the value does the scoping,
// exactly as the recorded placements of the canvas do.
//
// Must be called in a context.
#let sites-of(index) = (
  query(site-label).map(it => it.value).filter(it => it.slide == index)
)

// Where the first site of each of these tags sits on the canvas of one slide.
//
// The first site in document order, on the first page of the slide that lays it out, which
// is the site the browser finds first as well: a page is a state, states run in epoch order,
// and the browser takes the first occurrence in the first epoch frame that holds one.
// A name with no site on any page of the slide is absent from the answer.
//
// The marker sits inside the outer wrapper and outside the tag's own display state, so a
// tag's own `move` does not enter its anchor, while the display state of a tag around it does.
//
// One query for the whole slide rather than one per name, because every state of a plan
// holds every addressed tag, so a per-name query would be a pass over the document per tag
// per state.
//
// Must be called in a context.
#let anchors-of(index, names) = {
  let found = (:)
  if names.len() == 0 { return found }
  let sites = query(site-label).filter(it => (
    it.value.slide == index and it.value.corner and it.value.name in names
  ))
  for origin in query(origin-label).filter(it => it.value.slide == index) {
    if found.len() == names.len() { break }
    let page = origin.location().page()
    let zero = origin.location().position()
    for site in sites.filter(it => it.location().page() == page) {
      if site.value.name in found { continue }
      let at = site.location().position()
      found.insert(site.value.name, (x: at.x - zero.x, y: at.y - zero.y))
    }
  }
  found
}

// A position resolved against the anchors of one slide, as two absolute lengths.
//
// `anchor(relto) + offset - anchor(self)`, where the anchor of `none` is the canvas origin
// and `self` is `none` for the viewport, which is anchored there as well.
//
// An anchor that has not been found leaves the offset alone, which is what the first
// introspection pass sees, because no tag site has been laid out yet and nothing can be
// relative to one.
// A tag the slide really does not have is refused by the slide rather than resolved here.
#let resolve-position(position, self, anchors) = {
  let own = if self != none { anchors.at(self, default: none) }
  let along(axis, which) = {
    let offset = axis.offset.to-absolute()
    if axis.relto == self { return offset }
    let target = if axis.relto == none { (x: 0pt, y: 0pt) } else {
      anchors.at(axis.relto, default: none)
    }
    if target == none or (self != none and own == none) { return offset }
    target.at(which) + offset - if self == none { 0pt } else { own.at(which) }
  }
  (x: along(position.x, "x"), y: along(position.y, "y"))
}

// The position of the viewport on the canvas in one state, as two absolute lengths.
//
// The viewport is anchored at the canvas origin, and a `relto` puts the named tag where the
// body of a fresh slide starts, which is the margin in from that origin.
#let paged-pan(pan, anchors, margin) = {
  let at = resolve-position(pan, none, anchors)
  let shift(axis, which) = if axis.relto == none { at.at(which) } else {
    at.at(which) - margin
  }
  (x: shift(pan.x, "x"), y: shift(pan.y, "y"))
}

// The display state of one state with every tag's position resolved to two lengths.
//
// The translation a tag is given is what its own anchor has to travel to reach the position
// the timeline states, so a tag the timeline never moved is left exactly where the body put
// it: its position is its own anchor at offset zero, and the two terms cancel.
#let paged-display(display, anchors) = {
  let resolved = (:)
  for (name, current) in display {
    resolved.insert(
      name,
      (:..current, ..resolve-position(current, name, anchors)),
    )
  }
  resolved
}

// Check the `canvas` argument of a slide and hand back its two lengths.
#let explicit-extent(value) = {
  assert(
    type(value) == dictionary and value.keys().sorted() == ("height", "width"),
    message: "canvas must be `auto` or a dictionary with `width` and `height`, got "
      + describe(value),
  )
  (width: value.width, height: value.height)
}
