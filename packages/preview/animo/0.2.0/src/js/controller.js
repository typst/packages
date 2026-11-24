// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// The controller: the position of the deck, the clock that moves it, and the events that say
// it moved. Every piece of state the runtime keeps between two inputs is a variable of this
// file, and no other file writes one.
//
// The controller keeps one position, `<slide>.<state>`, and these things in step with it:
// which slide container is shown, the display state of that slide's tags, the URL
// fragment, and the `data-animo` attribute of the root element. The fragment is what
// makes a position addressable, which a deep link, a test and the reload of `typst watch`
// all need.
// The attribute lets a reader of the DOM see the position the runtime actually reached.
//
// A step animates, within a slide and across one slide boundary alike, and everything else
// snaps.
// Restoring a position therefore snaps to it rather than animating into it, and so
// does any jump that is not between neighbouring slides.
// The fragment is written with `replaceState`, so stepping leaves no history behind.
//
// `show` is the only writer of the position. What happened is announced as events on the
// root element, once the DOM, the fragment and the clock have been written, so a listener
// finds the page in the state the event describes:
//
// - `animo:leave` with `{slide}`, when a position on another slide is shown.
// - `animo:enter` with `{slide}`, after `animo:leave`, when the slide a position is on was
//   not the one before it. The first position of the page enters its slide and leaves none.
// - `animo:position` with `{from, to, animated}`, last, with positions as `{slide, state}`.
//   `from` is `null` for the first position of the page. `animated` says that the position
//   was reached by a step and that the deck lets motion run, which is false for a jump, for
//   a cut and for a reader who asked for less motion.
// - `animo:mode` with `{from, to}`, when the input mode changes.
//
// The events bubble, so a listener on the root element, the document or the window hears them.

/** Tell the page what happened, as an event on the root element. */
function announce(type, detail) {
  document.documentElement.dispatchEvent(new CustomEvent(type, { bubbles: true, detail }));
}

// The position the deck is at, or `null` until the first one has been shown.
let current = null;

// The mode input is read in, by name. `input.js` holds what each mode does with a key and a
// click, and this is only which one is active, so that a change of it is announced like any
// other change of the deck.
let mode = null;

/** The name of the active mode, or `null` before the page has booted. */
function currentMode() {
  return mode;
}

/** Make a mode the active one, and say so on the root element beside the position. */
function setMode(name) {
  if (name === mode) {
    return;
  }
  const from = mode;
  mode = name;
  document.documentElement.dataset.animoMode = name;
  announce("animo:mode", { from, to: name });
}

/** Show a position, and publish it in the fragment and on the root element. */
function show(position, animate = false) {
  const wanted = clamp(position);
  const previous = current;
  // Before the first position there is no slide to cross from, so the slide of the wanted
  // position is the one entered.
  const from = previous?.slide ?? wanted.slide;
  const crossing = wanted.slide !== from;
  // Only a step across one slide boundary animates.
  // A deep link, the first paint, `Home`, `End` and any longer jump snap, because the state
  // they would animate into is one the audience was shown no route to.
  // A backward step that walked over a join spanning a whole slide is the one longer jump
  // that had a route, and it snaps all the same.
  // A container has one opacity, so the slide passed through would have to be faded out
  // beside the one being left, and this seam is shaped to hand over one slide.
  const neighbour = Math.abs(wanted.slide - from) === 1;
  // The boundary belongs to the slide with the higher number, in both directions, so a
  // backward step undoes exactly what the forward step over it did.
  const transition =
    animate && crossing && neighbour ? slideTransitionOf(Math.max(wanted.slide, from)) : null;
  const boundary = boundaryTiming(transition);
  const slide = deck.get(wanted.slide);
  // Which state the slide being entered is showing, which is where its motion starts
  // and which is not the deck's position when a join is being walked back over.
  const shown = slide?.shown ?? null;
  // Whether that slide moves into the state it is asked for rather than snapping into it.
  // A step that stays on one slide does.
  // So does a backward step into the slide next door, which is how a join that runs out of a
  // slide is undone.
  // The audience saw that slide's motion and the boundary at once, so the way back plays both
  // at once too, each on the duration it took going forward.
  // A forward step snaps, because the slide it enters at
  // state 0 may still be showing a state from an earlier visit, and rewinding that is a
  // route the audience was never shown.
  const moving =
    animate && shown !== null && (!crossing || (neighbour && wanted.slide < from));
  const left = moving ? (slide.states[shown]?.epoch ?? 0) : null;
  // The step whose operations are being walked is the higher of the two states, forwards and
  // backwards alike, so that a backward step mirrors the schedule of the step it undoes.
  const walked = moving ? Math.max(shown, wanted.state) : wanted.state;
  // A step that lands below the state it starts from is that step played from the other
  // end, which is the whole of the difference between the two directions here.
  const reverse = moving && wanted.state < shown;
  current = wanted;
  // The slide being left keeps its layout for as long as the deck stays where it is, so
  // that stepping back over the same boundary finds it laid out already. Nothing else
  // is, so a deck pays for two slides however long it is.
  // The slide being left is `inert` meanwhile, because it is on screen only to be crossed
  // from, and neither a pointer nor the keyboard has any business in it.
  const leaving = boundary === null ? null : from;
  // The slides that had no layout before this step, which a transition brings in from its
  // far end rather than from what they show.
  const fresh = new Set();
  for (const [number, other] of deck) {
    if (!other.element.matches("[data-animo-current], [data-animo-leaving]")) {
      fresh.add(number);
    }
  }
  for (const [number, other] of deck) {
    other.element.toggleAttribute("data-animo-current", number === current.slide);
    other.element.toggleAttribute("data-animo-leaving", number === leaving);
    other.element.toggleAttribute("inert", number === leaving);
  }
  // A slide the runtime is not using has no layout, so its anchors wait until the loop
  // above lays it out, which is still before anything has been written on it.
  // A slide is laid out because it is being entered or because it is being left,
  // and a slide is only ever left after it has been entered.
  if (slide !== undefined && slide.anchors === null) {
    slide.anchors = measureAnchors(slide);
  }
  // The step is planned whole before any of it is written, and then applied in one task, so
  // that a boundary and whatever it carries take the same frame's time, which is the step's
  // one clock, and so that no part of the plan reads a style another part has written.
  // The operations of the slide being entered take `--animo-primitive-duration`,
  // where the boundary takes `--animo-transition-duration`.
  // A join is two clocks started on one frame, going back as coming.
  const effects = new Map();
  planSlides(effects, current.slide, leaving, boundary, transition, fresh);
  const options = moving ? timing() : null;
  planState(effects, slide, current.state, options, {
    from: left,
    step: walked,
    reverse,
  });
  apply(effects);
  const hash = `#${current.slide}.${current.state}`;
  if (location.hash !== hash) {
    history.replaceState(null, "", hash);
  }
  document.documentElement.dataset.animo = `${current.slide}.${current.state}`;
  arm();
  // The events come last, so that a listener finds the position fully written.
  if (previous === null || previous.slide !== current.slide) {
    if (previous !== null) {
      announce("animo:leave", { slide: previous.slide });
    }
    announce("animo:enter", { slide: current.slide });
  }
  announce("animo:position", {
    from: previous === null ? null : { ...previous },
    to: { ...current },
    animated: options !== null || boundary !== null,
  });
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
  if (delta > 0) {
    holds.delete("travel");
  }
  show(target, true);
}

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

/**
 * The position after one, or `null` at the end of the deck.
 *
 * Stepping past the last state of a slide enters the next one, which is the rule that the
 * forward key of the presenter follows, so a gap inside a slide and a gap across a slide
 * boundary are the same timer on the same sequence of positions.
 */
function after(position) {
  if (position.state + 1 < count(position.slide)) {
    return { slide: position.slide, state: position.state + 1 };
  }
  return position.slide < lastSlide() ? { slide: position.slide + 1, state: 0 } : null;
}

/** The position before one, or `null` at the start of the deck. */
function before(position) {
  if (position.state > 0) {
    return { slide: position.slide, state: position.state - 1 };
  }
  const slide = position.slide - 1;
  return position.slide > 1 ? { slide, state: count(slide) - 1 } : null;
}

/** The number of seconds that one state gives under one key, in milliseconds, or `null`. */
function secondsOf(position, key) {
  const seconds = deck.get(position.slide)?.states[position.state]?.[key];
  return typeof seconds === "number" ? seconds * 1000 : null;
}

/**
 * How long the deck holds a position before leaving it, in milliseconds, or `null` for a
 * presenter click.
 *
 * A gap is timed by the `hold:` of the state before it or by the `wait:` of the state
 * after it, never by both, which the resolver and the deck refuse at compile time.
 * This function therefore needs no precedence rule, and reads whichever of the two was
 * written.
 */
function gapAfter(position) {
  const next = after(position);
  if (next === null) {
    return null;
  }
  return secondsOf(position, "hold") ?? secondsOf(next, "wait");
}

/**
 * How long the deck holds a position before travelling back from it, in milliseconds, or
 * `null` for a presenter click.
 *
 * This is the gap that the backward step crosses, which is the gap before the position.
 * `landing` walks back over the joins on the way, so the gap after the state it lands on is
 * the one gap of that step that is not a join.
 * A position with no earlier state to land on has no gap before it.
 */
function gapBefore(position) {
  const target = landing(position);
  return target === null ? null : gapAfter(target);
}

/**
 * Where a backward step lands, which is the nearest earlier state the deck would rest at.
 *
 * A gap of zero is a join rather than a stop.
 * The state it is measured from is left in the same frame in which it is entered, so the
 * audience never sees it at rest, and the motion that state started is redirected in its
 * first frame rather than arriving.
 * Landing there would put a composition on the screen that was never shown,
 * and it would cost one press per join to walk back over a run the presenter got through in
 * one.
 * A join is crossed in both directions instead, so a backward step undoes a forward one.
 *
 * It is the timeline that says where the deck rests and not the clock, so this walk is the
 * same whether the deck is playing or stopped.
 * A state the walk passes over stays addressable, because a fragment reaches every state of
 * a deck exactly, and so does stepping forward through a deck whose clock is stopped.
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
// which is what a pause keeps and a resume puts back.
// `id` is the running timer, which is `null` while the clock is stopped.
//
// This is the only timer the runtime sets. The `delay:` of an operation becomes the delay
// of its effect instead, so a step keeps one clock however its operations are staggered.
let pending = null;

// Why the clock is stopped, as a set of reasons. The clock is stopped while the set holds any.
// It is the one thing the runtime knows that the URL does not carry, so a reload comes back
// running, deliberately.
// Every other piece of the position is in the fragment, and a deep link restores it exactly.
//
// - `user` is the pause key.
// - `travel` is backward travel running out of deck. A forward step releases it and the
//   pause key does not, because a reader carried back to the first state expects the deck to
//   play on when they move on, where one who stopped the deck on purpose expects it to stay
//   stopped until they say otherwise.
//   The two are never held together, because the forward step that ends `travel` is
//   expected to start the deck again whether or not the pause key had been pressed before.
//
// A mode that takes the deck over, such as an overview or an annotation, holds a separate
// reason, so that leaving it cannot start a clock that the pause key stopped.
const holds = new Set();

// Which way the deck is travelling, `1` or `-1`. It is what the clock steps the deck by
// when a gap runs out, and a pause keeps it, so a deck resumes the way it was going.
// Every key but `Space` says which way it means, and a jump means forwards.
let direction = 1;

/** Whether the clock is stopped, for whatever reason. */
function stopped() {
  return holds.size > 0;
}

/**
 * Whether the deck has a clock that the pause key acts on.
 *
 * That is a deck with a step pending and a deck that is stopped, because a stopped deck
 * has to be set going again. A deck that waits for the presenter has neither, and its keys
 * only step.
 */
function clockActive() {
  return pending !== null || stopped();
}

/** Say on the root element whether the clock is stopped, beside the position. */
function publish() {
  document.documentElement.toggleAttribute("data-animo-paused", stopped());
}

/** Set the pending step going, or hold it where it is while the deck is stopped. */
function schedule(left) {
  const way = direction;
  pending = { left, since: performance.now(), id: null };
  if (!stopped()) {
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
 * hand is never racing a clock that is still counting and a deep link starts a new timer
 * from where it lands.
 *
 * One gap times the step over it in both directions, because a gap lies between two states
 * rather than belonging to one of them. A gap the deck crosses on its own after a second
 * going forward is a gap it crosses on its own after a second coming back, so backward travel
 * plays a run of automatic gaps as the forward run played it, mirrored in time.
 * Travelling back, the step that is pending is the one over the gap before the position.
 * A position whose gap before it waits for the presenter arms nothing, and that is where
 * backward travel comes to rest. The clock never crosses a gap that waits for the presenter,
 * so the travel ends on the state that the presenter's forward press brought up.
 *
 * The first state of a deck is the other end of that travel and the one place the clock is
 * stopped rather than left unarmed. Nothing earlier is there to travel to, and the gap the
 * state does carry would arm forwards and undo the step that just arrived, which would
 * leave the state reachable for that gap's length and no longer.
 * The animations of the step that just arrived are left running, because it is the clock
 * that stops here and not the picture.
 */
function arm() {
  if (pending !== null && pending.id !== null) {
    clearTimeout(pending.id);
  }
  pending = null;
  if (direction < 0 && landing(current) === null) {
    direction = 1;
    if (gapAfter(current) !== null) {
      holds.delete("user");
      holds.add("travel");
    }
  }
  const gap = direction > 0 ? gapAfter(current) : gapBefore(current);
  if (gap === null) {
    // The deck rests here until a key says otherwise, and `Space` is the forward key where
    // no timer is pending, so the travel that brought it here is over.
    // A state that backward travel rests on may have a timed gap after it, which stays
    // unarmed, because the presenter is the one who sets the deck going forward again.
    direction = 1;
    publish();
    return;
  }
  schedule(gap);
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
 * The animations of the runtime are the only ones touched, so a CSS animation of the
 * page carries on.
 *
 * The key releases the reasons that belong to it, `user` and `travel`, and holds `user` when
 * neither is held. Where a reason of a mode is held as well, the deck stays stopped and the
 * key changes nothing else.
 *
 * The direction of travel is left alone, so a deck paused on its way back carries on back.
 * The forward key pauses only while there is a clock to pause, so a deck that waits
 * for the presenter keeps the forward key it has always had.
 */
function togglePause() {
  const was = stopped();
  if (holds.has("user") || holds.has("travel")) {
    holds.delete("user");
    holds.delete("travel");
  } else {
    holds.add("user");
  }
  const now = stopped();
  if (now === was) {
    return;
  }
  for (const animation of document.getAnimations()) {
    if (!ours(animation)) {
      continue;
    }
    if (now && animation.playState === "running") {
      animation.pause();
    } else if (!now && animation.playState === "paused") {
      animation.play();
    }
  }
  if (pending === null) {
    publish();
  } else if (now) {
    clearTimeout(pending.id);
    schedule(Math.max(0, pending.left - (performance.now() - pending.since)));
  } else {
    schedule(pending.left);
  }
}

/**
 * What the deck can be asked to do, by name.
 *
 * Whatever drives the deck asks through this table and not through `step`, `jump` or
 * `togglePause`, so that an input device only has to say which of these it means.
 */
const intents = {
  next: () => step(1),
  previous: () => step(-1),
  first: () => jump({ slide: 1, state: 0 }),
  last: () => jump({ slide: lastSlide(), state: count(lastSlide()) - 1 }),
  "toggle-pause": () => togglePause(),
};
