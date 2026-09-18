// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// Footprints: the box a set of renderings share, and where one of them sits in it.
//
// A footprint is what lets content change while what is around it stays where it is.
// It is the largest extent the renderings take, per axis, and one rendering is laid out
// inside it.
// Every rendering is measured once, which keeps the cost linear in renderings and
// independent of what they hold.
//
// These functions know nothing about tags, regions or subslides.
// A region reserves a footprint over the epochs of a slide, and a stack of one rendering
// per subslide reserves one over the states of a slide, on the same two axes.
// A rendering of `none` lays nothing out and counts as nothing.
//
// Every function here must be called in a context, because it measures.

#import "canvas.typ": unrecorded

// The height of a box that is taller than anything a slide puts on one line.
#let pole-height = 10000pt

// How wide inline content is, and how far it reaches above and below its baseline.
//
// `measure` reports a height and no baseline, so the descent is read off a line that holds
// the content beside a zero-width pole taller than it: such a line is as tall as the pole plus
// the content's descent.
//
// The content is measured inside a box, because a rendering carries the display state of
// its epoch and a `move` is block-level.
// A block-level body pushes the pole onto a line of its own, so the descent read beside it
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
// A rendering is placed instead, which gives the box no baseline of its own, at the height
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

// Where one rendering goes inside such a box: at the height that puts its baseline where
// the tallest one's is.
#let inline-placed(footprint, index, rendering) = place(
  top + left,
  dy: footprint.ascent - footprint.extents.at(index).ascent,
  rendering,
)

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
