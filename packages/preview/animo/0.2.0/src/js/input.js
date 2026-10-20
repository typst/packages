// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// Input: key, pointer and hash events, turned into the intents of `controller.js` by the
// active mode.
//
// A mode is `{name, keymap, pointer}`. The keymap maps `event.key` to an intent and the
// pointer table maps the type of a pointer event to one. An entry is the name of an intent,
// or a function that names one when the input arrives, for an input whose meaning depends on
// the state of the deck.
// An input that no entry names is not handled, and its default action is left alone.

/**
 * The mode the deck presents in.
 *
 * `Space` is the forward key every remote sends, and it pauses a deck that is playing
 * itself, whichever way it is going, and steps a deck that is not.
 */
const present = {
  name: "present",
  keymap: new Map([
    ...["ArrowRight", "ArrowDown", "PageDown", "Enter", "n"].map((key) => [key, "next"]),
    ...["ArrowLeft", "ArrowUp", "PageUp", "Backspace", "p"].map((key) => [key, "previous"]),
    [" ", () => (clockActive() ? "toggle-pause" : "next")],
    ["Home", "first"],
    ["End", "last"],
  ]),
  pointer: new Map([["click", "next"]]),
};

/** The modes by name. */
const modes = new Map([[present.name, present]]);

/** The intent a table of a mode gives an input, or `undefined` when it names none. */
function intentOf(table, input) {
  const entry = table.get(input);
  return typeof entry === "function" ? entry() : entry;
}

/**
 * Whether an event happened inside a control.
 *
 * A control handles the input it receives, so a key pressed on one and a click on one are not
 * the deck's. The attribute is what marks an element as a control.
 */
function inControl(event) {
  return event.target instanceof Element && event.target.closest("[data-animo-control]") !== null;
}

addEventListener("keydown", (event) => {
  if (event.altKey || event.ctrlKey || event.metaKey || inControl(event)) {
    return;
  }
  const intent = intentOf(modes.get(currentMode()).keymap, event.key);
  if (intent === undefined) {
    return;
  }
  intents[intent]();
  event.preventDefault();
});

addEventListener("click", (event) => {
  if (inControl(event)) {
    return;
  }
  const intent = intentOf(modes.get(currentMode()).pointer, "click");
  if (intent !== undefined) {
    intents[intent]();
  }
});

// A fragment written from outside, by a deep link or by the back button.
addEventListener("hashchange", () => jump(parseHash()));
