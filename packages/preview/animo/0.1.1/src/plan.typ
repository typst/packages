// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// The plan of a slide: what its timeline resolves to, and how that result reaches its tags.
//
// A slide with S `sub` calls has S+1 states.
// State 0 is the body as declared, in the initial state the timeline gives it, and state i
// is state i-1 with the i-th step applied.
// Each step modifies the state of what it addresses.
// `reveal` and `hide` set the visibility, `scale` sets the factor of the axes it names,
// and `move` sets the position of the axes it names, where a `dx` adds to the offset it
// found there.
//
// A state keeps the slide's own state apart from the state of its tags,
// because a slide primitive touches no tag, and a tag primitive no viewport.
//
// The result is *provided* to the body, not published to a state.
// A state cannot carry a value that has to vary inside `measure`,
// because `state.get()` there resolves at the location of the enclosing context block,
// and varying a value inside `measure` is exactly what a region has to do
// to size its footprint over its epochs.
// A marker element plus a show rule does reach inside `measure`, providers nest with the
// innermost winning, and the marker's own label does not reach the output.
// See *Findings* in the design document.

#import "anim.typ": (
  check-timeline, continuous-kinds, slide-kinds, structural-kinds,
)

// A position, per axis, as an anchor and an offset from it.
//
// An axis is a pair rather than a length, because the anchor of a `relto` is a tag's
// position, which only a rendering knows: typst on paper and the browser in the HTML
// target. The resolver keeps the two apart so that each target adds the anchor it
// measured, and a `dx` after a `relto` keeps the anchor it moves from.
//
// A target reads the pair as `anchor(relto) + offset - anchor(self)`, where `anchor(none)`
// is the canvas origin. For a `pan`, `anchor(self)` is the canvas origin too, so the pair
// is where the viewport goes. For a `move`, `anchor(self)` is the moved tag's own anchor,
// so a pair whose `relto` is the tag's own name is the identity, whatever that anchor
// turns out to be.
#let at(relto) = (
  x: (relto: relto, offset: 0pt),
  y: (relto: relto, offset: 0pt),
)

// The position of the viewport before anything has panned it: the canvas origin.
#let unpanned = at(none)

// A position after one operation that says where something goes, one axis at a time.
//
// `move` and `pan` differ in what their anchors mean and in nothing else, so both resolve
// their axes here: `x` sets the anchor and the offset, `dx` adds to the offset and keeps
// the anchor it moves from, an axis the call says nothing about keeps the pair it had, and
// `relto` alone sends both axes to the anchor.
#let apply-position(position, op) = {
  for (axis, absolute, relative) in (("x", op.x, op.dx), ("y", op.y, op.dy)) {
    let current = position.at(axis)
    position.insert(axis, if absolute != none {
      (relto: op.relto, offset: absolute)
    } else if relative != none {
      (..current, offset: current.offset + relative)
    } else if op.relto != none {
      (relto: op.relto, offset: 0pt)
    } else {
      current
    })
  }
  position
}

// The display state of a tag that nothing has addressed yet: visible, where the body put
// it, at its own size.
//
// The position is the tag's own anchor at offset zero, which is why this function takes the
// name.
// A target subtracts the tag's own anchor from every position it resolves, so the default
// has to be the one pair that cancels against it.
#let identity(name) = (hidden: false, ..at(name), scale: (x: 1.0, y: 1.0))

// Which property of a tag's display state each continuous operation writes.
//
// That property is what the browser animates, so a delay belongs to it.
// Two operations of one step on one tag may start at different moments, and an effect has
// one delay, so the step becomes as many effects as it has moments.
//
// This is the closest thing to a register of the display state, and a property added to it
// has to be added in seven more places: `identity` and `apply-op` here, `at-rest` and
// `displayed` in `site.typ`, `tags-of` in `runtime.typ`, and `declarations` and `showing`
// in `animo.js`.
#let property-of = (
  reveal: "opacity",
  hide: "opacity",
  move: "translate",
  scale: "scale",
)

// The timing of a step that holds no operation: nothing is held back and nothing is panned.
#let untimed = (tags: (:), pan: none)

// How long a step lasts in full, as the two numbers the browser adds up.
//
// A backward step is the forward one mirrored in time, so it needs the length of the step
// it undoes.
// That length is the last moment any of the step's operations reaches, which is the largest
// `delay + duration` over all of them, the pan and the structural ones included.
// Half of that sum can be missing here, because the duration of an operation that stated
// none is the deck's own and lives in a stylesheet the resolver cannot read.
// The two kinds are therefore kept apart and the browser adds the number it has to each.
// `stated` is the largest end over the operations that stated a duration, and `unstated`
// the largest delay over the operations that did not.
// Either is `none` when the step holds no operation of that kind, so a step that holds no
// operation at all is `none` twice.
#let span-of(ops) = {
  let stated = none
  let unstated = none
  for op in ops {
    let (delay, duration) = op.timing
    if duration == auto {
      unstated = if unstated == none { delay } else {
        calc.max(unstated, delay)
      }
    } else {
      let end = delay + duration
      stated = if stated == none { end } else { calc.max(stated, end) }
    }
  }
  (stated: stated, unstated: unstated)
}

// The length of a step that holds no operation.
#let unspanned = (stated: none, unstated: none)

// The timing of one step after one continuous operation.
//
// The last operation on a property wins, exactly as its value does.
// A step modifies what it addresses, and the timing is part of what it wrote.
#let note-timing(timing, op) = {
  let current = timing.tags.at(op.name, default: (:))
  current.insert(property-of.at(op.kind), op.timing)
  timing.tags.insert(op.name, current)
  timing
}

// The display state of one tag after one operation.
#let apply-op(display, op) = {
  let current = display.at(op.name, default: identity(op.name))
  display.insert(
    op.name,
    if op.kind == "reveal" {
      (..current, hidden: false)
    } else if op.kind == "hide" {
      (..current, hidden: true)
    } else if op.kind == "move" {
      (:..current, ..apply-position((x: current.x, y: current.y), op))
    } else if op.kind == "scale" {
      // A factor is set rather than multiplied into what is there, and an axis the call
      // omits keeps the factor it had.
      (
        ..current,
        scale: (
          x: if op.fx == none { current.scale.x } else { op.fx },
          y: if op.fy == none { current.scale.y } else { op.fy },
        ),
      )
    } else {
      panic("the resolver does not know the operation " + repr(op.kind))
    },
  )
  display
}

// The content state of a tag that no structural operation has addressed yet: its body, as
// the body declares it, with no wrappers around it.
//
// The other sources are `"replacement"`, with the content in `body`, and `"removed"`.
#let pristine = (source: "body", body: none, wrappers: ())

// The content state of one tag after one structural operation.
//
// What is laid out and the wrappers around it are two slots that do not know about each
// other, so that a restyling survives a replacement and a replacement arrives restyled.
// `reset` is the one operation that sets both.
#let apply-structural(content, op) = {
  let current = content.at(op.name, default: pristine)
  content.insert(
    op.name,
    if op.kind == "replace" {
      (..current, source: "replacement", body: op.body)
    } else if op.kind == "remove" {
      (..current, source: "removed", body: none)
    } else if op.kind == "apply" {
      (..current, wrappers: current.wrappers + op.fns)
    } else if op.kind == "reset" {
      (source: "body", body: none, wrappers: ())
    } else {
      panic("the resolver does not know the operation " + repr(op.kind))
    },
  )
  content
}

// How a state's `wait:` or `hold:` is written, for a message that names both sides of a
// gap that two numbers claim.
//
// State 0 has no `sub`, so its two numbers are `#slide`'s own, and every later state is
// the step of the `sub` with that index.
#let gap-site(state, what) = if state == 0 {
  "slide(" + what + ": ..)"
} else {
  "sub " + str(state) + "'s " + what + ":"
}

// Refuse a gap that both of its neighbours time.
//
// A gap elapses once, so there is nothing for a precedence rule to pick between.
// Two operations that disagree about a `delay:` in one region are refused for the same
// reason.
// Two numbers on one gap are two answers to one question rather than two parts of one
// duration, so summing them would produce a length that neither of them states.
#let check-gaps(states) = {
  for (index, state) in states.enumerate() {
    if index == 0 { continue }
    let before = states.at(index - 1)
    assert(
      before.hold == none or state.wait == none,
      message: "the gap before state "
        + str(index)
        + " of this slide is timed twice, by "
        + gap-site(index - 1, "hold")
        + " and by "
        + gap-site(index, "wait")
        + "; one gap takes one number, so keep whichever of the two reads better "
        + "where it stands and drop the other",
    )
  }
}

// The initial state of a slide, read from its timeline.
//
// A name whose first display operation is `reveal` starts hidden, and one whose first
// content operation is `reset` starts removed. Nothing can usefully start hidden without a
// `reveal` somewhere, nor removed without a `reset`, so the timeline already says which
// tags those are and a tag site does not repeat it.
//
// The two slots are read independently, so a name may start hidden, removed, both or
// neither, and a name that neither operation addresses first is absent from both
// dictionaries, which leaves it visible and laid out as the body wrote it.
//
// A `reveal` on a name that nothing hides therefore makes that name start hidden, where it
// would otherwise change nothing, so `reveal` and `reset` are not pure undos.
// No timeline is refused over it, because every timeline has a reading.
#let initial(steps) = {
  let display = (:)
  let content = (:)
  let addressed = (display: (), content: ())
  for step in steps {
    for op in step.ops {
      if op.kind in slide-kinds { continue }
      let slot = if op.kind in structural-kinds { "content" } else { "display" }
      if op.name in addressed.at(slot) { continue }
      addressed.insert(slot, addressed.at(slot) + (op.name,))
      if op.kind == "reveal" {
        display.insert(op.name, (..identity(op.name), hidden: true))
      } else if op.kind == "reset" {
        content.insert(op.name, (..pristine, source: "removed"))
      }
    }
  }
  (display: display, content: content)
}

// Resolve a timeline into the per-state display state and the per-epoch content state of a
// slide.
//
// An epoch is a maximal run of consecutive states with the same content state, and a new one
// starts at every state whose step holds a structural operation.
// So a slide with no structural operation has exactly one epoch, and nothing is measured
// more than once for it.
//
// A state holds `display`, the state of the tags keyed by name, `slide`, the state of the
// slide, the index of its `epoch`, its resolved `handout` flag, the `wait` before it is
// entered, the `hold` before the state after it is, the `timing` of the operations its
// own step performed and the `span` of that step.
// An epoch holds `tags`, the content state of every tag a structural operation has addressed
// so far, keyed by name, `changed`, the names its first step addressed, which are the
// implicit regions whose content changes at the boundary that starts it, and `timings`, the
// timing of every operation that changed each of those names.
// Operations are applied in the order they are written, within a step as well as across steps.
//
// The plan carries the `steps` it was resolved from, so that what the timeline asks of the
// tag sites is read off the plan rather than by checking and walking the timeline a second
// time.
//
// `handout`, `wait` and `hold` are the flags of state 0, which are `#slide(handout: ..)`,
// `#slide(wait: ..)` and `#slide(hold: ..)`: every state carries all three, and the
// initial state has no `sub` to write any of them on.
//
// `wait` times the gap before a state and `hold` the gap after it, so every gap inside a
// slide is named by two states and may be timed by at most one of them.
//
// A state's `timing` is the timing of the step that *enters* it, and its `span` is how long
// that step lasts in full, which is what a backward step mirrors its operations about.
// A step walked backwards therefore reads both off the state it leaves.
// State 0 is entered by no step, and is untimed and unspanned.
#let resolve(animation, handout: auto, wait: none, hold: none) = {
  let steps = check-timeline(animation)
  // State 0 is resolved from the timeline like every other state, out of which operation
  // addresses each name first, so nothing about it is read at a tag site.
  let start = initial(steps)
  let display = start.display
  let content = start.content
  let slide = (pan: unpanned)
  let epochs = ((tags: content, changed: (), timings: (:)),)
  let states = (
    (
      display: display,
      slide: slide,
      epoch: 0,
      handout: handout,
      wait: wait,
      hold: hold,
      timing: untimed,
      span: unspanned,
    ),
  )
  for step in steps {
    let changed = ()
    let timings = (:)
    let timing = untimed
    for op in step.ops {
      if op.kind in slide-kinds {
        slide.pan = apply-position(slide.pan, op)
        timing.pan = op.timing
      } else if op.kind in structural-kinds {
        content = apply-structural(content, op)
        if op.name not in changed { changed.push(op.name) }
        timings.insert(op.name, timings.at(op.name, default: ()) + (op.timing,))
      } else {
        display = apply-op(display, op)
        timing = note-timing(timing, op)
      }
    }
    if changed.len() > 0 {
      epochs.push((tags: content, changed: changed.sorted(), timings: timings))
    }
    states.push((
      display: display,
      slide: slide,
      epoch: epochs.len() - 1,
      handout: step.handout,
      wait: step.wait,
      hold: step.hold,
      timing: timing,
      span: span-of(step.ops),
    ))
  }
  // `handout: auto` asks for the page the handout shows anyway, which is the final state,
  // so a timeline that says nothing about the handout gets one page per slide.
  // Stating `true` or `false` overrides it in either direction,
  // including a final state the author would rather not hand out.
  //
  // State 0 goes through the same rule rather than through a case of its own, which is what
  // makes a slide with no `sub` at all work: its only state is also its last one, so `auto`
  // keeps it and `#slide(handout: false)` leaves the slide out of the handout.
  let last = states.len() - 1
  check-gaps(states)
  (
    states: states
      .enumerate()
      .map(((index, state)) => (
        ..state,
        handout: if state.handout == auto { index == last } else {
          state.handout
        },
      )),
    epochs: epochs,
    steps: steps,
  )
}

// Whether the content state of a tag differs between the epochs of a resolved plan.
//
// Only such a tag needs a footprint. A tag whose content never changes lays out the same
// in every epoch by itself, and measuring it would cost a layout per epoch for nothing.
// The content state is carried forward from the first operation on, so the last epoch holds
// every name that was ever addressed.
#let varies(epochs, name) = epochs.len() > 1 and name in epochs.last().tags

// The tags whose anchor a paged rendering has to read, as a sorted array of names.
//
// A position is `anchor(relto) + offset - anchor(self)`, so a pair that names the tag's own
// anchor needs no anchor at all, because the two terms cancel whatever it is.
// Reading only the anchors that are needed keeps a slide whose tags merely appear from
// querying for every one of them, because every state of the plan holds every addressed tag.
#let anchor-names(plan) = {
  let names = ()
  for state in plan.states {
    let positions = ((state.slide.pan, none),)
    for (name, display) in state.display {
      positions.push((display, name))
    }
    for (position, self) in positions {
      for axis in (position.x, position.y) {
        if axis.relto == self { continue }
        for name in (axis.relto, self) {
          if name != none and name not in names { names.push(name) }
        }
      }
    }
  }
  names.sorted()
}

// What the timeline asks of the tag sites of its slide, as four sets of names.
//
// `names` is every name a continuous primitive addresses, anywhere.
// A tag has to know this in every state, and not only in the state that moves it,
// because a tag site that cannot be animated at all has to say so at the first
// opportunity rather than in the state where the browser would silently do nothing.
// The tag a `pan` is relative to counts as addressed, since `pan` is a continuous
// primitive too: its position is read off the tag's group, and a tag with no group has
// no position for a browser to read.
//
// `targets` is every tag the timeline is relative to, as `(kind:, relto:)` pairs in the
// order written. The kind is what a refusal names, because "a pan relative to a tag the
// slide does not have" and the same sentence about a move are two different mistakes to make.
//
// `anchored` is every tag whose anchor a paged rendering has to read, which follows from the
// resolved plan rather than from the timeline.
//
// `transformed` is every tag the timeline moves or scales, anywhere.
// These are the tags whose display state moves what is laid out inside them, so they put
// the anchor of a tag below them out of reach.
// An anchor is the corner the body gave a tag, and a rendering that shows the enclosing tag
// transformed reports another corner.
// `reveal` and `hide` are not among them, because typst's `hide` lays content out as it is.
#let timeline-asks(plan) = {
  let names = ()
  let targets = ()
  let transformed = ()
  for step in plan.steps {
    for op in step.ops {
      if op.kind in continuous-kinds and op.name not in names {
        names.push(op.name)
      }
      if op.kind in ("move", "scale") and op.name not in transformed {
        transformed.push(op.name)
      }
      let relto = op.at("relto", default: none)
      if relto != none {
        if relto not in names { names.push(relto) }
        let target = (kind: op.kind, relto: relto)
        if target not in targets { targets.push(target) }
      }
    }
  }
  (
    names: names.sorted(),
    targets: targets,
    anchored: anchor-names(plan),
    transformed: transformed.sorted(),
  )
}

// Where the body of a slide sits: in no region at all.
//
// `key` identifies the nearest region whose footprint is the same in every epoch, which is
// the area a change of content inside it is confined to: `(kind: "region", id: ..)` for an
// explicit region, numbered in document order within one rendering of the slide, and
// `(kind: "tag", name: ..)` for the implicit region of a tag whose content changes.
// `explicit` says whether an explicit region bounds the content, in which case a tag inside
// it reserves no footprint of its own and its changes reflow the region.
// `stable` says whether the content is laid out in every epoch, which an explicit region
// needs to know before it takes a number.
// A region inside content that changes would shift the numbers of every region after it
// between epochs, so it takes no number and borrows the key around it, whose footprint
// contains it anyway.
#let outermost = (key: none, explicit: false, stable: true)

// What a tag site is handed: everything about the rendering it is part of.
//
// `slide` is the position of the slide in the deck.
// A tag needs it to report anything back out of the frame it sits in,
// because introspection is document-wide and a tag name means nothing outside its slide.
//
// `states` is how many states the slide has, which is what a stack of one rendering per
// state is built from. It is a property of the slide rather than of the rendering, so it
// is the same in every view of one slide, the HTML one included.
//
// `epochs` is the content state of every epoch and not only of the rendered one, because a
// tag whose content changes reserves the largest extent over all of them.
// `epoch` is the one to lay out, and a region measures another epoch by providing a copy of
// the view with only that entry changed.
//
// `region` is where the site sits, as `outermost` above describes.
//
// `within` is the tags whose display state encloses the site, outermost first, and only the
// ones the timeline addresses with a continuous primitive: a tag it never addresses cannot
// transform anything, so it need not thread a view through its body at all.
// A site reports it, which is how a timeline that reads an anchor below a transform is
// refused rather than resolved differently in each output type.
//
// `display` is the state's display state with every position resolved to two lengths, which
// only the rendering knows: a position is an anchor and an offset, and the anchor is a tag's
// corner. A tag site puts what it is handed on its content and resolves nothing itself.
//
// A rendering names one of `state` and `epoch`, and never both.
// A paged rendering is one of the S+1 states, so it names its `state`, and lays out the
// epoch that state belongs to under the display state the page resolved.
// An HTML frame is not one of them, so it names its `epoch` instead: one frame covers the
// whole run of states that share that epoch, `state` is `none` to say so, and the display
// state stays empty because the browser puts a state's own on the groups.
#let view-of(
  plan,
  names,
  slide,
  state: none,
  epoch: none,
  display: (:),
) = (
  slide: slide,
  state: state,
  states: plan.states.len(),
  epoch: if state == none { epoch } else { plan.states.at(state).epoch },
  epochs: plan.epochs,
  display: display,
  continuous: names,
  region: outermost,
  within: (),
)

// The label of the marker a tag emits to ask for the view of its slide.
#let ask-label = label("animo-ask")

// The label of the marker a `per-subslide` emits to ask for the stack view of its slide.
//
// A second marker rather than a second use of `ask-label`, because the two are answered in
// different places.
// A tag is answered by the body's view and refused everywhere else.
// A stack of renderings is answered wherever a slide lays content out, the background and
// the overlay included, because it addresses nothing in the timeline and is content the
// slide renders for itself.
#let stack-view-label = label("animo-stack-view")

// A stack view: what a stack of one rendering per state is built from.
//
// `states` is how many states the slide has, and `state` is which of them is being laid
// out, `none` in the HTML target, where one frame covers every state of an epoch.
// This is the part of a view that content outside the body may have, which is why a stack
// view is a record of its own rather than the view a tag site is handed.
#let stack-view-for(states, state) = (states: states, state: state)

// The stack view of the rendering a view describes.
#let stack-view-of(view) = stack-view-for(view.states, view.state)

// Hand `stack-view` to every `per-subslide` in `body`.
#let provide-stack-view(stack-view, body) = {
  show stack-view-label: it => (it.value.render)(stack-view)
  body
}

// Ask the enclosing slide for its stack view, and render `f` with it.
#let ask-stack-view(f) = [#metadata((render: f))#stack-view-label]

// Whether a body is being laid out inside a slide.
//
// This is the one thing about a slide that is published rather than provided, because it is
// the one thing that has to be readable where no provider ran.
// A marker that nobody replaced is indistinguishable from one that was, so a tag outside any
// slide cannot be diagnosed after the fact and is diagnosed at the tag site.
#let inside = state("animo-inside", false)

// Hand `view` to every tag in `body`, and to every tag those tags contain.
#let provide(view, body) = {
  show ask-label: it => (it.value.render)(view)
  provide-stack-view(stack-view-of(view), body)
}

// Refuse every tag and every region in `body`, naming the argument it was written in.
//
// This is a provider like `provide`, and the reason is the diagnosis.
// A marker nobody replaced is indistinguishable from one that was, so a tag in a background
// or an overlay cannot be found afterwards, and handing it back untouched would drop its
// content silently, which is what `tag` avoids by refusing raw cetz draw commands.
// A provider refuses it where it is written instead, in both targets, whatever order the two
// layers are laid out in relative to the body, and the marker already carries the name of
// the site for the message.
//
// `which` names the argument, and `index` the slide, because a name means nothing outside
// the slide it is written on.
#let refuse(which, index, stack-view, body) = {
  show ask-label: it => panic(
    it.value.what
      + " is in the "
      + which
      + " of slide "
      + str(index)
      + ", which belongs to the viewport rather than to the body: "
      + "nothing in the timeline could address it there, and a background and an overlay "
      + "are rendered once for the whole slide, so neither can depend on an epoch; "
      + "move it into the body of the slide",
  )
  provide-stack-view(stack-view, body)
}

// Ask the enclosing slide for its view, and render `f` with it.
//
// `what` names the asking site in the diagnosis, such as "the tag x" or "a region".
// It travels with the marker rather than staying at the call, because `refuse` raises its
// panic where the provider runs and not where the site asks.
//
// Must be called in a context, for the diagnosis above.
#let ask(what, f) = {
  assert(
    inside.get(),
    message: what
      + " is not inside a #slide, so there is no timeline that could address it",
  )
  [#metadata((what: what, render: f))#ask-label]
}
