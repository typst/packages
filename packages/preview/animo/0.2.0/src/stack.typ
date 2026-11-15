// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// Footprints and stacks: the box a set of renderings share, and the renderings placed in it.
//
// A footprint is what lets content change while what is around it stays where it is.
// It is the largest extent the renderings take, per axis.
// Every rendering is measured once, which keeps the cost linear in renderings and
// independent of what they hold.
// A rendering of `none` lays nothing out and counts as nothing.
//
// A stack places its renderings at one point inside their footprint, and the runtime shows
// one of them at a time.
// Typst renders every alternative and the browser chooses which of them is shown.
// A stack in the HTML target places every rendering the browser chooses between.
// A paged output knows the state of its page, so a stack there places the one rendering of
// that state in a footprint of the same size, and all three outputs agree to the pixel.
// A page lays out the epoch of its state on its own, so an epoch stack exists only in the
// HTML target.
//
// Each rendering of a stack carries the label `animo-<kind>-<index>`, so that the runtime
// finds it and knows what selects it.
// The kind says what the index counts.
// An `epoch` stack holds one rendering of a region per content state of the slide, and a
// `subslide` stack holds one rendering of a `per-subslide` per state of the slide.
// The runtime reads the renderings of a stack from the children of one group, so the
// renderings of one stack are siblings and every stack has a separate container.
// A rendering of `none` is not placed, exactly as a tag site whose content an epoch removed
// lays out nothing.
//
// An explicit region reserves its footprint with the measurements below as well.
// It places its epoch stack with `placed-blocks` in the HTML target, and on paper it lays the
// rendering of its epoch out in the footprint rather than placing it.
// Every function here must be called in a context, because it measures.

#import "canvas.typ": unrecorded
#import "site.typ": reserved
#import "wrap.typ": filling

// The height of a box that is taller than anything a slide puts on one line.
#let pole-height = 10000pt

// How wide inline content is, and how far it reaches above and below its baseline.
//
// `measure` reports a height and no baseline, so the descent is read off a line that holds
// the content beside a zero-width pole taller than the content.
// Such a line is as tall as the pole plus the content's descent.
//
// The content is measured inside a box, because a rendering carries the display state of
// its epoch and a `move` is block-level.
// A block-level body pushes the pole onto a separate line, so the descent read beside it
// covers a whole line and the ascent turns negative.
// The box is also the slot the rendering sits in on the page, so what is measured is what
// the line gives it.
#let inline-extent(body) = {
  if body == none { return (width: 0pt, ascent: 0pt, descent: 0pt) }
  let body = box(unrecorded(body))
  let whole = measure(body)
  let descent = (
    measure([#body#box(width: 0pt, height: pole-height)]).height - pole-height
  )
  (width: whole.width, ascent: whole.height - descent, descent: descent)
}

// The box a set of inline renderings share: the widest width and the tallest ascent plus
// the deepest descent over them, beside the extent of each.
//
// A box takes its baseline from the first line of its content even at a fixed size, so a
// fixed box alone still moves its line when one rendering's first line is taller, or when
// a rendering lays out nothing at all (measured on typst 0.15.0; see *Findings*).
// A rendering is placed instead, which gives the box no baseline, at the height
// that puts its baseline where the tallest one's is, and the box is lowered by the deepest
// descent.
#let inline-footprint(renderings) = {
  let extents = renderings.map(inline-extent)
  (
    extents: extents,
    width: calc.max(..extents.map(it => it.width)),
    ascent: calc.max(..extents.map(it => it.ascent)),
    descent: calc.max(..extents.map(it => it.descent)),
  )
}

// Whether a length that `layout` handed over is a real one.
//
// Inside a `measure` without a width, `layout` reports an infinite size
// (measured on typst 0.15.0), and a footprint cannot take that size.
#let finite(length) = length.pt() != float.inf

// What each rendering measures at one width, with a rendering of `none` counted as nothing.
#let measured-at(renderings, width) = renderings.map(it => {
  if it == none { (width: 0pt, height: 0pt) } else {
    measure(unrecorded(it), width: width)
  }
})

// The label of the rendering at `index` of a stack of `kind`.
#let stack-label(kind, index) = label(reserved + kind + "-" + str(index))

// The renderings a stack places, as `(index, rendering)` pairs.
//
// `shown` is the index of the one rendering to place, or `none` for all of them, which is
// the HTML target.
#let placed(renderings, shown) = (
  renderings
    .enumerate()
    .filter(((index, rendering)) => (
      rendering != none and (shown == none or shown == index)
    ))
)

// One rendering, in the wrapper that makes it a group in the output.
//
// A `kind` of `none` places the rendering as it is, unlabelled, for a stack that places one
// rendering in every output type.
// That is the implicit region of a tag on paper, and one inside the rendering of an epoch
// stack, which is laid out once per epoch already.
#let labelled(kind, wrapper, index, rendering) = {
  if kind == none { rendering } else {
    [#wrapper(rendering)#stack-label(kind, index)]
  }
}

// A stack on a line, in the box `inline-footprint` measures, with its baseline pinned.
//
// Each rendering is placed at the height that puts its baseline where the tallest one's is,
// because a box takes its baseline from the first line of its content even at a fixed
// size (see `inline-footprint`).
//
// `container(sized, inner, footprint)` builds the stack from the sized box function, the
// placed renderings and a description of the footprint, which an implicit region reports.
#let inline-stack(
  kind,
  renderings,
  shown,
  container: (sized, inner, footprint) => sized(inner),
) = {
  let shared = inline-footprint(renderings)
  let height = shared.ascent + shared.descent
  container(
    box.with(width: shared.width, height: height, baseline: shared.descent),
    for (index, rendering) in placed(renderings, shown) {
      place(
        top + left,
        dy: shared.ascent - shared.extents.at(index).ascent,
        labelled(kind, box, index, rendering),
      )
    },
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

// The renderings of a stack between paragraphs, each placed at the top left corner of the
// block that holds them.
//
// `wrapper` is the labelled container of a rendering, which fills the width of the block.
// A region that aligns its renderings needs one as tall as the block as well.
#let placed-blocks(kind, renderings, shown, wrapper: filling) = {
  for (index, rendering) in placed(renderings, shown) {
    place(top + left, labelled(kind, wrapper, index, rendering))
  }
}

// A stack between paragraphs: a block as wide as its container and as tall as the tallest
// rendering laid out at that width.
//
// The width has to come from `layout`, exactly as a region's does, because a rendering that
// states a ratio, which is what a progress bar is, has nothing else to be a ratio of.
#let block-stack(kind, renderings, shown) = layout(size => {
  let width = if finite(size.width) { size.width } else { auto }
  block(
    width: if width == auto { auto } else { 100% },
    height: calc.max(..measured-at(renderings, width).map(it => it.height)),
    placed-blocks(kind, renderings, shown),
  )
})
