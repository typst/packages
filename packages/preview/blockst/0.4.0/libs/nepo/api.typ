// Public NEPO API.
//
// Deliberately not folded into `scratch()`. The two dialects share a renderer
// pipeline but not a vocabulary: a Scratch document and a NEPO document are
// written differently, name their blocks differently and are read by different
// tools. One function taking a `dialect:` switch would make every call site
// carry an argument that changes what the first argument even means.

#import "../scratch/api.typ": _with-local-options
#import "plugin.typ": render-nepo, parse-nepo

#let _normalize-source(elements) = {
  if type(elements) == content and elements.func() == raw {
    elements = elements.text
  }
  if type(elements) == str { elements } else { str(elements) }
}

/// Render Open Roberta (NEPO) blocks from text.
///
/// ```typ
/// #nepo("
/// Start
///   Zeige Text \"Hallo\"
///   Wiederhole unendlich oft
///     Schalte RGB LED an (#ff0000)
///   Ende
/// ")
/// ```
///
/// `platform` selects the robot whose block set is offered — the prototype
/// ships `calliope`, `calliopev3` and `microbit`. `language` picks the
/// localisation; block text always prints in Open Roberta's own wording, even
/// when the source used a colloquial alias.
#let nepo(
  code,
  language: "de",
  platform: "calliope",
  theme: auto,
  scale: auto,
  font: auto,
) = context {
  let source = _normalize-source(code)
  _with-local-options(
    theme: theme,
    scale: scale,
    font: font,
    [#render-nepo(source, language: language, platform: platform)],
  )
}

/// Parse NEPO text to a block tree, without rendering.
#let nepo-parse(code, language: "de", platform: "calliope") = {
  parse-nepo(_normalize-source(code), language: language, platform: platform)
}

/// Enable NEPO code blocks in raw text:
///
/// ```typ
/// #show: raw-nepo()
/// ```
#let raw-nepo(..args) = (
  body => {
    show raw.where(block: true, lang: "nepo"): nepo.with(..args)
    body
  }
)
