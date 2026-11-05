// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// What a state of a slide looks like on the page: where each position puts what it addresses,
// the CSS of a tag's display state and of a pan, the anchors a position is relative to, and
// `planState`, which plans one state of a slide on its canvas and on every tag it addresses.

/** The canvas origin, which is the anchor a position with no `relto` is measured from. */
const ORIGIN = { x: 0, y: 0 };

/** The values an engine computes for the `scale` of an element at its unscaled size. */
const UNSCALED = new Set(["none", "1", "1 1"]);

/**
 * Where one position puts what it addresses, in typst points.
 *
 * `anchor(relto) + offset - anchor(self)`, where the anchor of `null` is the canvas origin.
 * `self` is the moved tag, or `null` for the viewport, which is anchored at the origin too.
 * A pair whose `relto` names the moved tag is therefore the identity, which is what a tag
 * the timeline never moved carries, and it needs no anchor to resolve.
 *
 * An anchor the page does not have leaves the offset alone, which can only happen on a page
 * edited by hand, because typst refuses a timeline relative to a tag its slide does not have.
 */
function resolvePosition(slide, position, self) {
  const own = self === null ? null : (slide.anchors.get(self) ?? null);
  const along = (which) => {
    const axis = position?.[which];
    if (axis === undefined) {
      return 0;
    }
    if (axis.relto === self) {
      return axis.offset;
    }
    const target = axis.relto === null ? ORIGIN : (slide.anchors.get(axis.relto) ?? null);
    if (target === null || (self !== null && own === null)) {
      return axis.offset;
    }
    return target[which] + axis.offset - (self === null ? 0 : own[which]);
  };
  return { x: along("x"), y: along("y") };
}

/**
 * The CSS of one tag's display state.
 *
 * The CSS uses only the individual transform properties and never the `transform` shorthand,
 * which would clobber the positioning typst wrote on the labelled group that holds this one.
 * A length inside a frame's SVG is a user unit, which is a typst point, so a move stays
 * the same fraction of the slide at any window size without the runtime measuring one.
 *
 * The CSS has one `scale` value rather than two while the two axes agree, because a property whose
 * keyframes are equal at both ends stops the browser from drawing the ones beside it
 * (see *Findings*), and the engines do not compute `1 1` to the same string, so a tag at
 * rest would otherwise look like a tag that changed.
 */
function declarations(slide, name, display) {
  const { x, y } = resolvePosition(slide, display, name);
  const factors = display.scale;
  return {
    opacity: display.hidden ? "0" : "1",
    translate: `${x}px ${y}px`,
    scale: factors.x === factors.y ? String(factors.x) : `${factors.x} ${factors.y}`,
  };
}

/**
 * The declarations that make a `scale` grow one slot about the point typst's `scale` grows it
 * about on paper.
 *
 * That point is the centre of the box typst laid out on an axis the tag was not placed on,
 * and the start of that box on an axis it was placed on with `x`, `y` or `relto`,
 * so that the corner the timeline put on a target stays there at any factor.
 * An axis whose anchor is the tag itself was never placed, whatever `dx` or `dy` shifted it.
 *
 * The box is the one typst laid out, and the ink of the slot need not fill it.
 * Its far corner is the origin of the `animo-corner` marker that typst places beside the slot.
 * The slot carries no transform attribute, so its box starts at the origin of the group the
 * two share, and under `transform-box: view-box` an origin in `px` is a point of the user space
 * of that group.
 * `fill-box` would measure the box of the ink instead, and firefox reads that
 * ink without the transform attributes of the elements inside the slot. See *Findings*.
 *
 * Without an origin a `scale` grows the slot about its top-left corner.
 * Both declarations are planned here, on the one element the runtime transforms,
 * and never as a rule in the stylesheet.
 * The declarations re-anchor the `transform` attribute of the element as much as the
 * properties beside it, so a selector broad enough to reach a group typst positioned
 * displaces that group, silently and with no transform property set at all.
 * A labelled group is not always a tag site, because a region's footprint carries a label
 * too, and its children are the region's content. See *Findings*.
 */
function growth(slot, name, display) {
  const placed = (which) => display[which] !== undefined && display[which].relto !== name;
  const marker = slot.parentNode.querySelector(':scope > [data-typst-label="animo-corner"]');
  const corner = marker?.transform.baseVal.consolidate()?.matrix;
  if (corner === undefined || corner === null) {
    // Typst places a marker beside every slot, so this is a page edited by hand,
    // and the slot grows about a point of the box of its ink.
    const at = (which) => (placed(which) ? "0%" : "50%");
    return { "transform-box": "fill-box", "transform-origin": `${at("x")} ${at("y")}` };
  }
  const at = (which, far) => (placed(which) ? 0 : far / 2);
  return {
    "transform-box": "view-box",
    "transform-origin": `${at("x", corner.e)}px ${at("y", corner.f)}px`,
  };
}

/**
 * The tags whose anchor this slide's plan asks for, as a set of names.
 *
 * A position is `anchor(relto) + offset - anchor(self)`,
 * so a pair whose `relto` names the moved tag asks for nothing,
 * because the two terms cancel whatever that anchor is.
 * Every state of a plan holds every addressed tag,
 * so a slide of tags that merely appear asks for none.
 */
function wantedAnchors(slide) {
  const names = new Set();
  const wanted = (position, self) => {
    for (const axis of [position?.x, position?.y]) {
      if (axis === undefined || axis.relto === self) {
        continue;
      }
      for (const name of [axis.relto, self]) {
        if (name !== null) {
          names.add(name);
        }
      }
    }
  };
  for (const state of slide.states) {
    wanted(state.pan, null);
    for (const [name, display] of Object.entries(state.tags ?? {})) {
      wanted(display, name);
    }
  }
  return names;
}

/**
 * The epoch of the rendering an element sits in, where an element outside every epoch stack
 * counts as epoch 0, because the body around the stacks is laid out once for all epochs.
 */
function epochOf(element) {
  for (let node = element; node !== null; node = node.parentElement) {
    const found = stackLabel(node.dataset?.typstLabel);
    if (found?.kind === "epoch") {
      return found.index;
    }
  }
  return 0;
}

/**
 * The labelled group of the first site of a tag, or `undefined` for a tag the slide does
 * not have.
 *
 * The first site is the first in document order among the sites of the lowest epoch, which is
 * the site a paged output reads in the first page that lays the tag out. Document order alone
 * would put a site that only a later epoch lays out first, when it comes earlier in the body.
 * A tag that holds an epoch stack has a slot in every rendering of the stack, and
 * its group is the one around the stack.
 */
function firstSite(slide, name) {
  let first;
  let lowest = Infinity;
  for (const slot of slide.slots.get(name) ?? []) {
    const epoch = epochOf(slot);
    if (epoch < lowest) {
      first = slot;
      lowest = epoch;
    }
  }
  const group = first?.parentNode;
  if (stackLabel(group?.dataset.typstLabel)?.kind === "epoch") {
    return group.parentNode.closest("[data-typst-label]");
  }
  return group;
}

/**
 * Where the first site of every tag the plan asks about sits on the canvas, in points.
 *
 * The anchor is the origin of the tag's labelled group, which is the top-left corner of the
 * wrapper typst laid out, and not the box of its ink.
 * The paged outputs read the same corner,
 * so the two targets resolve the same quantity rather than two neighbours.
 * The anchor is mapped into the user space of the frame, whose units are typst points and whose
 * origin is the canvas origin, so the pan of the canvas cancels out of it.
 * `firstSite` says which site is the first.
 *
 * The anchors have to be read while the slide has a layout and before the runtime has written a
 * display state on it, because a tag around the anchor would otherwise move it by
 * whatever state that happens to be.
 */
function measureAnchors(slide) {
  const anchors = new Map();
  for (const name of wantedAnchors(slide)) {
    const group = firstSite(slide, name);
    if (group === undefined || group === null) {
      // Typst refuses a timeline relative to a tag its slide does not have, so this is a
      // page edited by hand, and the position resolves as if nothing were relative to a tag.
      anchors.set(name, null);
      continue;
    }
    const frame = group.ownerSVGElement.getScreenCTM().inverse();
    const corner = frame.multiply(group.getScreenCTM());
    anchors.set(name, { x: corner.e, y: corner.f });
  }
  return anchors;
}

/** A percentage of `full` that covers `length`, without the `-0` a zero pan would give. */
function percent(length, full) {
  return full > 0 ? (100 * length) / full || 0 : 0;
}

/**
 * The CSS of one state's pan, which is a `translate` on the canvas.
 *
 * The pan is a percentage, because a translate in percent is a fraction of the box of the
 * canvas, which follows the window as the canvas does, and a percentage animates in every
 * engine.
 * A length written as a multiple of `--animo-unit` would have to put a custom property into
 * a keyframe.
 */
function viewport(slide, state) {
  const at = resolvePosition(slide, state.pan, null);
  // A `relto` puts the named tag where the body of a fresh slide starts, which is the
  // deck's margin in from the canvas origin. An axis measured from the origin itself is
  // already the position of the viewport.
  const along = (which) =>
    state.pan?.[which]?.relto == null ? at[which] : at[which] - slide.margin;
  const x = percent(-along("x"), slide.size.width);
  const y = percent(-along("y"), slide.size.height);
  return { translate: `${x}% ${y}%` };
}

/**
 * Plan one state of a slide on its canvas, on its stacks, and on every occurrence of every
 * tag it addresses.
 *
 * The pan goes on the canvas and never on the frame inside it, so moving the canvas moves
 * everything the frame holds and keeps the renderings of every stack registered.
 * The canvas is an HTML element, so its `translate` composes with nothing typst wrote.
 *
 * Continuous state is written on every occurrence in every rendering and not only in the
 * one being shown, so that entering an epoch needs no initialisation and a step that both
 * replaces and moves a tag moves it by the same amount in the rendering it leaves and in
 * the one it arrives at.
 *
 * Every effect of the step, the boundary's included, is planned into `effects`, and the
 * caller applies them in one task, so none of the animations is told when it began and the
 * browser starts them all on the same frame.
 *
 * `step` is the state whose own operations are being walked, which is the higher of the
 * two a step runs between, forwards and backwards alike.
 * One step is one schedule, and a backward step is that schedule mirrored rather than a
 * separate schedule.
 * A backward step that walked over a join runs between states that are not neighbours,
 * and the schedules of the steps it walked over are not replayed one by one.
 * What the audience saw across a join was one motion redirected before it arrived,
 * which neither schedule replayed on its own reproduces, so the way back is one motion too.
 *
 * `reverse` says which way that schedule is read. Every effect of a backward step is
 * mirrored about the length of the step it undoes, so the operation that arrived last is
 * the one that leaves first, and the step ends where the earlier state began.
 */
function planState(
  effects,
  slide,
  index,
  options,
  { from = null, step = index, reverse = false } = {},
) {
  const state = slide?.states[index];
  if (state === undefined) {
    return;
  }
  const timings = slide.states[step]?.timing ?? {};
  const mirror =
    reverse && options !== null ? span(slide.states[step]?.span, options) : null;
  if (slide.canvas !== null && slide.size !== null) {
    plan(effects, slide.canvas, viewport(slide, state), options === null
      ? null
      : { translate: scheduled(options, timings.pan, mirror) });
  }
  for (const [name, display] of Object.entries(state.tags ?? {})) {
    const own = timings.tags?.[name] ?? {};
    const timed =
      options === null
        ? null
        : {
            opacity: scheduled(options, own.opacity, mirror),
            translate: scheduled(options, own.translate, mirror),
            scale: scheduled(options, own.scale, mirror),
          };
    for (const element of slide.slots.get(name) ?? []) {
      const { "transform-box": box, "transform-origin": point } = growth(element, name, display);
      plan(effects, element, { "transform-box": box });
      // The origin changes with the placement, which only a `move` changes, so it travels
      // on the timing of the `translate` beside it, and the corner of a scaled tag goes
      // to its target without a jump.
      // An origin makes no difference to an element at its unscaled size, so such an
      // element takes the new origin at once, and the corner of a tag that the same step
      // places and scales goes to its target in a straight line.
      // An element that has no origin yet takes the first one without travelling as well,
      // because the origin it computes until then is no point the audience saw.
      const travels =
        timed !== null &&
        element.style.transformOrigin !== "" &&
        !UNSCALED.has(getComputedStyle(element).scale);
      plan(effects, element, { "transform-origin": point }, travels
        ? { "transform-origin": timed.translate }
        : null);
      plan(effects, element, declarations(slide, name, display), timed);
    }
  }
  planStacks(effects, slide, { index, from, options, mirror });
  slide.shown = index;
}
