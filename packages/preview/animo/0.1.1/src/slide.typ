// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// A slide: a viewport onto a canvas, plus the timeline that animates it.
//
// The two rectangles are what makes panning mean anything.
// The viewport is what the audience sees, and it clips: one HTML slide container,
// one static-presentation page, one handout page.
// The canvas is what the body is laid out on, at least as large as the viewport,
// with its origin at the viewport's origin and the body inset by the deck's margin.
// A slide that places nothing outside the viewport is indistinguishable from a slide
// with no canvas concept at all.
//
// The timeline is resolved before the body is laid out, because the body's layout depends
// on it, and the result is provided to the body rather than published to a state.
// A slide with S `sub` calls has S+1 states:
// the presentation renders one page each, the handout renders the states that asked for a
// page, and the HTML target renders one per epoch, each covering the whole run of states
// that share its content and all of them in one frame.

#import "anim.typ": check-gap, check-handout
#import "canvas.typ": (
  anchors-of, auto-extent, body-box, body-extent, canvas-label, explicit-extent,
  geometry-label, origin-marker, paged-display, paged-pan, record-placements,
  sites-of,
)
#import "deck.typ": (
  css-color, deck-shape, handout-tally, paged-mode, unit-length,
)
#import "member.typ": changed-groups, check-boundary-timings, members-of
#import "plan.typ": (
  inside, provide, refuse, resolve, stack-view-for, timeline-asks, unpanned,
  view-of,
)
#import "number.typ": numbered-flag, slide-counter, step-counter
#import "site.typ": describe, reserved
#import "region.typ": region-counter
#import "runtime.typ": browser-plan, pt-of

// Refuse what the tag sites of a slide contradict: a continuous primitive, `pan` included,
// on a name the slide has no site of, and an anchor read from inside a tag the timeline
// moves or scales.
//
// A name with no site is refused because the two targets would answer it differently.
// Typst finds nothing to move and the paged outputs do nothing, while the browser
// addresses a group by its label and any label of that name will do, including one the
// document wrote itself.
//
// Both checks can only be made from `query`, and a panic that depends on `query` can be
// swallowed.
// A panic empties the block it is raised in, and if that block holds the very tag sites the
// check reads, the next pass has nothing to check and passes, and the two alternate
// (see *Findings*).
// So this runs in a context block of its own, which emits nothing.
// A panic there leaves the slide and its tag sites alone, typst keeps only the errors of the
// pass it ends on, and so a site that is reported a pass late is a miss that is forgotten,
// while a tag that is really missing fails the last pass and is reported.
//
// `asked` is what the timeline asks of the tag sites, as `timeline-asks` in `plan.typ`
// builds it, and `sites` the tag sites of the slide, read back from its rendering,
// once per site per rendering.
//
// Must be called in a context.
#let check-sites(asked, index, sites) = {
  // The names the slide has a site of, which is what both checks below read.
  let present = sites.map(site => site.name).dedup()
  for target in asked.targets {
    assert(
      target.relto in present,
      message: "a "
        + target.kind
        + " on slide "
        + str(index)
        + " is relative to the tag "
        + target.relto
        + ", but that slide has no tag of that name",
    )
  }
  // An anchor below a transform is refused, because no rendering can read it as the design
  // says an anchor is read. The anchor of a tag is the corner the body gave it, and a `move`
  // or a `scale` on a tag around it moves that corner: the presentation and the browser
  // still resolve it from an untransformed layout, the first from its own first page and
  // the second from the slide before anything is written on it, while a handout reads
  // whichever page it keeps. So the three output types would disagree, and a `move` that
  // reads an anchor inside the tag it moves would not even converge.
  for site in sites {
    if site.name not in asked.anchored { continue }
    for around in site.within {
      assert(
        around not in asked.transformed,
        message: "the timeline of slide "
          + str(index)
          + " reads the anchor of the tag "
          + site.name
          + ", which sits inside the tag "
          + around
          + " that the same timeline moves or scales; "
          + "an anchor is the corner the body gave a tag, and a transform around it moves "
          + "that corner, so the three output types would not agree on where it is; "
          + "read the anchor of "
          + around
          + " instead, or take "
          + site.name
          + " out of it",
      )
    }
  }
  // The relto names are among these, and are checked above so that a `pan` or a `move`
  // relative to a tag is diagnosed as one.
  // An assert empties this block, so the first failure is the only one reported.
  //
  // The claim is about groups rather than about tags, which is what the reports say and
  // what the browser needs. It is also what keeps it true beside the refusal a `wrap: none`
  // tag raises where it is written: that tag exists and became no group, and its own message
  // is the one that says what to do about it.
  for name in asked.names {
    assert(
      name in present,
      message: "the timeline of slide "
        + str(index)
        + " addresses "
        + name
        + " with a continuous primitive, but no tag site on that slide became a group of "
        + "that name; a name means nothing outside its own slide, "
        + "and a label the document wrote itself is not a tag site",
    )
  }
}

// The label that the rendering of one epoch carries in the output.
//
// A slide is one frame, and the epoch renderings are boxes placed at one point inside it,
// so each of them becomes a group the runtime can show, hide and blend. The number is the
// epoch's own, and the reserved prefix keeps the label out of the author's namespace.
//
// One frame rather than one per epoch, because the scope of typst's deduplicator is the
// frame.
// The renderings of a slide then define each glyph they share once between them instead of
// once each. See *Findings*.
#let epoch-group(epoch) = reserved + "epoch-" + str(epoch)

// Where a slide sits in the deck, counting every slide.
// This is what addresses a slide in the URL and in the DOM, so it counts the slides
// the presenter walks through, not the ones that carry a number.
#let position = counter("animo-position")

// The `hold:` of the last state of the slide before this one, as a number of seconds or
// `none`.
//
// A gap across a slide boundary is the one gap neither of its slides can refuse on its own.
// The `hold:` that times it is resolved by one call of `resolve` and the `wait:` that times
// it by the next, so the pair is visible nowhere but between the two.
// This state carries the first number to the slide that holds the second, which is where the
// pair is checked.
#let trailing-hold = state("animo-hold", none)

// Refuse a slide boundary that both of the slides it joins time.
//
// The same rule as `check-gaps` inside a slide, for the same reason.
// A gap elapses once, so the two numbers are two answers to one question rather than two
// parts of one duration.
// `index` is where this slide sits, so that the message names both slides.
//
// This runs in a context block of its own that emits nothing, for the reason
// `check-handout-pages` does: a panic here empties no slide and leaves nothing for the
// next introspection pass to disagree about.
#let check-boundary-gap(index, first) = {
  assert(
    trailing-hold.get() == none or first.wait == none,
    message: "the gap between slide "
      + str(index - 1)
      + " and slide "
      + str(index)
      + " is timed twice, by hold: on the last step of the first and by slide(wait: ..) "
      + "on the second; one gap takes one number, so keep whichever of the two reads "
      + "better where it stands and drop the other",
  )
}

// Split one of the two outer layers into the two things it can be.
//
// A colour and content are drawn by different means, and the difference is worth keeping
// rather than resolving a colour to a filled rectangle, because a colour is one declaration
// where content is a whole rendering.
// Content is also the only form an image can take, since typst has no image page fill.
// A gradient or a tiling is refused rather than silently dropped in one of the targets,
// and the message says the form that does work in all three output types: typst resolves
// either against the element it fills, CSS would have to be handed an equivalent animo
// would have to write itself, and a tiling has no CSS equivalent at all.
//
// `which` names the argument, so that a deck with both of them gets a diagnosis about the
// one it got wrong.
#let split-layer(which, value) = {
  if value == none {
    (fill: none, ink: none)
  } else if type(value) == color {
    (fill: value, ink: none)
  } else if type(value) == content {
    (fill: none, ink: value)
  } else {
    panic(
      which
        + " takes a colour or content, got "
        + describe(value)
        + "; wrap a gradient or a tiling in a `rect` of the slide size to use it",
    )
  }
}

// One of the two outer layers, as the content both targets draw it from.
//
// The box is the viewport: a `#place(bottom + right, ..)` in a layer resolves its alignment
// against it, and an `image(width: 100%, height: 100%)` fills the slide.
// It clips at the viewport's own edge, as the viewport clips all three layers alike.
//
// The layer is laid out under a provider that refuses every tag and every region in it,
// so that the two layers stay what they are: content nothing in the timeline addresses.
//
// That provider hands the layer its stack view all the same, so a `per-subslide` in a layer
// is laid out rather than refused. It addresses nothing and is rendered by the slide
// itself, so it needs neither a timeline nor an epoch: in the HTML target the one frame of
// the layer carries every state's rendering, and on paper the layer is placed once per
// page and lays out the rendering of that page's state.
#let layer-of(which, index, viewport, stack-view, ink) = box(
  width: viewport.width,
  height: viewport.height,
  clip: true,
  refuse(which, index, stack-view, ink),
)

// The strategies a slide boundary may be given by name.
//
// The list lives here rather than only in the runtime because typst is what refuses a
// misspelling, and it has to do so at compile time.
// A name the runtime did not recognise would be a slide that quietly took the default.
#let transition-names = ("crossfade",)

// How a slide is entered, as the browser runtime reads it.
//
// `auto` is the deck's own strategy and `none` is a cut, both typst literals; a string
// names a strategy outright.
// A name is accepted although animo has one strategy, so that a richer transition is a value
// added to `transition-names` rather than a change of what the argument takes.
//
// The boundary above a slide belongs to that slide and is crossed the same way in both
// directions, so stepping back over it undoes exactly what stepping forward over it did.
// The paged outputs ignore this entirely: two consecutive pages have nothing between them
// to describe.
#let transition-name(value) = {
  assert(
    value == auto or value == none or value in transition-names,
    message: "transition takes `auto`, which is the deck's own, `none`, which cuts, or "
      + "one of "
      + repr(transition-names)
      + ", got "
      + describe(value),
  )
  if value == none { "none" } else if value == auto { "auto" } else { value }
}

// A colour overlay, as the paged outputs draw it.
//
// A background colour is the page's own `fill`, which is behind everything, and an overlay
// colour is ink over the slide, so it is a layer of its own.
// Only an alpha channel makes one useful, and a dimming tint is the case it exists for.
//
// Every visual field of the rectangle is stated, so that a `set rect(..)` in the deck
// around it cannot put a stroke or a corner radius on a layer animo emits for itself.
#let tint-of(viewport, fill) = rect(
  width: viewport.width,
  height: viewport.height,
  fill: fill,
  stroke: none,
  inset: 0pt,
  outset: 0pt,
  radius: 0pt,
)

#let slide(
  body,
  animation: (),
  canvas: auto,
  background: none,
  overlay: none,
  transition: auto,
  wait: none,
  hold: none,
  handout: auto,
  numbered: true,
) = {
  let (fill: back-fill, ink: back-ink) = split-layer("background", background)
  let (fill: front-fill, ink: front-ink) = split-layer("overlay", overlay)
  let entered = transition-name(transition)
  // The initial state has no `sub` of its own, so its handout flag and the two numbers
  // that time the gaps on either side of it are written here and resolved with every
  // other state's.
  let plan = resolve(
    animation,
    handout: check-handout("slide", handout),
    wait: check-gap("slide", "wait", wait),
    hold: check-gap("slide", "hold", hold),
  )
  let asked = timeline-asks(plan)
  let names = asked.names
  position.step()
  if numbered {
    slide-counter.step()
  }
  // Which slide carries a number, and where its states sit in the deck.
  // Both are published rather than provided, because both are read where no view of the
  // slide reaches: `slide-number()` is an ordinary counter read the author writes anywhere
  // in the body or in a layer, and the deck-wide step of a state is read from inside a
  // stack of renderings.
  numbered-flag.update(numbered)
  step-counter.update(it => it + plan.states.len())
  context check-boundary-gap(position.get().first(), plan.states.first())
  // Unconditional, so that a slide that holds nothing clears whatever the slide before it
  // left rather than handing it on to the slide after.
  trailing-hold.update(plan.states.last().hold)
  // A tag outside any slide has to be diagnosed at the tag site, and `inside` is what says
  // whether there is a slide around it.
  // It is published rather than provided because it has to be readable where no provider
  // ran, and it is set around the enclosing context block rather than inside it, because
  // a state read inside `measure` resolves at that block's own location.
  inside.update(true)
  context {
    let shape = deck-shape.get()
    let index = position.get().first()
    let viewport = (width: shape.width, height: shape.height)
    let inner = (
      width: viewport.width - 2 * shape.margin,
      height: viewport.height - 2 * shape.margin,
    )

    // The two outer layers, each content the size of the viewport.
    // They belong to the viewport rather than to the canvas, so a pan moves the canvas
    // between them and leaves both where they are, and a recurring element stays in place
    // while the canvas moves under it.
    //
    // Neither is laid out under the `show place:` rule that records the placements, and
    // neither is measured for the body box, so no placement in either enters the automatic
    // canvas extent: a full-bleed image in the background cannot make the body pannable by
    // accident, and an overlay full of `#place` cannot either.
    //
    // A layer is built for a state rather than once, because a `per-subslide` in it lays
    // out the rendering of that state. It is one call in the HTML target, whose one frame
    // per layer carries every state's rendering, and one call per page on paper, which is
    // where the layer is placed anyway.
    let view-at(state) = stack-view-for(plan.states.len(), state)
    let under-at(state) = if back-ink != none {
      layer-of("background", index, viewport, view-at(state), back-ink)
    }
    let over-at(state) = if front-ink != none {
      layer-of("overlay", index, viewport, view-at(state), front-ink)
    }

    // The view the body is measured with, and the one the canvas is computed from.
    // The canvas is a property of the slide and not of a state, so it is measured once,
    // and with a view that exists whatever the outputs ask for.
    // Any view gives the same answer, because a display state is layout-neutral and a
    // region keeps the same footprint in every epoch.
    let measuring = if target() == "html" {
      view-of(plan, names, index, epoch: 0)
    } else {
      // State 0 puts every tag where the body put it, so the measuring view needs no
      // anchors: its display state is empty whatever the timeline says.
      view-of(plan, names, index, state: 0)
    }

    // The box the body is laid out in, which is the viewport's inner size unless the body's
    // own flow is taller. It is derived from the body alone, so the recorded placements do not
    // move when the canvas grows around them.
    let container = body-box(provide(measuring, body), inner)

    // Whether this slide records its placements to size its canvas.
    //
    // The canvas is read by `pan` and by nothing else, so a slide that never pans is drawn
    // the same whatever canvas it gets, and a slide that states its canvas has no reader
    // for the recording at all.
    // Skipping it is what keeps a body that holds thousands of placements from paying a
    // `context`, a `measure` and a queried element for each of them.
    let records = (
      canvas == auto and plan.states.any(state => state.slide.pan != unpanned)
    )

    // One rendering of the canvas, for one view of its plan.
    // Regions are numbered within one rendering, so that a region has the same number in all
    // of them and a rendering can say which regions changed in terms another one understands.
    //
    // `recorded` says whether this is the rendering that records the placements of its
    // epoch. The states of one epoch share their content, and a display state puts a
    // `move`, a `scale` and a `hide` around a tag rather than a `place`, so every
    // rendering of an epoch records the same placements at the same offsets and at the
    // same size, and one of them is the whole recording.
    let laid-out(view, recorded: false) = {
      region-counter.update(0)
      place(
        top + left,
        dx: shape.margin,
        dy: shape.margin,
        block(width: container.width, height: container.height, provide(
          view,
          if recorded { record-placements(index, body) } else { body },
        )),
      )
    }

    // The first rendering of each epoch, among the renderings an output type asks for,
    // as their indices into those renderings.
    //
    // A handout renders the states that asked for a page and may skip the first state of
    // an epoch, or an epoch entirely, so the recording follows the renderings rather than
    // the plan.
    let first-renderings(epoch-of) = {
      if not records { return () }
      let seen = ()
      let first = ()
      for (rendering, epoch) in epoch-of.enumerate() {
        if epoch in seen { continue }
        seen.push(epoch)
        first.push(rendering)
      }
      first
    }
    let extent = if canvas != auto {
      explicit-extent(canvas)
    } else if records {
      auto-extent(index, container, viewport, shape.margin)
    } else {
      body-extent(container, viewport, shape.margin)
    }
    let size = (
      width: calc.max(viewport.width, extent.width),
      height: calc.max(viewport.height, extent.height),
    )

    [#metadata((
        slide: index,
        width: size.width,
        height: size.height,
      ))#canvas-label]

    if target() == "html" {
      let style = if back-fill == none { none } else {
        "background: " + css-color(back-fill)
      }
      html.elem(
        "div",
        attrs: (
          class: "animo-slide",
          data-animo-slide: str(index),
          data-animo-states: str(plan.states.len()),
          // How the boundary above this slide is crossed. An attribute rather than an
          // entry in the plan below, for the reason the plan itself is an attribute: it
          // is one value per slide, and a browser's element inspector shows it beside
          // the slide it is about.
          data-animo-transition: entered,
          // What the browser runtime applies: the resolved display state of every state,
          // state 0 included, which the resolver reads from the timeline alone.
          // The margin and the canvas travel beside the states, because the runtime
          // turns a pan into a `translate` on the canvas and needs both to do so:
          // a `relto` puts the tag where the body starts, and a percentage of the canvas
          // is a length that follows the window without being measured.
          data-animo-plan: json.encode(
            (
              ..browser-plan(
                plan,
                names,
                // Which groups each boundary redraws, read back from the frames below.
                // Only layout knows which tags a region holds, so this is an
                // introspection pass away, and it changes no layout of its own.
                range(plan.epochs.len()).map(epoch => changed-groups(
                  plan.epochs,
                  epoch,
                  members-of(index),
                )),
              ),
              margin: pt-of(shape.margin),
              canvas: (width: pt-of(size.width), height: pt-of(size.height)),
            ),
            pretty: false,
          ),
          ..if style == none { (:) } else { (style: style) },
        ),
        {
          let under = under-at(none)
          let over = over-at(none)
          if under != none {
            html.elem(
              "div",
              attrs: (class: "animo-background"),
              html.frame(under),
            )
          }
          html.elem(
            "div",
            attrs: (
              class: "animo-canvas",
              style: "width: "
                + unit-length(size.width)
                + "; height: "
                + unit-length(size.height),
            ),
            // One frame for the whole slide, holding one rendering per epoch, in epoch
            // order. Each covers every state that shares its content, so stepping inside
            // an epoch needs no rendering at all, and the runtime shows one rendering at
            // a time and crossfades the changed regions at a boundary.
            //
            // The renderings are placed at one point rather than laid out in sequence,
            // which is what stacks them, and each is a labelled box so that it becomes a
            // group the runtime can address. The frame's own extent is the block around
            // them and not the union of what they hold, which is what keeps the canvas
            // element the box animo computed.
            html.frame(block(
              width: size.width,
              height: size.height,
              {
                for epoch in range(plan.epochs.len()) {
                  place(top + left, [#box(
                      width: size.width,
                      height: size.height,
                      // One frame per epoch, so every frame records its own.
                      laid-out(
                        view-of(plan, names, index, epoch: epoch),
                        recorded: records,
                      ),
                    )#label(epoch-group(epoch))])
                }
              },
            )),
          )
          // Last, so that it paints last: the three layers are positioned siblings with no
          // z-index of their own, and such elements paint in document order.
          // A colour overlay is one declaration on this element rather than a frame of its
          // own, where a colour background is a declaration on the slide container: the
          // container is behind the canvas, and an overlay has to be in front of it.
          if front-fill != none or over != none {
            html.elem(
              "div",
              attrs: (
                class: "animo-overlay",
                ..if front-fill == none { (:) } else {
                  (style: "background: " + css-color(front-fill))
                },
              ),
              if over != none { html.frame(over) },
            )
          }
        },
      )
    } else {
      // Where the viewport and every moved tag sit on the canvas in every state.
      // An anchor is resolved from the positions of this very rendering, which typst
      // reaches by iterating: the first pass finds no tag and resolves as if nothing were
      // relative to one, and the next one reads each tag's corner off the marker its
      // wrapper carries. The document converges because neither consumer moves what it
      // measures: a pan shifts the whole canvas and the markers with it, which the canvas
      // origin cancels out of, and a tag's own translation sits inside the wrapper whose
      // corner the marker marks.
      let anchors = anchors-of(index, asked.anchored)
      let pans = plan.states.map(state => paged-pan(
        state.slide.pan,
        anchors,
        shape.margin,
      ))
      let displays = plan.states.map(state => paged-display(
        state.display,
        anchors,
      ))
      [#metadata((
          slide: index,
          pans: pans,
          displays: displays,
        ))#geometry-label]

      // The pages this paged output asks for, in page order:
      // every state in the presentation, and the states that asked for a page in the
      // handout. A slide whose every state is turned down contributes nothing, and that
      // is the author's decision to make, because `handout:` is the only thing that says
      // what a handout holds.
      // The deck refuses only the case where no slide contributes at all, which is what
      // `handout-tally` below is counted for.
      let page-of(state) = view-of(
        plan,
        names,
        index,
        state: state,
        display: displays.at(state),
      )
      let views = if paged-mode() == "presentation" {
        range(plan.states.len()).map(page-of)
      } else {
        plan
          .states
          .enumerate()
          .filter(((state, resolved)) => resolved.handout)
          .map(((state, resolved)) => page-of(state))
      }
      if paged-mode() == "handout" {
        handout-tally.update(tally => (
          slides: tally.slides + 1,
          pages: tally.pages + views.len(),
        ))
      }
      // A page is the viewport, so it shows the canvas shifted by the state's pan,
      // and whatever of the canvas falls outside the page is clipped by the page.
      let recording = first-renderings(views.map(view => (
        plan.states.at(view.state).epoch
      )))
      for (page-index, view) in views.enumerate() {
        let pan = pans.at(view.state)
        page(
          width: viewport.width,
          height: viewport.height,
          margin: 0pt,
          fill: back-fill,
          {
            let under = under-at(view.state)
            let over = over-at(view.state)
            if under != none { place(top + left, under) }
            place(top + left, dx: -pan.x, dy: -pan.y, block(
              width: size.width,
              height: size.height,
              {
                origin-marker(index)
                laid-out(view, recorded: page-index in recording)
              },
            ))
            // After the canvas, because placed content paints in document order.
            if front-fill != none {
              place(top + left, tint-of(viewport, front-fill))
            }
            if over != none { place(top + left, over) }
          },
        )
      }
    }
  }
  // Apart from the block above, so that a panic here cannot empty the slide it checks.
  context {
    let index = position.get().first()
    // Which region a tag belongs to is a layout-time fact, so this reads the membership
    // reports of the rendering, exactly as the site checks below read the site reports.
    check-boundary-timings(index, plan.epochs, members-of(index))
    // A paged slide with no page has no tag site to read back, and nothing to show
    // wrongly; the HTML target renders a frame whatever the handout flags say, so it
    // checks the same slide over that.
    if (
      target() == "html"
        or paged-mode() == "presentation"
        or plan.states.any(state => state.handout)
    ) {
      check-sites(asked, index, sites-of(index))
    }
  }
  inside.update(false)
}
