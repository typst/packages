/// Ready-made argument sets for `exam` for specific institutions.
/// Spread one into an exam call:
///
/// ```typst
/// #exam(..presets.utoronto, questions: [...])
/// ```
#let presets = (
  utoronto: (
    name_fields: (
      (prefix: [#text(size: .85em)[(Given then Family)] \ NAME:]),
      (prefix: [Email address:], suffix: [`@mail.utoronto.ca`]),
      (prefix: [UTORid:]),
    ),
  ),
)

/// API documentation for `presets`, consumed by docs/generate-api.typ
/// (keyed by export name).
#let DOCS = (
  presets: (
    desc: "Institution-specific argument sets. Currently `presets.utoronto.name_fields`: the University of Toronto name-block rows (NAME / Email address / UTORid).",
  ),
)
