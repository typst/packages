// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// What runs when the page loads: the page is prepared, the slides are read, and the deck
// jumps to the position the fragment names. This is the only file that calls into the others
// while the script loads, so it comes last.

/**
 * Copy every paint server and clip path of the document into an `<svg>` that is always laid
 * out, put it first in the document, and take the ids off the originals.
 *
 * Typst names a gradient, a clip path, a tiling, a mask and a filter by a hash of its
 * content, so a slide that repeats one of them from an earlier slide defines the same id in
 * a second frame. A reference resolves to the first element of its id in the document,
 * which sits in the earliest slide that uses it, and that slide is `display: none` unless
 * it is one of the two being laid out. Chromium and firefox do not resolve a reference into
 * a subtree that is not laid out, so the fill is dropped and the clip is not applied.
 * A glyph is referenced through `<use>`, which resolves through the same first match and
 * does draw, so text is not affected. See *Findings*.
 *
 * The holder is not `display: none` for the same reason, and it comes first in the document
 * so that it is the first match of every id. Equal ids mean equal content, so the first
 * definition of an id serves every slide that uses it.
 *
 * In webkit, a definition that stops being laid out drops every reference to its id, even
 * while the holder still defines the id, until a slide that defines it is laid out again.
 * The holder is therefore the only element that keeps an id.
 */
function hoistPaintServers() {
  const holder = document.createElementNS("http://www.w3.org/2000/svg", "svg");
  holder.setAttribute("width", "0");
  holder.setAttribute("height", "0");
  holder.setAttribute("aria-hidden", "true");
  holder.style.cssText = "position: absolute; overflow: hidden";
  const defs = document.createElementNS("http://www.w3.org/2000/svg", "defs");
  const seen = new Set();
  for (const node of document.querySelectorAll(
    "clipPath, linearGradient, radialGradient, pattern, mask, filter",
  )) {
    if (node.id !== "" && !seen.has(node.id)) {
      seen.add(node.id);
      defs.append(node.cloneNode(true));
    }
    node.removeAttribute("id");
  }
  holder.append(defs);
  document.body.prepend(holder);
}

// The paint servers are hoisted before any slide is read, and while every slide is still
// `display: none`, so that no frame is ever painted with a missing gradient.
hoistPaintServers();

for (const element of document.querySelectorAll("[data-animo-slide]")) {
  deck.set(Number(element.dataset.animoSlide), readSlide(element));
}

setMode(present.name);
jump(parseHash());
