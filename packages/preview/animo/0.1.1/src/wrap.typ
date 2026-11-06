// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// What container a tag site becomes.
//
// A tag has to wrap its body, because only a labelled `box` or `block` becomes a
// `<g data-typst-label>` in the SVG output, and that group is what the browser addresses.
// The wrapper is decided from the body alone and never from the timeline,
// so that adding an animation step cannot reflow a paragraph,
// and so that the three output types and all of a slide's states lay out the same.
//
// The axis that decides the wrapper is hugging versus filling.
// A `box` and a `block` render identically for content that already sits between paragraph
// breaks, while a wrapper at `width: auto` left-aligns whatever the container was centring,
// so the two candidates are `box` and `block(width: 100%)`.
// See *Findings* in the design document.

#import "site.typ": at-rest, describe, displayed

// The wrapper that fills its container, which is what keeps centred content centred.
#let filling = block.with(width: 100%)

// A neighbour with no size of its own, which `breaks-the-line` puts beside a body.
#let nothing = box(width: 0pt, height: 0pt)

// Look through the `styled` elements a `set` rule or a `text(..)` call wraps content in.
#let peel(value) = {
  while type(value) == content and repr(value.func()) == "styled" {
    value = value.child
  }
  value
}

// Whether content pushes a neighbour onto a line of its own.
//
// This is the decision procedure for `wrap: auto`.
// It measures rather than inspecting element kinds, because a `context` block reports
// nothing about what it will produce and `measure` lays it out.
// Over the constructs a slide is likely to hold, the separation is exactly zero for every
// inline body and at least twelve points for every block-level one,
// so the comparison needs no tolerance.
// The comparison needs no available width either, because an unbounded `measure` resolves
// a `100%` width to zero rather than to infinity.
//
// Must be called in a context.
#let breaks-the-line(body) = {
  measure([#nothing#body#nothing]).height > measure(body).height
}

// Whether content is itself several paragraphs.
//
// The measurement in `breaks-the-line` misses this case.
// The neighbours merge into the first and the last paragraph instead of being pushed off,
// so such a body measures as inline.
// The children of the body are read instead.
#let several-paragraphs(body) = {
  let inner = peel(body)
  (
    repr(inner.func()) == "sequence"
      and inner.children.any(child => child.func() == parbreak)
  )
}

// The wrapper `auto` chooses for content: the filling block for content that pushes a
// neighbour onto a line of its own, and a box for content that does not.
//
// Must be called in a context, because it measures.
#let wrapper-for(body) = {
  if breaks-the-line(body) or several-paragraphs(body) { filling } else { box }
}

// The three values a `wrap` argument may state outright.
//
// A tag site takes more than these and a stack of one rendering per subslide takes exactly
// these, so each caller refuses what is left in its own words.
#let wrapper-literals = (auto, box, block)

// The wrapper one of those three asks for.
//
// `block` becomes the filling block rather than a plain one, which is what keeps centred
// content centred, and `auto` measures the body.
//
// Must be called in a context, because `auto` measures.
#let literal-wrapper(wrap, body) = {
  if wrap == auto { wrapper-for(body) } else if wrap == box { box } else {
    filling
  }
}

// The wrapper of one tag site, as a function from the inner content to the inner slot.
//
// `none` is the answer for a tag site that becomes no container at all, which a tag asks
// for when the timeline only ever addresses it structurally.
// Without a label there is no group, and the continuous primitives have nothing to animate.
//
// A function is a wrapper the author wrote, and it is taken as it is.
//
// Must be called in a context, because `auto` measures.
#let choose-wrapper(name, body, wrap) = {
  if wrap == none {
    none
  } else if wrap in wrapper-literals {
    literal-wrapper(wrap, body)
  } else if type(wrap) == function {
    wrap
  } else {
    panic(
      "the wrap argument of the tag "
        + name
        + " takes auto, box, block, none or a function, got "
        + describe(wrap),
    )
  }
}

// The outer wrapper that matches an inner slot: `box` for a box, and the filling block for
// a block.
//
// The kind of the outer slot follows the inner one, which is how a `wrap` function that
// carries ink of its own keeps the outer wrapper from changing the layout it chose.
// The kind is a property of the wrapper rather than of what it holds,
// so it is read from the wrapper with nothing inside.
#let outer-of(name, wrapper) = {
  let kind = peel(wrapper([])).func()
  if kind == box {
    box
  } else if kind == block {
    filling
  } else {
    panic(
      "the wrap function of the tag "
        + name
        + " produced a "
        + repr(kind)
        + "; a tag site has to be a box or a block, "
        + "because nothing else becomes an addressable group in the output",
    )
  }
}

// The two nested slots of a tag site, with the label on the outer one.
//
// Continuous state and boundary state each get a slot of their own, because CSS gives an
// element one `translate` and one `scale` and the two classes would clobber each other.
// The labelled outer group is the boundary slot, since a boundary effect is measured in
// the frame's own coordinates and has to sit above the continuous transforms.
//
// `display` is the display state of the rendering, and it goes around the wrapper rather
// than inside it.
// A `move` is an inline element, and a block-level body inside one is laid out in a
// paragraph, where the filling block that a centring container needs no longer fills.
// Putting the display state outside the wrapper also matches the HTML target, where the
// runtime sets the CSS transform on the group rather than on something inside it.
// See *Findings*.
//
// `anchor` is content that takes no room, put first inside the outer slot, so that it
// shares the slot's top-left corner without being moved by the tag's own display state.
#let slots(name, wrapper, payload, anchor: none, display: at-rest) = {
  [#outer-of(name, wrapper)({
      anchor
      displayed(display, wrapper(payload))
    })#label(name)]
}
