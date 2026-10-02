// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// Numbering: what a slide is called, and what one of its subslides is called.
//
// A slide number is a counter and needs nothing else, because it is the same in every
// rendering of the slide, so it is ink in all three output types.
//
// A subslide number differs between the states of one slide, and the cost model decides how
// it is rendered.
// The HTML target renders one frame per epoch, and a frame covers every state that shares
// its content, so a number baked into that frame would be one number for a run of
// subslides, and rendering one frame per state is what the design refuses.
//
// A subslide number uses the mechanism the rest of the package rests on.
// Typst renders every value, and the browser chooses which of them is shown.
// `per-subslide` lays its callback out once per state, stacks the renderings in a container
// with the footprint of the largest, and labels each of them, and the runtime then shows the
// one belonging to the state it is on.
// The paged outputs know their state and lay out that one rendering, in a container of the
// same size, so all three outputs agree to the pixel.
//
// The stack is one rendering per state wherever it sits, so an overlay is the place to put
// it.
// An overlay is one frame per slide, where the body is one frame per epoch, so a number in
// the body is the same content multiplied by the number of epochs.

#import "plan.typ": ask-stack-view, inside
#import "footprint.typ": finite, inline-footprint, inline-placed, measured-at
#import "site.typ": describe, reserved
#import "wrap.typ": filling, literal-wrapper, wrapper-literals

// What `numbered:` counts, and which slide carries a number at all.
//
// The two are one fact read in two places.
// The counter says what the number is, and the flag says whether this slide has one, which
// a counter alone cannot, because a slide that is not counted leaves the counter on the
// number of the slide before it.
#let slide-counter = counter("animo-slide")
#let numbered-flag = state("animo-numbered", true)

// Every state of every slide of the deck, counted over the whole deck.
//
// This is what a progress indicator that spans the talk rather than the slide is measured
// against, so it counts the states a presenter walks through and not the slides that carry
// a number.
#let step-counter = counter("animo-step")

// The number of the slide being laid out, or `none` on a slide that is not counted.
//
// Must be called in a context, because it reads a counter.
#let slide-number() = {
  if numbered-flag.get() { slide-counter.get().first() }
}

// How many slides of the deck carry a number.
//
// Must be called in a context, because it reads a counter.
#let slide-count() = slide-counter.final().first()

// The label of the rendering that belongs to one state of the slide.
//
// The runtime shows the one whose number is the state it is on and hides the others, so
// the number here is the state index, which is what the fragment and `data-animo-states`
// count, rather than the number an author reads.
#let subslide-group(state) = reserved + "subslide-" + str(state)

// The subslide numbers one rendering of a `per-subslide` callback is handed.
//
// `number` and `count` are the state's number within its slide, counted from one, and how
// many states that slide has. `step` and `steps` are the same pair over the whole deck,
// which is what a progress bar that spans the talk needs.
#let subslide-numbers(state, states, base, total) = (
  number: state + 1,
  count: states,
  step: base + state + 1,
  steps: total,
)

// The renderings of one `per-subslide` call, one per state of the slide.
//
// Must be called in a context, because it reads the deck-wide step counter.
#let renderings-of(f, states) = {
  // The counter is stepped by the slide before its body is laid out, so what it holds
  // here is the deck up to and including this slide.
  let base = step-counter.get().first() - states
  let total = step-counter.final().first()
  range(states).map(state => {
    let value = f(subslide-numbers(state, states, base, total))
    // `none` is a rendering that lays nothing out, which is what an `if` with no `else`
    // returns: a number worth showing on one subslide is often not worth showing on
    // another, and writing that should not need an empty content block.
    assert(
      value == none or type(value) == content,
      message: "a per-subslide callback returns content or none, got "
        + describe(value)
        + " for subslide "
        + str(state + 1),
    )
    value
  })
}

// One rendering of the stack, labelled so that the runtime can find it.
//
// A rendering of `none` lays nothing out, not even an empty wrapper, exactly as a tag site
// whose content an epoch removed does.
// There is nothing to show or hide, so the state has no group and the runtime passes over it.
#let labelled(wrapper, state, rendering) = if rendering != none {
  [#wrapper(rendering)#label(subslide-group(state))]
}

// The stack on a line: the footprint an implicit region takes over its epochs, taken over
// the states of the slide instead, with every rendering placed in it.
//
// `shown` is the state to lay out, or `none` for all of them, which is the HTML target.
#let inline-stack(renderings, shown) = {
  let shared = inline-footprint(renderings)
  box(
    width: shared.width,
    height: shared.ascent + shared.descent,
    baseline: shared.descent,
    {
      for (state, rendering) in renderings.enumerate() {
        if shown == none or shown == state {
          inline-placed(shared, state, labelled(box, state, rendering))
        }
      }
    },
  )
}

// The stack between paragraphs: a block as wide as its container and as tall as the
// tallest state laid out at that width.
//
// The width has to come from `layout`, exactly as a region's does, because a rendering
// that states a ratio, which is what a progress bar is, has nothing else to be a ratio of.
#let block-stack(renderings, shown) = layout(size => {
  let width = if finite(size.width) { size.width } else { auto }
  let height = calc.max(
    ..measured-at(renderings, width).map(it => it.height),
  )
  block(
    width: if width == auto { auto } else { 100% },
    height: height,
    {
      for (state, rendering) in renderings.enumerate() {
        if shown == none or shown == state {
          place(top + left, labelled(filling, state, rendering))
        }
      }
    },
  )
})

// What container the renderings of a stack become, as `tag` decides it for a tag site.
//
// The axis is hugging versus filling, and `auto` measures the first rendering rather than
// inspecting it, for the reason `wrap: auto` measures. A stack that fills is what a
// progress bar needs, because a rendering that states a ratio has nothing else to be a
// ratio of, and a stack that hugs is what a number in a line of text needs.
//
// A function and `none` are refused where a tag takes them, because a stack is animo's own
// container and every rendering in it has to become a group the runtime can address.
//
// Must be called in a context, because `auto` measures.
#let stack-wrapper(wrap, first) = {
  if wrap not in wrapper-literals {
    panic(
      "the wrap argument of per-subslide takes auto, box or block, got "
        + describe(wrap),
    )
  }
  literal-wrapper(wrap, first)
}

// One rendering of a `per-subslide` call, for the stack view it is handed.
//
// `stack-view.state` is the state to lay out and is `none` in the HTML target, where one
// frame covers a run of states and the browser is what chooses between the renderings.
#let render(f, wrap, stack-view) = context {
  let renderings = renderings-of(f, stack-view.states)
  // The wrapper is decided from the renderings and never from the state being shown, so
  // that the three output types and all of a slide's states lay out the same, and the
  // widest and tallest rendering is what the stack reserves.
  // The first rendering that lays anything out is what decides the container, since one
  // that lays nothing out says nothing about whether it hugs or fills.
  let first = renderings.find(it => it != none)
  let wrapper = stack-wrapper(wrap, if first == none { [] } else { first })
  if wrapper == box { inline-stack(renderings, stack-view.state) } else {
    block-stack(renderings, stack-view.state)
  }
}

#let per-subslide(f, wrap: auto) = {
  assert(
    type(f) == function,
    message: "per-subslide takes a function of one argument, got "
      + describe(f),
  )
  context {
    assert(
      inside.get(),
      message: "per-subslide is not inside a #slide, so there is no slide whose "
        + "subslides it could be laid out for",
    )
    ask-stack-view(stack-view => render(f, wrap, stack-view))
  }
}
