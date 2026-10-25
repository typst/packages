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
// The HTML target lays the body of a slide out once, so a region there is where the epochs
// of the slide differ.
// Such a region places an epoch stack in its footprint, one rendering per epoch,
// and the browser shows one of them at a time.
// Only a region that sits in no other region places a stack,
// because the renderings of a stack are laid out once per epoch already,
// and a region inside one lays out the epoch of its rendering.
// A page lays out the epoch of the state it shows, so a region on paper lays out that epoch alone.
//
// A region between paragraphs is shaped by `block-region` below, which receives one
// rendering per epoch, `none` for an epoch with nothing to lay out, and a function that
// builds the container, and which knows nothing about tags.
// An explicit region and a tag that forms an implicit region therefore share one measurement.
// A tag forms an implicit region when its content changes and no explicit region holds it.
// Such a tag on a line is an `inline-stack` of `stack.typ`, and `stack.typ` also measures the
// box a region reserves.
//
// `block-region` must be called in a context, because it measures.

#import "canvas.typ": anchor-marker, site-marker
#import "stack.typ": finite, measured-at, placed-blocks
#import "member.typ": member
#import "plan.typ": ask, provide, varies
#import "site.typ": (
  check-container-child, check-name, describe, display-of, reserved,
)
#import "wrap.typ": filling, slots

// The label every footprint carries, so that it can be read back.
#let footprint-label = label("animo-footprint")

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
// `stacked` places every rendering as an epoch stack rather than laying out the one of
// `epoch`, and a rendering that is aligned is placed in a block that fills the footprint,
// which is what it is aligned in.
#let block-region(
  renderings,
  epoch,
  container,
  width: auto,
  height: auto,
  align: none,
  clip: false,
  stacked: false,
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
    if stacked and align == none {
      placed-blocks("epoch", renderings, none)
    } else if stacked {
      placed-blocks(
        "epoch",
        renderings.map(it => if it != none { std.align(align, it) }),
        none,
        wrapper: block.with(width: 100%, height: 100%),
      )
    } else if align == none or current == none { current } else {
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

// How many regions come before a region inside the rendering of an epoch stack, counting
// itself.
//
// The renderings of a stack are laid out one after the other, and a region inside them has to
// take the number it takes on paper, where one rendering is laid out, and count once.
// A region inside a stack therefore counts on this counter,
// which every rendering sets back to zero,
// and its number is that of the region holding the stack plus this count.
// Only the first rendering steps `region-counter` as well, which leaves it where a single
// rendering would, for the regions after the stack.
// Every update of both counters is a constant or a step and none is a value read back from a
// counter, so the numbers settle in one pass of layout whatever the number of regions.
// The key built from a number goes into the view a region hands its body, however,
// and the context blocks of a region inside it capture that view,
// so every level of nesting costs a pass of layout (see *Findings*).
// Measured on typst 0.15.0, three nested regions converge and four do not.
#let stacked-counter = counter("animo-region-stacked")

// The label that the group of an unnamed region carries in the output.
//
// A region the timeline never addresses still has to be addressable by the runtime, because
// it holds the epoch stack that a boundary crossfades, and only a labelled box or block becomes
// a group at all. The number belongs to the region, so the label is the same in every output
// type, and the reserved prefix keeps it out of the author's namespace.
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
  let numbering = view.numbering
  if stable {
    if numbering == none { region-counter.step() } else {
      stacked-counter.step()
      if numbering.counts { region-counter.step() }
    }
  }
  context {
    let key = if not stable { view.region.key } else if numbering == none {
      (kind: "region", id: region-counter.get().first())
    } else {
      (kind: "region", id: numbering.base + stacked-counter.get().first())
    }
    // Every epoch is laid out with a separate view, so that the tags in the body resolve
    // their content for that epoch, and learn that a region bounds them.
    //
    // A region with a name carries a display state, so it is one of the tags
    // enclosing what it holds, exactly as a tag site is, and for the same reason.
    // A `move` on the region moves the corner every anchor below it is read from.
    let inside = (key: key, explicit: true, stable: stable)
    let within = if name != none and name in view.continuous {
      view.within + (name,)
    } else { view.within }
    let stacked = view.stack and view.epochs.len() > 1
    let renderings = range(view.epochs.len()).map(epoch => {
      if stacked { stacked-counter.update(0) }
      provide(
        (
          ..view,
          epoch: epoch,
          region: inside,
          within: within,
          stack: false,
          numbering: if stacked and stable {
            (base: key.id, counts: epoch == 0)
          } else { numbering },
        ),
        body,
      )
    })
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
      stacked: stacked,
    )
  }
}

/// An area laid out afresh whenever its content changes, inside a footprint that never
/// changes.
///
/// - body (content): What is laid out afresh.
/// - width (auto, length, ratio): The width of the footprint, measured when `auto`.
/// - height (auto, length, ratio): The height of the footprint, measured when `auto`.
/// - align (alignment): Where a state smaller than the footprint sits.
/// - clip (auto, bool): Whether the footprint clips, which is `true` when a size is given.
/// - name (none, str): Makes the footprint a site the continuous primitives reach.
/// -> content
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
  check-container-child(
    what,
    body,
    "region[..]",
    "region(block(fill: .., width: 100%, height: 100%)[..])",
  )
  // A size that is given is a size that a state can exceed, so clipping matters there.
  // A measured footprint fits every state by construction.
  let clip = if clip == auto { width != auto or height != auto } else { clip }
  ask(what, view => render(
    body,
    width,
    height,
    align,
    clip,
    name,
    view,
  ))
}
