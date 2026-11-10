// Scale expansion, the last step every coord `train` shares before any flip.

#import "../scale/train.typ": transform-fwd
#import "../scale/expansion.typ": DISCRETE-AUTO-DATA-PAD, normalise-expansion

// Apply scale expansion on top of the already-padded domain produced by
// `_post-train`. Multiplicative breathing room (ratio) is folded into
// `view-transform` (continuous) / `view-index` (discrete); absolute additive
// padding (length) is recorded as `view-pad-cm` and applied later by
// `_draw-axis-and-layers` as a canvas-cm inset on the data area.
// `no-expand` zeroes everything, for `coord-cartesian(expand: false)`.
// `zero-lo-axis` names the radial axis under `coord-radial`, which maps
// view-min to canvas radius 0, so any lo-side padding there would leave a hole
// at the centre: its lo side collapses to zero when `expand` is auto.
#let apply-expand(trained, no-expand: false, zero-lo-axis: none) = {
  for axis in ("x", "y") {
    let entry = trained.at(axis, default: none)
    if entry == none { continue }
    let spec = entry.at("spec", default: none)
    let raw = if spec == none { auto } else { spec.at("expand", default: auto) }
    let expand = if no-expand { false } else { raw }
    let (mult-lo, add-cm-lo, mult-hi, add-cm-hi) = normalise-expansion(
      expand,
      entry.type,
    )
    // A side left at `auto` (whole value or one tuple element) gets the
    // auto-only treatments below; an explicit value on that side opts out.
    let lo-auto = (
      raw == auto
        or (
          type(raw) == array and raw.len() == 2 and raw.at(0) == auto
        )
    )
    let hi-auto = (
      raw == auto
        or (
          type(raw) == array and raw.len() == 2 and raw.at(1) == auto
        )
    )
    // Bars / areas anchor at y=0: when the user did not pin `expand`
    // explicitly, drop the multiplicative expansion on the anchored side so
    // the baseline sits flush against the axis line. Length-add is always
    // honoured.
    let anchor = entry.at("anchor-zero", default: none)
    if anchor != none {
      if (anchor == "lo" or anchor == "both") and lo-auto { mult-lo = 0 }
      if (anchor == "hi" or anchor == "both") and hi-auto { mult-hi = 0 }
    }
    // A `flush` axis drops the automatic expansion on each side left at
    // `auto`, the same as `coord-cartesian(expand: false)` there.
    if entry.at("flush", default: false) {
      if lo-auto {
        mult-lo = 0
        add-cm-lo = 0
      }
      if hi-auto {
        mult-hi = 0
        add-cm-hi = 0
      }
    }
    let radial-zero-lo = axis == zero-lo-axis and lo-auto
    if radial-zero-lo {
      mult-lo = 0
      add-cm-lo = 0
    }
    let new-entry = entry
    if entry.type == "continuous" {
      let (lo, hi) = entry.domain
      let transform = entry.at("transform", default: "identity")
      let pre = entry.at("pre-transformed", default: false)
      // Pre-transformed domains already live in stat space; warping again
      // would double-apply.
      let t-lo = if pre { lo } else { transform-fwd(transform, lo) }
      let t-hi = if pre { hi } else { transform-fwd(transform, hi) }
      let span = t-hi - t-lo
      new-entry.insert(
        "view-transform",
        (t-lo - mult-lo * span, t-hi + mult-hi * span),
      )
    } else if entry.type == "discrete" {
      let n = entry.domain.len()
      let span = if n > 1 { n - 1 } else { 0 }
      // A discrete side left at `auto` gets a default 0.6-slot data-unit pad;
      // an explicit value on that side supersedes it. Radial axes skip
      // the lo-side data pad so the inner edge sits at radius 0.
      let auto-data-pad-lo = if lo-auto { DISCRETE-AUTO-DATA-PAD } else { 0 }
      let auto-data-pad-hi = if hi-auto { DISCRETE-AUTO-DATA-PAD } else { 0 }
      let geom-min = entry.at("geom-min-pad", default: 0)
      let lo-pad-base = if radial-zero-lo { 0 } else { auto-data-pad-lo }
      let pad-lo = calc.max(mult-lo * span + lo-pad-base, geom-min)
      let pad-hi = calc.max(mult-hi * span + auto-data-pad-hi, geom-min)
      new-entry.insert("view-index", (0 - pad-lo, (n - 1) + pad-hi))
    }
    new-entry.insert("view-pad-cm", (add-cm-lo, add-cm-hi))
    trained.insert(axis, new-entry)
  }
  trained
}
