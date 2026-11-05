// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// The stacks of a slide: renderings that typst placed at one point, of which the runtime
// shows one at a time.
//
// `stack.typ` labels every rendering of a stack `animo-<kind>-<index>`, and the renderings of
// one stack are the labelled children of one group. The kind says what the index counts and
// how the rendering to show is chosen, which `stackKinds` holds. Nothing about a stack
// travels in the plan, so a stack is found by its labels alone.

/**
 * How the rendering of a state is chosen, per kind of stack.
 *
 * `select(effects, slide, stack, step, prepared)` plans one stack of a slide for the state the
 * step is entering, as `planState` describes the step.
 * `index` is that state, `from` the epoch the slide was showing, `options` how the step moves
 * and `mirror` how long it lasts when it runs backwards.
 *
 * A kind may also have `read(stack)`, which adds what it needs to a stack once, when the slide
 * is read, and `prepare(effects, slide, step)`, which plans what one step needs once per slide
 * before any stack of the kind is planned, and whose result every `select` of the step is
 * handed as `prepared`.
 *
 * An `epoch` stack holds one rendering of a region per content state, and a boundary between
 * two of them is crossed by the transitions of `boundaries.js`.
 * A `subslide` stack holds one rendering of a `per-subslide` per state, and snaps.
 */
const stackKinds = {
  epoch: { read: readEpochStack, prepare: planBoundary, select: planEpoch },
  subslide: { select: planSubslide },
};

/**
 * The kind and the index of a rendering of a stack, by its label, or `null` for any other
 * label.
 *
 * A region group carries a label of the same shape, `animo-region-<n>`, so a kind is one that
 * `stackKinds` knows.
 */
function stackLabel(label) {
  const found = /^animo-([a-z]+)-(\d+)$/.exec(label ?? "");
  if (found === null || !Object.hasOwn(stackKinds, found[1])) {
    return null;
  }
  return { kind: found[1], index: Number(found[2]) };
}

/**
 * The stacks of one slide, in document order, each as its kind, its container and its
 * renderings by index.
 *
 * A rendering that laid nothing out is not in the page, so the renderings of a stack may
 * have holes, which `forEach` passes over.
 */
function readStacks(element) {
  const stacks = new Map();
  for (const rendering of element.querySelectorAll('[data-typst-label^="animo-"]')) {
    const found = stackLabel(rendering.dataset.typstLabel);
    if (found === null) {
      continue;
    }
    const container = rendering.parentNode;
    let stack = stacks.get(container);
    if (stack === undefined) {
      stack = { kind: found.kind, element: container, renderings: [] };
      stacks.set(container, stack);
    }
    stack.renderings[found.index] = rendering;
  }
  for (const stack of stacks.values()) {
    stackKinds[stack.kind].read?.(stack);
  }
  return Array.from(stacks.values());
}

/** Plan every stack of a slide for one state, each as its kind chooses. */
function planStacks(effects, slide, step) {
  const prepared = new Map();
  for (const [kind, { prepare }] of Object.entries(stackKinds)) {
    if (prepare !== undefined) {
      prepared.set(kind, prepare(effects, slide, step));
    }
  }
  for (const stack of slide.stacks) {
    stackKinds[stack.kind].select(effects, slide, stack, step, prepared.get(stack.kind));
  }
}

/**
 * Show the rendering of a `per-subslide` that belongs to a state, and hide the others.
 *
 * This is how a value finer than a slide number reaches the page at all.
 * One epoch rendering covers a run of states, so typst renders every value and the choice
 * is made here.
 *
 * It snaps rather than animating, in a step that animates as much as in one that does not.
 * A number is read rather than watched, and two numbers crossfading into each other are
 * two numbers neither of which can be read.
 */
function planSubslide(effects, slide, stack, { index }) {
  stack.renderings.forEach((rendering, state) => {
    plan(effects, rendering, { opacity: state === index ? "1" : "0" });
  });
}
