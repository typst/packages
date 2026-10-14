// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// The morph, which carries what the outgoing and the incoming region share from its old place
// to its new one, and hands the region over as the crossfade does.
//
// A match is a pair of elements, one in each region, that show the same ink.
// The outgoing element is translated from its place to the place of the incoming one, and
// the incoming element from the place of the outgoing one to its place, so the two are at one
// position at every moment. `handOver` in `boundaries.js` then draws a pair whose two elements
// are identical once, by hiding the element of the upper rendering, and lets the upper element
// of any other pair fade over the opaque lower one, which shows the interpolation of the two.
// The morph therefore clones nothing.
// A resize is a match of two paths of one structure whose geometry differs, and both paths
// also animate their `d` and stroke width from the outgoing geometry to the incoming one, so
// the two have one geometry at every moment as well. A shape morph is a match of two paths of
// different structures, which `alignPaths` rewrites into one structure before they are
// animated in the same way.
//
// The translations and resizes are routes and never states. They are animations over a
// `translate`, a `d` and a `stroke-width` whose inline style stays unset, so a slide at rest
// carries none,
// and the geometry a later step reads is the geometry of the layout once they are over.
// Until then, `slide.morphed` holds every element a morph is still moving, which is what a
// later step needs to know to read the layout under them and to settle them.
// A hidden element takes no route, and `slide.standIns` holds the element that is shown in its
// place, which is where a later step reads what the hidden element shows (see `displayed`).

/**
 * The largest number of differences between the glyphs of two regions for which the glyphs
 * are matched.
 *
 * The diff takes time in proportion to the number of glyphs times the number of
 * differences, and a region beyond the bound crossfades its glyphs, which is always correct.
 * See *Performance* for the measurement the number comes from.
 */
const MORPH_DIFFERENCES = 400;

/** A distance, in CSS pixels, below which a match has not moved. */
const MORPH_STILL = 0.01;

/** No `translate`, as a keyframe states it. */
const AT_REST = "0px 0px";

/** The elements that draw ink themselves, which are the candidates of a match below tags. */
const INK = new Set(["use", "path", "image"]);

/**
 * The elements whose content is never drawn where it sits: definitions, the paths of a clip
 * and the outlines of a glyph. The walk for ink does not enter them, wherever typst puts them.
 */
const NOT_INK = new Set([
  "clipPath",
  "defs",
  "filter",
  "linearGradient",
  "marker",
  "mask",
  "pattern",
  "radialGradient",
  "symbol",
]);

/**
 * The attributes of a `<path>` that shape its ink, apart from its `d`.
 *
 * The stroke width is among them because a route does not scale a stroke, and the fill rule
 * because two copies under two rules cover two areas. The colors are not, because the copy of
 * one color fading over the opaque copy of the other shows the interpolation of the two.
 */
const PATH_SHAPE = [
  "fill-rule",
  "stroke-width",
  "stroke-linecap",
  "stroke-linejoin",
  "stroke-miterlimit",
  "stroke-dasharray",
  "stroke-dashoffset",
];

/**
 * Whether the engine animates the `d` of a path, which a resize needs.
 *
 * Chromium 151 and firefox 153 do, and webkit 26.5 does not, so webkit crossfades the shapes a
 * resize would carry. See *Findings*.
 */
const RESIZES = CSS.supports("d", 'path("M 0 0")');

/** The CSS properties a resize animates, besides the `translate` of its route. */
const RESHAPED = ["d", "stroke-width"];

/** The command letters of SVG path data, which a number never contains. */
const COMMANDS = /[MmZzLlHhVvCcSsQqTtAa]/g;

/** A number in SVG path data. */
const NUMBER = /[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?/g;

/** How far apart the linear parts of two matrices may be and still count as one. */
const SAME_FRAME = 1e-6;

/**
 * The attributes of an element that color its ink, which two identical copies share.
 *
 * The match leaves them out of its key, so a pair may differ in them, and such a pair is drawn
 * as two copies rather than one.
 */
const PAINT = ["fill", "fill-opacity", "stroke", "stroke-opacity", "opacity"];

/**
 * Plan the translations of the matches in an epoch stack a morph carries, on `timing`, and
 * return the matches, each with whether its two elements are identical copies.
 *
 * Nothing here touches an opacity, which `handOver` plans after this.
 * The two renderings of the stack are the outgoing and the incoming region.
 */
function morphStack(effects, slide, { stack, from, to, record }, timing) {
  const outgoing = stack.renderings[from];
  const incoming = stack.renderings[to];
  if (outgoing === undefined || incoming === undefined) {
    return [];
  }
  // The screen matrix of every parent read so far, because the glyphs of a run share one.
  const screen = new Map();
  const labels = new Map();
  const pairs = matches(slide, outgoing, incoming, new Set(record.names), screen).map((pair) =>
    measured(slide, pair, screen),
  );
  for (const pair of pairs) {
    pair.same = identical(pair, { outgoing, incoming, labels, screen });
  }
  for (const match of rigid(pairs, slide.morphed)) {
    carry(effects, slide, match, timing, { stack, from, to, screen });
  }
  return pairs;
}

/**
 * Whether the two elements of a match draw exactly the same ink at every moment of its route.
 *
 * The two copies of such a match are at one place and have one geometry all the way, so
 * drawing one of them shows the same pixels as drawing both.
 * That needs the same paint, the same user space up to a translation, and the same tags above
 * both, because the display state of a tag goes on its slot and two tags may be shown
 * differently.
 * A tag match also needs the same content, and an ink match of two paths needs the same
 * shape, unless its route animates every attribute in which the two shapes differ.
 */
function identical({ outgoing, incoming, shape }, regions) {
  if (
    outgoing.localName !== incoming.localName ||
    labelsAbove(outgoing, regions.outgoing, regions.labels) !==
      labelsAbove(incoming, regions.incoming, regions.labels) ||
    !sameFrame(outgoing, incoming, regions.screen)
  ) {
    return false;
  }
  if (!INK.has(outgoing.localName)) {
    const before = outgoing.children;
    const after = incoming.children;
    return (
      before.length === after.length &&
      Array.from(before).every((child, index) => child.isEqualNode(after[index]))
    );
  }
  const same = (name) => outgoing.getAttribute(name) === incoming.getAttribute(name);
  if (!PAINT.every(same)) {
    return false;
  }
  if (inkKey(outgoing) === inkKey(incoming)) {
    return true;
  }
  return (
    shape !== null &&
    PATH_SHAPE.every((name) => same(name) || Object.hasOwn(shape.end, name)) &&
    RESHAPED.every((name) => same(name) || Object.hasOwn(shape.end, name))
  );
}

/**
 * The element that shows an element in its place, which is the element itself unless a
 * hand-over that is still running hid it behind a partner.
 *
 * A hidden element takes no route, so what it shows is what its partner shows, which is
 * where a step that interrupts the hand-over starts from.
 * `slide.shownBy` holds the partners of the hand-overs before this step.
 */
function displayed(slide, element) {
  const found = slide.shownBy.get(element);
  if (found === undefined || !found.holder.getAnimations().some(ours)) {
    return element;
  }
  return found.partner;
}

/**
 * Whether a labelled group moves as one when a morph matches it.
 *
 * A tag and a named region do, and so does the rendering of one state of a `per-subslide`,
 * which is the same in both regions. An unnamed region is a box around content and not a
 * separate thing, so what it holds is matched in its place.
 */
function movesAsOne(label) {
  return !label.startsWith("animo-") || stackLabel(label)?.kind === "subslide";
}

/**
 * The matches of two renderings of a region, as pairs of an outgoing and an incoming element,
 * with whether the pair is a resize.
 *
 * First the tag matches: two labelled groups of one name, paired by their index among the
 * groups of that name in document order. A tag the boundary changes is not one, and neither is
 * a group that holds such a tag, because the content of both differs, and what they hold is
 * matched in its place. Then the ink matches: the glyphs, paths and images outside every
 * matched group, paired by a longest common subsequence of their keys in document order, so a
 * box beside a word keeps its place among the letters. Then the resizes, which pair the paths
 * left over between the same two ink matches by their structure (see `resizes`), and last the
 * shape morphs, which pair the one path a changed tag holds on each side (see `shapeMorphs`).
 * Every match has the same clips above it in both regions.
 */
function matches(slide, outgoing, incoming, changed, screen) {
  const pairs = [];
  const claimed = new Set();
  const clips = new Map();
  const above = (element, region) =>
    clipsAbove(slide, element, { region, laidOut: region === incoming }, clips, screen);
  const candidates = (region) => {
    const groups = Array.from(region.querySelectorAll("[data-typst-label]"));
    const holding = new Set();
    for (const group of groups) {
      if (changed.has(group.dataset.typstLabel)) {
        for (let node = group.parentElement; node !== region; node = node.parentElement) {
          holding.add(node);
        }
      }
    }
    return groups.filter(
      (group) =>
        movesAsOne(group.dataset.typstLabel) &&
        !changed.has(group.dataset.typstLabel) &&
        !holding.has(group),
    );
  };
  const partners = new Map();
  for (const group of candidates(incoming)) {
    const name = group.dataset.typstLabel;
    if (!partners.has(name)) {
      partners.set(name, []);
    }
    partners.get(name).push(group);
  }
  const seen = new Map();
  // Document order puts a group before the groups inside it, so a group inside a matched
  // one is found to be claimed before it could be matched itself.
  for (const group of candidates(outgoing)) {
    const name = group.dataset.typstLabel;
    const index = seen.get(name) ?? 0;
    seen.set(name, index + 1);
    const partner = partners.get(name)?.[index];
    if (
      partner === undefined ||
      within(group, claimed) ||
      within(partner, claimed) ||
      above(group, outgoing) !== above(partner, incoming)
    ) {
      continue;
    }
    claimed.add(group);
    claimed.add(partner);
    pairs.push([group, partner, false]);
  }
  const before = ink(outgoing, claimed);
  const after = ink(incoming, claimed);
  // Each key as a small number, so the diff compares numbers and not long strings.
  const numbers = new Map();
  const numbered = (element, region) => {
    const key = `${inkKey(element)}|${above(element, region)}`;
    let number = numbers.get(key);
    if (number === undefined) {
      number = numbers.size;
      numbers.set(key, number);
    }
    return number;
  };
  const common = commonSubsequence(
    before.map((element) => numbered(element, outgoing)),
    after.map((element) => numbered(element, incoming)),
    MORPH_DIFFERENCES,
  );
  if (common === null) {
    return pairs;
  }
  for (const [i, j] of common) {
    pairs.push([before[i], after[j], false]);
  }
  if (RESIZES) {
    const labels = new Map();
    const structure = (region) => (element) =>
      `${pathStructure(element)}|${above(element, region)}|${labelsAbove(element, region, labels)}`;
    const found = resizes(before, after, common, structure(outgoing), structure(incoming));
    const taken = new Set(common.flatMap(([i, j]) => [before[i], after[j]]));
    for (const [from, to] of found) {
      taken.add(from);
      taken.add(to);
      if (sameFrame(from, to, screen)) {
        pairs.push([from, to, true]);
      }
    }
    const left = (list) => list.filter((element) => !taken.has(element));
    for (const [from, to] of shapeMorphs(left(before), left(after), changed, outgoing, incoming)) {
      if (above(from, outgoing) === above(to, incoming) && sameFrame(from, to, screen)) {
        pairs.push([from, to, true]);
      }
    }
  }
  return pairs;
}

/**
 * The shape morphs among the ink the other matches left over, as pairs of an outgoing and an
 * incoming path.
 *
 * A tag the boundary changes that holds exactly one path left over in each region pairs the
 * two, whatever their structure, because a tag that holds one shape before and one after is
 * a clear statement that the one becomes the other. Any other path left over is crossfaded,
 * because two paths of different structures give no other clue that they belong together.
 * A path belongs to the nearest tag above it, which is the tag around its region when there
 * is none inside the region, and the tags inside one region are paired by name and by index,
 * as the tag matches are.
 */
function shapeMorphs(before, after, changed, outgoing, incoming) {
  const held = (leftovers, region) => {
    const index = new Map();
    const seen = new Map();
    for (const group of region.querySelectorAll("[data-typst-label]")) {
      const name = group.dataset.typstLabel;
      seen.set(name, (seen.get(name) ?? 0) + 1);
      index.set(group, `${name} ${seen.get(name)}`);
    }
    const found = new Map();
    for (const path of leftovers) {
      const tag = holder(path, region);
      if (path.localName === "path" && tag !== null && changed.has(tag.dataset.typstLabel)) {
        const key = index.get(tag) ?? tag.dataset.typstLabel;
        found.set(key, [...(found.get(key) ?? []), path]);
      }
    }
    return found;
  };
  const partners = held(after, incoming);
  const pairs = [];
  for (const [key, paths] of held(before, outgoing)) {
    const other = partners.get(key);
    if (paths.length === 1 && other?.length === 1) {
      pairs.push([paths[0], other[0]]);
    }
  }
  return pairs;
}

/**
 * The tag an element belongs to: the nearest labelled group above it that Animo did not
 * create, inside its region or, failing that, the nearest labelled group above the
 * region when that is a tag, or `null`.
 */
function holder(element, region) {
  let node = element.parentElement;
  while (node !== null && node !== region) {
    const label = node.dataset.typstLabel;
    if (label !== undefined && !label.startsWith("animo-")) {
      return node;
    }
    node = node.parentElement;
  }
  node = region.parentElement?.closest("[data-typst-label]") ?? null;
  return node !== null && !node.dataset.typstLabel.startsWith("animo-") ? node : null;
}

/**
 * The resizes among the ink an ink match left over, as pairs of an outgoing and an incoming
 * path.
 *
 * The leftovers between two consecutive ink matches, or before the first or after the last,
 * are a hunk, and the paths of one hunk are paired by a longest common subsequence of their
 * structure, which `beforeKey` and `afterKey` give. A path is therefore paired only with one
 * between the same two matched neighbours, so a fraction bar that widens between its numerator
 * and its denominator is paired, and a box removed in one place is not paired with one added
 * in another.
 */
function resizes(before, after, common, beforeKey, afterKey) {
  const pairs = [];
  let i = 0;
  let j = 0;
  for (const [end, otherEnd] of [...common, [before.length, after.length]]) {
    const outgoing = before.slice(i, end).filter((element) => element.localName === "path");
    const incoming = after.slice(j, otherEnd).filter((element) => element.localName === "path");
    if (outgoing.length > 0 && incoming.length > 0) {
      const found = commonSubsequence(
        outgoing.map(beforeKey),
        incoming.map(afterKey),
        MORPH_DIFFERENCES,
      );
      for (const [a, b] of found ?? []) {
        pairs.push([outgoing[a], incoming[b]]);
      }
    }
    i = end + 1;
    j = otherEnd + 1;
  }
  return pairs;
}

/**
 * What a path is made of apart from its numbers, as a string that two paths share when the
 * engine can interpolate one into the other.
 *
 * Chromium 151 and firefox 153 interpolate `d` between two paths with the same commands in the
 * same order, number by number, and flip from one to the other halfway through otherwise (see
 * *Findings*). The stroke attributes other than the width are part of it, because the width
 * is animated beside the `d` and the others are not.
 */
function pathStructure(path) {
  const d = path.getAttribute("d") ?? "";
  const commands = (d.match(COMMANDS) ?? []).join("");
  const numbers = (d.match(NUMBER) ?? []).length;
  const shape = PATH_SHAPE.filter((name) => name !== "stroke-width").map(
    (name) => path.getAttribute(name) ?? "",
  );
  return `${commands} ${numbers} ${shape.join(" ")}`;
}

/**
 * The labels of the groups above an element inside its region, as a string.
 *
 * Two paths are a resize only under the same labels, so a shape in a tag is not resized into
 * one outside it, which is how an author keeps two shapes apart.
 */
function labelsAbove(element, region, labels) {
  const parent = element.parentElement;
  if (parent === null || parent === region) {
    return "";
  }
  let found = labels.get(parent);
  if (found === undefined) {
    found = labelsAbove(parent, region, labels);
    const label = parent.dataset.typstLabel;
    if (label !== undefined) {
      found = `${found}${label};`;
    }
    labels.set(parent, found);
  }
  return found;
}

/**
 * Whether two elements draw in user spaces that differ by a translation only.
 *
 * A resize animates the `d` of each path towards the other's, which is the right geometry only
 * when the two user spaces have one scale and one orientation, and the route's `translate`
 * carries what is left. Everything typst lays out differs by a translation, unless a `scale`
 * or a `rotate` sits above one of the two and not above the other.
 */
function sameFrame(outgoing, incoming, screen) {
  const frame = (element) => {
    const own = element.transform.baseVal.consolidate();
    const parent = matrixOf(element.parentNode, screen);
    return own === null ? parent : parent.multiply(own.matrix);
  };
  const a = frame(outgoing);
  const b = frame(incoming);
  const size = Math.max(Math.abs(a.a), Math.abs(a.b), Math.abs(a.c), Math.abs(a.d));
  return ["a", "b", "c", "d"].every(
    (name) => Math.abs(a[name] - b[name]) <= SAME_FRAME * size,
  );
}

/** Whether an element is a matched group or sits inside one. */
function within(element, claimed) {
  for (let node = element; node !== null; node = node.parentElement) {
    if (claimed.has(node)) {
      return true;
    }
  }
  return false;
}

/** The glyphs, paths and images of a region in document order, leaving out claimed groups. */
function ink(region, claimed) {
  const found = [];
  const walk = (node) => {
    for (const child of node.children) {
      if (claimed.has(child) || NOT_INK.has(child.localName)) {
        continue;
      }
      if (INK.has(child.localName)) {
        found.push(child);
      } else {
        walk(child);
      }
    }
  };
  walk(region);
  return found;
}

/**
 * What an element draws, as a string that two elements share when they show the same ink.
 *
 * Typst writes a glyph as a `<use>` of a definition named by a hash of its outline, a shape as
 * a `<path>` whose `d` starts at a local origin, and an image as an `<image>` without a
 * position, so in each case the place is in a transform and the key leaves it out.
 * The colors are left out of every key. See *Findings*.
 */
function inkKey(element) {
  if (element.localName === "use") {
    return `g:${element.href.baseVal}`;
  }
  if (element.localName === "image") {
    const size = ["width", "height"].map((name) => element.getAttribute(name));
    return `i:${element.href.baseVal} ${size.join(" ")}`;
  }
  const shape = PATH_SHAPE.map((name) => element.getAttribute(name) ?? "");
  return `p:${element.getAttribute("d")} ${shape.join(" ")}`;
}

/**
 * The clips above an element inside its region, as a string, with the place of each on the
 * screen.
 *
 * A `translate` carries a clip on the element itself but not the clip of an ancestor, which
 * stays where it is and cuts a moving element off at its edge (see *Findings*). Two copies
 * under two clips would then not sum to one opaque element, so a match needs the same clips
 * at the same places on both sides. A clip is named by its `clip-path`, whose id is a hash of
 * the clip's path. An element of the incoming region is placed as it is laid out, which leaves
 * out a morph translation that is still running above the clip.
 */
function clipsAbove(slide, element, side, clips, screen) {
  const parent = element.parentElement;
  if (parent === null || parent === side.region) {
    return "";
  }
  let found = clips.get(parent);
  if (found === undefined) {
    found = clipsAbove(slide, parent, side, clips, screen);
    const clip = parent.getAttribute("clip-path");
    if (clip !== null) {
      const { a, b, c, d, e, f } = matrixOf(parent, screen);
      const shift = side.laidOut ? running(slide, parent, screen) : { x: 0, y: 0 };
      const place = [a, b, c, d, e - shift.x, f - shift.y]
        .map((value) => value.toFixed(2))
        .join(" ");
      found = `${found}${clip} ${place};`;
    }
    clips.set(parent, found);
  }
  return found;
}

/**
 * A longest common subsequence of two lists of strings, as pairs of indices, or `null` when
 * the lists differ in more than `limit` places.
 *
 * The diff is of the Myers kind, which walks the edit graph one difference at a time and so
 * takes time in proportion to the length of the lists times the number of differences. The
 * common head and tail are paired first, because an edit of a paragraph leaves most of it on
 * either side of the change.
 */
function commonSubsequence(a, b, limit) {
  let head = 0;
  while (head < a.length && head < b.length && a[head] === b[head]) {
    head += 1;
  }
  let tail = 0;
  while (
    tail < a.length - head &&
    tail < b.length - head &&
    a[a.length - 1 - tail] === b[b.length - 1 - tail]
  ) {
    tail += 1;
  }
  const middle = shortestEdit(
    a.slice(head, a.length - tail),
    b.slice(head, b.length - tail),
    limit,
  );
  if (middle === null) {
    return null;
  }
  const pairs = [];
  for (let k = 0; k < head; k += 1) {
    pairs.push([k, k]);
  }
  for (const [i, j] of middle) {
    pairs.push([head + i, head + j]);
  }
  for (let k = tail; k > 0; k -= 1) {
    pairs.push([a.length - k, b.length - k]);
  }
  return pairs;
}

/**
 * The common elements along a shortest edit of `a` into `b`, as pairs of indices in order, or
 * `null` when the edit needs more than `limit` insertions and deletions.
 *
 * `furthest[k]` is how far along `a` the walk got on diagonal `k = x - y`, and one copy of it
 * is kept per number of differences, which is what the walk back reads.
 */
function shortestEdit(a, b, limit) {
  const n = a.length;
  const m = b.length;
  const most = Math.min(n + m, limit);
  const offset = most + 1;
  const furthest = new Int32Array(2 * most + 3);
  const trace = [];
  for (let d = 0; d <= most; d += 1) {
    trace.push(furthest.slice());
    for (let k = -d; k <= d; k += 2) {
      const down = k === -d || (k !== d && furthest[offset + k - 1] < furthest[offset + k + 1]);
      let x = down ? furthest[offset + k + 1] : furthest[offset + k - 1] + 1;
      let y = x - k;
      while (x < n && y < m && a[x] === b[y]) {
        x += 1;
        y += 1;
      }
      furthest[offset + k] = x;
      if (x >= n && y >= m) {
        return walkBack(trace, offset, n, m);
      }
    }
  }
  return null;
}

/** The diagonal steps of the edit `shortestEdit` found, from its end back to its start. */
function walkBack(trace, offset, n, m) {
  const pairs = [];
  let x = n;
  let y = m;
  for (let d = trace.length - 1; d >= 0; d -= 1) {
    const furthest = trace[d];
    const k = x - y;
    const down = k === -d || (k !== d && furthest[offset + k - 1] < furthest[offset + k + 1]);
    const previous = down ? k + 1 : k - 1;
    const px = furthest[offset + previous];
    const py = px - previous;
    while (x > px && y > py) {
      x -= 1;
      y -= 1;
      pairs.push([x, y]);
    }
    x = px;
    y = py;
  }
  return pairs.reverse();
}

/**
 * A match with the distance it travels on the screen: from where the outgoing element is
 * displayed to where the incoming element is laid out.
 *
 * Both are what the page shows before the step, so a morph that interrupts another starts
 * from where the other one had got to. An incoming element is laid out where it is displayed
 * less the morph translations still running on it and above it, which the step is about to
 * end.
 * An outgoing element that a hand-over hid is displayed where its partner is, and `standing`
 * is how far that is from its place, which its route starts from. It is `null` otherwise.
 */
function measured(slide, [outgoing, incoming, resize], screen) {
  const shown = displayed(slide, outgoing);
  const start = origin(slide, shown, screen);
  const end = origin(slide, incoming, screen);
  const shift = running(slide, incoming, screen);
  let standing = null;
  if (shown !== outgoing) {
    const place = origin(slide, outgoing, screen);
    standing = { x: start.x - place.x, y: start.y - place.y };
  }
  return {
    outgoing,
    incoming,
    delta: { x: end.x - shift.x - start.x, y: end.y - shift.y - start.y },
    shape: reshaped(slide, shown, outgoing, incoming, resize),
    standing,
  };
}

/**
 * How a match changes its geometry on the way, as the `start` and `end` of the properties a
 * resize animates, or `null` for a match that keeps its geometry.
 *
 * Both paths start at what the outgoing one shows, which `shown` shows in its place, and end at
 * the `d` of the incoming one.
 * Each path states its `d` in its user space from a local origin, and `sameFrame` holds,
 * so the two have one geometry at every moment, and the route's `translate` puts them at one
 * place. An exact match whose outgoing path an earlier resize is still changing goes on from
 * what that path shows as well.
 * When the two `d` have different commands, which is the case for a shape morph and for a path
 * that a shape morph is still changing, both are rewritten into one structure first, because
 * the engine interpolates only between paths of the same commands. An open subpath is closed
 * as its fill closes it (see `alignPaths`).
 *
 * A property is animated only where it changes, because chromium 151 stops drawing the other
 * properties of an effect beside a keyframe property that is equal at both ends (see
 * *Findings*), and `d` is equal at both ends in another spelling when only the stroke width
 * changes.
 */
function reshaped(slide, shown, outgoing, incoming, resize) {
  const changing = slide.morphed.get(shown)?.shape !== undefined;
  if (!resize && !changing) {
    return null;
  }
  const names = RESHAPED.filter((name) => {
    const before = outgoing.getAttribute(name);
    const after = incoming.getAttribute(name);
    return before !== null && after !== null && (changing || before !== after);
  });
  const value = (name) => {
    const after = incoming.getAttribute(name).trim();
    return name === "d" ? `path("${after}")` : `${after}px`;
  };
  const start = showing(shown, names);
  const end = Object.fromEntries(names.map((name) => [name, value(name)]));
  if (names.includes("d") && pathCommands(start.d) !== pathCommands(end.d)) {
    const filled = (path) => path.getAttribute("fill") !== "none";
    const aligned = alignPaths(start.d, end.d, [filled(outgoing), filled(incoming)]);
    if (aligned === null) {
      delete start.d;
      delete end.d;
    } else {
      start.d = `path("${aligned[0]}")`;
      end.d = `path("${aligned[1]}")`;
    }
  }
  return Object.keys(end).length === 0 ? null : { start, end };
}

/** The morph translations still running on an element and above it, on the screen. */
function running(slide, element, screen) {
  const total = { x: 0, y: 0 };
  for (const node of morphedChain(slide, element)) {
    const offset = onScreen(node, translation(node), screen);
    total.x += offset.x;
    total.y += offset.y;
  }
  return total;
}

/**
 * Where an element puts its origin on the screen, in CSS pixels.
 *
 * `getScreenCTM()` includes the `translate` of the element itself in all three engines, and the `x`
 * and `y` of a `<use>` are an offset inside it. See *Findings*.
 * A glyph, a path or an image that no morph is moving has no `translate`, so its matrix is its
 * parent's followed by its `transform` attribute, and the glyphs of a run share the
 * parent's.
 */
function origin(slide, element, screen) {
  const x = element.x?.baseVal?.value ?? 0;
  let point = new DOMPoint(x, element.y?.baseVal?.value ?? 0);
  if (INK.has(element.localName) && !slide.morphed.has(element)) {
    const own = element.transform.baseVal.consolidate();
    if (own !== null) {
      point = point.matrixTransform(own.matrix);
    }
    point = point.matrixTransform(matrixOf(element.parentNode, screen));
  } else {
    point = point.matrixTransform(element.getScreenCTM());
  }
  return { x: point.x, y: point.y };
}

/** The screen matrix of an element, read once per step. */
function matrixOf(element, screen) {
  let found = screen.get(element);
  if (found === undefined) {
    found = element.getScreenCTM();
    screen.set(element, found);
  }
  return found;
}

/** The element and its ancestors that a morph is still moving, up to its rendering. */
function morphedChain(slide, element) {
  const found = [];
  for (let node = element; node !== null; node = node.parentElement) {
    if (slide.morphed.has(node)) {
      found.push(node);
    }
    if (stackLabel(node.dataset?.typstLabel)?.kind === "epoch") {
      break;
    }
  }
  return found;
}

/** The `translate` an element computes, which is the one a running animation gives it. */
function translation(element) {
  const value = getComputedStyle(element).translate;
  if (value === "none" || value === "") {
    return { x: 0, y: 0 };
  }
  const [x = 0, y = 0] = value.split(/\s+/).map(Number.parseFloat);
  return { x, y };
}

/**
 * A `translate` of an element as a distance on the screen.
 *
 * A `translate` acts in the user space of the element's parent, which for a glyph is a run
 * that typst has flipped upside down, so the distance goes through the matrix of the parent
 * and not through the matrix of the element.
 */
function onScreen(element, { x, y }, screen) {
  const point = new DOMPoint(x, y, 0, 0).matrixTransform(matrixOf(element.parentNode, screen));
  return { x: point.x, y: point.y };
}

/** A distance on the screen as a `translate` of an element, which `onScreen` undoes. */
function inParent(element, { x, y }, screen) {
  const point = new DOMPoint(x, y, 0, 0).matrixTransform(
    matrixOf(element.parentNode, screen).inverse(),
  );
  return { x: point.x, y: point.y };
}

/** A `translate` as CSS, rounded to a ten thousandth of a pixel. */
function px({ x, y }) {
  const round = (value) => Math.round(value * 10000) / 10000 || 0;
  return `${round(x)}px ${round(y)}px`;
}

/**
 * Replace the glyph matches of a run of text that moves as one by one match of the two runs.
 *
 * Typst draws a run of text as a group of `<use>` elements, so a run whose every glyph is
 * matched to every glyph of one other run, at one distance, can be carried with one
 * animation instead of one per glyph. A run with a glyph a morph is still moving keeps its
 * matches, because the translation of the glyph would be added to the translation of the run.
 * So does a run with a glyph that starts from where its partner is shown, because each such
 * glyph starts from a different distance.
 */
function rigid(measuredPairs, morphed) {
  const result = [];
  let start = 0;
  while (start < measuredPairs.length) {
    const first = measuredPairs[start];
    const before = first.outgoing.parentElement;
    const after = first.incoming.parentElement;
    let end = start;
    while (
      end < measuredPairs.length &&
      measuredPairs[end].outgoing.parentElement === before &&
      measuredPairs[end].incoming.parentElement === after
    ) {
      end += 1;
    }
    const run = measuredPairs.slice(start, end);
    const whole =
      run.length === before.childElementCount &&
      run.length === after.childElementCount &&
      !isSlot(before) &&
      !isSlot(after) &&
      run.every(
        (pair) =>
          pair.outgoing.localName === "use" &&
          Math.hypot(pair.delta.x - first.delta.x, pair.delta.y - first.delta.y) < MORPH_STILL &&
          pair.standing === null &&
          !morphed.has(pair.outgoing) &&
          !morphed.has(pair.incoming),
      );
    if (whole) {
      result.push({ outgoing: before, incoming: after, delta: first.delta });
    } else {
      result.push(...run);
    }
    start = end;
  }
  return result;
}

/** Whether a group is one of the two slots of a tag site, which hold other translations. */
function isSlot(group) {
  return group.hasAttribute("data-typst-label") || group.parentElement.hasAttribute("data-typst-label");
}

/**
 * Plan the two translations of one match, and the geometry of a resize, and remember the
 * elements as moving.
 *
 * The outgoing element goes from what it shows to the place of the incoming one. A morph still
 * moving one of its ancestors goes on moving it in this step, to where `settleMorphs` sends it,
 * so the route of the outgoing element leaves out what that ancestor still travels, and the
 * two arrive together. The incoming element comes from the place of the outgoing one.
 * The `d` and the stroke width of a resize take both paths from the outgoing geometry to the
 * incoming one, and neither is written as inline style, so a path at rest shows its attribute.
 *
 * An outgoing element that a hand-over hid starts from where its partner is shown, which
 * `standing` gives.
 *
 * A match that has not moved, does not change its geometry and that no morph is moving needs
 * no animation.
 */
function carry(effects, slide, match, timing, where) {
  const { outgoing, incoming, delta, shape = null, standing = null } = match;
  const { stack, from, to, screen } = where;
  const { morphed } = slide;
  if (
    Math.hypot(delta.x, delta.y) < MORPH_STILL &&
    shape === null &&
    standing === null &&
    !morphed.has(outgoing) &&
    !morphed.has(incoming)
  ) {
    return;
  }
  const travel = { ...delta };
  for (const node of morphedChain(slide, outgoing.parentElement)) {
    const now = onScreen(node, translation(node), screen);
    const heading = morphed.get(node).heading;
    const then = heading === null ? { x: 0, y: 0 } : onScreen(node, parsed(heading), screen);
    travel.x += now.x - then.x;
    travel.y += now.y - then.y;
  }
  let own = { x: 0, y: 0 };
  if (morphed.has(outgoing)) {
    own = translation(outgoing);
  } else if (standing !== null) {
    own = inParent(outgoing, standing, screen);
  }
  const step = inParent(outgoing, travel, screen);
  const end = px({ x: own.x + step.x, y: own.y + step.y });
  const names = ["translate", ...Object.keys(shape?.end ?? {})];
  const unset = Object.fromEntries(names.map((name) => [name, ""]));
  const timed = Object.fromEntries(names.map((name) => [name, timing]));
  plan(effects, outgoing, unset, timed, {
    start: { translate: px(own), ...shape?.start },
    end: { translate: end, ...shape?.end },
  });
  const back = inParent(incoming, { x: -delta.x, y: -delta.y }, screen);
  plan(effects, incoming, unset, timed, {
    start: { translate: px(back), ...shape?.start },
    end: { translate: AT_REST, ...shape?.end },
  });
  // Both paths end at the incoming geometry, which is the geometry of the incoming path at rest,
  // in the commands the two share while they move.
  morphed.set(outgoing, { epoch: from, stack, end, heading: end, shape: shape?.end });
  morphed.set(incoming, { epoch: to, stack, end: null, heading: null, shape: shape?.end });
}

/** A `translate` as `px` writes it, back as a distance. */
function parsed(value) {
  const [x = 0, y = 0] = value.split(/\s+/).map(Number.parseFloat);
  return { x, y };
}

/**
 * Plan every translation and resize an earlier morph left running on a slide, before a step.
 *
 * A translation in a stack the step carries again runs on to where it was going, on the
 * clock of the new boundary, so it ends as the stack's new crossfade ends rather than in the
 * middle of it. The exception is an element of the rendering being entered, which this step
 * shows as it is laid out.
 * The translation of such an element snaps to rest, and a morph of this step that matches
 * it again gives it a separate route. Every other translation snaps to rest, as the
 * crossfade of a stack the step does not carry does. The `d` and the stroke width of a resize
 * run on or snap with the translation of their path.
 *
 * `carried` is the record of every stack the step carries, by stack.
 * `heading` records where each element is going in this step, which `carry` reads for the
 * ancestors of what it matches.
 */
function settleMorphs(effects, slide, to, carried, options, mirror) {
  for (const [element, record] of slide.morphed) {
    if (!element.getAnimations().some(ours)) {
      slide.morphed.delete(element);
      continue;
    }
    const own = record.epoch === to ? undefined : carried.get(record.stack);
    const timing = own === undefined ? null : scheduled(options, own.timing, mirror);
    const names = ["translate", ...Object.keys(record.shape ?? {})];
    const unset = Object.fromEntries(names.map((name) => [name, ""]));
    if (timing === null) {
      plan(effects, element, unset);
      record.heading = null;
      continue;
    }
    plan(effects, element, unset, Object.fromEntries(names.map((name) => [name, timing])), {
      end: { translate: record.end, ...record.shape },
    });
    record.heading = record.end;
  }
}
