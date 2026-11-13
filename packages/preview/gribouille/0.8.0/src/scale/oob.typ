// Out-of-range pre-pass.
//
// Walks each prepared layer once after training and removes rows whose value
// for any user-limited aesthetic falls outside the trained domain. When the
// scale's `oob` is `"squish"` the row stays and the cell is clamped to the
// nearest limit so downstream resolvers see an in-range value. Discrete
// scales censor only — squish has no geometric meaning on levels. A cell that
// a continuous scale cannot read, such as `"zz"` or NaN, drops its row too.

#import "../utils/types.typ": parse-number
#import "../utils/late-binding.typ": is-late-binding
#import "../utils/palette.typ": spec-attr
#import "train.typ": (
  level-lookup, mapping-ref-col, positional-aesthetics, to-stat-fn,
  view-bounds-stat,
)
#import "../utils/errors.typ": fail

// An empty string is a missing cell, as `none` is, not an unusable one.
#let _is-missing(raw) = raw == none or raw == ""

// Drop a cell that a continuous channel cannot read, such as `"zz"` on a colour
// scale, so the row does not draw in the fallback ink. A missing cell stays.
#let _drop-unusable(raw) = {
  if _is-missing(raw) or parse-number(raw) != none { return ("in", raw) }
  ("unusable", raw)
}

// Build the per-row check for one trained scale, or `none` when the scale
// censors nothing: a scale with no user `limits`, other than a continuous
// non-position scale that trained on a cell it cannot read.
//
// The check is a closure taking the cell alone, so the level lookup is
// captured once rather than reaching the call on every row. Holding the same
// values in a record instead was measured to be slower, and to keep growing
// with the level count.
//
// The closure returns one of:
//   ("in",     value)   — unchanged
//   ("squish", clamped) — kept, value rewritten
//   ("drop",   value)   — caller drops the row
//   ("unusable", value) — caller drops the row, also under `strict`
#let _checker(aes, trained) = {
  if spec-attr(trained, "limits") == none {
    if (
      trained.type == "continuous"
        // A position cell that does not parse, on x, y or a feeder such as
        // ymin, is skipped by every geom, so the pre-pass leaves it alone.
        and aes not in positional-aesthetics
        and trained.at("unusable", default: false)
    ) {
      return _drop-unusable
    }
    return none
  }

  if trained.type == "continuous" {
    // Only a continuous scale reads `oob`, because only it can squish.
    let oob = spec-attr(trained, "oob", fallback: "drop")
    // The expanded view in stat space, rather than the raw `limits`, so a value
    // sitting in the expansion headroom -- which still maps inside the visible
    // panel -- survives instead of being dropped.
    //
    // `oob-cutoff` holds the user limits when the extents fold of `_post-train`
    // widened the domain to fit whole marks. A side it gives cuts at the limit
    // itself, so the wider domain does not let a mark centred outside the
    // limits back in.
    let (t-lo, t-hi) = view-bounds-stat(trained)
    let to-stat = to-stat-fn(trained)
    let cutoff = trained.at("oob-cutoff", default: (none, none))
    if cutoff.at(0) != none { t-lo = to-stat(cutoff.at(0)) }
    if cutoff.at(1) != none { t-hi = to-stat(cutoff.at(1)) }
    // `t-lo`/`t-hi` follow the domain order, which runs high-to-low when the
    // user supplies reversed `limits` to flip the axis; the in-range test reads
    // the sorted span so it holds either way.
    let span-lo = calc.min(t-lo, t-hi)
    let span-hi = calc.max(t-lo, t-hi)
    let domain = trained.domain
    return raw => {
      if _is-missing(raw) { return ("in", raw) }
      let v = parse-number(raw)
      if v == none { return ("unusable", raw) }
      let sv = to-stat(v)
      if sv >= span-lo and sv <= span-hi { return ("in", raw) }
      if oob == "squish" {
        // Clamp to the nearest `limits` endpoint (the visible data edge), not
        // the expanded bound, matching the documented squish-to-limit
        // semantics. `t-lo` pairs with `lo` and `t-hi` with `hi` whatever the
        // order.
        //
        // The endpoints are read here rather than when the check is built, so
        // a scale whose domain is not a pair fails only where the clamp needs
        // them, as it did before the check was hoisted out of the row walk.
        let (lo, hi) = domain
        if cutoff.at(0) != none { lo = cutoff.at(0) }
        if cutoff.at(1) != none { hi = cutoff.at(1) }
        let to-lo = calc.abs(sv - t-lo) <= calc.abs(sv - t-hi)
        return ("squish", if to-lo { lo } else { hi })
      }
      ("drop", raw)
    }
  }

  if trained.type == "discrete" {
    // A discrete scale censors whatever `oob` says, so the mode is not read
    // here: clamping to a level has no geometric meaning.
    //
    // The level lookup is resolved once, so the row test is one dict read
    // rather than a scan of the domain.
    let level-index = level-lookup(trained)
    return raw => {
      if raw == none { return ("in", raw) }
      // The level name first, then the position, which is the order
      // `map-discrete` reads a cell in. Reading the position first would leave
      // a level whose name parses as a number impossible to censor, and would
      // then miss that same level in the lookup and place the row at its face
      // value, far outside the panel.
      if str(raw) in level-index { return ("in", raw) }
      // A native number addresses a 1-indexed fractional level position rather
      // than a level name (`map-discrete` places it at `value - 1`), e.g. a
      // polygon vertex set between level centres or a jittered point. The
      // renderer can place it, so the pre-pass keeps it and lets panel clipping
      // bound any overflow. A numeric string is not one of these: every writer
      // of a position (`_prepare-layer`, `position-jitter`) writes a native
      // number.
      if type(raw) in (int, float) { return ("in", raw) }
      ("drop", raw)
    }
  }

  // Any other scale type, `identity` among them, censors nothing. Answering
  // `none` keeps the aesthetic out of the walk entirely, rather than calling a
  // closure that can only ever answer "in" on every row.
  none
}

// Resolve every limited scale in the trained dict into the plan the row walk
// runs it under.
//
// Everything a check reads is constant per aesthetic, so each scale is resolved
// once here into a closure the row walk calls with the cell alone. Held as an
// array rather than a dict, so the row walk iterates it directly instead of
// looking each aesthetic up again on every row. The limits travel with the
// check because the `strict` panic names them; nothing on the row path reads
// them.
//
// The plans are built here rather than inside `filter-oob`, because a faceted
// render filters the whole layer set and then every panel in turn, always
// against the same trained dict. Resolving them per call would resolve each
// scale once per panel.
#let oob-plans(trained) = {
  let plans = ()
  for (aes, t) in trained.pairs() {
    let check = _checker(aes, t)
    if check == none { continue }
    plans.push((aes: aes, check: check, limits: spec-attr(t, "limits")))
  }
  plans
}

// Filter rows of every layer through the plans `oob-plans` resolved. Returns
// the rewritten layers and a per-aesthetic dropped-row count. `strict: true`
// converts the first drop into a `panic` instead. `centres` maps a layer
// name to the mapping key that holds its centre per position aesthetic, for
// a geom such as ellipse whose centre is not `x`/`y`.
#let filter-oob(layers, plans, strict: false, centres: (:)) = {
  if plans.len() == 0 { return (layers: layers, counts: (:)) }

  let counts = (:)
  let new-layers = ()
  for layer in layers {
    // A `clip: false` layer (e.g. `annotate(clip: false)`) is meant to draw
    // beyond the limits, so it opts out of the drop pre-pass entirely; its rows
    // pass through verbatim. Mirror the unclipped-set predicate in `panel-draw`
    // (`not layer.clip`) so the two passes agree on which layers are unclipped.
    if not layer.at("clip", default: true) {
      new-layers.push(layer)
      continue
    }
    let mapping = layer.at("mapping", default: none)
    let data = layer.at("data", default: none)
    if mapping == none or type(data) != array {
      new-layers.push(layer)
      continue
    }
    // Which column each limited aesthetic reads is a property of the layer, not
    // of the row, and `mapping-ref-col` walks the wrapper chain to find it.
    // Resolve it once per layer so the row walk only reads the cell.
    let centre = centres.at(layer.at("name", default: ""), default: (:))
    let bound = ()
    for entry in plans {
      let key = centre.at(entry.aes, default: entry.aes)
      let raw = mapping.at(key, default: none)
      if raw == none { continue }
      if is-late-binding(raw) { continue }
      bound.push((col: mapping-ref-col(raw), ..entry))
    }
    if bound.len() == 0 {
      new-layers.push(layer)
      continue
    }
    let kept = ()
    for (row-idx, row) in data.enumerate() {
      let new-row = row
      let drop = false
      for binding in bound {
        let aes = binding.aes
        let col = binding.col
        let cell = row.at(col, default: none)
        let (action, value) = (binding.check)(cell)
        if action == "in" { continue }
        if action == "squish" {
          new-row.insert(col, value)
          continue
        }
        // A cell the scale cannot read is not outside the limits, so `strict`
        // does not report it.
        if strict and action == "drop" {
          fail(
            "plot",
            "row "
              + str(row-idx)
              + " on "
              + aes
              + " is outside limits "
              + repr(binding.limits)
              + "; got "
              + repr(cell),
            hint: "Set `oob: \"squish\"` to clamp, widen `limits`, "
              + "or remove `strict: true` to drop silently.",
          )
        }
        drop = true
        counts.insert(aes, counts.at(aes, default: 0) + 1)
        break
      }
      if not drop { kept.push(new-row) }
    }
    let new-layer = layer
    new-layer.data = kept
    new-layers.push(new-layer)
  }
  (layers: new-layers, counts: counts)
}
