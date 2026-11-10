/// folio v0.0.1 — Validators
/// Wrappers around compute functions for use in rendering context.
/// These import from the compute layer and provide convenient access
/// for section components and audit dashboards.

#import "../compute.typ": (
  audit-missing, audit-summary, compute-context, find-orphans,
)
#import "../core/state.typ": folio-state

/// Run orphan detection on the current folio state.
/// Returns: array of orphan records
#let orphan-check() = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  find-orphans(data)
}

/// Run field-status audit on the current folio state.
/// Returns: array of (path, severity, phase, kind, status) records
#let missing-fields() = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  let extra-checks = st.config.at("extra-checks", default: ())
  audit-missing(data, extra-checks: extra-checks)
}

/// Build a full audit report from current folio state.
/// Returns: (fields: [...], orphans: [...], summary: (...))
#let audit-builder() = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  let extra-checks = st.config.at("extra-checks", default: ())

  let fields = audit-missing(data, extra-checks: extra-checks)
  let orphans = find-orphans(data)
  let summary = audit-summary(fields)

  (
    fields: fields,
    orphans: orphans,
    summary: summary,
  )
}
