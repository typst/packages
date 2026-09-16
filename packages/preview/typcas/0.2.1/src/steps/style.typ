// =========================================================================
// typcas v2 Step Styling
// =========================================================================
// Doc-level style state for step rendering.
// - `set-step-style(...)` updates current style for the document.
// - `get-step-style()` reads merged style (defaults + overrides).
// =========================================================================

#let default-step-style = (
  palette: (
    transform: rgb("#0E8A9A"), // teal
    note: luma(98%),
    warn: rgb("#C18400"), // amber
    error: rgb("#B33A3A"),
    meta: rgb("#2F6F78"),
  ),
  indent-size: 1.2em,
  equation-gap: 0.42em,
  arrow: (
    main: "⇒",
    sub: "↦",
    meta: "⟹",
  ),
  line-weight: (
    major: 620,
    minor: 470,
  ),
  branch: (
    mode: "inline",
    marker: "↳",
    marker-fill: rgb("#2F6F78"),
    marker-size: 0.84em,
    marker-weight: 560,
    marker-gap: 0.32em,
    show-divider: true,
    divider-stroke: 0.5pt + rgb("#9AB8BD"),
    label-fill: rgb("#2F6F78"),
    label-size: 0.78em,
    label-weight: 520,
    gap-top: 0.2em,
    gap-bottom: 0.36em,
  ),
)

#let _style-state = state("typcas.v2.step-style", default-step-style)

#let _deep-merge(base, patch) = {
  if type(base) != dictionary { return patch }
  if type(patch) != dictionary { return patch }

  let out = (:)
  for k in base.keys() {
    out.insert(k, base.at(k))
  }

  for k in patch.keys() {
    let pv = patch.at(k)
    let bv = out.at(k, default: none)
    if type(bv) == dictionary and type(pv) == dictionary {
      out.insert(k, _deep-merge(bv, pv))
    } else {
      out.insert(k, pv)
    }
  }

  out
}

#let _style-safe(v, fallback) = if v == none { fallback } else { v }

#let _normalize-style(style, patch: none) = {
  let merged = _deep-merge(default-step-style, style)
  let p = merged.at("palette", default: default-step-style.palette)
  let a = merged.at("arrow", default: default-step-style.arrow)
  let lw = merged.at("line-weight", default: default-step-style.line-weight)
  let br = merged.at("branch", default: default-step-style.branch)
  let br-patch = if type(patch) == dictionary and "branch" in patch and type(patch.at("branch")) == dictionary {
    patch.at("branch")
  } else {
    none
  }
  let mode-explicit = br-patch != none and "mode" in br-patch
  let divider-hint = br-patch != none and (
    "show-divider" in br-patch
      or "divider-stroke" in br-patch
      or "gap-top" in br-patch
      or "gap-bottom" in br-patch
  )
  let branch-mode = if patch == none {
    _style-safe(br.at("mode", default: none), default-step-style.branch.mode)
  } else if mode-explicit {
    _style-safe(br.at("mode", default: none), default-step-style.branch.mode)
  } else if divider-hint {
    "divider"
  } else {
    default-step-style.branch.mode
  }

  (
    palette: (
      transform: _style-safe(p.at("transform", default: none), default-step-style.palette.transform),
      note: _style-safe(p.at("note", default: none), default-step-style.palette.note),
      warn: _style-safe(p.at("warn", default: none), default-step-style.palette.warn),
      error: _style-safe(p.at("error", default: none), default-step-style.palette.error),
      meta: _style-safe(p.at("meta", default: none), default-step-style.palette.meta),
    ),
    indent-size: _style-safe(merged.at("indent-size", default: none), default-step-style.indent-size),
    equation-gap: _style-safe(merged.at("equation-gap", default: none), default-step-style.equation-gap),
    arrow: (
      main: _style-safe(a.at("main", default: none), default-step-style.arrow.main),
      sub: _style-safe(a.at("sub", default: none), default-step-style.arrow.sub),
      meta: _style-safe(a.at("meta", default: none), default-step-style.arrow.meta),
    ),
    line-weight: (
      major: _style-safe(lw.at("major", default: none), default-step-style.line-weight.major),
      minor: _style-safe(lw.at("minor", default: none), default-step-style.line-weight.minor),
    ),
    branch: (
      mode: branch-mode,
      marker: _style-safe(br.at("marker", default: none), default-step-style.branch.marker),
      marker-fill: _style-safe(br.at("marker-fill", default: none), default-step-style.branch.marker-fill),
      marker-size: _style-safe(br.at("marker-size", default: none), default-step-style.branch.marker-size),
      marker-weight: _style-safe(br.at("marker-weight", default: none), default-step-style.branch.marker-weight),
      marker-gap: _style-safe(br.at("marker-gap", default: none), default-step-style.branch.marker-gap),
      show-divider: _style-safe(br.at("show-divider", default: none), default-step-style.branch.show-divider),
      divider-stroke: _style-safe(br.at("divider-stroke", default: none), default-step-style.branch.divider-stroke),
      label-fill: _style-safe(br.at("label-fill", default: none), default-step-style.branch.label-fill),
      label-size: _style-safe(br.at("label-size", default: none), default-step-style.branch.label-size),
      label-weight: _style-safe(br.at("label-weight", default: none), default-step-style.branch.label-weight),
      gap-top: _style-safe(br.at("gap-top", default: none), default-step-style.branch.gap-top),
      gap-bottom: _style-safe(br.at("gap-bottom", default: none), default-step-style.branch.gap-bottom),
    ),
  )
}

/// Public helper `set-step-style`.
#let set-step-style(style-map) = {
  let patch = if style-map == none { (:)} else { style-map }
  let next = _normalize-style(_deep-merge(default-step-style, patch), patch: patch)
  _style-state.update(next)
}

/// Public helper `get-step-style`.
#let get-step-style() = context { _normalize-style(_style-state.get()) }

// Internal helper for renderers operating inside known context.
#let _step-style-current() = _normalize-style(_style-state.get())
