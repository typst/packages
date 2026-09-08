#import "src/core.typ" as _core
#import "src/citations.typ" as _citations
#import "src/collect.typ" as _collect
#import "src/engine.typ" as _engine
#import "src/report.typ" as _report

#let _mode() = sys.inputs.at("sanity", default: none)

#let _config-in-effect(bibliography, checks, severities) = {
  let stored = _collect.stored-config()
  let keys = _citations.entry-keys(bibliography)
  if stored == none {
    _core.config(checks: checks, severities: severities, bib-keys: keys)
  } else {
    _core.config(
      checks: stored.checks + checks,
      severities: stored.severities + severities,
      bib-keys: if keys == none { stored.bib-keys } else { keys },
    )
  }
}

/// sanity check :)
#let sanity(
  body,
  checks: (:),
  severities: (:),
  bibliography: none,
  report: auto,
  strict: false,
) = {
  assert(
    report == auto or report == none,
    message: "sanity: report must be auto or none",
  )

  let cfg = _core.config(
    checks: checks,
    severities: severities,
    bib-keys: _citations.entry-keys(bibliography),
  )

  // left in the document
  [#metadata((
      checks: cfg.checks,
      severities: cfg.severities,
      bib-keys: cfg.bib-keys,
    )) <sanity-config>]

  body

  [#metadata(none) <sanity-end>]

  context {
    let mode = _mode()
    let outermost = query(selector(<sanity-end>).after(here())).len() == 0
    let will-panic = strict and mode not in ("report", "off")
    let will-report = report == auto and outermost and mode != "off"

    if will-panic or will-report {
      let result = _engine.analyse(cfg)
      if will-panic and _core.blocking(result.findings) {
        panic(_report.format-text(result.findings))
      }
      if will-report {
        _report.appended-report(result.findings, locations: result.locations)
      }
    }
  }
}

/// silence findings about the given labels
/// ```typ
/// #sanity-ignore(<fig:cover>, reason: "decorative")
/// #sanity-ignore(<fig:map>, checks: "unreferenced-figure")
/// ```
#let sanity-ignore(..targets, reason: none, checks: none) = {
  assert(
    reason == none or type(reason) == str,
    message: "sanity: reason must be a string",
  )

  let ids = if type(checks) == str { (checks,) } else { checks }
  if ids != none {
    assert(
      type(ids) == array,
      message: "sanity: checks takes a check id or an array of them",
    )
    _core.assert-known(ids)
  }

  for target in targets.pos() {
    [#metadata((target: str(target), reason: reason, checks: ids)) <sanity-ignore>]
  }
}

#let sanity-findings(bibliography: none, checks: (:), severities: (:)) = {
  _engine.analyse(_config-in-effect(bibliography, checks, severities)).findings
}

#let sanity-text(bibliography: none, checks: (:), severities: (:)) = {
  _report.format-text(sanity-findings(
    bibliography: bibliography,
    checks: checks,
    severities: severities,
  ))
}
