#import "@preview/oxifmt:1.0.0": strfmt

/// -> str
#let get-decimal-separator(lang) = {
  let decimal-separators = ("fi": ",", "en": ".", "sv": ",")

  decimal-separators.at(lang)
}

/// -> content
#let formatter(
  format,
  ..replacements,
) = context {
  strfmt(format, ..replacements, fmt-decimal-separator: get-decimal-separator(
    text.lang,
  ))
}

