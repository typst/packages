// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// Numbering: what a slide is called, and what one of its subslides is called.
//
// A slide number is a counter and needs nothing else, because it is the same in every
// rendering of the slide, so it is ink in all three output types.
//
// A subslide number differs between the states of one slide, and the cost model decides how
// it is rendered.
// The HTML target lays out one rendering per epoch, and a rendering covers every state that
// shares its content.
// A number baked into a rendering would therefore be one number for a run of subslides,
// and laying out one rendering per state is what the design refuses.
//
// A subslide number uses the mechanism the rest of the package rests on.
// Typst renders every value, and the browser chooses which of them is shown.
// `per-subslide` lays its callback out once per state and puts the renderings in a stack of
// the kind `subslide`, and the runtime shows the rendering of the state it is on.
// `stack.typ` says how a stack agrees with the paged outputs.
//
// The stack holds one rendering per state wherever it sits, so an overlay is the place to
// put it.
// An overlay is one rendering per slide, while a region in the body is one rendering per
// epoch, so a stack in a region is the same content multiplied by the number of epochs.

#import "plan.typ": ask-stack-view, inside
#import "site.typ": describe
#import "stack.typ": block-stack, inline-stack
#import "wrap.typ": literal-wrapper, wrapper-literals

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

/// The number of the slide being laid out, or `none` on a slide that is not counted.
/// Called in a context.
///
/// -> int
#let slide-number() = {
  if numbered-flag.get() { slide-counter.get().first() }
}

/// How many slides of the deck carry a number. Called in a context.
///
/// -> int
#let slide-count() = slide-counter.final().first()

// The subslide info one rendering of a `per-subslide` callback is handed.
//
// `number` and `count` are the state's number within its slide, counted from one, and how
// many states that slide has. `step` and `steps` are the same pair over the whole deck,
// which is what a progress bar that spans the talk needs.
// `handout` is the state's resolved `handout` flag, which is the same in every output type,
// so a rendering can mark a subslide that the handout keeps or leaves out.
#let subslide-info(state, handouts, base, total) = (
  number: state + 1,
  count: handouts.len(),
  step: base + state + 1,
  steps: total,
  handout: handouts.at(state),
)

// The renderings of one `per-subslide` call, one per state of the slide, for the resolved
// `handout` flags of those states.
//
// Must be called in a context, because it reads the deck-wide step counter.
#let renderings-of(f, handouts) = {
  let states = handouts.len()
  // The counter is stepped by the slide before its body is laid out, so what it holds
  // here is the deck up to and including this slide.
  let base = step-counter.get().first() - states
  let total = step-counter.final().first()
  range(states).map(state => {
    let value = f(subslide-info(state, handouts, base, total))
    // `none` is a rendering that lays nothing out, which is what an `if` with no `else`
    // returns.
    // A number worth showing on one subslide is often not worth showing on another,
    // and writing that should not need an empty content block.
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

// What container the renderings of a stack become, as `tag` decides it for a tag site.
//
// The choice is between a stack that hugs and a stack that fills,
// and `auto` measures the first rendering rather than inspecting it,
// for the reason `wrap: auto` measures.
// A stack that fills is what a
// progress bar needs, because a rendering that states a ratio has nothing else to be a
// ratio of, and a stack that hugs is what a number in a line of text needs.
//
// A function and `none` are refused where a tag takes them, because animo creates every stack
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
  let renderings = renderings-of(f, stack-view.handouts)
  // The wrapper is decided from the renderings and never from the state being shown, so
  // that the three output types and all of a slide's states lay out the same, and the
  // widest and tallest rendering is what the stack reserves.
  // The first rendering that lays anything out is what decides the container, since one
  // that lays nothing out says nothing about whether it hugs or fills.
  let first = renderings.find(it => it != none)
  let wrapper = stack-wrapper(wrap, if first == none { [] } else { first })
  if wrapper == box {
    inline-stack("subslide", renderings, stack-view.state)
  } else { block-stack("subslide", renderings, stack-view.state) }
}

/// Content laid out once per subslide, of which the one belonging to the subslide on screen
/// is shown.
///
/// - f (function): Called with `(number:, count:, step:, steps:, handout:)`, the number of
///   the subslide in its slide and in the deck, how many there are, and whether the handout
///   keeps the subslide, and returns content.
/// - wrap (auto, function): The container the stack becomes: `auto`, `box` or `block`.
/// -> content
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
