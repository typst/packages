// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// How an element is put into a display state: the timing a step takes from the stylesheet and
// from its operations, and the two phases that plan the effects of a step and apply them.
//
// Motion is driven by the Web Animations API rather than by CSS transitions.
// Each step writes the state's display state as inline style on the tag's inner group and
// animates from what the element was showing to that, so the style is the state and the
// animation is only how it got there.
// A step interrupted halfway therefore continues from where it is,
// stepping backwards lands on exactly the geometry the earlier state had,
// and a deep link needs no transition to suppress.
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

/** The `id` of every animation the runtime creates, which is how it tells them from others. */
const ANIMATION_ID = "animo";

/**
 * Whether the runtime created an animation.
 *
 * The document may hold animations that the author added, from a stylesheet or a script,
 * and what the runtime does to the animations of the page, such as pausing them, is done
 * only to the animations the runtime started.
 */
function ours(animation) {
  return animation.id === ANIMATION_ID;
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
 * The values live in CSS rather than in this file, because the deck writes its
 * `primitive-duration:`, `transition-duration:` and `easing:` arguments there.
 * `property` is which duration is wanted.
 * A primitive within a slide and a slide boundary have one each,
 * so a deck of hard cuts between slides keeps the motion inside them.
 *
 * The duration is a default, so a deck duration of zero is still a step that moves when an
 * operation states a duration, and an effect snaps only when it ends up with no
 * time at all (see `scheduled`).
 * The one thing that snaps a whole step is `--animo-motion: none`, which the stylesheet's
 * media query sets for a reader who asked for less motion, because a media query cannot
 * reach a number written in a typst source.
 */
function timing(property = "--animo-primitive-duration") {
  const style = getComputedStyle(document.documentElement);
  if (style.getPropertyValue("--animo-motion").trim() === "none") {
    return null;
  }
  const duration = Math.max(0, milliseconds(style.getPropertyValue(property)));
  // An easing the stylesheet does not state is no easing at all.
  const easing = style.getPropertyValue("--animo-easing").trim() || "linear";
  return { duration, easing, fill: "none" };
}

/**
 * The options of one effect, which are the defaults of the deck with the delay and the
 * duration of its operation applied.
 *
 * A delay becomes the effect's delay and a duration the effect's duration, rather than a
 * separate timer.
 * The step therefore keeps one clock, because every animation of a step is still created in
 * one task and measured from the same instant.
 * A duration the operation does not state is the `--animo-primitive-duration` of the deck,
 * so that a change of the deck's tempo reaches every operation that said nothing
 * and leaves the ones that did alone.
 *
 * Only a delay needs `fill: backwards`. The display state is written as inline style before
 * the animation is created, so an effect that does not hold its first keyframe while it
 * waits shows the state it is going to reach and then jumps back to where it started.
 *
 * A step that snaps stays snapped, delays and durations alike.
 * `options` is `null` for a reader who asked for less motion, a deep link and the first
 * paint.
 * An effect with no time at all, no delay and a duration of zero, snaps as well, which is
 * what an operation that takes the deck's duration of zero and a hard cut both are.
 * A delay with a duration of zero holds the effect back and then jumps.
 *
 * `mirror` is how long the step lasts, and it turns the schedule around.
 * A backward step is the forward one played from the other end, so an operation that ran
 * from `delay` to `delay + duration` runs from `mirror - delay - duration` instead and
 * takes exactly as long.
 * The last thing to arrive is then the first to leave, so a backward step undoes a forward
 * one in time as well as in geometry. `mirror` is `null` for a step that plays forwards.
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
  if (!(duration > 0) && !(delay > 0)) {
    return null;
  }
  return delay > 0 ? { ...own, delay, fill: "backwards" } : own;
}

/**
 * How long one step lasts, in milliseconds, which is what a backward step mirrors about.
 *
 * The step ends when the last of its operations does, so this is the largest
 * `delay + duration` over all of them. The resolver could only add up the operations that
 * stated a duration, because the one an operation does not state lives in the stylesheet,
 * so it hands over the two halves and they are added here.
 * `stated` is the largest end it could compute, and `unstated` the largest delay of the
 * operations whose duration is the `--animo-primitive-duration` of the deck.
 *
 * A step that states no timing at all carries no span, and lasts exactly the
 * `--animo-primitive-duration` of the deck, which is what every operation of it takes.
 */
function span(record, options) {
  // A step that carries no record is one whose every operation starts with it and takes the
  // `--animo-primitive-duration` of the deck, which is an unstated delay of zero,
  // so that is what stands in for it.
  // An absent `unstated` beside a `stated` is the other case and adds nothing, because the
  // step holds no operation whose duration the stylesheet owns.
  const { stated, unstated } = record ?? { unstated: 0 };
  return Math.max(
    stated === undefined ? 0 : stated * 1000,
    unstated === undefined ? 0 : unstated * 1000 + options.duration,
  );
}

/**
 * What a property shows at rest, for the properties whose unset value the engine reports as a
 * keyword rather than as that value.
 *
 * `none` is what `getComputedStyle` gives for the property when nothing sets it, and `rest` is
 * the value that keyword stands for, which is what a keyframe and a comparison need.
 * A property that is not in the table is read as the engine reports it, so a transition can
 * animate a property this file does not know.
 */
const PROPERTIES = {
  opacity: { rest: "1" },
  translate: { rest: "0px 0px", none: "none" },
  scale: { rest: "1", none: "none" },
  // No clip and a clip at the box of the element paint the same on a slide, which clips at
  // its box already, and only the second interpolates with the clip of a wipe.
  "clip-path": { rest: "inset(0px)", none: "none" },
};

/** What an element is showing right now, for the CSS properties named. */
function showing(element, names) {
  const computed = getComputedStyle(element);
  return Object.fromEntries(
    names.map((name) => {
      const value = computed.getPropertyValue(name);
      const known = PROPERTIES[name];
      return [name, value === known?.none ? known.rest : value];
    }),
  );
}

/** A CSS property as a keyframe names it, which is the camel case of its IDL attribute. */
function keyframeName(name) {
  return name.replace(/-([a-z])/g, (_, letter) => letter.toUpperCase());
}

// A step is put on the page in two phases, which the two functions below are.
//
// The first plans it. It reads what every element the step animates is showing, and a
// transition reads whatever geometry it needs beside that, and nothing is written.
// The result is the step's effects, one per element and property, each with what the
// element shows now, what it is to show, and the timing that takes it there or `null`
// for a property that snaps.
// The second applies them, writing every style and then creating every animation in one
// task, which is the step's one clock.
//
// The split keeps every read of a step ahead of every write of it. Continuous state is
// written to every occurrence of a tag in a loop, so a read between two writes could see
// the ancestors of one occurrence in the new state and those of another in the old one,
// and reading and writing in alternation recalculates style once per element.

/**
 * Plan a display state on one element, as effects of the step being planned.
 *
 * `effects` maps an element to its effects by property, and an effect planned for an
 * element and a property that already have one replaces it. That is how a transition puts a
 * region it carries in place of the state at rest that `planEpoch` planned for it first.
 *
 * `options` is `null` for a state that snaps, and otherwise one options object per property
 * of `to`, because two operations of one step may start at different moments and an effect
 * has one delay. A property without options snaps.
 *
 * `start` states where an animated property starts, in place of what the element is showing,
 * for an element whose current value is no point on the route to the new one.
 * A slide that a push brings in has not been laid out, and it starts outside the stage.
 *
 * `end` states where an animated property ends, in place of the state written, for an
 * effect that is a route and not a state.
 * A morph carries an outgoing element to the place of the incoming one,
 * and the element is back at rest once the animation is over,
 * which is when the crossfade has made it transparent.
 *
 * `hold` states a value that a property keeps for the whole effect, in place of the state
 * written, for a value that belongs to the route and not to the state.
 * A hand-over holds the outgoing rendering below the incoming one at opacity 1 until it ends,
 * and an element it draws once at opacity 0.
 * A held property is animated although it is equal at both ends.
 */
function plan(
  effects,
  element,
  to,
  options = null,
  { start = null, end = null, hold = null } = {},
) {
  let own = effects.get(element);
  if (own === undefined) {
    own = new Map();
    effects.set(element, own);
  }
  for (const [property, value] of Object.entries(to)) {
    const timing = options?.[property] ?? null;
    const held = timing === null ? null : (hold?.[property] ?? null);
    const from =
      timing === null
        ? null
        : (held ?? start?.[property] ?? showing(element, [property])[property]);
    own.set(property, { to: value, timing, from, end: held ?? end?.[property] ?? null, held });
  }
}

/**
 * Apply the effects of a step: write every style, then animate into it.
 *
 * Every element the step touches loses the animations it was running, because the style
 * written here is where they were going and the animation created here starts from where
 * they had got to.
 */
function apply(effects) {
  for (const [element, own] of effects) {
    for (const animation of element.getAnimations()) {
      animation.cancel();
    }
    for (const [property, effect] of own) {
      element.style.setProperty(property, effect.to);
    }
  }
  // The styles are read after every write of the step, and before any animation is created,
  // so that the engine recalculates style once.
  // An animation created between two reads makes the second one recalculate the style of the
  // page again, which costs a step of a few thousand elements seconds in chromium 151.
  const animations = [];
  for (const [element, own] of effects) {
    const names = [...own].filter(([, effect]) => effect.timing !== null).map(([name]) => name);
    if (names.length === 0) {
      continue;
    }
    // The animation starts from what the element now computes, rather than from what was
    // just written, because an engine normalises what it computes.
    // Chromium 151 gives back `0px` for the `0px 0px` of a tag at rest,
    // so comparing the two spellings finds a difference where there is none.
    // An effect that states an `end` ends there instead, and is not read at all, which
    // is what keeps a morph of a few thousand glyphs from reading as many styles.
    const unstated = names.filter((name) => own.get(name).end === null);
    const shown = unstated.length === 0 ? {} : showing(element, unstated);
    const into = Object.fromEntries(names.map((name) => [name, own.get(name).end ?? shown[name]]));
    // Only the properties this step actually changes are animated, because in chromium 151 a
    // `translate` or `scale` that is equal at both ends stops the browser from drawing the
    // `opacity` beside it, and the element stays as it was until the step ends and then jumps.
    // Measured; see *Findings*.
    // A held property is the exception, because it is equal at both ends by design.
    const changed = names.filter(
      (name) => own.get(name).held !== null || own.get(name).from !== into[name],
    );
    // There is one effect per group of properties that are timed alike, so that a step whose
    // operations are timed alike, which is every step that says nothing about timing, is
    // still one animation on this element.
    const groups = new Map();
    for (const name of changed) {
      const key = JSON.stringify(own.get(name).timing);
      const found = groups.get(key);
      if (found === undefined) {
        groups.set(key, { timing: own.get(name).timing, names: [name] });
      } else {
        found.names.push(name);
      }
    }
    for (const group of groups.values()) {
      const frame = (pick) =>
        Object.fromEntries(group.names.map((name) => [keyframeName(name), pick(name)]));
      animations.push([
        element,
        [frame((name) => own.get(name).from), frame((name) => into[name])],
        { ...group.timing, id: ANIMATION_ID },
      ]);
    }
  }
  for (const [element, keyframes, options] of animations) {
    element.animate(keyframes, options);
  }
}
