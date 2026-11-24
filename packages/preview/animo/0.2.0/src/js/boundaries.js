// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// How a step crosses a boundary, of an epoch inside a slide and of a slide inside the deck.
//
// A slide is one `html.frame` holding one rendering of its body, and every region whose
// content changes holds an epoch stack in its footprint.
// The stack holds one rendering of the region per content state, of which one is shown at a
// time. A step that stays inside an epoch touches
// only the display state of the renderings already shown. A step that crosses a boundary
// carries the stacks that hold what changed from the outgoing rendering to the incoming one,
// which is what `transitions` below does, and every other stack shows the rendering of the
// epoch being entered without animating, because its renderings are the same picture.
//
// A slide boundary is the same mechanism one container out, and it is the whole container
// that crosses, because two slides share nothing to hold still. Two slides are laid out
// while they cross and no more: laying every slide of a deck out for the whole session
// costs a long deck seconds of first paint, which is paid at every reload of the live
// preview. See *Findings*.

/**
 * How a step carries an epoch stack from the outgoing rendering to the incoming one.
 *
 * There is one entry per transition, and the plan names the one each stack takes.
 * The record of a stack that a boundary crosses has an optional `transition`, which is the
 * name of an entry here, and an optional `args`, which is handed to the transition as part
 * of the record. A stack with
 * no `transition` crossfades, so a plan that names none is the plan of a deck in which every
 * boundary crossfades.
 *
 * `planEpoch` has already planned the state at rest of every rendering of the stack when a
 * transition runs.
 * The rendering being entered is shown and opaque, and every other rendering is hidden and
 * transparent. A transition plans effects for the renderings it carries in place
 * of those, and an effect it plans replaces the one at rest for the same element and
 * property.
 *
 * Each transition is handed the effects of the step being planned, the slide, the stack, the
 * epoch a step leaves and the one it enters, the record of the stack, how the step moves and
 * how long it lasts when it is running backwards, and takes what it needs of that.
 * It runs in the phase that reads and writes nothing, so any geometry it reads is the
 * geometry of the page before the step.
 *
 * A transition plans the state it is arriving at and animates from what the element was
 * showing into it, exactly as a display state is planned, so an interrupted boundary
 * continues from where it is and stepping backwards undoes it.
 */
const transitions = {
  /**
   * Fade the outgoing rendering of the stack out and the incoming one in, and draw the ink
   * that the two have in common at one place once, which `handOver` plans.
   *
   * A delayed crossfade starts late and a long one takes long, and either holds the boundary
   * open.
   * An outgoing rendering stays visible for the whole of the delay and the whole of the
   * duration.
   */
  crossfade(effects, slide, context) {
    const timing = scheduled(context.options, context.record.timing, context.mirror);
    if (timing !== null) {
      handOver(effects, slide, context, timing, inPlace(context));
    }
  },
  /**
   * Carry what the two renderings of the stack share from its old place to its new one, which
   * `morphStack` plans, and hand the rest over as the crossfade does.
   */
  morph(effects, slide, context) {
    const timing = scheduled(context.options, context.record.timing, context.mirror);
    if (timing !== null) {
      handOver(effects, slide, context, timing, morphStack(effects, slide, context, timing));
    }
  },
};

/**
 * Plan how the renderings of a stack hand the region over on `timing`, given the pairs of an
 * outgoing and an incoming element that a transition puts at one place.
 *
 * Of the outgoing and the incoming rendering, the one that comes first in the document is
 * drawn below the other.
 * The lower rendering stays opaque for the whole hand-over, and the upper one fades, in on a
 * forward step and out on a backward one.
 * Where both renderings have ink, the upper ink at opacity `t` over the opaque lower ink
 * shows the interpolation of the two, so nothing dips and nothing blends.
 * A pair whose two elements are identical copies is drawn once.
 * The upper copy is hidden for the length of the hand-over and takes no route, and the lower
 * copy is the one the audience sees.
 * The ink of the lower rendering without a partner fades on its own, out when that rendering
 * is the outgoing one and in when it is the incoming one.
 * Where it overlaps different ink of the upper rendering, the two dissolve as any two layers
 * do.
 *
 * Neither rendering blends and the stack does not isolate. In firefox 155, either one made
 * every frame of a morph of a long paragraph cost several times as much, and every frame of a
 * crossfade about three times as much. Drawing an identical copy once halves what a morph
 * moves, which firefox needs as well. See *Performance* for the measurements.
 *
 * Every other rendering that is showing any ink fades out on the boundary's clock. A boundary
 * crossed while an earlier one is still running finds such a rendering, which is what a long
 * `duration:` on a `replace` makes easy to reach and what a `wait:` shorter than a step or a
 * presenter clicking twice reaches as well. A rendering that is hidden has nothing to hand
 * over and stays hidden where it is.
 */
function handOver(effects, slide, { stack, from, to }, timing, pairs) {
  const outgoing = stack.renderings[from];
  const incoming = stack.renderings[to];
  let lower = null;
  if (outgoing !== undefined && incoming !== undefined) {
    const follows = outgoing.compareDocumentPosition(incoming) & Node.DOCUMENT_POSITION_FOLLOWING;
    lower = follows ? outgoing : incoming;
  }
  stack.renderings.forEach((rendering, epoch) => {
    const active = epoch === to;
    const state = { visibility: "visible", opacity: active ? "1" : "0" };
    const painting = getComputedStyle(rendering).visibility === "visible";
    if (rendering === lower) {
      // The rendering below is opaque for the whole hand-over. An incoming one that was not
      // painting is opaque at once, and one that an interrupted hand-over left partly faded
      // becomes opaque on the way. An outgoing one stays opaque until the hand-over ends.
      const opaque = showing(rendering, ["opacity"]).opacity === "1";
      if (active) {
        plan(effects, rendering, state, painting ? { opacity: timing } : null);
      } else {
        plan(effects, rendering, state, { opacity: timing }, opaque
          ? { hold: { opacity: "1" } }
          : { end: { opacity: "1" } });
      }
    } else if (active || painting) {
      plan(effects, rendering, state, { opacity: timing });
    }
  });
  if (lower === null) {
    return;
  }
  const upper = lower === outgoing ? incoming : outgoing;
  const below = (pair) => (lower === outgoing ? pair.outgoing : pair.incoming);
  const above = (pair) => (lower === outgoing ? pair.incoming : pair.outgoing);
  const copies = pairs.filter((pair) => pair.same).map(above);
  const hidden = gathered(slide, new Set(copies.flatMap((copy) => free(slide, copy))), upper);
  for (const element of hidden) {
    plan(effects, element, { opacity: "" }, { opacity: timing }, { hold: { opacity: "0" } });
    slide.handed.add(element);
  }
  for (const pair of pairs) {
    if (pair.same) {
      const element = above(pair);
      let holder = element;
      while (holder !== null && !hidden.has(holder)) {
        holder = holder.parentElement;
      }
      slide.standIns.set(element, { partner: below(pair), holder: holder ?? element });
    }
  }
  // A hidden element takes no route, because the copy below it carries what it shows.
  for (const [element, record] of slide.morphed) {
    if (record.stack === stack && within(element, hidden)) {
      const names = ["translate", ...Object.keys(record.shape ?? {})];
      plan(effects, element, Object.fromEntries(names.map((name) => [name, ""])));
      slide.morphed.delete(element);
    }
  }
  const [start, end] = lower === outgoing ? ["1", "0"] : ["0", "1"];
  for (const element of gathered(slide, new Set(ink(lower, new Set(pairs.map(below)))), lower)) {
    // An element that an interrupted hand-over was fading goes on from what it shows.
    const fresh = !slide.handing.has(element);
    plan(effects, element, { opacity: "" }, { opacity: timing }, {
      start: fresh ? { opacity: start } : null,
      end: { opacity: end },
    });
    slide.handed.add(element);
  }
}

/**
 * The pairs of an outgoing and an incoming element that draw the same ink at the same place,
 * which is what a crossfade draws once.
 *
 * Typst writes the same layout as the same attributes, so the place of an element is the
 * chain of its ancestors' `transform` and `clip-path` up to the rendering, with its own `x`,
 * `y` and `transform`, and no geometry is read from the page.
 * The labels on that chain belong to the place as well, because the display state of a tag
 * goes on its slot, and two copies under two tags may be shown differently.
 * A pair of the same place and shape whose paint differs is not identical, and the copy of
 * the upper rendering fades over the other one.
 */
function inPlace({ stack, from, to }) {
  const outgoing = stack.renderings[from];
  const incoming = stack.renderings[to];
  if (outgoing === undefined || incoming === undefined) {
    return [];
  }
  const chains = new Map();
  const chain = (node, rendering) => {
    if (node === rendering) {
      return "";
    }
    let found = chains.get(node);
    if (found === undefined) {
      const own = ["transform", "clip-path", "data-typst-label"].map(
        (name) => node.getAttribute(name) ?? "",
      );
      found = `${chain(node.parentElement, rendering)}/${own.join(" ")}`;
      chains.set(node, found);
    }
    return found;
  };
  const place = (element, rendering) => {
    const own = ["x", "y", "transform"].map((name) => element.getAttribute(name) ?? "");
    return `${chain(element.parentElement, rendering)}|${inkKey(element)}|${own.join(" ")}`;
  };
  const waiting = new Map();
  for (const element of ink(incoming, new Set())) {
    const key = place(element, incoming);
    waiting.set(key, [...(waiting.get(key) ?? []), element]);
  }
  const pairs = [];
  for (const element of ink(outgoing, new Set())) {
    const partner = waiting.get(place(element, outgoing))?.shift();
    if (partner !== undefined) {
      const same = PAINT.every((name) => element.getAttribute(name) === partner.getAttribute(name));
      pairs.push({ outgoing: element, incoming: partner, same });
    }
  }
  return pairs;
}

/**
 * Whether a hand-over may write the opacity of an element, which is when nothing else writes
 * it.
 *
 * The display state of a tag goes on its slot, and a subslide stack shows its renderings with
 * their opacity, so neither is free.
 */
function isFree(slide, element) {
  return !slide.slotted.has(element) && stackLabel(element.dataset.typstLabel) === null;
}

/** An element whose opacity a hand-over may write, or else the children that stand for it. */
function free(slide, element) {
  if (isFree(slide, element)) {
    return [element];
  }
  return Array.from(element.children)
    .filter((child) => !NOT_INK.has(child.localName))
    .flatMap((child) => free(slide, child));
}

/**
 * The elements of a set, with each group whose children are all in it standing in for them.
 *
 * One animation on a group costs less than one on each of its children, and typst draws a line
 * of text as a group of glyphs, so a paragraph is a few groups rather than a few thousand
 * glyphs.
 * Only a group that `isFree` stands in for its children.
 * `rendering` is where the walk up stops.
 */
function gathered(slide, elements, rendering) {
  const found = new Set(elements);
  let parents = new Set(Array.from(found, (element) => element.parentElement));
  while (parents.size > 0) {
    const next = new Set();
    for (const parent of parents) {
      if (
        parent === null ||
        parent === rendering ||
        found.has(parent) ||
        !isFree(slide, parent)
      ) {
        continue;
      }
      const children = Array.from(parent.children).filter(
        (child) => !NOT_INK.has(child.localName),
      );
      if (children.every((child) => found.has(child))) {
        for (const child of children) {
          found.delete(child);
        }
        found.add(parent);
        next.add(parent.parentElement);
      }
    }
    parents = next;
  }
  return found;
}

/**
 * Plan every element that an earlier hand-over still hides or fades back to rest, before a
 * step.
 *
 * A hand-over this step plans again replaces what is planned here, so an element it hides
 * again is never shown in between.
 * `slide.handing` keeps those elements for the length of the step, because a fade that goes on
 * starts from what its element shows.
 * `slide.shownBy` keeps the partners that showed the hidden elements, which a morph of this
 * step starts from, while `slide.standIns` collects the partners of this step.
 */
function settleHandOvers(effects, slide) {
  slide.handing = new Set();
  for (const element of slide.handed) {
    if (element.getAnimations().some(ours)) {
      plan(effects, element, { opacity: "" });
      slide.handing.add(element);
    }
  }
  slide.handed = new Set();
  slide.shownBy = slide.standIns;
  slide.standIns = new Map();
}

/** The transition a stack takes when its record names none, which is every ordinary one. */
const defaultTransition = "crossfade";

/**
 * The transition of an epoch boundary by the name the record of a stack carries.
 *
 * A name typst does not know is refused at compile time, so nothing unknown arrives, and a
 * record that names none takes the default.
 */
function transitionOf(name) {
  return transitions[name] ?? transitions[defaultTransition];
}

/**
 * How a step gets from one slide to the next.
 *
 * This is a separate table rather than an entry in the one above, because the two are
 * handed different things and neither could use the other's.
 * An epoch transition is given the renderings of one region, inside a slide that it holds
 * still.
 * A slide transition is given two containers and has nothing to hold still, since the two
 * slides share nothing. One
 * table would take the union of both and every entry would ignore half of it.
 *
 * A slide transition is a function of the boundary's owner, which is the slide with the
 * higher number, and of a progress `p` that is 0 where the owner is not there yet and 1 where it
 * is. `at(p, args)` gives the display state of the owner and of the other slide at one of
 * those two ends, and `planSlides` animates from what each container is showing into the
 * end a step is heading for. A forward step heads for 1 and a backward step for 0, so a
 * backward step is the forward one played from the other end and needs no direction of its
 * own. The owner comes later in the document, so it is in front in both directions.
 *
 * `blend` is the `mix-blend-mode` both containers take for the boundary, and the empty
 * string leaves the stylesheet's `plus-lighter`. Two slides that overlap while both are
 * opaque have to cover rather than add, because two opaque grounds of different colors sum
 * to a third color. A crossfade is the one transition that wants them to add.
 *
 * `front` is the role of the slide that is in front, which is the owner unless an entry
 * says otherwise. The owner comes later in the document, so it is in front without a
 * `z-index`, and only an entry that wants the other slide in front needs one.
 *
 * A `direction` is the direction of travel on a forward step, which typst writes as `ltr`,
 * `rtl`, `ttb` or `btt`. Typst states every parameter, its defaults included, so the
 * runtime holds no defaults.
 */
const slideTransitions = {
  /**
   * Fade the owner in over the other slide, which fades out.
   *
   * The two add to exactly one opaque slide at every moment through the `plus-lighter` the
   * stylesheet puts on every slide, so nothing dips halfway through, which two slides of
   * different background colors would otherwise do badly.
   */
  crossfade: {
    blend: "",
    at: (p) => ({ owner: { opacity: String(p) }, other: { opacity: String(1 - p) } }),
  },
  /** Move the owner in from one edge while it moves the other slide out at the opposite one. */
  push: {
    blend: "normal",
    at: (p, { direction }) => ({
      owner: { opacity: "1", translate: travelled(direction, p - 1) },
      other: { opacity: "1", translate: travelled(direction, p) },
    }),
  },
  /** Move the owner in from one edge over the other slide, which stays where it is. */
  cover: {
    blend: "normal",
    at: (p, { direction }) => ({
      owner: { opacity: "1", translate: travelled(direction, p - 1) },
      other: { opacity: "1" },
    }),
  },
  /**
   * Move the other slide out at one edge over the owner, which stays where it is.
   *
   * This is a cover played with the two slides swapped, so the other slide is in front.
   */
  uncover: {
    blend: "normal",
    front: "other",
    at: (p, { direction }) => ({
      owner: { opacity: "1" },
      other: { opacity: "1", translate: travelled(direction, p) },
    }),
  },
  /**
   * Show the owner over the other slide behind an edge that travels across the stage.
   *
   * The clip is an `inset` whose one side shrinks from the whole stage to nothing, and the
   * other three sides stay at zero, so the two ends of the boundary interpolate.
   */
  wipe: {
    blend: "normal",
    at: (p, { direction }) => ({
      owner: { opacity: "1", "clip-path": hidden(direction, 1 - p) },
      other: { opacity: "1" },
    }),
  },
};

/** The way each direction travels, as a fraction of the stage along each axis. */
const TRAVEL = {
  ltr: { x: 1, y: 0 },
  rtl: { x: -1, y: 0 },
  ttb: { x: 0, y: 1 },
  btt: { x: 0, y: -1 },
};

/**
 * A `translate` that has carried a container `fraction` of the stage along a direction.
 *
 * A percentage of the box of a container is a fraction of the stage, because a slide fills
 * it, so a pushed slide keeps its place at any window size without the runtime measuring
 * one.
 *
 * No travel is the empty string, which is the slide at rest, rather than a translate of
 * zero. An engine computes the two to different strings, so the next boundary would find a
 * difference where there is none and animate a property that does not change, which in
 * chromium 151 stops the `opacity` beside it from being drawn. See *Findings*.
 */
function travelled(direction, fraction) {
  const { x, y } = TRAVEL[direction];
  return fraction === 0 ? "" : `${100 * x * fraction || 0}% ${100 * y * fraction || 0}%`;
}

/**
 * A `clip-path` that hides the part of a container that an edge travelling along a
 * direction has not reached, which is `fraction` of the stage.
 *
 * The side clipped is the one the edge travels towards. The sides follow the order of
 * `inset`: top, right, bottom, left. Nothing hidden is the slide at rest, for the reason
 * `travelled` gives.
 */
function hidden(direction, fraction) {
  if (fraction === 0) {
    return "";
  }
  const side = { ltr: 1, rtl: 3, ttb: 2, btt: 0 }[direction];
  const sides = [0, 0, 0, 0];
  sides[side] = 100 * fraction;
  return `inset(${sides.map((value) => `${value}%`).join(" ")})`;
}

/** The transition a boundary takes when neither its slide nor the deck names one. */
const defaultSlideTransition = "crossfade";

/**
 * The transition the boundary above one slide takes, as `{name, args}`, or `null` for a
 * slide the deck does not have.
 *
 * `auto` resolves here rather than in typst, to the default transition of the deck, which
 * the deck states in its configuration and which is the crossfade on a page that states none.
 * A `duration` the slide's `init` states travels in `args` either way, because it belongs
 * to the slide rather than to the transition.
 * A name or a parameter typst does not know is refused at compile time, so nothing unknown
 * arrives.
 */
function slideTransitionOf(number) {
  const slide = deck.get(number);
  if (slide === undefined) {
    return null;
  }
  if (slide.transition.name !== "auto") {
    return slide.transition;
  }
  const { name = defaultSlideTransition, ...args } = config.transition ?? {};
  return { name, args: { ...args, ...slide.transition.args } };
}

/**
 * How a boundary that takes a transition is crossed, or `null` when it cuts.
 *
 * The deck's `--animo-transition-duration` is the default of a slide whose `init` states no
 * `duration`, and one it states overrides it, also when the deck's is zero, which is how a
 * deck of hard cuts pushes one slide in. A duration of zero is a cut, whatever the
 * transition. A reader who asked for less motion gets a cut everywhere, because `timing`
 * reads `--animo-motion` first.
 */
function boundaryTiming(transition) {
  if (transition === null) {
    return null;
  }
  const own = timing("--animo-transition-duration");
  if (own === null) {
    return null;
  }
  const { duration } = transition.args;
  const options = duration === undefined ? own : { ...own, duration: duration * 1000 };
  return options.duration > 0 ? options : null;
}

/**
 * Plan every slide container of the deck, and the boundary a step crosses between two.
 *
 * Every slide is planned at rest first.
 * At rest, the slide being shown is opaque, every other one is transparent, and none of them
 * is moved, clipped or blended by a transition. A slide that
 * becomes the one being entered therefore always starts from a state this function wrote.
 * The two slides a boundary crosses are then planned by its transition, in place of their
 * state at rest, and the properties of theirs that their transition does not name move to
 * rest on the boundary's clock. That is what takes a slide that a push left half way out of
 * the stage back into it when a crossfade interrupts the push.
 *
 * `options` is how the boundary moves, or `null` when it snaps, which is what a cut, a
 * duration of zero, a deep link and any jump between slides that are not neighbours all
 * produce. A boundary that snaps leaves both slides at rest.
 *
 * Each container animates from what it is showing, so an interrupted boundary continues
 * from where it is and stepping back undoes it. The exception is a slide in `fresh`, which
 * had no layout before this step and shows nothing worth continuing from.
 * Such a slide starts at the far end of the transition instead, which for a push is outside
 * the stage.
 *
 * The transition's blend and `front` stay on the two slides after the boundary has been
 * crossed, for as long as the slide being left keeps its layout. A slide that a cover or a
 * wipe has covered is still laid out under the owner, and under `plus-lighter` the two would
 * add. An owner that a backward uncover has covered is laid out under the other slide, and
 * without the `z-index` it would be in front again.
 */
function planSlides(effects, shown, leaving, options, transition, fresh) {
  for (const [number, slide] of deck) {
    const rest = { opacity: number === shown ? "1" : "0", translate: "", "clip-path": "" };
    const crossing = options !== null && (number === shown || number === leaving);
    plan(effects, slide.element, rest, crossing ? timed(rest, options) : null);
    // A blend and a stacking order are not animated, because no value between two of them
    // exists.
    plan(effects, slide.element, { "mix-blend-mode": "", "z-index": "" });
  }
  if (options === null || leaving === null) {
    return;
  }
  const entry = slideTransitions[transition.name] ?? slideTransitions[defaultSlideTransition];
  const { args } = transition;
  const owner = Math.max(shown, leaving);
  const p = shown === owner ? 1 : 0;
  const end = entry.at(p, args);
  const start = entry.at(1 - p, args);
  for (const [number, role] of [
    [owner, "owner"],
    [Math.min(shown, leaving), "other"],
  ]) {
    const element = deck.get(number).element;
    plan(effects, element, end[role], timed(end[role], options), {
      start: fresh.has(number) ? start[role] : null,
    });
    plan(effects, element, {
      "mix-blend-mode": entry.blend,
      "z-index": role === "other" && entry.front === "other" ? "1" : "",
    });
  }
}

/** One options object per property of a display state, which is what `plan` takes. */
function timed(state, options) {
  return Object.fromEntries(Object.keys(state).map((property) => [property, options]));
}

/**
 * What an epoch stack needs beside its renderings, read once with the slide.
 *
 * `region` is the label of the group of the region that holds the stack, which for a tag
 * whose content changes is the tag, and `names` is that label and every label laid out in
 * the renderings. A boundary crosses the stack when it changes one of these names, or a tag
 * that becomes no group in the region the plan names by `region`. `differs` holds, per
 * epoch, whether the rendering of that epoch differs from the one before, which is read the
 * first time a boundary asks.
 */
function readEpochStack(stack) {
  stack.names = new Set();
  stack.region = stack.element.closest("[data-typst-label]")?.dataset.typstLabel ?? null;
  if (stack.region !== null) {
    stack.names.add(stack.region);
  }
  stack.renderings.forEach((rendering) => {
    for (const group of rendering.querySelectorAll("[data-typst-label]")) {
      stack.names.add(group.dataset.typstLabel);
    }
  });
  stack.differs = [];
}

/**
 * Whether the rendering of an epoch differs from the one before it in a stack.
 *
 * A rendering that laid nothing out is not in the page, and two such renderings are the same.
 * The labelled groups of two renderings differ in their labels, so their children are
 * compared. The runtime writes the same inline style on every occurrence of a tag, so the
 * style it has written by then differs nowhere the content does not.
 */
function differs(stack, epoch) {
  let found = stack.differs[epoch];
  if (found === undefined) {
    const before = stack.renderings[epoch - 1];
    const after = stack.renderings[epoch];
    if (before === undefined || after === undefined) {
      found = before !== after;
    } else {
      const a = Array.from(before.childNodes);
      const b = after.childNodes;
      found = a.length !== b.length || a.some((node, i) => !node.isEqualNode(b[i]));
    }
    stack.differs[epoch] = found;
  }
  return found;
}

/**
 * The epoch stacks a step carries across the boundaries it crosses, each with its record, as
 * a map, and every hand-over and morph an earlier step left running planned for this one.
 *
 * A stack is carried when a boundary changes a tag it holds, which is a tag whose group is
 * in the stack or a tag without a group that the plan places in the stack's region. It is
 * also carried when its renderings on the two sides of the boundary differ. Its record is
 * the plan's record of the first tag the boundary changes in it, and `names` holds every tag
 * the step changes in it, which a morph does not match. The operations of one stack agree
 * about the timing and the transition, because typst refuses a boundary otherwise. A stack
 * whose renderings differ while the plan names no tag of it, which is a region whose site
 * typst had not reported when it wrote the plan, crossfades on the default timing of the deck.
 *
 * A step that animates hands over every boundary between the two epochs, which is one for an
 * ordinary step and several for a backward step that walked over a join. A step that snaps
 * hands over none, which is what a deep link and a clamped fragment get.
 *
 * A step over more than one boundary drops the timings of the operations that opened them,
 * as it drops the schedules of the steps it walked over, because those steps are ones the
 * deck ran through, and the one clock left is the clock of this step.
 * A stack that two of the boundaries change takes the record of the first.
 */
function planBoundary(effects, slide, { index, from, options, mirror }) {
  const to = slide.states[index]?.epoch ?? 0;
  const carried = new Map();
  if (options !== null && from !== null && from !== to) {
    const walked = Math.abs(to - from) > 1;
    for (let epoch = Math.min(from, to) + 1; epoch <= Math.max(from, to); epoch += 1) {
      const { changed, regions } = slide.epochs[epoch] ?? { changed: {}, regions: {} };
      for (const stack of slide.stacks) {
        if (stack.kind !== "epoch") {
          continue;
        }
        const names = Object.keys(changed).filter((name) => stack.names.has(name));
        if (Object.hasOwn(regions, stack.region) && !names.includes(regions[stack.region])) {
          names.push(regions[stack.region]);
        }
        const found = carried.get(stack);
        if (found !== undefined) {
          found.names.push(...names.filter((name) => !found.names.includes(name)));
          continue;
        }
        if (names.length === 0 && !differs(stack, epoch)) {
          continue;
        }
        const { timing, ...untimed } = names.length === 0 ? {} : changed[names[0]];
        const record = { ...untimed, names };
        if (!walked && timing !== undefined) {
          record.timing = timing;
        }
        carried.set(stack, record);
      }
    }
  }
  // The earlier hand-overs and morphs are settled before the transitions, so that a transition
  // of this step that hides, fades or matches an element again plans it in place of what an
  // earlier one was doing to it.
  settleHandOvers(effects, slide);
  settleMorphs(effects, slide, to, carried, options, mirror);
  return carried;
}

/**
 * Plan the rendering of an epoch stack that a state belongs to, which is how an epoch stack
 * is planned for a state.
 *
 * Which rendering is shown is decided here, for every transition alike.
 * The rendering of the epoch the state belongs to is shown and opaque,
 * and every other one is hidden and transparent.
 * That is the state at rest, and a stack that the step carries across a boundary is then
 * planned by the transition its record names, in place of its state at rest. One boundary
 * may therefore carry one stack with one transition and another stack with another.
 *
 * A step that stays inside one epoch still plans this, because the rendering it is showing
 * is already the right one and writing the state it is in changes nothing.
 * Such a step that interrupts a hand-over takes the stack to rest at once, together with
 * every element the hand-over hid or faded, which `settleHandOvers` plans.
 */
function planEpoch(effects, slide, stack, { index, from, options, mirror }, carried) {
  const to = slide.states[index]?.epoch ?? 0;
  stack.renderings.forEach((rendering, epoch) => {
    const active = epoch === to;
    plan(effects, rendering, {
      visibility: active ? "visible" : "hidden",
      opacity: active ? "1" : "0",
    });
  });
  const record = carried.get(stack);
  if (record !== undefined) {
    transitionOf(record.transition)(effects, slide, { stack, from, to, record, options, mirror });
  }
}
