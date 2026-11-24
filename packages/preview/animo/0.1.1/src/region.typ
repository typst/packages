// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// Regions: areas of a slide whose interior may be laid out afresh in every epoch,
// inside a footprint that stays the same.
//
// A region's content may change between epochs while everything around it stays where it
// is, so a region reserves the largest extent its content takes on over the epochs the slide
// actually has, per axis, and lays each epoch out inside that.
// It measures every epoch once, which keeps the cost linear in epochs and independent of how
// many tags the region holds.
//
// The two functions that shape a region receive one rendering per epoch, `none` for an
// epoch with nothing to lay out, and a function that builds the container, and they know
// nothing about tags.
// An explicit region and a tag that is its own region therefore share one measurement.
// A tag is its own region when its content changes and no explicit region holds it.
// The box they reserve is measured by `footprint.typ`.
//
// Both must be called in a context, because they measure.

#import "canvas.typ": anchor-marker, site-marker
#import "footprint.typ": finite, inline-footprint, inline-placed, measured-at
#import "member.typ": member
#import "plan.typ": ask, provide, varies
#import "site.typ": check-name, describe, display-of, reserved
#import "wrap.typ": filling, slots

// The label every footprint carries, so that it can be read back.
#let footprint-label = label("animo-footprint")

// A region on a line, in the box `inline-footprint` measures, with its baseline pinned.
//
// `container(sized, inner, footprint)` builds the region from the sized box function,
// the placed content and a description of the footprint.
#let inline-region(renderings, epoch, container) = {
  let shared = inline-footprint(renderings)
  let height = shared.ascent + shared.descent
  let current = renderings.at(epoch)
  container(
    box.with(width: shared.width, height: height, baseline: shared.descent),
    if current != none { inline-placed(shared, epoch, current) },
    (
      kind: "inline",
      width: shared.width,
      height: height,
      measured: shared.extents.map(it => (
        width: it.width,
        height: it.ascent + it.descent,
      )),
    ),
  )
}

// A requested size resolved against the size of the container, or `auto`.
//
// A ratio has nothing to be a ratio of in a container of unbounded size, which only an
// unbounded `measure` produces, so the answer is `auto` there.
// Such a measurement asks whether content breaks the line, or how wide it is, and a region
// is block-level at any size.
#let fit(value, full) = {
  if value == auto {
    auto
  } else if type(value) == length {
    value.to-absolute()
  } else if not finite(full) {
    auto
  } else if type(value) == ratio {
    value * full
  } else {
    value.length.to-absolute() + value.ratio * full
  }
}

// A region between paragraphs: a block as wide as its container, or as `width` says,
// and as tall as the tallest epoch laid out at that width, or as `height` says.
//
// The width is the container's, which only `layout` knows, and `layout` is block-level, which
// a region here already is.
// Nothing is measured when there is nothing to choose between: a height that is given, or a
// slide with one epoch, whose only rendering takes the height it takes.
// `align` places the rendering inside the footprint, and is `none` for a region that has no
// argument for it, which then lays its rendering out as it comes.
#let block-region(
  renderings,
  epoch,
  container,
  width: auto,
  height: auto,
  align: none,
  clip: false,
) = layout(size => {
  let width = if width == auto and finite(size.width) { size.width } else {
    fit(width, size.width)
  }
  let height = fit(height, size.height)
  let measured = if height == auto and renderings.len() > 1 {
    measured-at(renderings, width)
  } else { () }
  if measured.len() > 0 {
    height = calc.max(..measured.map(it => it.height))
  }
  let current = renderings.at(epoch)
  container(
    block.with(
      width: if width == size.width { 100% } else { width },
      height: height,
      clip: clip,
    ),
    if align == none or current == none { current } else {
      std.align(align, current)
    },
    (
      kind: "block",
      width: width,
      height: height,
      clip: clip,
      measured: measured,
    ),
  )
})

// The number of an explicit region in one rendering of a slide, in document order.
//
// The counter is set back to zero before every rendering of a slide, so a region has the
// same number in every rendering in which the content before it is the same, which is every
// rendering when the region is not inside content that changes.
#let region-counter = counter("animo-region")

// The label that the group of an unnamed region carries in the output.
//
// A region the timeline never addresses still has to be addressable by the runtime, because
// it is what an epoch boundary crossfades, and only a labelled box or block becomes a group
// at all. The number is the region's own, so the label is stable across the epoch frames of
// the slide, and the reserved prefix keeps it out of the author's namespace.
#let region-group(id) = reserved + "region-" + str(id)

// One rendering of an explicit region, for the view it is handed.
#let render(body, width, height, align, clip, name, view) = {
  if name != none and varies(view.epochs, name) {
    panic(
      "the timeline changes the content of "
        + name
        + " with a structural primitive, but "
        + name
        + " names a region, which only the continuous primitives address; "
        + "tag the content inside the region and change that instead",
    )
  }
  let stable = view.region.stable
  if stable { region-counter.step() }
  context {
    let key = if stable {
      (kind: "region", id: region-counter.get().first())
    } else { view.region.key }
    // Every epoch is laid out with a view of its own, so that the tags in the body resolve
    // their content for that epoch, and learn that a region bounds them.
    //
    // A region with a name carries a display state of its own, so it is one of the tags
    // enclosing what it holds, exactly as a tag site is, and for the same reason.
    // A `move` on the region moves the corner every anchor below it is read from.
    let inside = (key: key, explicit: true, stable: stable)
    let within = if name != none and name in view.continuous {
      view.within + (name,)
    } else { view.within }
    let renderings = range(view.epochs.len()).map(epoch => provide(
      (..view, epoch: epoch, region: inside, within: within),
      body,
    ))
    let container(sized, inner, footprint) = {
      // A region that borrows the key around it is not the region that key names, so it
      // owns no group.
      // The footprint that redraws it is the one it borrowed.
      let group = if not stable { none } else if name == none {
        region-group(key.id)
      } else { name }
      member(view, "region", name, key, group: group)
      let described = [#metadata((
          slide: view.slide,
          name: name,
          region: key,
          epoch: view.epoch,
          ..footprint,
        ))#footprint-label]
      if name == none {
        let body = sized({
          described
          inner
        })
        if group == none { body } else { [#body#label(group)] }
      } else {
        // A region with a name is a site of that name, exactly as a tag is,
        // with the footprint as what its display state moves, scales and hides.
        if view.state == none { site-marker(view, name) }
        let anchor = if view.state != none { anchor-marker(view, name) }
        slots(
          name,
          filling,
          anchor: {
            anchor
            described
          },
          sized(inner),
          display: display-of(name, view),
        )
      }
    }
    block-region(
      renderings,
      view.epoch,
      container,
      width: width,
      height: height,
      align: align,
      clip: clip,
    )
  }
}

#let region(
  body,
  width: auto,
  height: auto,
  align: top,
  clip: auto,
  name: none,
) = {
  if name != none { check-name("a region", name) }
  let what = if name == none { "a region" } else { "the region " + name }
  for (argument, value) in (("width", width), ("height", height)) {
    assert(
      value == auto or type(value) in (length, ratio, relative),
      message: "the "
        + argument
        + " argument of "
        + what
        + " takes auto or a length, got "
        + describe(value),
    )
  }
  assert(
    type(align) == alignment,
    message: "the align argument of "
      + what
      + " takes an alignment, such as top or bottom + center, got "
      + describe(align),
  )
  assert(
    clip == auto or type(clip) == bool,
    message: "the clip argument of "
      + what
      + " takes auto, true or false, got "
      + describe(clip),
  )
  if type(body) != content {
    panic(
      "the body of "
        + what
        + " is not content, but "
        + describe(body)
        + "; a region bounds content, so a stream of draw commands goes inside a canvas "
        + "that the region is put around",
    )
  }
  // A size that is given is a size that a state can exceed, so clipping matters there.
  // A measured footprint fits every state by construction.
  let clip = if clip == auto { width != auto or height != auto } else { clip }
  context ask(what, view => render(
    body,
    width,
    height,
    align,
    clip,
    name,
    view,
  ))
}
