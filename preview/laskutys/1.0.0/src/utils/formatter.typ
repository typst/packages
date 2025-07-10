#import "@preview/oxifmt:1.0.0": strfmt

/// -> str
#let get_decimal_separator(lang) = {
  let decimal_separators = ("fi": ",", "en": ".", "sv": ",")

  decimal_separators.at(lang)
}

/// -> content
#let formatter(
  format,
  ..replacements,
) = context {
  strfmt(format, ..replacements, fmt-decimal-separator: get_decimal_separator(
    text.lang,
  ))
}

