// The standalone page footer: `preferences.page-footer` /
// `last-modified-footer`, `labels` and the CV's `meta` (`_cv-details`,
// `internal/footers.typ`) mapped onto the footers in
// `internal/components/footer.typ`, as the value for `set page(...)`.

#import "../internal/components/footer.typ": (
  _auto-page-footer, _updated-footer, _updated-line,
)

// From the CV's `_cv-details` and the built `theme`. `page-footer`
// takes precedence; `last-modified-footer` is sugar that applies only
// when `page-footer` is `none`.
#let _footer(details, prefs, theme) = {
  let page-footer = prefs.page-footer
  if page-footer != none {
    if page-footer == auto {
      _auto-page-footer(details.owner, details.page-number)
    } else {
      page-footer
    }
  } else if prefs.last-modified-footer and details.last-modified != none {
    _updated-footer(
      details.last-modified-label,
      _updated-line(details, prefs.footer-version),
      theme.separator.label,
    )
  } else {
    none
  }
}
