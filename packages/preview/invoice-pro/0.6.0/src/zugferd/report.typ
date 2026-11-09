// Presents the diagnostics of the e-invoice validation (see
// `rules/engine.typ`), either as the message of a compiler error or as
// content in the document.

#let _errors(diagnostics) = diagnostics.filter(d => d.level == "error")
#let _warnings(diagnostics) = diagnostics.filter(d => d.level != "error")

#let _count(n, noun) = str(n) + " " + noun + if n != 1 { "s" }

// How the profile was chosen, for `zugferd: auto`.
#let _profile-note(profile) = if profile.at("automatic", default: false) {
  let skipped = profile.at("skipped", default: ())
  (
    "Profile chosen by `zugferd: auto`: "
      + profile.name
      + "."
      + if skipped.len() > 0 {
        (
          " Not possible: "
            + skipped.map(candidate => candidate.name).join(", ")
            + " (see the warnings)."
        )
      } else { "" }
  )
}

/// Formats the diagnostics as plain text, for the message of a compiler error.
///
/// -> str
#let format-report(result) = {
  let profile = result.profile
  let errors = _errors(result.diagnostics)
  let warnings = _warnings(result.diagnostics)

  let entry(d) = {
    let head = "[" + d.rule + "] " + d.field + ": " + d.message
    if d.hint != none { head + "\n     Hint: " + d.hint } else { head }
  }

  let lines = (
    "The e-invoice (ZUGFeRD / Factur-X, profile "
      + profile.name
      + ") is not valid: "
      + _count(errors.len(), "error")
      + if warnings.len() > 0 { ", " + _count(warnings.len(), "warning") }
      + ".",
  )
  for (i, d) in errors.enumerate() {
    lines.push("  " + str(i + 1) + ". " + entry(d))
  }
  if warnings.len() > 0 {
    lines.push("Warnings:")
    for d in warnings { lines.push("  - " + entry(d)) }
  }
  let note = _profile-note(profile)
  if note != none { lines.push(note) }
  lines.push(
    "Set `zugferd-errors: \"report\"` on the invoice to list these problems in the document instead.",
  )
  lines.join("\n")
}

/// Renders the diagnostics as a block, placed above the invoice body when
/// `zugferd-errors` is `"report"`.
///
/// -> content
#let render-zugferd-report(ctx, result) = {
  let errors = _errors(result.diagnostics)
  let warnings = _warnings(result.diagnostics)
  let color = if errors.len() > 0 { rgb("#b91c1c") } else { rgb("#a16207") }

  let entry(d) = {
    [#strong(d.rule) #h(0.3em) #raw(d.field) \ #d.message]
    if d.hint != none { [ \ #emph(d.hint)] }
  }

  block(
    width: 100%,
    breakable: true,
    inset: 8pt,
    radius: 3pt,
    stroke: 1pt + color,
    fill: color.lighten(92%),
    {
      set text(size: 0.85em)
      set par(justify: false)
      strong(text(fill: color)[
        E-invoice (#result.profile.name):
        #_count(errors.len(), "error"), #_count(warnings.len(), "warning")
      ])
      if errors.len() > 0 { enum(..errors.map(entry)) }
      if warnings.len() > 0 { list(..warnings.map(entry)) }
      let note = _profile-note(result.profile)
      if note != none { emph(note) }
    },
  )
}
