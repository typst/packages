// Semantic layout layer for xwysyy-typst — telemetry schema v4.
//
// Authors (human or AI) pick a semantic component and provide typed content
// items; each component measures the real rendered size of every block, runs
// a shared allocator, and exports the *measured* normalized geometry as
// `<xwysyy-slide-layout>` v4 metadata for scripts/slide-check.py.
//
// Honesty rules baked into the schema:
//   * sizing is DECLARED, never inferred: percent-sized content must be
//     wrapped in `visual(...)` (fit: "stretch"); required slots panic on
//     `none`; text slots panic on content with no measurable width or height
//     (spacers, empty strings, bare rules) instead of masquerading as a
//     payload;
//   * every object carries `frame` (allocated), `preferred` (what the
//     allocator saw), `payload` (a 2-D flow bbox of the inner content —
//     approximate for wrapped text, exact for fixed-size content) and
//     `paint` (the visible card box + its fill colour, or none);
//   * `payload_source` separates "measured" payloads from "declared" ones
//     (stretch slots and percent-width media): a declared payload is a
//     claim, not evidence — the checker verifies it against rendered pixels
//     instead of trusting it;
//   * unbreakable content wider than its slot is exported as `overflow_x`
//     (wrapped text is clamped honestly; a long URL that cannot wrap is not);
//   * the allocator has four states — normal / compressed (gaps squeezed
//     below their preferred size) / tight (outer margins consumed) /
//     overflow — with the invariants overflow => body_overflow_ratio > 0 and
//     compressed => gap_ratio < 1;
//   * one `<xwysyy-frame>` mapping is emitted per physically rendered
//     subslide, carrying the physical body geometry in pt, and the slide id
//     is stable across subslides (touying's logical slide counter), so every
//     frame joins its layout record and coverage counts real pages.
//
// Authors never write raw `v()` spacing or absolute coordinates; they adjust
// `mode` and read the numeric feedback the checker returns after each
// compile.  Numeric layout knobs live in the `tuning` dictionary (validated
// for key, type, and range); the AI generation contract treats `tuning` as
// off-limits and the telemetry records whether it was used.
//
// Stepwise reveal: touying's `#pause` cannot be used inside these components
// (marks do not survive `context` / `layout` closures; touying panics).
// Components take `reveal: true` (or per-item `reveal-from`) instead, which
// shows blocks one subslide at a time via the callback-style `utils.uncover`
// — hidden steps keep their measured space, so the layout is identical on
// every subslide.  One resolver (`_steps`) serves every component and an
// explicit `reveal-from` always wins over the `reveal: true` sugar;
// components without reveal steps reject `reveal-from` instead of silently
// ignoring it.

#import "@preview/touying:0.7.4": utils
#import "slides.typ": xwysyy-slide
#import "elements.typ": textbox
#import "themes.typ": _theme-state

// Capture alignment references before any parameter named `top` / `bottom` /
// `left` shadows them inside a component body.
#let _atop = top
#let _abottom = bottom
#let _aleft = left
#let _acenter = center
#let _ahorizon = horizon

#let _note-mode() = sys.inputs.at("mode", default: "slides") == "note"
#let _clamp(x, lo, hi) = calc.min(calc.max(x, lo), hi)

// Optical center sits slightly above the geometric center so a centered group
// does not read as sinking.  Only focus-slide centers a group; every other
// component fills the body instead.
#let _OPTICAL-CENTER = 0.46

// Fill-first distribution.  Outer margins are pinned small; leftover space
// grows the content (figures become dominant, cards become tall) instead of
// becoming blank margin.
#let _MARGIN-TOP = 0.07
#let _MARGIN-BOT = 0.09
#let _FILL = 1.0 - 0.07 - 0.09
// A card row occupies at least this fraction of the body height, so a row of
// short cards reads as substantial cards rather than tiles floating in space.
#let _CARD-FILL-MIN = 0.60
// Hard minimum for a stretch visual: below this the visual is starved and the
// slide must degrade to tight/overflow instead of reporting normal.
#let _VISUAL-MIN = 0.28
// Semantic gaps compress down to this fraction of their preferred size before
// the slide starts consuming its outer margins.
#let _GAP-MIN = 0.4
// Card inner padding.
#let _CARD-PAD = 0.9em
// stat-slide shrinks a long value to fit its tile, but never below this scale
// (below it the value wraps and the tile grows, reported honestly by fit).
#let _STAT-SCALE-MIN = 0.6
// Measurement epsilon: below this a dimension counts as zero.
#let _EPS-L = 0.01pt
// Nominal measurement width for note-mode content validation.
#let _NOTE-W = 20em

#let _MODES = ("compact", "balanced", "separated")
#let _check-mode(mode) = {
  if mode not in _MODES {
    panic("unknown mode " + repr(mode) + "; use \"compact\" | \"balanced\" | \"separated\"")
  }
}

// Gap between semantically-related blocks, as a fraction of body height.  The
// three values land inside the checker's proximity ranges so a correctly
// generated slide passes without diagnostics.
#let _mode-gap(mode) = {
  if mode == "compact" { 0.06 } else if mode == "separated" { 0.22 } else { 0.13 }
}
#let _mode-proximity(mode) = {
  if mode == "compact" { "compact" } else if mode == "separated" { "loose" } else { "medium" }
}

// Numeric layout knobs, validated for key, type, and range so a typo or a
// nonsense value fails loudly instead of being silently ignored.
// `spec` maps key -> (default:, lo:, hi:).
#let _tuning(comp, given, spec) = {
  for (k, v) in given {
    if k not in spec {
      panic(comp + ": unknown tuning key " + repr(k) + "; allowed: " + repr(spec.keys()))
    }
    if type(v) != float and type(v) != int {
      panic(comp + ": tuning " + repr(k) + " must be a number, got " + repr(v))
    }
    let s = spec.at(k)
    if v < s.lo or v > s.hi {
      panic(comp + ": tuning " + repr(k) + " = " + repr(v) + " outside [" + repr(s.lo) + ", " + repr(s.hi) + "]")
    }
  }
  let out = (:)
  for (k, s) in spec { out.insert(k, float(given.at(k, default: s.default))) }
  out
}

#let _require(comp, slot, v) = {
  if v == none { panic(comp + ": " + slot + " is required") }
}

// Reveal gating.  The block becomes visible from subslide `step` (1-based);
// hidden steps keep their measured space.  Uses the callback-style
// `utils.uncover` because mark-based `#pause` / global `#uncover` panic inside
// `context` / `layout`.
#let _from(self, step, body) = {
  if step <= 1 { body } else { utils.uncover(self: self, str(step) + "-", body) }
}

// ---------------------------------------------------------------------------
// typed items (declared sizing; every component slot takes them)
// ---------------------------------------------------------------------------
//
// `visual(...)` marks the slide's visual payload: never carded, and with
// fit: "stretch" (the default) it absorbs free space and its content is told
// to fill the allocated frame (use `rect(height: 100%)`, or
// `image(width: 100%, height: 100%, fit: "contain")` for real images).
// fit: "natural" keeps the visual at its measured size (`image(width: 100%)`).
// `card(...)` / `takeaway(...)` draw the theme card behind their content.
// `plain(...)` is an uncarded text block.  Plain (untyped) content passed to
// a slot is coerced per component (documented at each component).
//
// Roles form a closed set: they weight the checker's optical-centre estimate
// and must not be able to change its control flow, so there is no
// "decorative" escape hatch.

#let _ROLES = (
  "main_visual", "figure", "image", "chart", "visual", "table", "formula",
  "callout", "takeaway", "option", "column", "explanation", "label",
  "metric", "text", "content", "caption",
)
#let _check-role(ctor, role) = {
  if role not in _ROLES {
    panic(ctor + ": role " + repr(role) + " is not in the closed role set " + repr(_ROLES))
  }
}

#let visual(body, fit: "stretch", role: "main_visual", reveal-from: auto) = {
  if fit not in ("stretch", "natural") {
    panic("visual: fit must be \"stretch\" or \"natural\", got " + repr(fit))
  }
  _check-role("visual", role)
  (xwysyy-item: true, kind: "visual", fit: fit, role: role, body: body, reveal-from: reveal-from)
}
#let card(body, role: "explanation", reveal-from: auto) = {
  _check-role("card", role)
  (xwysyy-item: true, kind: "card", fit: "natural", role: role, body: body, reveal-from: reveal-from)
}
#let takeaway(body, reveal-from: auto) = (
  xwysyy-item: true, kind: "takeaway", fit: "natural", role: "takeaway", body: body, reveal-from: reveal-from,
)
#let plain(body, role: "text", reveal-from: auto) = {
  _check-role("plain", role)
  (xwysyy-item: true, kind: "plain", fit: "natural", role: role, body: body, reveal-from: reveal-from)
}

#let _as-item(x, default-kind) = {
  if type(x) == dictionary and x.at("xwysyy-item", default: false) { x }
  else if default-kind == "visual" {
    (xwysyy-item: true, kind: "visual", fit: "natural", role: "main_visual", body: x, reveal-from: auto)
  } else if default-kind == "takeaway" {
    (xwysyy-item: true, kind: "takeaway", fit: "natural", role: "takeaway", body: x, reveal-from: auto)
  } else if default-kind == "plain" {
    (xwysyy-item: true, kind: "plain", fit: "natural", role: "text", body: x, reveal-from: auto)
  } else {
    (xwysyy-item: true, kind: "card", fit: "natural", role: "explanation", body: x, reveal-from: auto)
  }
}

#let _painted(it) = it.kind in ("card", "takeaway")
#let _stretchy(it) = it.kind == "visual" and it.fit == "stretch"

#let _KINDS = ("visual", "card", "takeaway", "plain")

// Central item validation, run in BOTH note and slides mode before any
// branching.  The constructor marker is not trusted: a hand-built dictionary
// with an unknown kind, fit, or role fails here instead of silently taking
// some other code path.  `stretch: false` marks slots sized by their natural
// height; `reveal: false` marks components without reveal steps, which must
// reject `reveal-from` instead of ignoring it.
#let _validate-item(comp, slot, it, stretch: true, reveal: true) = {
  if it.at("kind", default: none) not in _KINDS {
    panic(comp + ": " + slot + " item kind must be one of " + repr(_KINDS)
      + ", got " + repr(it.at("kind", default: none)))
  }
  if it.at("fit", default: none) not in ("stretch", "natural") {
    panic(comp + ": " + slot + " fit must be \"stretch\" or \"natural\", got "
      + repr(it.at("fit", default: none)))
  }
  if it.at("role", default: none) not in _ROLES {
    panic(comp + ": " + slot + " role " + repr(it.at("role", default: none))
      + " is not in the closed role set " + repr(_ROLES))
  }
  if it.at("body", default: none) == none {
    panic(comp + ": " + slot + " body is required")
  }
  if not stretch and _stretchy(it) {
    panic(comp + ": " + slot + " cannot be visual(fit: \"stretch\") — this slot is "
      + "sized by its natural height; use fit: \"natural\"")
  }
  let rf = it.at("reveal-from", default: auto)
  if not reveal and rf != auto and rf != 1 {
    panic(comp + ": " + slot + " has no reveal steps; remove reveal-from")
  }
  it
}

// Relation kinds an author may declare between blocks.  Structural kinds
// (peer / caption / labels) are emitted by the components themselves.
#let _AUTHOR-RELS = ("supports", "contrast")
#let _check-relation(comp, rel) = {
  if rel not in _AUTHOR-RELS {
    panic(comp + ": relation must be one of " + repr(_AUTHOR-RELS) + ", got " + repr(rel))
  }
}

// Resolve per-item reveal steps — the single resolver for every component.
// `reveal: true` reveals auto items in order (item i on subslide
// min(i+1, max-step)); an explicit `reveal-from` must be an integer in
// [1, max-step] and ALWAYS wins over the sugar.
#let _steps(comp, items, reveal, max-step) = {
  items.enumerate().map(((i, it)) => {
    let rf = it.at("reveal-from", default: auto)
    if rf == auto {
      if reveal { calc.min(i + 1, max-step) } else { 1 }
    } else {
      if type(rf) != int {
        panic(comp + ": reveal-from must be an integer >= 1, got " + repr(rf))
      }
      if rf < 1 or rf > max-step {
        panic(comp + ": reveal-from = " + str(rf) + " outside [1, " + str(max-step) + "]")
      }
      rf
    }
  })
}

// ---------------------------------------------------------------------------
// allocator
// ---------------------------------------------------------------------------
//
// Column: every item is a spec (min:, pref:, max:, grow:) in absolute
// lengths (max: none = unbounded); every gap is (min:, pref:).  Resolution
// order and states:
//   normal     — everything at preferred fits the safe area; free space goes
//                to grow-weighted items (water-filling against max); residual
//                free space centers the group inside the safe area
//   compressed — fits the safe area only with gaps squeezed below preferred
//                (but not below their min); gap_ratio in [_GAP-MIN, 1)
//   tight      — fits the page only by consuming the outer margins; gaps at
//                min, group centered on the page; margin_deficit_ratio > 0
//   overflow   — taller than the page even at minimums;
//                body_overflow_ratio > 0 (hard invariant)
// `gap_ratio` is the REAL ratio of the summed actual gaps to the summed
// preferred gaps (1.0 when the layout has no gaps), not an interpolation
// parameter.
#let _alloc-column(specs, gaps, H) = {
  let budget = H * _FILL
  let prefs = specs.map(s => calc.max(s.pref, s.min))
  let body = prefs.fold(0pt, (a, h) => a + h)
  let gap-pref = gaps.fold(0pt, (a, g) => a + g.pref)
  let gap-min = gaps.fold(0pt, (a, g) => a + g.min)
  let base = body + gap-pref
  let min-ratio = if gap-pref > 0pt { gap-min / gap-pref } else { 1.0 }
  if base <= budget {
    let heights = prefs
    let free = budget - base
    let frozen = specs.map(s => s.grow <= 0)
    while free > 0.05pt {
      let gsum = 0.0
      for (i, s) in specs.enumerate() {
        if not frozen.at(i) { gsum += s.grow }
      }
      if gsum == 0 { break }
      let spent = 0pt
      for (i, s) in specs.enumerate() {
        if frozen.at(i) { continue }
        let add = free * (s.grow / gsum)
        if s.max != none and heights.at(i) + add >= s.max {
          add = calc.max(s.max - heights.at(i), 0pt)
          frozen.at(i) = true
        }
        heights.at(i) += add
        spent += add
      }
      free -= spent
      if spent <= 0.05pt { break }
    }
    let used = heights.fold(0pt, (a, h) => a + h) + gap-pref
    (heights: heights, gaps: gaps.map(g => g.pref),
     y0: H * _MARGIN-TOP + calc.max(budget - used, 0pt) / 2,
     fit: (state: "normal", required_height_ratio: base / H, gap_ratio: 1.0,
           margin_deficit_ratio: 0.0, body_overflow_ratio: 0.0))
  } else if body + gap-min <= budget {
    let span = gap-pref - gap-min
    let t = if span > 0pt { (budget - body - gap-min) / span } else { 1.0 }
    let actual = gaps.map(g => g.min + (g.pref - g.min) * t)
    let actual-sum = actual.fold(0pt, (a, g) => a + g)
    (heights: prefs, gaps: actual,
     y0: H * _MARGIN-TOP,
     fit: (state: "compressed", required_height_ratio: base / H,
           gap_ratio: if gap-pref > 0pt { actual-sum / gap-pref } else { 1.0 },
           margin_deficit_ratio: 0.0, body_overflow_ratio: 0.0))
  } else if body + gap-min <= H {
    let total = body + gap-min
    (heights: prefs, gaps: gaps.map(g => g.min), y0: (H - total) / 2,
     fit: (state: "tight", required_height_ratio: base / H, gap_ratio: min-ratio,
           margin_deficit_ratio: (total - budget) / H, body_overflow_ratio: 0.0))
  } else {
    let total = body + gap-min
    (heights: prefs, gaps: gaps.map(g => g.min), y0: 0pt,
     fit: (state: "overflow", required_height_ratio: base / H, gap_ratio: min-ratio,
           margin_deficit_ratio: (H - budget) / H, body_overflow_ratio: (total - H) / H))
  }
}

// Row variant: one shared height for side-by-side cards.  No gaps to
// compress, so the states are normal / tight / overflow and gap_ratio is 1.
#let _fit-row(naturals, H) = {
  let natural = naturals.fold(0pt, (a, h) => calc.max(a, h))
  let budget = H * _FILL
  if natural <= budget {
    let row = _clamp(natural, _CARD-FILL-MIN * H, budget)
    (row: row, y: H * _MARGIN-TOP + (budget - row) / 2,
     fit: (state: "normal", required_height_ratio: natural / H, gap_ratio: 1.0,
           margin_deficit_ratio: 0.0, body_overflow_ratio: 0.0))
  } else if natural <= H {
    (row: natural, y: (H - natural) / 2,
     fit: (state: "tight", required_height_ratio: natural / H, gap_ratio: 1.0,
           margin_deficit_ratio: (natural - budget) / H, body_overflow_ratio: 0.0))
  } else {
    (row: natural, y: 0pt,
     fit: (state: "overflow", required_height_ratio: natural / H, gap_ratio: 1.0,
           margin_deficit_ratio: (H - budget) / H, body_overflow_ratio: (natural - H) / H))
  }
}

// ---------------------------------------------------------------------------
// measurement
// ---------------------------------------------------------------------------

// Content signatures (verified against typst 0.14 `measure`):
//   * `v(...)` and an empty string have zero unconstrained WIDTH;
//   * a bare horizontal rule has zero constrained HEIGHT;
//   * percent-width media (`image(width: 100%)`) measures exactly like a
//     spacer — zero unconstrained width — so only visual() slots may fall
//     back to the slot width, and that payload is marked "declared";
//   * `hide(...)` keeps its full layout size and can only be caught by the
//     pixel cross-check.
// Text slots (card / takeaway / plain / metric fields) therefore require a
// positive unconstrained width AND a positive constrained height; visuals
// only panic when every dimension is zero (genuinely empty content).
#let _assert-measurable(comp, slot, kind, body, w) = {
  let mu = measure(body)
  let mc = measure(block(width: w, body))
  if kind == "visual" {
    if mu.width < _EPS-L and mu.height < _EPS-L and mc.height < _EPS-L {
      panic(comp + ": " + slot + " renders empty — pass real content; percent-sized "
        + "content must be declared visual() (fit: \"stretch\")")
    }
  } else {
    if mu.width < _EPS-L {
      panic(comp + ": " + slot + " has no measurable width — spacers and empty "
        + "strings are not content, and percent-width media belongs in visual()")
    }
    if mc.height < _EPS-L {
      panic(comp + ": " + slot + " has no measurable height — a bare rule is "
        + "decoration, not content")
    }
  }
  (mu: mu, mc: mc)
}

// Note-mode content validation: the same panics as slides mode, against a
// nominal width, so a deck cannot compile as a note while its slides build
// is broken.  Declared-stretch content legitimately measures zero (percent
// sizing) and is skipped here — its evidence comes from the pixel check.
#let _note-assert(comp, slot, it) = {
  if not _stretchy(it) {
    context {
      let _ = _assert-measurable(comp, slot, it.kind, it.body, _NOTE-W.to-absolute())
    }
  }
}

// Measure a natural item for a slot of width `w`.  Returns the outer size the
// allocator uses (including card padding), the 2-D payload flow bbox, the
// payload source, and horizontal-overflow evidence.
#let _measure-item(comp, slot, it, w) = {
  let pad = if _painted(it) { _CARD-PAD.to-absolute() } else { 0pt }
  let iw = w - 2 * pad
  let m = _assert-measurable(comp, slot, it.kind, it.body, iw)
  // Only reachable for visual items: percent-width media measures at zero
  // width, claims the slot width, and is marked "declared" so the checker
  // demands pixel evidence instead of counting it as measured payload.
  let fallback = m.mu.width < _EPS-L
  (
    outer: m.mc.height + 2 * pad,
    pay-w: if fallback { iw } else { calc.min(m.mu.width, iw) },
    pay-h: m.mc.height,
    pad: pad,
    src: if fallback { "declared" } else { "measured" },
    // Unbreakable content wider than its slot cannot wrap: the constrained
    // height stays at the unconstrained height while the natural width
    // exceeds the slot.  Wrapped text is clamped honestly instead.
    over-x: m.mu.width > iw + _EPS-L and m.mc.height <= m.mu.height + _EPS-L,
  )
}

// Build the allocator spec and telemetry seed for one column/slot item.
// Stretch visuals get the hard minimum and a grow weight; natural items are
// pinned at their measured size (max = pref) unless the component grants
// cards a grow weight.
#let _item-slot(comp, slot, it, w, H) = {
  if _stretchy(it) {
    (stretch: true, painted: false, pad: 0pt,
     spec: (min: H * _VISUAL-MIN, pref: H * _VISUAL-MIN, max: none, grow: 1.0),
     pay-w: none, pay-h: none, src: "declared", over-x: false)
  } else {
    let m = _measure-item(comp, slot, it, w)
    (stretch: false, painted: _painted(it), pad: m.pad,
     spec: (min: m.outer, pref: m.outer, max: m.outer, grow: 0.0),
     pay-w: m.pay-w, pay-h: m.pay-h, src: m.src, over-x: m.over-x)
  }
}

// ---------------------------------------------------------------------------
// telemetry primitives (schema v4)
// ---------------------------------------------------------------------------

// One telemetry object.
//   frame          — the box the component allocated (normalized to the body)
//   preferred      — the natural outer size the allocator saw
//   payload        — 2-D flow bbox of the inner content (inside card
//                    padding); approximate for wrapped text (flow bbox, not
//                    glyph ink); equals the padded frame for declared-stretch
//                    content
//   paint          — the visible card box, or none for unpainted objects
//   paint_fill     — hex colour of the card fill (pixel-check evidence)
//   payload_source — "measured" | "declared"; declared payloads are claims
//                    the checker verifies against pixels, never evidence
//   overflow_x     — unbreakable content wider than the slot (see
//                    _measure-item)
// Payload height is NOT clamped to the frame: overflowing content reports a
// payload that runs past its frame, and the checker sees it.
#let _obj(
  id, kind, role, group,
  fx, fy, fw, fh,
  pref-w: none, pref-h: none,
  pay-w: none, pay-h: none,
  pay-src: "measured", over-x: false,
  pad-x: 0.0, pad-y: 0.0,
  calign: "center", halign: "center",
  painted: false, paint-fill: none, visible-from: 1,
) = {
  let ix = fx + pad-x
  let iy = fy + pad-y
  let iw = calc.max(fw - 2 * pad-x, 0.0)
  let ih = calc.max(fh - 2 * pad-y, 0.0)
  let sx = if pay-w == none { "stretch" } else { "natural" }
  let sy = if pay-h == none { "stretch" } else { "natural" }
  let pw = if pay-w == none { iw } else { calc.min(pay-w, iw) }
  let ph = if pay-h == none { ih } else { pay-h }
  let px = if sx == "stretch" or halign == "left" { ix } else { ix + (iw - pw) / 2 }
  let py = if sy == "stretch" or calign == "top" { iy } else { iy + (ih - ph) / 2 }
  (
    id: id,
    object_kind: kind,
    semantic_role: role,
    group: group,
    frame: (x: fx, y: fy, w: fw, h: fh),
    preferred: (w: if pref-w == none { fw } else { pref-w },
                h: if pref-h == none { fh } else { pref-h }),
    payload: (x: px, y: py, w: pw, h: ph),
    paint: if painted { (x: fx, y: fy, w: fw, h: fh) } else { none },
    paint_fill: if painted { paint-fill } else { none },
    payload_source: if pay-w == none or pay-h == none { "declared" } else { pay-src },
    overflow_x: over-x,
    sizing: (x: sx, y: sy),
    visible_from: visible-from,
  )
}

#let _rel(from, to, kind, axis, proximity) = (
  from: from,
  to: to,
  kind: kind,
  axis: axis,
  desired_proximity: proximity,
)

// One frame mapping per physically rendered subslide, carrying the physical
// body geometry (pt) so the pixel checker maps normalized telemetry onto the
// render without hard-coded page constants.  In handout mode only the
// surviving subslide emits, so coverage counts real pages.
#let _frame-mark(sid, self, size) = {
  let pos = here().position()
  [#metadata((
    schema: "xwysyy-frame/v2",
    id: sid,
    step: self.subslide,
    steps: self.at("repeat", default: 1),
    page: pos.page,
    handout: self.at("handout", default: false),
    body: (x: pos.x.pt(), y: pos.y.pt(), w: size.width.pt(), h: size.height.pt()),
    page_size: (w: page.width.pt(), h: page.height.pt()),
  )) <xwysyy-frame>]
}

// Emit one slide's telemetry.  Must be produced in markup so the label binds
// (a label on `metadata(...)` in code mode is a Typst syntax error).
#let _emit(id, archetype, engine, page, frame-count, objects, relations, fit, extra) = [
  #metadata((
    schema: "xwysyy-slide-layout/v4",
    id: id,
    archetype: archetype,
    layout_engine: engine,
    page: page,
    frame_count: frame-count,
    coordinate_system: "normalized-slide-body",
    objects: objects,
    relations: relations,
    fit: fit,
    extra: extra,
  )) <xwysyy-slide-layout>
]

// Debug overlay: solid rect = frame, dashed rect = payload bbox.
#let _debug-palette = (
  rgb("#d7263d"), rgb("#2e86ab"), rgb("#4f772d"),
  rgb("#7b2cbf"), rgb("#f77f00"), rgb("#006d77"),
)
#let _debug-layer(objects, W, H) = {
  for (i, o) in objects.enumerate() {
    let c = _debug-palette.at(calc.rem(i, _debug-palette.len()))
    let f = o.frame
    place(_atop + _aleft, dx: W * f.x, dy: H * f.y, rect(
      width: W * f.w, height: H * f.h,
      stroke: (paint: c, thickness: 0.7pt), fill: c.transparentize(93%),
    ))
    if o.sizing.y == "natural" or o.sizing.x == "natural" {
      let p = o.payload
      place(_atop + _aleft, dx: W * p.x, dy: H * p.y, rect(
        width: W * p.w, height: H * p.h,
        stroke: (paint: c, thickness: 0.5pt, dash: "dashed"),
      ))
    }
    place(_atop + _aleft, dx: W * f.x + 0.2em, dy: H * f.y + 0.12em,
      text(fill: c, size: 0.5em, weight: "bold", o.id))
  }
}

// Column container for slot rendering.  Cards draw the theme's rounded skyll
// box; `calign` controls where content sits inside a fixed-height box.
#let _card-box(cw, h, fill, body, cardp, calign: _ahorizon) = {
  let inner = if h == auto { body } else { align(calign, body) }
  if cardp {
    block(width: cw, height: h, fill: fill, inset: _CARD-PAD, radius: 0.4em, inner)
  } else {
    block(width: cw, height: h, inner)
  }
}

// Render one typed item into its allocated slot.
#let _render-item(it, w, h, fill, calign: _ahorizon) = {
  if _painted(it) {
    _card-box(w, h, fill, it.body, true, calign: calign)
  } else {
    block(width: w, height: h, align(_acenter + calign, it.body))
  }
}

// Resolve the slide id: `auto` becomes "<base>@s<n>" from touying's logical
// slide counter, which is STABLE across reveal subslides and handout mode
// (the physical page number is not: it changes per subslide and would detach
// early frames from their layout record).  Must run inside a context.
#let _sid(id, base) = {
  if id == auto { base + "@s" + str(utils.slide-counter.get().first()) } else { id }
}

// ---------------------------------------------------------------------------
// duo-slide — one vertical semantic pair (e.g. figure over takeaway)
// ---------------------------------------------------------------------------
//
// `top` coerces plain content to visual(fit: "natural"); wrap percent-height
// content in visual() to make it the growing dominant block.  `bottom`
// coerces plain content to card() (painted).

#let duo-slide(
  title: auto,
  id: auto,
  top: none,
  bottom: none,
  mode: "balanced",
  relation: "supports",
  reveal: false,
  debug: false,
  tuning: (:),
) = {
  _check-mode(mode)
  _check-relation("duo-slide", relation)
  _require("duo-slide", "top", top)
  _require("duo-slide", "bottom", bottom)
  let tn = _tuning("duo-slide", tuning, (
    "top-width": (default: 0.82, lo: 0.3, hi: 0.95),
    "bottom-width": (default: 0.74, lo: 0.3, hi: 0.95),
  ))
  let ti = _validate-item("duo-slide", "top", _as-item(top, "visual"))
  let bi = _validate-item("duo-slide", "bottom", _as-item(bottom, "card"))
  let steps = _steps("duo-slide", (ti, bi), reveal, 2)
  let rep = calc.max(..steps, 1)
  if _note-mode() {
    xwysyy-slide(title: title)[
      #_note-assert("duo-slide", "top", ti)
      #_note-assert("duo-slide", "bottom", bi)
      #block(ti.body)
      #if _painted(bi) { textbox(bi.body) } else { block(bi.body) }
    ]
  } else {
    xwysyy-slide(title: title, repeat: rep, self => context {
      let cfill = _theme-state.get().skyll
      layout(size => {
        let W = size.width
        let H = size.height
        let sid = _sid(id, "duo")
        _frame-mark(sid, self, size)
        let twn = tn.at("top-width")
        let bwn = tn.at("bottom-width")
        let tw = W * twn
        let bw = W * bwn
        let gap = H * _mode-gap(mode)
        let ts = _item-slot("duo-slide", "top", ti, tw, H)
        let bs = _item-slot("duo-slide", "bottom", bi, bw, H)
        let alloc = _alloc-column((ts.spec, bs.spec), ((min: gap * _GAP-MIN, pref: gap),), H)
        let th = alloc.heights.at(0)
        let bh = alloc.heights.at(1)
        let g = alloc.gaps.at(0)
        let y0 = alloc.y0

        place(_atop + _aleft, dx: (W - tw) / 2, dy: y0,
          _from(self, steps.at(0), _render-item(ti, tw, th, cfill)))
        place(_atop + _aleft, dx: (W - bw) / 2, dy: y0 + th + g,
          _from(self, steps.at(1), _render-item(bi, bw, bh, cfill)))

        let objects = (
          _obj(sid + ":top", ti.kind, ti.role, sid,
            (1.0 - twn) / 2, y0 / H, twn, th / H,
            pref-h: ts.spec.pref / H,
            pay-w: if ts.stretch { none } else { ts.pay-w / W },
            pay-h: if ts.stretch { none } else { ts.pay-h / H },
            pay-src: ts.src, over-x: ts.over-x,
            pad-x: ts.pad / W, pad-y: ts.pad / H,
            halign: if ts.painted { "left" } else { "center" },
            painted: ts.painted, paint-fill: cfill.to-hex(),
            visible-from: steps.at(0)),
          _obj(sid + ":bottom", bi.kind, bi.role, sid,
            (1.0 - bwn) / 2, (y0 + th + g) / H, bwn, bh / H,
            pref-h: bs.spec.pref / H,
            pay-w: if bs.stretch { none } else { bs.pay-w / W },
            pay-h: if bs.stretch { none } else { bs.pay-h / H },
            pay-src: bs.src, over-x: bs.over-x,
            pad-x: bs.pad / W, pad-y: bs.pad / H,
            halign: if bs.painted { "left" } else { "center" },
            painted: bs.painted, paint-fill: cfill.to-hex(),
            visible-from: steps.at(1)),
        )
        let relations = (
          _rel(sid + ":top", sid + ":bottom", relation, "vertical", _mode-proximity(mode)),
        )
        if self.subslide == rep {
          _emit(sid, "duo", "column", here().position().page, rep, objects, relations,
            alloc.fit, (mode: mode, gap_fraction: g / H, tuned: tuning.len() > 0))
          if debug { _debug-layer(objects, W, H) }
        }
      })
    })
  }
}

// ---------------------------------------------------------------------------
// focus-slide — a single centered block for low-content pages
// ---------------------------------------------------------------------------
//
// The one deliberate exception to fill-first: a focus page states a single
// point and is allowed its symmetric whitespace.  Plain content is coerced to
// card().  A focus page has exactly one frame: it rejects reveal-from and
// stretch visuals (there is no free space to absorb).  Fit still honours the
// safe area: content taller than it reports tight, taller than the page
// reports overflow.

#let focus-slide(
  title: auto,
  id: auto,
  body: none,
  debug: false,
  tuning: (:),
) = {
  _require("focus-slide", "body", body)
  let tn = _tuning("focus-slide", tuning, (
    "width": (default: 0.76, lo: 0.3, hi: 0.95),
    "center-y": (default: _OPTICAL-CENTER, lo: 0.30, hi: 0.70),
  ))
  let it = _validate-item("focus-slide", "body", _as-item(body, "card"),
    stretch: false, reveal: false)
  if _note-mode() {
    xwysyy-slide(title: title)[
      #_note-assert("focus-slide", "body", it)
      #if _painted(it) { textbox(it.body) } else { block(it.body) }
    ]
  } else {
    xwysyy-slide(title: title, self => context {
      let cfill = _theme-state.get().skyll
      layout(size => {
        let W = size.width
        let H = size.height
        let sid = _sid(id, "focus")
        _frame-mark(sid, self, size)
        let wn = tn.at("width")
        let cw = W * wn
        let m = _measure-item("focus-slide", "body", it, cw)
        let hr = m.outer / H
        let fit = if hr <= _FILL {
          (state: "normal", required_height_ratio: hr, gap_ratio: 1.0,
           margin_deficit_ratio: 0.0, body_overflow_ratio: 0.0)
        } else if hr <= 1.0 {
          (state: "tight", required_height_ratio: hr, gap_ratio: 1.0,
           margin_deficit_ratio: hr - _FILL, body_overflow_ratio: 0.0)
        } else {
          (state: "overflow", required_height_ratio: hr, gap_ratio: 1.0,
           margin_deficit_ratio: 1.0 - _FILL, body_overflow_ratio: hr - 1.0)
        }
        let y = if fit.state == "normal" {
          _clamp(tn.at("center-y") - hr / 2, _MARGIN-TOP,
            calc.max(1.0 - _MARGIN-BOT - hr, _MARGIN-TOP))
        } else if fit.state == "tight" { (1.0 - hr) / 2 } else { 0.0 }

        place(_atop + _aleft, dx: (W - cw) / 2, dy: H * y,
          _render-item(it, cw, m.outer, cfill))

        let objects = (
          _obj(sid + ":focus", it.kind, it.role, sid,
            (1.0 - wn) / 2, y, wn, hr,
            pref-h: hr,
            pay-w: m.pay-w / W, pay-h: m.pay-h / H,
            pay-src: m.src, over-x: m.over-x,
            pad-x: m.pad / W, pad-y: m.pad / H,
            halign: if _painted(it) { "left" } else { "center" },
            painted: _painted(it), paint-fill: cfill.to-hex()),
        )
        _emit(sid, "focus", "single", here().position().page, 1, objects, (), fit,
          (center_y: tn.at("center-y"), intent: "focus", tuned: tuning.len() > 0))
        if debug { _debug-layer(objects, W, H) }
      })
    })
  }
}

// ---------------------------------------------------------------------------
// stack-slide — N vertical blocks, fill-first (duo generalized)
// ---------------------------------------------------------------------------
//
// Takes typed items; plain content is coerced to card().  Stretch visuals
// absorb the free space; a stack with no stretch visual grows its cards so
// every card reads tall.  With `reveal: true` item i appears on subslide i
// (override per item with `reveal-from`).

#let stack-slide(
  title: auto,
  id: auto,
  items: (),
  relation: "supports",
  mode: "balanced",
  reveal: false,
  debug: false,
  tuning: (:),
) = {
  _check-mode(mode)
  _check-relation("stack-slide", relation)
  let tn = _tuning("stack-slide", tuning, (
    "width": (default: 0.82, lo: 0.3, hi: 0.95),
  ))
  let its = items.enumerate().map(((i, x)) =>
    _validate-item("stack-slide", "items[" + str(i) + "]", _as-item(x, "card")))
  let n = its.len()
  if n == 0 {
    panic("stack-slide: items is empty")
  }
  let steps = _steps("stack-slide", its, reveal, n)
  let rep = calc.max(..steps, 1)
  if _note-mode() {
    xwysyy-slide(title: title)[
      #for (i, it) in its.enumerate() {
        _note-assert("stack-slide", "items[" + str(i) + "]", it)
        if _painted(it) { textbox(it.body) } else { block(it.body) }
      }
    ]
  } else {
    xwysyy-slide(title: title, repeat: rep, self => context {
      let cfill = _theme-state.get().skyll
      layout(size => {
        let W = size.width
        let H = size.height
        let sid = _sid(id, "stack")
        _frame-mark(sid, self, size)
        let wn = tn.at("width")
        let bw = W * wn
        let slots = its.enumerate().map(((i, it)) =>
          _item-slot("stack-slide", "items[" + str(i) + "]", it, bw, H))
        // Grow policy: stretch visuals absorb free space; without one, the
        // cards share it so a pure-text stack reads as tall cards.
        let has-stretch = slots.any(s => s.stretch)
        let specs = slots.enumerate().map(((i, s)) => {
          if s.stretch { s.spec }
          else if not has-stretch and its.at(i).kind == "card" {
            (min: s.spec.min, pref: s.spec.pref, max: none, grow: 1.0)
          } else { s.spec }
        })
        let gap = H * _mode-gap(mode)
        let alloc = _alloc-column(specs, ((min: gap * _GAP-MIN, pref: gap),) * (n - 1), H)

        let objects = ()
        let relations = ()
        let cy = alloc.y0
        for (i, it) in its.enumerate() {
          let h = alloc.heights.at(i)
          let s = slots.at(i)
          place(_atop + _aleft, dx: (W - bw) / 2, dy: cy,
            _from(self, steps.at(i), _render-item(it, bw, h, cfill)))
          let oid = sid + ":" + str(i)
          objects.push(_obj(oid, it.kind, it.role, sid,
            (1.0 - wn) / 2, cy / H, wn, h / H,
            pref-h: specs.at(i).pref / H,
            pay-w: if s.stretch { none } else { s.pay-w / W },
            pay-h: if s.stretch { none } else { s.pay-h / H },
            pay-src: s.src, over-x: s.over-x,
            pad-x: s.pad / W, pad-y: s.pad / H,
            halign: if s.painted { "left" } else { "center" },
            painted: s.painted, paint-fill: cfill.to-hex(),
            visible-from: steps.at(i)))
          if i > 0 {
            relations.push(_rel(sid + ":" + str(i - 1), oid, relation, "vertical", _mode-proximity(mode)))
          }
          cy = cy + h + if i < n - 1 { alloc.gaps.at(i) } else { 0pt }
        }
        if self.subslide == rep {
          _emit(sid, "stack", "column", here().position().page, rep, objects, relations,
            alloc.fit, (mode: mode, count: n, tuned: tuning.len() > 0,
              gap_fraction: if n > 1 { alloc.gaps.at(0) / H } else { 0.0 }))
          if debug { _debug-layer(objects, W, H) }
        }
      })
    })
  }
}

// ---------------------------------------------------------------------------
// grid-slide — N equal-height peer columns (N >= 2)
// ---------------------------------------------------------------------------
//
// Columns take typed items; plain content is coerced to card().  Row layouts
// are sized by their natural height, so stretch visuals are rejected up
// front (in both note and slides mode).  Consecutive columns carry a `peer`
// relation so the checker validates the gutter.

#let grid-slide(
  title: auto,
  id: auto,
  columns: (),
  reveal: false,
  debug: false,
  tuning: (:),
) = {
  let tn = _tuning("grid-slide", tuning, (
    "gutter": (default: 0.04, lo: 0.0, hi: 0.2),
  ))
  let its = columns.enumerate().map(((i, x)) =>
    _validate-item("grid-slide", "columns[" + str(i) + "]", _as-item(x, "card"),
      stretch: false))
  let n = its.len()
  if n < 2 {
    panic("grid-slide: needs at least 2 columns (use stack-slide or focus-slide for one block)")
  }
  let steps = _steps("grid-slide", its, reveal, n)
  let rep = calc.max(..steps, 1)
  if _note-mode() {
    xwysyy-slide(title: title)[
      #for (i, it) in its.enumerate() {
        _note-assert("grid-slide", "columns[" + str(i) + "]", it)
      }
      #grid(columns: (1fr,) * n, column-gutter: 1em,
        ..its.map(it => if _painted(it) { textbox(it.body) } else { it.body }))
    ]
  } else {
    xwysyy-slide(title: title, repeat: rep, self => context {
      let cfill = _theme-state.get().skyll
      layout(size => {
        let W = size.width
        let H = size.height
        let sid = _sid(id, "grid")
        _frame-mark(sid, self, size)
        let gutter = tn.at("gutter")
        let cwn = (1.0 - gutter * (n - 1)) / n
        if cwn <= 0.0 {
          panic("grid-slide: gutter " + repr(gutter) + " leaves no width for " + repr(n) + " columns")
        }
        let cw = W * cwn
        let slots = its.enumerate().map(((i, it)) =>
          _item-slot("grid-slide", "columns[" + str(i) + "]", it, cw, H))
        let naturals = slots.map(s => s.spec.pref)
        let row = _fit-row(naturals, H)

        let objects = ()
        let relations = ()
        for (i, it) in its.enumerate() {
          let s = slots.at(i)
          let xn = i * (cwn + gutter)
          place(_atop + _aleft, dx: W * xn, dy: row.y,
            _from(self, steps.at(i), _render-item(it, cw, row.row, cfill)))
          let oid = sid + ":" + str(i)
          objects.push(_obj(oid, it.kind, it.role, sid,
            xn, row.y / H, cwn, row.row / H,
            pref-h: s.spec.pref / H,
            pay-w: s.pay-w / W, pay-h: s.pay-h / H,
            pay-src: s.src, over-x: s.over-x,
            pad-x: s.pad / W, pad-y: s.pad / H,
            halign: if s.painted { "left" } else { "center" },
            painted: s.painted, paint-fill: cfill.to-hex(),
            visible-from: steps.at(i)))
          if i > 0 {
            relations.push(_rel(sid + ":" + str(i - 1), oid, "peer", "horizontal", "gutter"))
          }
        }
        let nmax = naturals.fold(0pt, (a, h) => calc.max(a, h))
        let nmin = naturals.fold(nmax, (a, h) => calc.min(a, h))
        if self.subslide == rep {
          _emit(sid, "grid", "row", here().position().page, rep, objects, relations, row.fit, (
            count: n,
            gutter: gutter,
            natural_height_variance: (nmax - nmin) / H,
            tuned: tuning.len() > 0,
          ))
          if debug { _debug-layer(objects, W, H) }
        }
      })
    })
  }
}

// ---------------------------------------------------------------------------
// compare-slide — two equal-height cards read as a contrast
// ---------------------------------------------------------------------------
//
// Cards share one row height; content is TOP-aligned so the two openings sit
// on the same line, which is how a contrast is read.  Both sides are
// required; plain content is coerced to card(); stretch visuals are rejected
// up front (row layouts are sized by their natural height).

#let compare-slide(
  title: auto,
  id: auto,
  left: none,
  right: none,
  reveal: false,
  debug: false,
  tuning: (:),
) = {
  _require("compare-slide", "left", left)
  _require("compare-slide", "right", right)
  let tn = _tuning("compare-slide", tuning, (
    "gutter": (default: 0.06, lo: 0.0, hi: 0.2),
  ))
  let li = _validate-item("compare-slide", "left", _as-item(left, "card"), stretch: false)
  let ri = _validate-item("compare-slide", "right", _as-item(right, "card"), stretch: false)
  let steps = _steps("compare-slide", (li, ri), reveal, 2)
  let rep = calc.max(..steps, 1)
  if _note-mode() {
    xwysyy-slide(title: title)[
      #_note-assert("compare-slide", "left", li)
      #_note-assert("compare-slide", "right", ri)
      #grid(columns: (1fr, 1fr), column-gutter: 1em,
        ..(li, ri).map(it => if _painted(it) { textbox(it.body) } else { it.body }))
    ]
  } else {
    xwysyy-slide(title: title, repeat: rep, self => context {
      let cfill = _theme-state.get().skyll
      layout(size => {
        let W = size.width
        let H = size.height
        let sid = _sid(id, "compare")
        _frame-mark(sid, self, size)
        let gutter = tn.at("gutter")
        let cwn = (1.0 - gutter) / 2
        let cw = W * cwn
        let ls = _item-slot("compare-slide", "left", li, cw, H)
        let rs = _item-slot("compare-slide", "right", ri, cw, H)
        let row = _fit-row((ls.spec.pref, rs.spec.pref), H)

        place(_atop + _aleft, dx: 0pt, dy: row.y,
          _from(self, steps.at(0), _render-item(li, cw, row.row, cfill, calign: _atop)))
        place(_atop + _aleft, dx: W * (cwn + gutter), dy: row.y,
          _from(self, steps.at(1), _render-item(ri, cw, row.row, cfill, calign: _atop)))

        let objects = (
          _obj(sid + ":left", li.kind, li.role, sid,
            0.0, row.y / H, cwn, row.row / H,
            pref-h: ls.spec.pref / H,
            pay-w: ls.pay-w / W, pay-h: ls.pay-h / H,
            pay-src: ls.src, over-x: ls.over-x,
            pad-x: ls.pad / W, pad-y: ls.pad / H,
            calign: "top", halign: if ls.painted { "left" } else { "center" },
            painted: ls.painted, paint-fill: cfill.to-hex(),
            visible-from: steps.at(0)),
          _obj(sid + ":right", ri.kind, ri.role, sid,
            cwn + gutter, row.y / H, cwn, row.row / H,
            pref-h: rs.spec.pref / H,
            pay-w: rs.pay-w / W, pay-h: rs.pay-h / H,
            pay-src: rs.src, over-x: rs.over-x,
            pad-x: rs.pad / W, pad-y: rs.pad / H,
            calign: "top", halign: if rs.painted { "left" } else { "center" },
            painted: rs.painted, paint-fill: cfill.to-hex(),
            visible-from: steps.at(1)),
        )
        let relations = (
          _rel(sid + ":left", sid + ":right", "contrast", "horizontal", "gutter"),
        )
        if self.subslide == rep {
          _emit(sid, "compare", "row", here().position().page, rep, objects, relations, row.fit, (
            gutter: gutter,
            natural_height_variance: calc.abs(ls.spec.pref - rs.spec.pref) / H,
            tuned: tuning.len() > 0,
          ))
          if debug { _debug-layer(objects, W, H) }
        }
      })
    })
  }
}

// ---------------------------------------------------------------------------
// stat-slide — a row of metric tiles (big value + label)
// ---------------------------------------------------------------------------
//
// Standalone row engine (shares `_fit-row`), so the value auto-shrink scale
// is measured here and exported in the telemetry.  `stats` takes typed
// `metric(value, label, reveal-from: ...)` entries; the value and the label
// are measured separately (never through the tile's forced width) and both
// must render non-empty.

#let metric(value, label, reveal-from: auto) = {
  if value == none { panic("metric: value is required") }
  if label == none { panic("metric: label is required") }
  (xwysyy-metric: true, value: value, label: label, reveal-from: reveal-from)
}

#let stat-slide(
  title: auto,
  id: auto,
  stats: (),
  reveal: false,
  debug: false,
  tuning: (:),
) = {
  let n = stats.len()
  if n == 0 {
    panic("stat-slide: stats is empty")
  }
  for (i, s) in stats.enumerate() {
    if type(s) != dictionary or not s.at("xwysyy-metric", default: false) {
      panic("stat-slide: stats[" + str(i) + "] must be built with metric(value, label)")
    }
    if s.at("value", default: none) == none or s.at("label", default: none) == none {
      panic("stat-slide: stats[" + str(i) + "] must carry both value and label")
    }
  }
  let tn = _tuning("stat-slide", tuning, (
    "gutter": (default: 0.04, lo: 0.0, hi: 0.2),
  ))
  let steps = _steps("stat-slide", stats, reveal, n)
  let rep = calc.max(..steps, 1)
  // Both metric fields must render non-empty (an empty string still has line
  // height, but zero width).
  let assert-metric(i, s) = {
    if measure(text(weight: 700, s.value)).width < _EPS-L {
      panic("stat-slide: stats[" + str(i) + "] value renders empty")
    }
    if measure(s.label).width < _EPS-L {
      panic("stat-slide: stats[" + str(i) + "] label renders empty")
    }
  }
  if _note-mode() {
    xwysyy-slide(title: title)[
      #context { for (i, s) in stats.enumerate() { assert-metric(i, s) } }
      #grid(columns: (1fr,) * n, column-gutter: 1em,
        ..stats.map(s => textbox[#align(_acenter, strong(s.value)) #align(_acenter, s.label)]))
    ]
  } else {
    xwysyy-slide(title: title, repeat: rep, self => context {
      let t = _theme-state.get()
      layout(size => {
        let W = size.width
        let H = size.height
        let sid = _sid(id, "stat")
        _frame-mark(sid, self, size)
        for (i, s) in stats.enumerate() { assert-metric(i, s) }
        let gutter = tn.at("gutter")
        let cwn = (1.0 - gutter * (n - 1)) / n
        if cwn <= 0.0 {
          panic("stat-slide: gutter " + repr(gutter) + " leaves no width for " + repr(n) + " tiles")
        }
        let cw = W * cwn
        let pad = _CARD-PAD.to-absolute()
        let iw = cw - 2 * pad
        // Fit each value to its tile: shrink down to the floor scale, below
        // which the value wraps and the tile grows (reported by fit).
        let scales = stats.map(s => {
          let vw = measure(text(size: 2.6em, weight: 700, s.value)).width
          if vw > iw and vw > 0pt { calc.max(iw / vw, _STAT-SCALE-MIN) } else { 1.0 }
        })
        let tile(i) = {
          let s = stats.at(i)
          align(_acenter + _ahorizon, stack(
            spacing: 0.2em,
            align(_acenter, text(size: 2.6em * scales.at(i), weight: 700, fill: t.sea, s.value)),
            align(_acenter, text(size: 0.95em, fill: t.sea.lighten(12%), s.label)),
          ))
        }
        // Payload width comes from the value and the label measured
        // separately, never from the tile's forced full width.
        let pays = range(n).map(i => {
          let s = stats.at(i)
          let vstyled = text(size: 2.6em * scales.at(i), weight: 700, s.value)
          let vm = measure(vstyled)
          let lm = measure(text(size: 0.95em, s.label))
          let vc = measure(block(width: iw, vstyled))
          (
            w: calc.max(vm.width, lm.width),
            h: measure(block(width: iw, tile(i))).height,
            over-x: vm.width > iw + _EPS-L and vc.height <= vm.height + _EPS-L,
          )
        })
        let naturals = pays.map(p => p.h + 2 * pad)
        let row = _fit-row(naturals, H)

        let objects = ()
        let relations = ()
        for i in range(n) {
          let xn = i * (cwn + gutter)
          place(_atop + _aleft, dx: W * xn, dy: row.y,
            _from(self, steps.at(i),
              block(width: cw, height: row.row, fill: t.skyll, inset: _CARD-PAD,
                radius: 0.4em, align(_ahorizon, tile(i)))))
          let oid = sid + ":" + str(i)
          objects.push(_obj(oid, "card", "metric", sid,
            xn, row.y / H, cwn, row.row / H,
            pref-h: naturals.at(i) / H,
            pay-w: calc.min(pays.at(i).w, iw) / W, pay-h: pays.at(i).h / H,
            pay-src: "measured", over-x: pays.at(i).over-x,
            pad-x: pad / W, pad-y: pad / H,
            painted: true, paint-fill: t.skyll.to-hex(),
            visible-from: steps.at(i)))
          if i > 0 {
            relations.push(_rel(sid + ":" + str(i - 1), oid, "peer", "horizontal", "gutter"))
          }
        }
        if self.subslide == rep {
          _emit(sid, "stat", "row", here().position().page, rep, objects, relations, row.fit, (
            count: n,
            gutter: gutter,
            value_scales: scales,
            tuned: tuning.len() > 0,
          ))
          if debug { _debug-layer(objects, W, H) }
        }
      })
    })
  }
}

// ---------------------------------------------------------------------------
// figure-slide — figure, tight caption, optional takeaway
// ---------------------------------------------------------------------------
//
// The caption is measured first and subtracted, then the figure slot receives
// an explicit height, so a stretch figure fills its slot instead of escaping
// the wrapper (Typst measures percentage heights as 0 in an unbounded
// context).  `fig` coerces plain content to visual(fit: "natural"); wrap it
// in visual() to make it fill.  `takeaway` coerces to a painted takeaway card
// and rejects stretch.  Reveal goes through the shared resolver: with
// `reveal: true` the figure shows first and the takeaway follows; per-item
// `reveal-from` overrides that order, and the caption always follows the
// figure.

#let figure-slide(
  title: auto,
  id: auto,
  fig: none,
  caption: none,
  takeaway: none,
  mode: "balanced",
  reveal: false,
  debug: false,
  tuning: (:),
) = {
  _check-mode(mode)
  _require("figure-slide", "fig", fig)
  let tn = _tuning("figure-slide", tuning, (
    "figure-width": (default: 0.80, lo: 0.3, hi: 0.95),
    "takeaway-width": (default: 0.74, lo: 0.3, hi: 0.95),
  ))
  let fi = _validate-item("figure-slide", "fig", _as-item(fig, "visual"))
  let ki = if takeaway == none { none } else {
    _validate-item("figure-slide", "takeaway", _as-item(takeaway, "takeaway"), stretch: false)
  }
  let items = if ki == none { (fi,) } else { (fi, ki) }
  let steps = _steps("figure-slide", items, reveal, items.len())
  let fig-step = steps.at(0)
  let tk-step = if ki != none { steps.at(1) } else { 1 }
  let rep = calc.max(..steps, 1)
  let cap = if caption == none { none } else {
    context text(size: 0.85em, fill: _theme-state.get().sea.lighten(12%), style: "italic", caption)
  }
  if _note-mode() {
    xwysyy-slide(title: title)[
      #_note-assert("figure-slide", "fig", fi)
      #if ki != none { _note-assert("figure-slide", "takeaway", ki) }
      #align(_acenter, fi.body)
      #if cap != none { align(_acenter, cap) }
      #if ki != none { textbox(ki.body) }
    ]
  } else {
    xwysyy-slide(title: title, repeat: rep, self => context {
      let cfill = _theme-state.get().skyll
      layout(size => {
        let W = size.width
        let H = size.height
        let sid = _sid(id, "figure")
        _frame-mark(sid, self, size)
        let fwn = tn.at("figure-width")
        let twn = tn.at("takeaway-width")
        let fw = W * fwn
        let tw = W * twn
        let cap-gap = 0.5em.to-absolute()
        let mode-gap = H * _mode-gap(mode)

        let fs = _item-slot("figure-slide", "fig", fi, fw, H)
        let specs = (fs.spec,)
        let gaps = ()
        let cap-m = if cap != none {
          let m = measure(block(width: fw, cap))
          specs.push((min: m.height, pref: m.height, max: m.height, grow: 0.0))
          // The caption gap is tight by design and not compressible.
          gaps.push((min: cap-gap, pref: cap-gap))
          m
        } else { none }
        let ks = if ki != none {
          let s = _item-slot("figure-slide", "takeaway", ki, tw, H)
          specs.push(s.spec)
          gaps.push((min: mode-gap * _GAP-MIN, pref: mode-gap))
          s
        } else { none }
        let alloc = _alloc-column(specs, gaps, H)

        let objects = ()
        let relations = ()
        let cy = alloc.y0
        let idx = 0
        let fh = alloc.heights.at(idx)
        place(_atop + _aleft, dx: (W - fw) / 2, dy: cy,
          _from(self, fig-step, _render-item(fi, fw, fh, cfill)))
        objects.push(_obj(sid + ":figure", fi.kind, fi.role, sid,
          (1.0 - fwn) / 2, cy / H, fwn, fh / H,
          pref-h: fs.spec.pref / H,
          pay-w: if fs.stretch { none } else { fs.pay-w / W },
          pay-h: if fs.stretch { none } else { fs.pay-h / H },
          pay-src: fs.src, over-x: fs.over-x,
          pad-x: fs.pad / W, pad-y: fs.pad / H,
          painted: fs.painted, paint-fill: cfill.to-hex(),
          visible-from: fig-step))
        cy = cy + fh
        idx += 1
        if cap != none {
          cy = cy + alloc.gaps.at(idx - 1)
          let ch = alloc.heights.at(idx)
          place(_atop + _aleft, dx: (W - fw) / 2, dy: cy,
            _from(self, fig-step, block(width: fw, align(_acenter, cap))))
          let cm = measure(cap)
          objects.push(_obj(sid + ":caption", "plain", "caption", sid,
            (1.0 - fwn) / 2, cy / H, fwn, ch / H,
            pref-h: ch / H,
            pay-w: calc.min(cm.width, fw) / W, pay-h: cap-m.height / H,
            pay-src: "measured",
            over-x: cm.width > fw + _EPS-L and cap-m.height <= cm.height + _EPS-L,
            visible-from: fig-step))
          relations.push(_rel(sid + ":figure", sid + ":caption", "caption", "vertical", "tight"))
          cy = cy + ch
          idx += 1
        }
        if ki != none {
          cy = cy + alloc.gaps.at(idx - 1)
          let th = alloc.heights.at(idx)
          place(_atop + _aleft, dx: (W - tw) / 2, dy: cy,
            _from(self, tk-step, _render-item(ki, tw, th, cfill)))
          let anchor = if cap != none { sid + ":caption" } else { sid + ":figure" }
          objects.push(_obj(sid + ":takeaway", ki.kind, ki.role, sid,
            (1.0 - twn) / 2, cy / H, twn, th / H,
            pref-h: ks.spec.pref / H,
            pay-w: ks.pay-w / W, pay-h: ks.pay-h / H,
            pay-src: ks.src, over-x: ks.over-x,
            pad-x: ks.pad / W, pad-y: ks.pad / H,
            halign: if ks.painted { "left" } else { "center" },
            painted: ks.painted, paint-fill: cfill.to-hex(),
            visible-from: tk-step))
          relations.push(_rel(anchor, sid + ":takeaway", "supports", "vertical", _mode-proximity(mode)))
        }
        if self.subslide == rep {
          _emit(sid, "figure", "column", here().position().page, rep, objects, relations,
            alloc.fit, (mode: mode, has_caption: cap != none, has_takeaway: ki != none,
              tuned: tuning.len() > 0))
          if debug { _debug-layer(objects, W, H) }
        }
      })
    })
  }
}

// ---------------------------------------------------------------------------
// sidebar-slide — a narrow label tab beside a wide content card
// ---------------------------------------------------------------------------
//
// No `reveal`: the label and its content have no presentation order.  Both
// slots take plain content only (the component paints its own boxes; do not
// wrap the body in `textbox` or pass typed items).

#let sidebar-slide(
  title: auto,
  id: auto,
  label: none,
  body: none,
  debug: false,
  tuning: (:),
) = {
  _require("sidebar-slide", "label", label)
  _require("sidebar-slide", "body", body)
  if type(label) == dictionary or type(body) == dictionary {
    panic("sidebar-slide: label and body take plain content, not typed items")
  }
  let tn = _tuning("sidebar-slide", tuning, (
    "label-width": (default: 0.26, lo: 0.1, hi: 0.5),
    "gutter": (default: 0.04, lo: 0.0, hi: 0.2),
  ))
  // Both slots are text cards: spacers, empty strings, and bare rules panic.
  let assert-slot(slot, body, w) = {
    let mu = measure(body)
    let mc = measure(block(width: w, body))
    if mu.width < _EPS-L {
      panic("sidebar-slide: " + slot + " has no measurable width — spacers and "
        + "empty strings are not content")
    }
    if mc.height < _EPS-L {
      panic("sidebar-slide: " + slot + " has no measurable height — a bare rule "
        + "is decoration, not content")
    }
    (mu: mu, mc: mc)
  }
  if _note-mode() {
    xwysyy-slide(title: title)[
      #context {
        let _ = assert-slot("label", label, _NOTE-W.to-absolute())
        let _ = assert-slot("body", body, _NOTE-W.to-absolute())
      }
      #strong(label) \
      #body
    ]
  } else {
    xwysyy-slide(title: title, self => context {
      let t = _theme-state.get()
      layout(size => {
        let W = size.width
        let H = size.height
        let sid = _sid(id, "sidebar")
        _frame-mark(sid, self, size)
        let lwn = tn.at("label-width")
        let gutter = tn.at("gutter")
        let bwn = 1.0 - lwn - gutter
        if bwn <= 0.0 {
          panic("sidebar-slide: label-width " + repr(lwn) + " + gutter leaves no body width")
        }
        let lw = W * lwn
        let bw = W * bwn
        let pad = _CARD-PAD.to-absolute()
        // The label is measured with the same styled content it is rendered
        // with (bold via `set text`, not `strong`, whose show rule enlarges
        // the run and would make the measurement disagree with the render).
        let label-inner = {
          set text(weight: "bold")
          show raw: set text(fill: t.sea)
          label
        }
        let lmm = assert-slot("label", label-inner, lw - 2 * pad)
        let bmm = assert-slot("body", body, bw - 2 * pad)
        let lh = lmm.mc.height + 2 * pad
        let bh = bmm.mc.height + 2 * pad
        let row = _fit-row((lh, bh), H)

        place(_atop + _aleft, dx: 0pt, dy: row.y,
          block(width: lw, height: row.row, fill: t.sea, inset: pad, radius: 0.4em,
            align(_ahorizon + _aleft, {
              // Label text is light (paper) on the dark sea tab; inline code
              // keeps its light chip but takes dark (sea) text so it stays
              // readable instead of light-on-light.
              set text(fill: t.paper)
              label-inner
            })))
        place(_atop + _aleft, dx: W * (lwn + gutter), dy: row.y,
          block(width: bw, height: row.row, fill: t.skyll, inset: pad, radius: 0.4em,
            align(_ahorizon, body)))

        let objects = (
          _obj(sid + ":label", "card", "label", sid,
            0.0, row.y / H, lwn, row.row / H,
            pref-h: lh / H,
            pay-w: calc.min(lmm.mu.width, lw - 2 * pad) / W,
            pay-h: lmm.mc.height / H,
            pay-src: "measured",
            over-x: lmm.mu.width > lw - 2 * pad + _EPS-L and lmm.mc.height <= lmm.mu.height + _EPS-L,
            pad-x: pad / W, pad-y: pad / H,
            halign: "left", painted: true, paint-fill: t.sea.to-hex()),
          _obj(sid + ":body", "card", "content", sid,
            lwn + gutter, row.y / H, bwn, row.row / H,
            pref-h: bh / H,
            pay-w: calc.min(bmm.mu.width, bw - 2 * pad) / W,
            pay-h: bmm.mc.height / H,
            pay-src: "measured",
            over-x: bmm.mu.width > bw - 2 * pad + _EPS-L and bmm.mc.height <= bmm.mu.height + _EPS-L,
            pad-x: pad / W, pad-y: pad / H,
            halign: "left", painted: true, paint-fill: t.skyll.to-hex()),
        )
        let relations = (_rel(sid + ":label", sid + ":body", "labels", "horizontal", "gutter"),)
        _emit(sid, "sidebar", "row", here().position().page, 1, objects, relations, row.fit,
          (label_width: lwn, gutter: gutter, tuned: tuning.len() > 0))
        if debug { _debug-layer(objects, W, H) }
      })
    })
  }
}
