/// folio v0.0.1 — Data Audit Rendering
/// Called internally by orchestrator.typ when config.audit == true.
/// These functions are NOT public API — they are not exported from lib.typ.
///
/// Note on folio-orphans coupling: orphan state is defined and accumulated in
/// refs.typ (via safe-link), and read here for display. This is intentional for
/// v0.0.1 — audit renders what refs accumulates. Refactor target: v0.1.0.
#import "state.typ": folio-state
#import "resolve.typ": _walk, nonempty
#import "../theme/ui.typ": badge, data-table
#import "../theme/resolver.typ": resolve-token
#import "schema.typ": folio-schema
#import "refs.typ": folio-orphans

#let data-audit-header() = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  let danger = resolve-token(st, "palette.intent.danger")
  let neutral = resolve-token(st, "palette.intent.neutral")

  // Merge extra checks from config
  let extra-checks = st.config.at("extra-checks", default: ())
  for check in extra-checks {
    let valid-severities = ("critical", "important", "recommended")
    if check.at("severity", default: "") not in valid-severities {
      panic(
        "Invalid severity in extra-checks: "
          + check.at("severity", default: "")
          + ". Must be one of "
          + str(valid-severities),
      )
    }
  }
  let full-schema = folio-schema + extra-checks

  // Path status using nonempty + _walk (replaces the old duplicated check-path loop)
  let path-status(p) = {
    let r = _walk(data, p)
    if not r.found { "Missing" } else if not nonempty(data, p) {
      "Empty"
    } else { "Present" }
  }

  let render-group(sev, title) = {
    let items = full-schema.filter(r => r.severity == sev)
    if items.len() == 0 { return none }

    let rows = items
      .map(r => {
        let stat = path-status(r.path)
        let b = if stat == "Present" {
          badge("Present", intent: "success")
        } else if stat == "Empty" {
          badge("Empty", intent: "warning")
        } else {
          badge("Missing", intent: "danger")
        }
        (r.path, b, r.at("phase", default: "custom"))
      })
      .flatten()

    v(1em)
    heading(level: 3)[#title]
    data-table(
      columns: (1fr, auto, auto),
      headers: ("Path", "Status", "Phase"),
      rows: rows,
    )
  }

  block(
    width: 100%,
    stroke: 4pt + danger,
    inset: 1.5em,
    fill: danger.lighten(90%),
    radius: 4pt,
  )[
    #align(center)[
      #text(
        fill: danger,
        weight: "bold",
        size: 1.5em,
      )[⚠ DIAGNOSTIC DRAFT — DO NOT SHIP]
    ]
    #v(1em)
    #text(
      style: "italic",
    )[This dashboard indicates data completeness based on the PMBOK standard. Turn off by setting `config: (audit: false)`.]

    #render-group("critical", "Critical Data")
    #render-group("important", "Important Data")
    #render-group("recommended", "Recommended Data")
  ]
}

#let data-audit-orphans() = context {
  let orphans = folio-orphans.get()

  heading(level: 2)[Orphan References]

  if orphans.len() == 0 {
    [No orphan references detected.]
  } else {
    data-table(
      columns: (1fr, 1fr),
      headers: ("Target Label", "Fallback Text"),
      rows: orphans
        .map(o => (
          str(o.target),
          o.fallback,
        ))
        .flatten(),
    )
    v(1em)
    text(
      style: "italic",
      size: 0.8em,
    )[Note: Orphan detection may require a second compile pass to be fully accurate.]
  }
}
// data-audit() (one-liner alias) intentionally removed — TODO-9.
// Audit is triggered internally via config: (audit: true) in project-doc.
