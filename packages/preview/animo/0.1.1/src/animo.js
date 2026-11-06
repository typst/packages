// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// The animo presentation runtime.
//
// It keeps one position, `<slide>.<state>`, and four things in step with it:
// which slide container is shown, the display state of that slide's tags, the URL
// fragment, and the `data-animo` attribute of the root element. The fragment is what
// makes a position addressable, which a deep link, a test and the reload of `typst watch`
// all need; the attribute is what lets a reader of the DOM see the position the runtime
// actually reached.
//
// A step animates, within a slide and across one slide boundary alike; everything else
// snaps. Restoring a position therefore snaps to it rather than animating into it, and so
// does any jump that is not between neighbouring slides.
// The fragment is written with `replaceState`, so stepping leaves no history behind.
//
// A slide is one `html.frame` holding one rendering per content state, stacked at one
// point, of which one is shown at a time. A step that stays inside an epoch touches only
// the display state of the rendering it is already showing. A step that crosses a boundary
// hands over the regions whose content changed, which is what `transitions` below does,
// and leaves everything else alone, because the two renderings are pixel-identical outside
// those regions.
//
// A slide boundary is the same mechanism one container out, and it is the whole container
// that crosses, because two slides share nothing to hold still. Two slides are laid out
// while they cross and no more: laying every slide of a deck out for the whole session
// costs a long deck seconds of first paint, which is paid at every reload of the live
// preview. See *Findings*.
//
// Motion is driven by the Web Animations API rather than by CSS transitions.
// Each step writes the state's display state as inline style on the tag's inner group and
// animates from what the element was showing to that, so the style is the state and the
// animation is only how it got there: a step interrupted halfway continues from where it
// is, stepping backwards lands on exactly the geometry the earlier state had, and a
// deep link needs no transition to suppress.
//
// When a step starts an animation it never says when it began.
// Every animation of one step is created in one task, so they are all pending until the
// same frame and all take that frame's time, which gives the step one clock by
// construction, and that clock is the one an epoch crossfade joins.
// `document.timeline.currentTime` is the time of the last frame the browser drew, and
// firefox 153 draws no frames at all while the page sits still, so on a deck being read
// rather than clicked through it lags by as long as the reader paused, and an animation
// told it began then is already over.
// See *Findings*.

/** One slide of the deck, as the runtime needs it, read from the DOM once. */
function readSlide(element) {
  const plan = JSON.parse(element.dataset.animoPlan || '{"states":[]}');
  // Every occurrence of a tag name, in every epoch rendering of this slide, because
  // continuous state belongs to the slide and not to the rendering that is showing.
  const slots = new Map();
  for (const group of element.querySelectorAll("[data-typst-label]")) {
    const slot = group.querySelector(":scope > g");
    if (slot === null) {
      continue;
    }
    const name = group.dataset.typstLabel;
    const found = slots.get(name);
    if (found === undefined) {
      slots.set(name, [slot]);
    } else {
      found.push(slot);
    }
  }
  // What each boundary redraws, by epoch, where epoch i holds the groups that the step
  // into it changes, each with the timing of the operations that changed it.
  // The first epoch begins no boundary.
  const epochs = (plan.epochs ?? [{}]).map((epoch) => epoch.regions ?? []);
  const carried = new Set(epochs.flat().map((region) => region.group));
  return {
    element,
    canvas: element.querySelector(":scope > .animo-canvas"),
    slots,
    // The epoch renderings, in epoch order, each with the region groups a boundary may
    // carry across. A group is looked up once here rather than per step, and by its own
    // label, because a label is a tag name and a name is whatever the author wrote.
    // The renderings are groups placed at one point in the slide's single frame rather
    // than frames of their own, which is what shares their glyph definitions.
    renderings: Array.from(
      element.querySelectorAll(
        ':scope > .animo-canvas [data-typst-label^="animo-epoch-"]',
      ),
      (rendering) => ({
        element: rendering,
        regions: Array.from(rendering.querySelectorAll("[data-typst-label]")).filter(
          (group) => carried.has(group.dataset.typstLabel),
        ),
      }),
    ),
    epochs,
    states: plan.states ?? [],
    count: Math.max(1, Number(element.dataset.animoStates ?? 1)),
    // How the boundary above this slide is crossed: the name of a strategy, `auto` for
    // the deck's own, or `none` for a cut. It is the setting of the slide a forward step
    // enters and is used in both directions.
    transition: element.dataset.animoTransition ?? "auto",
    margin: plan.margin ?? 0,
    size: plan.canvas ?? null,
    // The renderings of a `per-subslide`, by state: one label per state of the slide, and
    // any number of groups under each, because one slide may carry several stacks and one
    // stack sits in every epoch rendering it was written in.
    // A stack is looked up once here rather than per step, as the tag slots above are.
    subslides: Array.from(element.querySelectorAll('[data-typst-label^="animo-subslide-"]'))
      .reduce((found, group) => {
        const state = Number(group.dataset.typstLabel.slice("animo-subslide-".length));
        (found[state] ??= []).push(group);
        return found;
      }, []),
    // Where the tags the plan is relative to sit, measured when the slide is first shown.
    anchors: null,
    // Which state this slide is showing, or `null` while it has never been rendered.
    // Its own rather than the deck's position, because a backward step that walks back
    // over a join leaves one slide and rewinds another, and the state it rewinds from is
    // the one this slide was left at.
    shown: null,
  };
}

const deck = new Map(
  Array.from(document.querySelectorAll("[data-animo-slide]"), (element) => [
    Number(element.dataset.animoSlide),
    readSlide(element),
  ]),
);
const last = deck.size;

/** How many states a slide has, which is one more than its number of subslide steps. */
function count(number) {
  return deck.get(number)?.count ?? 1;
}

/** Read the position from the URL fragment, falling back to the first slide. */
function parseHash() {
  const found = /^(\d+)\.(\d+)$/.exec(location.hash.slice(1));
  if (found === null) {
    return { slide: 1, state: 0 };
  }
  return { slide: Number(found[1]), state: Number(found[2]) };
}

/** Bring a position inside the deck, so that a hand-written fragment cannot leave it. */
function clamp(position) {
  const slide = Math.min(Math.max(position.slide, 1), last);
  return { slide, state: Math.min(Math.max(position.state, 0), count(slide) - 1) };
}

/** A CSS time as a number of milliseconds, or zero when it is not one. */
function milliseconds(value) {
  const found = /^\s*(-?[\d.]+)(ms|s)\s*$/.exec(value);
  if (found === null) {
    return 0;
  }
  return Number(found[1]) * (found[2] === "s" ? 1000 : 1);
}

/**
 * How a step moves, read from the stylesheet at every step, or `null` when it snaps.
 *
 * The values live in CSS rather than in this file: the deck writes its `primitive-duration:`,
 * `transition-duration:` and `easing:` arguments there, and a reader who asked for less motion
 * gets a duration of zero from the media query that outranks them.
 * `property` is which duration is wanted: a primitive within a slide and a slide boundary
 * have one each, so a deck of hard cuts between slides keeps the motion inside them.
 * A duration of zero and a `transition: none` therefore reach the same `null`, which is
 * the one path that has no animation in it at all.
 */
function timing(property = "--animo-primitive-duration") {
  const style = getComputedStyle(document.documentElement);
  const duration = milliseconds(style.getPropertyValue(property));
  if (!(duration > 0)) {
    return null;
  }
  // An easing the stylesheet does not state is no easing at all.
  const easing = style.getPropertyValue("--animo-easing").trim() || "linear";
  return { duration, easing, fill: "none" };
}

/**
 * The options of one effect: the deck's own, held back and stretched by its operation's.
 *
 * A delay becomes the effect's delay and a duration the effect's duration, rather than a
 * timer of its own, which is what keeps the step's one clock: every animation of a step is
 * still created in one task and measured from the same instant.
 * A duration the operation does not state is the deck's own, `--animo-primitive-duration`,
 * so that a change of the deck's tempo reaches every operation that said nothing
 * and leaves the ones that did alone.
 *
 * Only a delay needs `fill: backwards`. The display state is written as inline style before
 * the animation is created, so an effect that does not hold its first keyframe while it
 * waits shows the state it is going to reach and then jumps back to where it started.
 *
 * A step that snaps stays snapped, delays and durations alike: `options` is `null` when the
 * deck's duration is zero, which is what a reader who asked for less motion, a deep link
 * and the first paint all get. A `duration:` that an operation states is covered by the
 * same rule and by no second one, because a media query cannot reach a number written in a
 * typst source.
 *
 * `mirror` is how long the step lasts, and it turns the schedule around.
 * A backward step is the forward one played from the other end, so an operation that ran
 * from `delay` to `delay + duration` runs from `mirror - delay - duration` instead and
 * takes exactly as long.
 * The last thing to arrive is then the first to leave, so a backward step undoes a forward
 * one in time as well as in geometry. It is `null` for a step that plays forwards.
 */
function scheduled(options, timing, mirror = null) {
  if (options === null) {
    return null;
  }
  const duration =
    timing?.duration === undefined ? options.duration : timing.duration * 1000;
  const own = duration === options.duration ? options : { ...options, duration };
  const stated = (timing?.delay ?? 0) * 1000;
  const delay = mirror === null ? stated : mirror - stated - duration;
  return delay > 0 ? { ...own, delay, fill: "backwards" } : own;
}

/**
 * How long one step lasts, in milliseconds, which is what a backward step mirrors about.
 *
 * The step ends when the last of its operations does, so this is the largest
 * `delay + duration` over all of them. The resolver could only add up the operations that
 * stated a duration, because the one an operation does not state lives in the stylesheet,
 * so it hands over the two halves and they are added here: `stated` is the largest end it
 * could compute, and `unstated` the largest delay of the operations whose duration is the
 * deck's own.
 *
 * A step that states no timing at all carries no span, and lasts exactly one step of the
 * deck, which is what every operation of it takes.
 */
function span(record, options) {
  // A step that carries no record is one whose every operation starts with it and takes the
  // deck's own step, which is an unstated delay of zero, so that is what stands in for it.
  // An absent `unstated` beside a `stated` is the other case and adds nothing, because the
  // step holds no operation whose duration the stylesheet owns.
  const { stated, unstated } = record ?? { unstated: 0 };
  return Math.max(
    stated === undefined ? 0 : stated * 1000,
    unstated === undefined ? 0 : unstated * 1000 + options.duration,
  );
}

/** The canvas origin, which is the anchor a position with no `relto` is measured from. */
const ORIGIN = { x: 0, y: 0 };

/**
 * Where one position puts what it addresses, in typst points.
 *
 * `anchor(relto) + offset - anchor(self)`, where the anchor of `null` is the canvas origin.
 * `self` is the moved tag, or `null` for the viewport, which is anchored at the origin too.
 * A pair whose anchor is the tag's own name is therefore the identity, which is what a tag
 * the timeline never moved carries, and it needs no anchor to resolve.
 *
 * An anchor the page does not have leaves the offset alone, which can only happen on a page
 * edited by hand: typst refuses a timeline relative to a tag its slide does not have.
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
 * Only the individual transform properties, never the `transform` shorthand: it would
 * clobber the positioning typst wrote on the labelled group that holds this one.
 * A length inside a frame's SVG is a user unit, which is a typst point, so a move stays
 * the same fraction of the slide at any window size without the runtime measuring one.
 *
 * One `scale` value rather than two while the two axes agree, because a property whose
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
 * Centre the transforms of one slot on the element's own box.
 *
 * Without this a `scale` grows the element about the origin of the whole frame and moves it
 * far across the slide. Both declarations are written here, on the one element the runtime
 * transforms, and never as a rule in the stylesheet: they re-anchor the element's own
 * `transform` attribute as much as the properties beside it, so a selector broad enough to
 * reach a group typst positioned displaces it, silently and with no transform property set
 * at all. A labelled group is not always a tag site, because a region's footprint carries
 * a label too, and its children are the region's content. See *Findings*.
 */
function centreTransforms(element) {
  element.style.transformBox = "fill-box";
  element.style.transformOrigin = "center";
}

/**
 * The tags whose anchor this slide's plan asks for, as a set of names.
 *
 * A position is `anchor(relto) + offset - anchor(self)`, so a pair naming the tag's own
 * anchor asks for nothing: the two terms cancel whatever that anchor is. Every state of a
 * plan holds every addressed tag, so a slide of tags that merely appear asks for none.
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
 * Where the first site of every tag the plan asks about sits on the canvas, in points.
 *
 * The anchor is the origin of the tag's labelled group, which is the top-left corner of the
 * wrapper typst laid out, and not the box of its ink: that is the corner the paged outputs
 * read as well, so the two targets resolve the same quantity rather than two neighbours.
 * It is mapped into the user space of the frame, whose units are typst points and whose
 * origin is the canvas origin, so the pan of the canvas cancels out of it.
 *
 * The first site is the first occurrence in document order, which is in the first epoch
 * rendering that lays the tag out, since the renderings are placed in epoch order.
 *
 * It has to be read while the slide has a layout and before the runtime has written a
 * display state on it, because a tag around the anchor would otherwise move it by
 * whatever state that happens to be.
 */
function measureAnchors(slide) {
  const anchors = new Map();
  for (const name of wantedAnchors(slide)) {
    const group = slide.slots.get(name)?.[0]?.parentNode;
    if (group === undefined) {
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
 * A percentage, because a translate in percent is a fraction of the canvas's own box, which
 * follows the window as the canvas does, and it animates in every engine: a length written
 * as a multiple of `--animo-unit` would have to put a custom property into a keyframe.
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

/** What an element is showing right now, for the properties named, as `declarations` has it. */
function showing(element, names) {
  const computed = getComputedStyle(element);
  const read = {
    opacity: () => computed.opacity,
    translate: () => (computed.translate === "none" ? "0px 0px" : computed.translate),
    scale: () => (computed.scale === "none" ? "1" : computed.scale),
  };
  return Object.fromEntries(names.map((name) => [name, read[name]()]));
}

/**
 * Put a display state on one element, animating into it unless the step snaps.
 *
 * `options` is `null` for a step that snaps, and otherwise one options object per property
 * of `to`, because two operations of one step may start at different moments and an effect
 * has one delay.
 */
function put(element, to, options) {
  const names = Object.keys(to);
  const from = options === null ? null : showing(element, names);
  for (const animation of element.getAnimations()) {
    animation.cancel();
  }
  Object.assign(element.style, to);
  if (from === null) {
    return;
  }
  // What the element now computes, rather than what was just written: an engine
  // normalises what it computes, and chromium 151 gives back `0px` for the `0px 0px` of
  // a tag at rest, so comparing the two spellings finds a difference where there is none.
  const into = showing(element, names);
  // Only the properties this step actually changes, because in chromium 151 a `translate`
  // or `scale` that is equal at both ends stops the browser from drawing the `opacity`
  // beside it, and the element stays as it was until the step ends and then jumps.
  // Measured; see *Findings*.
  const changed = names.filter((name) => from[name] !== into[name]);
  // One effect per group of properties that are timed alike, so that a step whose
  // operations are timed alike, which is every step that says nothing about timing, is
  // still one effect on this element.
  const groups = new Map();
  for (const name of changed) {
    const found = groups.get(JSON.stringify(options[name]));
    if (found === undefined) {
      groups.set(JSON.stringify(options[name]), { timing: options[name], names: [name] });
    } else {
      found.names.push(name);
    }
  }
  for (const group of groups.values()) {
    const only = (values) =>
      Object.fromEntries(group.names.map((name) => [name, values[name]]));
    element.animate([only(from), only(into)], group.timing);
  }
}

/**
 * How a step gets from the outgoing epoch rendering to the incoming one.
 *
 * One entry per strategy, and one selection below, because a step does not choose between
 * them. A morph between the two layouts of a region is the intended second entry and needs
 * the same seam, which is what the geometry of both renderings being readable is for.
 *
 * Each strategy is handed the renderings, the epoch a step leaves and the one it enters,
 * the groups of the regions whose content the boundary redraws, how the step moves and how
 * long it lasts when it is running backwards, and takes what it needs of that: the
 * crossfade below needs no `from`, where the morph will read the outgoing rendering's
 * geometry. An empty list of regions tells the strategy to snap, which is what a deep link,
 * a step inside one epoch and a reader who asked for less motion all produce.
 *
 * A strategy writes the state it is arriving at as style and animates from what the
 * element was showing into it, exactly as a display state is written, so an interrupted
 * boundary continues from where it is and stepping backwards undoes it.
 */
const transitions = {
  /**
   * Crossfade the regions the boundary redraws, and nothing else.
   *
   * The incoming rendering is shown whole and at once, which is invisible because the
   * renderings are pixel-identical everywhere but in those regions. Every other rendering
   * is hidden, and only the regions it is handing over take their visibility back, so it
   * paints nowhere else and the containment is exact rather than blended to within a
   * rounding error. The halves of one region add to one through the `plus-lighter` the
   * stylesheet puts on the renderings.
   *
   * Every rendering that is not the one being entered hands the region over, and not only
   * the one the step is leaving. A boundary crossed while an earlier one is still running
   * finds two of them painting the region, which is what a long `duration:` on a `replace`
   * makes easy to reach and what a `wait:` shorter than a step or a presenter clicking
   * twice reaches as well. Fading all of them out on the new boundary's clock is what
   * keeps the sum at one: the outgoing renderings leave under one easing while the
   * incoming one arrives under its complement, whatever they were showing when it began.
   * A rendering no boundary is crossing is at zero already, so writing it changes nothing.
   *
   * A boundary that bounds its change in no region hands the whole rendering over instead,
   * and the two renderings crossfade as they are. Nothing outside the changed area is still
   * in that case, so there is nothing to contain the blend to.
   */
  crossfade(slide, { to, regions, options, mirror }) {
    // An entry with no group of its own names the rendering itself, which is what a change
    // that no region bounds redraws: a `wrap: none` tag outside any region has no box to
    // confine the change to. The rendering then hands its own ink over as a region hands
    // its own, and every region in it stays opaque, because each rendering is a complete
    // picture and the crossfade is between the two of them.
    const whole = regions.find((region) => region.group === null);
    slide.renderings.forEach((rendering, epoch) => {
      const active = epoch === to;
      // Whether this rendering hands a region over, which is what it paints through while
      // the rest of it is hidden.
      const handing =
        whole === undefined &&
        !active &&
        rendering.regions.some((group) =>
          regions.some((region) => region.group === group.dataset.typstLabel),
        );
      // A rendering hands its own ink over only if it is showing any: the one being left,
      // and any that a boundary this one interrupted is still fading out. One that is
      // showing none has nothing to hand over and stays hidden where it is.
      const leaving =
        whole !== undefined &&
        !active &&
        getComputedStyle(rendering.element).visibility === "visible";
      const fading = whole !== undefined && (active || leaving);
      rendering.element.style.visibility = active || leaving ? "visible" : "hidden";
      // A rendering is opaque when it is the one being shown, and when it is handing a
      // region over, which it paints through the visibility that region takes back.
      // It is transparent on every other, so that the rendering a whole boundary enters
      // has a state to come up from and the one it leaves has one to go down to: a
      // rendering hidden by its visibility alone has none, and would arrive at once.
      put(
        rendering.element,
        { opacity: active || handing ? "1" : "0" },
        fading ? { opacity: scheduled(options, whole.timing, mirror) } : null,
      );
      for (const group of rendering.regions) {
        const carried =
          whole === undefined
            ? regions.find((region) => region.group === group.dataset.typstLabel)
            : undefined;
        group.style.visibility = carried && !active ? "visible" : "";
        // A delayed region crossfades late and a long one crossfades slowly, which is what
        // holds the boundary open: an outgoing rendering keeps the visibility of the
        // regions it is handing over, so it paints them for the whole of the delay and the
        // whole of the duration.
        const effect = carried
          ? { opacity: scheduled(options, carried.timing, mirror) }
          : null;
        put(group, { opacity: active || whole !== undefined ? "1" : "0" }, effect);
      }
    });
  },
};

/** The strategy every epoch boundary of every deck takes. */
const transition = transitions.crossfade;

/**
 * How a step gets from one slide to the next.
 *
 * A table of its own rather than an entry in the one above, because the two are handed
 * different things and neither could use the other's. An epoch strategy is given the
 * renderings of one slide and the regions a boundary carries across, which it holds
 * still; a slide strategy is given two containers and has nothing to hold still, since
 * the two slides share nothing. One table would take the union of both and every entry
 * would ignore half of it. The seam is the same one, and richer slide transitions than a
 * crossfade and a cut are a second entry here, as the morph is a second entry above.
 *
 * `options` is how the boundary moves, or `null` when it snaps, which is what a cut, a
 * duration of zero, a deep link and any jump between slides that are not neighbours all
 * produce.
 */
const slideTransitions = {
  /**
   * Crossfade the two whole containers, and hand every other slide's opacity to zero.
   *
   * The slide being entered animates up from zero and the one being left down to it,
   * both through the `plus-lighter` the stylesheet puts on every slide, so the two add
   * to exactly one opaque slide at every moment and nothing dips halfway through, which
   * two slides of different background colours would otherwise do badly.
   * Every other slide is snapped to zero rather than left alone: that is what a slide
   * carries when it becomes the one being entered, so a boundary always has an opacity
   * to animate up from, and it is what cancels an animation left in flight on a slide
   * the deck has stepped past.
   */
  crossfade(shown, leaving, options) {
    for (const [number, slide] of deck) {
      const active = number === shown;
      const crossing = active || number === leaving;
      put(slide.element, { opacity: active ? "1" : "0" }, crossing ? { opacity: options } : null);
    }
  },
};

/** The strategy a boundary takes when its slide says `auto`, which is every ordinary one. */
const defaultSlideTransition = "crossfade";

/**
 * The strategy one boundary takes, by the name its slide carries.
 *
 * `auto` resolves here rather than in typst, so that the deck's own strategy is one
 * constant and a slide that named nothing follows it.
 * `none` resolves here too, and to the same entry: a cut still writes what the two
 * containers are showing, and what makes it a cut is the `null` timing `boundaryTiming`
 * hands it. So only a name of a strategy overrides the default, which is why the lookup
 * falls through rather than branching on the two literals.
 * A name typst does not know is refused at compile time, so nothing unknown arrives.
 */
function slideTransitionOf(name) {
  return slideTransitions[name] ?? slideTransitions[defaultSlideTransition];
}

/**
 * How the boundary above one slide is crossed, or `null` when it cuts.
 *
 * The slide named is the one a forward step enters, and its setting is what both
 * directions take, so stepping back over a boundary undoes exactly what stepping forward
 * over it did.
 */
function boundaryTiming(number) {
  const name = deck.get(number)?.transition;
  return name !== undefined && name !== "none" ? timing("--animo-transition-duration") : null;
}

/**
 * Show the epoch rendering that a state belongs to.
 *
 * A step that stays inside one epoch still writes this, because the rendering it is
 * showing is already the right one and writing the state it is in changes nothing.
 * A step that animates hands over every boundary between the two epochs, which is one for
 * an ordinary step and several for a backward step that walked over a join. A step that
 * snaps hands over none, which is what a deep link and a clamped fragment get.
 *
 * A step over more than one boundary drops the timings of the operations that opened them,
 * as it drops the schedules of the steps it walked over: those steps are ones the deck ran
 * through, and the one clock left is this step's own. A region that two of the boundaries
 * redraw is therefore carried once and by whichever entry is found first, since the two
 * say the same thing once their timings are gone.
 */
function putEpoch(slide, index, from, options, mirror) {
  const to = slide.states[index]?.epoch ?? 0;
  const crossed = [];
  if (options !== null && from !== null) {
    for (let epoch = Math.min(from, to) + 1; epoch <= Math.max(from, to); epoch += 1) {
      crossed.push(...(slide.epochs[epoch] ?? []));
    }
  }
  const regions = Math.abs(to - from) > 1 ? crossed.map(({ group }) => ({ group })) : crossed;
  transition(slide, { from, to, regions, options, mirror });
}

/**
 * Put one state of a slide on its canvas, on its epoch renderings, and on every
 * occurrence of every tag it addresses.
 *
 * The pan goes on the canvas and never on the frame inside it: the epoch renderings are
 * stacked in that frame, so moving the canvas moves them all and keeps them registered.
 * The canvas is an HTML element, so its `translate` composes with nothing typst wrote.
 *
 * Continuous state is written on every occurrence in every rendering and not only in the
 * one being shown, so that entering an epoch needs no initialisation and a step that both
 * replaces and moves a tag moves it by the same amount in the rendering it leaves and in
 * the one it arrives at.
 *
 * Every animation of the step, the boundary's included, is created here in one task, so
 * none of them is told when it began and the browser starts them all on the same frame.
 *
 * `step` is the state whose own operations are being walked, which is the higher of the
 * two a step runs between, forwards and backwards alike: one step is one schedule, and a
 * backward step is that schedule mirrored rather than a schedule of its own. A backward
 * step that walked over a join runs between states that are not neighbours, and the
 * schedules of the steps it walked over go with them: what the audience saw across a join
 * was one motion redirected before it arrived, which neither schedule replayed on its own
 * reproduces, so the way back is one motion too.
 *
 * `reverse` says which way that schedule is read. Every effect of a backward step is
 * mirrored about the length of the step it undoes, so the operation that arrived last is
 * the one that leaves first, and the step ends where the earlier state began.
 */
function render(slide, index, options, { from = null, step = index, reverse = false } = {}) {
  const state = slide?.states[index];
  if (state === undefined) {
    return;
  }
  const timings = slide.states[step]?.timing ?? {};
  const mirror =
    reverse && options !== null ? span(slide.states[step]?.span, options) : null;
  if (slide.canvas !== null && slide.size !== null) {
    put(slide.canvas, viewport(slide, state), options === null
      ? null
      : { translate: scheduled(options, timings.pan, mirror) });
  }
  for (const [name, display] of Object.entries(state.tags ?? {})) {
    const own = timings.tags?.[name] ?? {};
    const effects =
      options === null
        ? null
        : {
            opacity: scheduled(options, own.opacity, mirror),
            translate: scheduled(options, own.translate, mirror),
            scale: scheduled(options, own.scale, mirror),
          };
    for (const element of slide.slots.get(name) ?? []) {
      centreTransforms(element);
      put(element, declarations(slide, name, display), effects);
    }
  }
  putEpoch(slide, index, from, options, mirror);
  putSubslides(slide, index);
  slide.shown = index;
}

/**
 * Show the rendering that belongs to a state, out of the stack that holds one per state.
 *
 * This is how a value finer than a slide number reaches the page at all.
 * One epoch rendering covers a run of states, so typst renders every value and the choice
 * is made here.
 *
 * It snaps rather than animating, in a step that animates as much as in one that does not.
 * A number is read rather than watched, and two numbers crossfading into each other are
 * two numbers neither of which can be read; the stylesheet's `plus-lighter` would make
 * them add rather than cover as well.
 */
function putSubslides(slide, index) {
  slide.subslides.forEach((groups, state) => {
    for (const group of groups) {
      group.style.opacity = state === index ? "1" : "0";
    }
  });
}

let current = { slide: 1, state: 0 };

/** Show a position, and publish it in the fragment and on the root element. */
function show(position, animate = false) {
  const wanted = clamp(position);
  const from = current.slide;
  const crossing = wanted.slide !== from;
  // Only a step across one slide boundary animates: a deep link, the first paint, `Home`,
  // `End` and any longer jump snap, because the state they would animate into is one the
  // audience was shown no route to. A backward step that walked over a join spanning a
  // whole slide is the one longer jump that had a route, and it snaps all the same: a
  // container has one opacity, so the slide passed through would have to be faded out
  // beside the one being left, and one slide to hand over is what this seam is shaped for.
  const neighbour = Math.abs(wanted.slide - from) === 1;
  const boundary =
    animate && crossing && neighbour
      ? boundaryTiming(Math.max(wanted.slide, from))
      : null;
  const slide = deck.get(wanted.slide);
  // Which state the slide being entered is showing, which is where its own motion starts
  // and which is not the deck's position when a join is being walked back over.
  const shown = slide?.shown ?? null;
  // Whether that slide moves into the state it is asked for rather than snapping into it.
  // A step that stays on one slide does. So does a backward step into the slide next door,
  // which is how a join that runs out of a slide is undone: the audience saw that slide's
  // motion and the boundary at once, so the way back plays both at once too, each on the
  // duration it took going forward. A forward step snaps, because the slide it enters at
  // state 0 may still be showing a state from an earlier visit, and rewinding that is a
  // route the audience was never shown.
  const moving =
    animate && shown !== null && (!crossing || (neighbour && wanted.slide < from));
  const left = moving ? (slide.states[shown]?.epoch ?? 0) : null;
  // Which step's operations are being walked: the higher of the two states, forwards and
  // backwards alike, so that a backward step mirrors the schedule of the step it undoes.
  const walked = moving ? Math.max(shown, wanted.state) : wanted.state;
  // A step that lands below the state it starts from is that step played from the other
  // end, which is the whole of the difference between the two directions here.
  const reverse = moving && wanted.state < shown;
  current = wanted;
  // The slide being left keeps its layout for as long as the deck stays where it is, so
  // that stepping back over the same boundary finds it laid out already. Nothing else
  // is, so a deck pays for two slides however long it is.
  const leaving = boundary === null ? null : from;
  for (const [number, other] of deck) {
    other.element.toggleAttribute("data-animo-current", number === current.slide);
    other.element.toggleAttribute("data-animo-leaving", number === leaving);
  }
  // A slide the runtime is not using has no layout, so its anchors wait until the loop
  // above lays it out, which is still before anything has been written on it: a slide is
  // laid out because it is being entered or because it is being left, and a slide is only
  // ever left after it has been entered.
  if (slide !== undefined && slide.anchors === null) {
    slide.anchors = measureAnchors(slide);
  }
  // In the same task as the state below, so that a boundary and whatever it carries are
  // created together and take the same frame's time, which is the step's one clock.
  // The slide being entered takes the deck's own step where the boundary takes the deck's
  // slide duration: a join is two clocks started on one frame, going back as coming.
  slideTransitionOf(slide?.transition ?? "auto")(current.slide, leaving, boundary);
  render(slide, current.state, moving ? timing() : null, {
    from: left,
    step: walked,
    reverse,
  });
  const hash = `#${current.slide}.${current.state}`;
  if (location.hash !== hash) {
    history.replaceState(null, "", hash);
  }
  document.documentElement.dataset.animo = `${current.slide}.${current.state}`;
  arm();
}

/**
 * Step one position forward or backward, crossing slide boundaries.
 *
 * A backward step lands where `landing` walks to, which is the nearest earlier state the
 * deck would rest at, and it turns the deck around. The clock carries a deck back over the
 * gaps it carried it forward over, so a run the presenter got through on one press is
 * undone on one press. Where that travel comes to rest is `arm`'s answer.
 *
 * A forward step puts back the clock that backward travel stopped at the first state of the
 * deck. A deck whose gap at that position waits for the presenter has no clock to stop, so
 * `Space` and every other key keep the behaviour they have there.
 */
function step(delta) {
  const target = delta > 0 ? after(current) : landing(current);
  if (target === null) {
    return;
  }
  direction = Math.sign(delta);
  if (delta > 0 && suspended) {
    paused = false;
    suspended = false;
  }
  show(target, true);
}

/**
 * The position after one, or `null` at the end of the deck.
 *
 * Stepping past the last state of a slide enters the next one, which is the rule the
 * presenter's own forward key follows, so a gap inside a slide and a gap across a slide
 * boundary are the same timer on the same sequence of positions.
 */
function after(position) {
  if (position.state + 1 < count(position.slide)) {
    return { slide: position.slide, state: position.state + 1 };
  }
  return position.slide < last ? { slide: position.slide + 1, state: 0 } : null;
}

/** The position before one, or `null` at the start of the deck. */
function before(position) {
  if (position.state > 0) {
    return { slide: position.slide, state: position.state - 1 };
  }
  const slide = position.slide - 1;
  return position.slide > 1 ? { slide, state: count(slide) - 1 } : null;
}

/** A state's own number of seconds under one key, in milliseconds, or `null`. */
function secondsOf(position, key) {
  const seconds = deck.get(position.slide)?.states[position.state]?.[key];
  return typeof seconds === "number" ? seconds * 1000 : null;
}

/**
 * How long the deck holds a position before leaving it, in milliseconds, or `null` for a
 * presenter click.
 *
 * A gap is timed by the `hold:` of the state before it or by the `wait:` of the state
 * after it, never by both, which the resolver and the deck refuse at compile time. So
 * this needs no precedence rule: it reads whichever of the two was written.
 */
function gapAfter(position) {
  const next = after(position);
  if (next === null) {
    return null;
  }
  return secondsOf(position, "hold") ?? secondsOf(next, "wait");
}

/**
 * Where a backward step lands: the nearest earlier state the deck would rest at.
 *
 * A gap of zero is a join rather than a stop.
 * The state it is measured from is left in the same frame in which it is entered, so the
 * audience never sees it at rest, and the motion that state started is redirected in its
 * first frame rather than arriving. Landing there would
 * put a composition on the screen that was never shown, and it would cost one press per
 * join to walk back over a run the presenter got through in one. A join is crossed in both
 * directions instead, so a backward step undoes a forward one.
 *
 * It is the timeline that says where the deck rests and not the clock, so this walk is the
 * same whether the deck is playing or stopped. A state it walks over stays addressable:
 * a fragment reaches every state of a deck exactly, and so does stepping forward through a
 * deck whose clock is stopped.
 *
 * The walk stops at the first state of the deck whatever its gap says, because there is
 * nothing earlier to land on. That is the one case the clock stop in `arm` answers.
 */
function landing(position) {
  let target = before(position);
  while (target !== null && gapAfter(target) === 0) {
    const earlier = before(target);
    if (earlier === null) {
      break;
    }
    target = earlier;
  }
  return target;
}

// The pending step, or `null` when the deck is waiting for the presenter.
// `left` is how much of the wait is still to run and `since` when it was last set going,
// which is what a pause keeps and a resume puts back; `id` is the running timer, which is
// `null` while the clock is stopped.
//
// This is the only timer the runtime sets. An operation's own `delay:` becomes its effect's
// delay instead, so a step keeps one clock however its operations are staggered.
let pending = null;

// Whether the clock is stopped. It is the one thing the runtime knows that the URL does
// not carry, so a reload comes back running, deliberately.
// Every other piece of the position is in the fragment, and a deep link restores it exactly.
let paused = false;

// Whether the stop came from backward travel running out of deck rather than from the
// pause key. That is what a forward step puts back and the pause key does not: a reader
// carried back to the first state expects the deck to play on when they move on, where one
// who stopped the deck on purpose expects it to stay stopped until they say otherwise.
let suspended = false;

// Which way the deck is travelling, `1` or `-1`. It is what the clock steps the deck by
// when a gap runs out, and a pause keeps it, so a deck resumes the way it was going.
// Every key but `Space` says which way it means, and a jump means forwards.
let direction = 1;

/** Say on the root element whether the clock is stopped, beside the position. */
function publish() {
  document.documentElement.toggleAttribute("data-animo-paused", paused);
}

/** Set the pending step going, or hold it where it is while the deck is paused. */
function hold(left) {
  const way = direction;
  pending = { left, since: performance.now(), id: null };
  if (!paused) {
    pending.id = setTimeout(() => {
      pending = null;
      step(way);
    }, left);
  }
  publish();
}

/**
 * Arm the timer for the next step in the direction of travel, and clear whatever was pending.
 *
 * Called whenever a position is entered, whatever entered it, so a presenter stepping by
 * hand is never racing a clock that is still counting and a deep link starts its own timer
 * from where it lands.
 *
 * One gap times the step in both directions, because a gap lies between two states rather
 * than belonging to one of them. A state the deck leaves on its own after a second going
 * forward is a state it leaves on its own after a second coming back, so a state inside a
 * run is shown for as long either way. A state whose gap waits for the presenter arms
 * nothing, and that is where backward travel comes to rest. The deck stops where the
 * presenter would have had to press a key to get past it.
 *
 * The first state of a deck is the other end of that travel and the one place the clock is
 * stopped rather than left unarmed. Nothing earlier is there to travel to, and the gap the
 * state does carry would arm forwards and undo the step that just arrived, which would
 * leave the state reachable for that gap's length and no longer.
 */
function arm() {
  if (pending !== null && pending.id !== null) {
    clearTimeout(pending.id);
  }
  pending = null;
  if (direction < 0 && landing(current) === null) {
    direction = 1;
    if (gapAfter(current) !== null) {
      paused = true;
      suspended = true;
    }
  }
  const gap = gapAfter(current);
  if (gap === null) {
    // The deck rests here until a key says otherwise, and `Space` is the forward key where
    // no timer is pending, so the travel that brought it here is over.
    direction = 1;
    publish();
    return;
  }
  hold(gap);
}

/**
 * Stop the deck where it is, or set it going again the way it was going.
 *
 * This is what a reader of a deck that plays itself asks for. It reaches the motion as well
 * as the clock. An animation in flight is paused where it is and picked up from there, so
 * the picture holds still instead of running on to the end of the step it was in. Only what
 * this key stopped is put back in motion, because a step the presenter made by hand while
 * the deck was paused is running already and a step that has ended is gone from the
 * document's animations.
 *
 * The direction of travel is left alone, so a deck paused on its way back carries on back.
 * The forward key below pauses only while there is a clock to pause, so a deck that waits
 * for the presenter keeps the forward key it has always had.
 */
function togglePause() {
  paused = !paused;
  // Either way the deck has been told what to do, so a later forward step is a step and
  // nothing more.
  suspended = false;
  for (const animation of document.getAnimations()) {
    if (paused && animation.playState === "running") {
      animation.pause();
    } else if (!paused && animation.playState === "paused") {
      animation.play();
    }
  }
  if (pending === null) {
    publish();
  } else if (paused) {
    clearTimeout(pending.id);
    hold(Math.max(0, pending.left - (performance.now() - pending.since)));
  } else {
    hold(pending.left);
  }
}

const forward = new Set(["ArrowRight", "ArrowDown", "PageDown", " ", "Enter", "n"]);
const backward = new Set(["ArrowLeft", "ArrowUp", "PageUp", "Backspace", "p"]);

addEventListener("keydown", (event) => {
  if (event.altKey || event.ctrlKey || event.metaKey) {
    return;
  }
  if (event.key === " " && (pending !== null || paused)) {
    // Space pauses a deck that is playing itself, whichever way it is going, and steps a
    // deck that is not, which is what keeps it the forward key every remote sends.
    togglePause();
  } else if (forward.has(event.key)) {
    step(1);
  } else if (backward.has(event.key)) {
    step(-1);
  } else if (event.key === "Home") {
    jump({ slide: 1, state: 0 });
  } else if (event.key === "End") {
    jump({ slide: last, state: count(last) - 1 });
  } else {
    return;
  }
  event.preventDefault();
});

addEventListener("click", () => step(1));

/**
 * Show a position the deck was not stepped to, which leaves it travelling forwards.
 *
 * A deep link, `Home`, `End` and the first paint land rather than arrive, so whatever the
 * deck was doing before is over and a gap at the position they land on runs the deck on.
 */
function jump(position) {
  direction = 1;
  show(position);
}

// A fragment written from outside, by a deep link or by the back button.
addEventListener("hashchange", () => jump(parseHash()));

jump(parseHash());
