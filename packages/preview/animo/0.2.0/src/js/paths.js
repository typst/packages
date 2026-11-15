// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// The alignment of two paths, which rewrites them into one structure so that the engine can
// interpolate the `d` of one into the other.
//
// Chromium and firefox interpolate `d` only between two paths of the same commands (see
// *Findings*), so a square and a circle have to be written with one sequence of commands
// before a morph can carry one into the other. Every segment becomes a cubic Bézier, the two
// paths get as many subpaths, and paired subpaths get as many segments, cut at the vertices of
// both by their fraction of the length, after the starting point and the direction that make
// the points travel least. Nothing here reads the DOM, so the alignment can be tested on
// numbers alone.

/** How many points of a segment its length and its points along the length are read from. */
const PATH_SAMPLES = 8;

/** How many points of a subpath the travel of an alignment is measured on. */
const TRAVEL_SAMPLES = 64;

/** How many starting points of a closed subpath are tried before the best one is refined. */
const START_CANDIDATES = 128;

/**
 * How close, as a fraction of the length, a vertex of one subpath has to come to a vertex of
 * its partner for the two to be one cut, so that no segment is cut into a sliver.
 */
const SAME_CUT = 1e-3;

/** A length, in user units, below which a segment or a subpath has none. */
const NO_LENGTH = 1e-6;

/** How many numbers each command of SVG path data takes. */
const ARITY = { M: 2, L: 2, H: 1, V: 1, C: 6, S: 4, Q: 4, T: 2, A: 7, Z: 0 };

/** A command letter or a number of SVG path data. */
const PATH_TOKEN = /[MmLlHhVvCcSsQqTtAaZz]|[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?/g;

/**
 * Two paths rewritten into one structure, as the path data of each, or `null` when one of the
 * two cannot be read or draws nothing.
 *
 * Both are written as absolute cubic Béziers with the same number of subpaths and the same
 * number of segments in each, closed with `Z` in the same places, so that the engine
 * interpolates the one into the other number by number. Each keeps its geometry.
 * The path data may be an attribute or a computed `path("..")`.
 * `filled` says for each of the two whether it has a fill, which decides how an open subpath
 * is closed when its partner is closed (see `closedLike`).
 */
function alignPaths(from, to, filled = [false, false]) {
  const a = parsePath(from);
  const b = parsePath(to);
  if (a === null || b === null || a.length === 0 || b.length === 0) {
    return null;
  }
  const [before, after] = pairSubpaths(a.map(measure), b.map(measure));
  const aligned = before.map((subpath, index) => {
    const other = after[index];
    if (subpath.closed === other.closed) {
      return alignSubpaths(subpath, other);
    }
    return subpath.closed
      ? alignSubpaths(subpath, closedLike(other, filled[1]))
      : alignSubpaths(closedLike(subpath, filled[0]), other);
  });
  return [
    writePath(aligned.map(([one, , closed]) => [one, closed])),
    writePath(aligned.map(([, other, closed]) => [other, closed])),
  ];
}

/**
 * An open subpath as a closed one that looks the same, for a partner that is closed.
 *
 * A path with a fill fills an open subpath as if a line closed it, so that line closes it.
 * Without a fill, the subpath runs back along itself, which strokes the same apart from its
 * two ends, where the turn is a join and not a cap. A line then opens into the outline of
 * its partner on both sides at once, and an outline folds onto a line.
 */
function closedLike(subpath, filled) {
  const { segments } = subpath;
  const [x0, y0] = segments[0];
  const [x1, y1] = segments[segments.length - 1].slice(6);
  const back = filled
    ? [line(x1, y1, x0, y0)]
    : segments.map(reversedCubic).reverse();
  return measure({ segments: [...segments, ...back], closed: true });
}

/**
 * The command letters of path data in upper case, which two paths share exactly when the
 * engine interpolates the one into the other.
 */
function pathCommands(data) {
  return (data.match(/[MmLlHhVvCcSsQqTtAaZz]/g) ?? []).join("").toUpperCase();
}

/**
 * The subpaths of path data, each as its segments and whether it is closed, or `null` for
 * data with an arc or a number missing.
 *
 * A segment is a cubic Bézier as the eight coordinates of its four points. A line becomes a
 * cubic whose control points sit on it at a third and two thirds, and a quadratic is raised
 * to a cubic exactly. Typst writes no arcs, so an arc is not read. A segment without length
 * is dropped, and so is a subpath without segments, such as the `M 0 0` that starts every
 * path typst writes. A subpath that ends where it starts is closed, with `Z` or without it.
 */
function parsePath(data) {
  const text = data.trim().replace(/^path\(\s*["']?/, "").replace(/["']?\s*\)$/, "");
  const tokens = text.match(PATH_TOKEN) ?? [];
  const subpaths = [];
  let current = null;
  let x = 0;
  let y = 0;
  let startX = 0;
  let startY = 0;
  // The second control point of the previous segment, for the reflection of `S` and `T`.
  let cubic = null;
  let quadratic = null;
  const begin = (px, py) => {
    current = { segments: [], closed: false };
    subpaths.push(current);
    startX = px;
    startY = py;
  };
  const add = (segment) => {
    if (current === null) {
      begin(x, y);
    }
    const [x0, y0] = segment;
    if (segment.some((value, index) => Math.abs(value - (index % 2 === 0 ? x0 : y0)) > 0)) {
      current.segments.push(segment);
    }
    x = segment[6];
    y = segment[7];
  };
  let index = 0;
  let command = null;
  while (index < tokens.length) {
    if (/[A-Za-z]/.test(tokens[index])) {
      command = tokens[index];
      index += 1;
    } else if (command === null || command === "Z" || command === "z") {
      return null;
    }
    const upper = command.toUpperCase();
    const relative = command !== upper;
    const count = ARITY[upper];
    const values = tokens.slice(index, index + count).map(Number);
    if (values.length < count || values.some(Number.isNaN) || upper === "A") {
      return null;
    }
    index += count;
    const ox = relative ? x : 0;
    const oy = relative ? y : 0;
    let nextCubic = null;
    let nextQuadratic = null;
    if (upper === "M") {
      x = values[0] + ox;
      y = values[1] + oy;
      begin(x, y);
      // Further pairs after a move are lines.
      command = relative ? "l" : "L";
    } else if (upper === "Z") {
      if (current !== null) {
        if (Math.hypot(x - startX, y - startY) > 0) {
          add(line(x, y, startX, startY));
        }
        current.closed = true;
        current = null;
      }
      x = startX;
      y = startY;
    } else if (upper === "L" || upper === "H" || upper === "V") {
      const nx = upper === "V" ? x : values[0] + ox;
      const ny = upper === "H" ? y : values[upper === "V" ? 0 : 1] + oy;
      add(line(x, y, nx, ny));
    } else if (upper === "C" || upper === "S") {
      const [x1, y1] =
        upper === "C"
          ? [values[0] + ox, values[1] + oy]
          : cubic === null
            ? [x, y]
            : [2 * x - cubic[0], 2 * y - cubic[1]];
      const rest = upper === "C" ? values.slice(2) : values;
      const x2 = rest[0] + ox;
      const y2 = rest[1] + oy;
      add([x, y, x1, y1, x2, y2, rest[2] + ox, rest[3] + oy]);
      nextCubic = [x2, y2];
    } else {
      const [qx, qy] =
        upper === "Q"
          ? [values[0] + ox, values[1] + oy]
          : quadratic === null
            ? [x, y]
            : [2 * x - quadratic[0], 2 * y - quadratic[1]];
      const rest = upper === "Q" ? values.slice(2) : values;
      const ex = rest[0] + ox;
      const ey = rest[1] + oy;
      add([
        x,
        y,
        x + ((qx - x) * 2) / 3,
        y + ((qy - y) * 2) / 3,
        ex + ((qx - ex) * 2) / 3,
        ey + ((qy - ey) * 2) / 3,
        ex,
        ey,
      ]);
      nextQuadratic = [qx, qy];
    }
    cubic = nextCubic;
    quadratic = nextQuadratic;
  }
  return subpaths
    .filter((subpath) => subpath.segments.length > 0)
    .map(({ segments, closed }) => {
      const [sx, sy] = segments[0];
      const last = segments[segments.length - 1];
      const ends = Math.hypot(last[6] - sx, last[7] - sy) < NO_LENGTH * 1000;
      return { segments, closed: closed || ends };
    });
}

/** A straight line as a cubic Bézier. */
function line(x0, y0, x1, y1) {
  const dx = (x1 - x0) / 3;
  const dy = (y1 - y0) / 3;
  return [x0, y0, x0 + dx, y0 + dy, x1 - dx, y1 - dy, x1, y1];
}

/** The point of a cubic Bézier at a parameter. */
function cubicAt(segment, t) {
  const u = 1 - t;
  const [a, b, c, d] = [u * u * u, 3 * u * u * t, 3 * u * t * t, t * t * t];
  return [
    a * segment[0] + b * segment[2] + c * segment[4] + d * segment[6],
    a * segment[1] + b * segment[3] + c * segment[5] + d * segment[7],
  ];
}

/** A cubic Bézier cut in two at a parameter, by de Casteljau. */
function splitCubic(segment, t) {
  const mix = (i, j, s) => [
    segment[i] + (segment[j] - segment[i]) * s,
    segment[i + 1] + (segment[j + 1] - segment[i + 1]) * s,
  ];
  const p01 = mix(0, 2, t);
  const p12 = mix(2, 4, t);
  const p23 = mix(4, 6, t);
  const p012 = [p01[0] + (p12[0] - p01[0]) * t, p01[1] + (p12[1] - p01[1]) * t];
  const p123 = [p12[0] + (p23[0] - p12[0]) * t, p12[1] + (p23[1] - p12[1]) * t];
  const p = [p012[0] + (p123[0] - p012[0]) * t, p012[1] + (p123[1] - p012[1]) * t];
  return [
    [segment[0], segment[1], ...p01, ...p012, ...p],
    [...p, ...p123, ...p23, segment[6], segment[7]],
  ];
}

/** The part of a cubic Bézier between two parameters. */
function cubicPart(segment, t0, t1) {
  if (t1 <= t0) {
    const [x, y] = cubicAt(segment, t0);
    return [x, y, x, y, x, y, x, y];
  }
  const right = t0 <= 0 ? segment : splitCubic(segment, t0)[1];
  const along = t0 >= 1 ? 1 : (t1 - t0) / (1 - t0);
  return along >= 1 ? right : splitCubic(right, along)[0];
}

/** A cubic Bézier run the other way. */
function reversedCubic(segment) {
  return [
    segment[6],
    segment[7],
    segment[4],
    segment[5],
    segment[2],
    segment[3],
    segment[0],
    segment[1],
  ];
}

/**
 * A subpath with the points its length is read from.
 *
 * `xs`, `ys` and `lengths` hold `PATH_SAMPLES` points per segment and the length of the
 * polyline through them up to each, and `vertices` the fraction of the length at which each
 * segment starts, with one more for the end.
 */
function measure({ segments, closed }) {
  const count = segments.length * PATH_SAMPLES + 1;
  const xs = new Float64Array(count);
  const ys = new Float64Array(count);
  const lengths = new Float64Array(count);
  [xs[0], ys[0]] = segments[0];
  let k = 1;
  for (const segment of segments) {
    for (let step = 1; step <= PATH_SAMPLES; step += 1) {
      [xs[k], ys[k]] = cubicAt(segment, step / PATH_SAMPLES);
      lengths[k] = lengths[k - 1] + Math.hypot(xs[k] - xs[k - 1], ys[k] - ys[k - 1]);
      k += 1;
    }
  }
  const total = lengths[count - 1];
  const vertices = segments.map((_, index) =>
    total > 0 ? lengths[index * PATH_SAMPLES] / total : index / segments.length,
  );
  vertices.push(1);
  return { segments, closed, xs, ys, lengths, total, vertices };
}

/** The point at a fraction of the length of a measured subpath, going round a closed one. */
function pointAlong(subpath, fraction) {
  const { xs, ys, lengths, total } = subpath;
  const wrapped = subpath.closed ? fraction - Math.floor(fraction) : fraction;
  const target = Math.min(Math.max(wrapped, 0), 1) * total;
  let low = 0;
  let high = lengths.length - 1;
  while (high - low > 1) {
    const middle = (low + high) >> 1;
    if (lengths[middle] <= target) {
      low = middle;
    } else {
      high = middle;
    }
  }
  const span = lengths[high] - lengths[low];
  const s = span > 0 ? (target - lengths[low]) / span : 0;
  return [xs[low] + (xs[high] - xs[low]) * s, ys[low] + (ys[high] - ys[low]) * s];
}

/**
 * The parameter of a segment at a fraction of the length of its subpath, held to the
 * segment.
 */
function parameterAt(subpath, segment, fraction) {
  const { lengths, total } = subpath;
  const first = segment * PATH_SAMPLES;
  const target = fraction * total;
  if (target <= lengths[first]) {
    return 0;
  }
  for (let step = 1; step <= PATH_SAMPLES; step += 1) {
    const end = lengths[first + step];
    if (target <= end) {
      const start = lengths[first + step - 1];
      const s = end > start ? (target - start) / (end - start) : 0;
      return (step - 1 + s) / PATH_SAMPLES;
    }
  }
  return 1;
}

/** The index of the segment that holds a fraction of the length of its subpath. */
function segmentAt(subpath, fraction) {
  const { vertices } = subpath;
  let low = 0;
  let high = vertices.length - 1;
  while (high - low > 1) {
    const middle = (low + high) >> 1;
    if (vertices[middle] <= fraction) {
      low = middle;
    } else {
      high = middle;
    }
  }
  return low;
}

/** The area a closed subpath encloses, with the sign of its winding. */
function signedArea({ xs, ys }) {
  let area = 0;
  for (let k = 1; k < xs.length; k += 1) {
    area += xs[k - 1] * ys[k] - xs[k] * ys[k - 1];
  }
  return area / 2;
}

/** The middle of the box around the subpaths of a path. */
function middle(subpaths) {
  let [left, top, right, bottom] = [Infinity, Infinity, -Infinity, -Infinity];
  for (const { xs, ys } of subpaths) {
    for (let k = 0; k < xs.length; k += 1) {
      left = Math.min(left, xs[k]);
      right = Math.max(right, xs[k]);
      top = Math.min(top, ys[k]);
      bottom = Math.max(bottom, ys[k]);
    }
  }
  return [(left + right) / 2, (top + bottom) / 2];
}

/**
 * The subpaths of two paths in pairs, as two lists of one length.
 *
 * The subpaths are paired by their length, the longest with the longest, which pairs the
 * outline of a shape with the outline and a hole with a hole. A subpath without a partner is
 * paired with a point, at the place in the box of the other path that the middle of the subpath
 * has in the box of its path, so that it grows out of nothing or shrinks into nothing there.
 */
function pairSubpaths(a, b) {
  const longest = (list) => [...list].sort((one, other) => other.total - one.total);
  const before = longest(a);
  const after = longest(b);
  const [ax, ay] = middle(a);
  const [bx, by] = middle(b);
  const point = (subpath, dx, dy) => {
    const [x, y] = middle([subpath]);
    const at = [x + dx, y + dy];
    return measure({ segments: [[...at, ...at, ...at, ...at]], closed: subpath.closed });
  };
  for (let index = before.length; index < after.length; index += 1) {
    before.push(point(after[index], ax - bx, ay - by));
  }
  for (let index = after.length; index < before.length; index += 1) {
    after.push(point(before[index], bx - ax, by - ay));
  }
  return [before, after];
}

/**
 * Two subpaths, both open or both closed, with one number of segments, as the segments of
 * each and whether both are closed.
 *
 * Two closed subpaths are run the same way round, which is the sign of their area, or the one
 * turns itself inside out on the way, and the second starts where the points travel least.
 * Two open ones run the way that travels least. Both are then cut at the vertices of both,
 * which leaves every piece within one segment of each side.
 */
function alignSubpaths(a, b) {
  if (a.total < NO_LENGTH || b.total < NO_LENGTH) {
    return collapsed(a, b);
  }
  let other = b;
  if (a.closed) {
    const [areaA, areaB] = [signedArea(a), signedArea(b)];
    const options =
      areaA * areaB === 0 ? [b, reversedSubpath(b)] : [areaA * areaB < 0 ? reversedSubpath(b) : b];
    const best = startOf(a, options);
    other = opened(best.subpath, best.start);
  } else {
    const reversed = reversedSubpath(b);
    other = travelOf(a, reversed, 0) < travelOf(a, b, 0) ? reversed : b;
  }
  const [first, second] = correspond(a, other);
  return [first, second, a.closed];
}

/** Two subpaths of which one has no length, as the other and a point repeated as often. */
function collapsed(a, b) {
  const point = (subpath) => {
    const [x, y] = subpath.segments[0];
    return [x, y, x, y, x, y, x, y];
  };
  if (a.total < NO_LENGTH && b.total < NO_LENGTH) {
    return [[point(a)], [point(b)], a.closed && b.closed];
  }
  const long = a.total < NO_LENGTH ? b : a;
  const still = long.segments.map(() => point(a.total < NO_LENGTH ? a : b));
  const closed = long.closed;
  return a.total < NO_LENGTH ? [still, long.segments, closed] : [long.segments, still, closed];
}

/** A measured subpath run the other way. */
function reversedSubpath({ segments, closed }) {
  return measure({ segments: segments.map(reversedCubic).reverse(), closed });
}

/**
 * The squared distance the points of one subpath travel to those of another, at as many
 * places along the length of each, with the second starting at a fraction of its length.
 *
 * The distance is squared so that a translation of one subpath against the other adds the
 * same amount at every start and in either direction, which leaves the best of them where
 * the two sit in their user spaces.
 */
function travelOf(a, b, start) {
  let sum = 0;
  for (let k = 0; k < TRAVEL_SAMPLES; k += 1) {
    const fraction = a.closed ? (k + 0.5) / TRAVEL_SAMPLES : k / (TRAVEL_SAMPLES - 1);
    const [ax, ay] = pointAlong(a, fraction);
    const [bx, by] = pointAlong(b, fraction + start);
    sum += (ax - bx) ** 2 + (ay - by) ** 2;
  }
  return sum;
}

/**
 * Where a closed subpath starts so that the points of another closed subpath travel least to
 * it, as the fraction of its length and the subpath, among the options of its direction.
 *
 * `START_CANDIDATES` starts at equal distances are tried, and the best is refined between its
 * neighbours by a golden section search. A start close to a vertex is moved onto the vertex,
 * so that no segment is cut into a sliver there.
 */
function startOf(reference, options) {
  let best = null;
  for (const subpath of options) {
    const cost = (start) => travelOf(reference, subpath, start);
    let found = 0;
    let lowest = Infinity;
    for (let k = 0; k < START_CANDIDATES; k += 1) {
      const value = cost(k / START_CANDIDATES);
      if (value < lowest) {
        lowest = value;
        found = k / START_CANDIDATES;
      }
    }
    let low = found - 1 / START_CANDIDATES;
    let high = found + 1 / START_CANDIDATES;
    const ratio = (Math.sqrt(5) - 1) / 2;
    for (let round = 0; round < 24; round += 1) {
      const left = high - ratio * (high - low);
      const right = low + ratio * (high - low);
      if (cost(left) < cost(right)) {
        high = right;
      } else {
        low = left;
      }
    }
    let start = (low + high) / 2;
    start -= Math.floor(start);
    for (const vertex of subpath.vertices) {
      const gap = Math.abs(vertex - start);
      if (Math.min(gap, 1 - gap) < SAME_CUT) {
        start = vertex % 1;
      }
    }
    const value = cost(start);
    if (best === null || value < best.value) {
      best = { subpath, start, value };
    }
  }
  return best;
}

/** A closed subpath opened at a fraction of its length, as a subpath that starts there. */
function opened(subpath, start) {
  const { segments } = subpath;
  const index = segmentAt(subpath, start);
  const t = parameterAt(subpath, index, start);
  const [head, tail] = splitCubic(segments[index], t);
  const parts = [tail, ...segments.slice(index + 1), ...segments.slice(0, index), head];
  const lengthOf = (segment) =>
    Math.hypot(segment[6] - segment[0], segment[7] - segment[1]) +
    Math.hypot(segment[2] - segment[0], segment[3] - segment[1]) +
    Math.hypot(segment[4] - segment[6], segment[5] - segment[7]);
  return measure({ segments: parts.filter((part) => lengthOf(part) > NO_LENGTH), closed: false });
}

/**
 * Two subpaths that start together and end together cut into as many pieces.
 *
 * The cuts are the vertices of both, by their fraction of the length, and a vertex of one
 * side close to one of the other is one cut at the vertex of each, so that no segment is cut
 * into a sliver. Each piece then lies within one segment of each side.
 */
function correspond(a, b) {
  const cuts = [];
  for (const [side, subpath] of [["a", a], ["b", b]]) {
    for (const vertex of subpath.vertices.slice(1, -1)) {
      cuts.push({ at: vertex, a: vertex, b: vertex, side });
    }
  }
  cuts.sort((one, other) => one.at - other.at);
  const merged = [{ a: 0, b: 0 }];
  let last = null;
  for (const cut of cuts) {
    if (last !== null && last.side !== null && last.side !== cut.side && cut.at - last.at < SAME_CUT) {
      last[cut.side] = cut[cut.side];
      last.side = null;
    } else {
      last = { ...cut };
      merged.push(last);
    }
  }
  merged.push({ a: 1, b: 1 });
  const pieces = (subpath, side) => {
    const found = [];
    for (let k = 0; k + 1 < merged.length; k += 1) {
      const from = merged[k][side];
      const to = merged[k + 1][side];
      const segment = segmentAt(subpath, (from + to) / 2);
      found.push(
        cubicPart(
          subpath.segments[segment],
          parameterAt(subpath, segment, from),
          parameterAt(subpath, segment, to),
        ),
      );
    }
    return found;
  };
  return [pieces(a, "a"), pieces(b, "b")];
}

/** Subpaths as path data of absolute cubic Béziers, rounded to a ten thousandth. */
function writePath(subpaths) {
  const round = (value) => Math.round(value * 10000) / 10000 || 0;
  const parts = [];
  for (const [segments, closed] of subpaths) {
    parts.push(`M ${round(segments[0][0])} ${round(segments[0][1])}`);
    for (const segment of segments) {
      parts.push(`C ${segment.slice(2).map(round).join(" ")}`);
    }
    if (closed) {
      parts.push("Z");
    }
  }
  return parts.join(" ");
}
