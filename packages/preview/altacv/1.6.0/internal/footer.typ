// Page footer — resolves the `pageFooter` / `lastModifiedFooter`
// preferences into the value handed to `set page(...)`, and renders
// the "auto" variant. The auto footer suppresses itself on single-page
// documents (the common case stays clean) via the reactive page
// counter, so content growth brings it back without a caller change.

#import "state.typ": _body_size_state, _body_colour
#import "text.typ": _present

#let _auto_page_footer(name) = context {
  let total = counter(page).final().first()
  if total <= 1 { return }
  let body-size = _body_size_state.get()
  set text(0.8 * body-size, fill: _body_colour)
  grid(
    columns: (1fr, auto),
    align: (left, right),
    name,
    [Page #counter(page).display() / #total],
  )
}

// `pageFooter` is the general mechanism and takes precedence;
// `lastModifiedFooter` is sugar that applies only when `pageFooter`
// is `none` (its default). Resulting value passed to `set page(...)`:
//   `none`             — no footer
//   auto renderer      — name + "Page N / M", multi-page only
//   verbatim content   — rendered on every page
#let _resolve_page_footer(preferences, labels, meta, name) = {
  let page-footer = preferences.pageFooter
  let last-modified = meta.at("lastModified", default: none)
  if page-footer != none {
    if page-footer == "auto" {
      _auto_page_footer(name)
    } else {
      page-footer
    }
  } else if preferences.lastModifiedFooter and _present(last-modified) {
    // `footerVersion` appends `meta.version` in parentheses (e.g.
    // "(v1.0.0)") — rendered verbatim, since the schema's own example
    // value already carries the "v". Rides the last-updated line; no
    // standalone footer of its own.
    let version = meta.at("version", default: none)
    let version-suffix = if preferences.footerVersion and type(version) == str and version != "" {
      " (" + version + ")"
    } else { "" }
    align(right, text(0.8 * preferences.bodySize, fill: _body_colour, {
      labels.lastModified
      ": "
      last-modified
      version-suffix
    }))
  } else {
    none
  }
}
