// status.typ - Semantic colours shared by the dashboard pieces

#import "../theme.typ": _is-dark

/// Good / bad / caution colours for metric deltas and alerts, light or dark.
/// A theme can override them with `positive-color`, `negative-color` and
/// `warning-color`; `info` is the theme's first palette colour.
///
/// - t (dictionary): Resolved theme
/// -> dictionary with `positive`, `negative`, `warning`, `info`
#let status-colors(t) = {
  let dark = _is-dark(t)
  (
    positive: if "positive-color" in t { t.positive-color } else if dark { rgb("#4ade80") } else { rgb("#16a34a") },
    negative: if "negative-color" in t { t.negative-color } else if dark { rgb("#f87171") } else { rgb("#dc2626") },
    warning: if "warning-color" in t { t.warning-color } else if dark { rgb("#fbbf24") } else { rgb("#d97706") },
    info: t.palette.at(0),
  )
}
