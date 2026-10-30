/// The University of Toronto name-block rows.
#let _UTORONTO_NAME_FIELDS = (
  (prefix: [#text(size: .85em)[(Given then Family)] \ NAME:]),
  (prefix: [Email address:], suffix: [`@mail.utoronto.ca`]),
  (prefix: [UTORid:]),
)

/// Ready-made settings for specific institutions, e.g. a name block's
/// rows:
///
/// ```typst
/// #name-block(fields: presets.utoronto.name-fields)
/// ```
#let presets = (
  utoronto: (
    name-fields: _UTORONTO_NAME_FIELDS,
    // Deprecated: the name `name-fields` had in 0.4 and earlier, when it
    // was the only snake_case key. Kept so that documents written for 0.4
    // still compile.
    name_fields: _UTORONTO_NAME_FIELDS,
  ),
)

/// API documentation for `presets`, consumed by docs/api.typ
/// (keyed by export name).
#let DOCS = (
  presets: (
    desc: "Settings for specific institutions. Currently only `presets.utoronto.name-fields`, the University of Toronto rows for `#name-block(fields: presets.utoronto.name-fields)`.",
  ),
)
