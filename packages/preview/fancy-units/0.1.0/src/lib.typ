#import "content.typ": unwrap-content
#import "number.typ": interpret-number, format-number
#import "unit.typ": interpret-unit, format-unit-power, format-unit-fraction, format-unit-slash

// Source for the separators https://en.wikipedia.org/wiki/Decimal_separator#Conventions_worldwide
#let language-decimal-separator = (
  af: ",", // Afrikaans
  sq: ",", // Albanian
  be: ",", // Belarusian
  bg: ",", // Bulgarian
  hr: ",", // Croatian
  cs: ",", // Czech
  da: ",", // Danish
  nl: ",", // Dutch
  en: ".", // English
  et: ",", // Estonian
  fi: ",", // Finnish
  fr: ",", // French
  ka: ",", // Georgian
  de: ",", // German
  el: ",", // Greek
  hu: ",", // Hungarian
  is: ",", // Icelandic
  it: ",", // Italian
  lt: ",", // Lithuanian
  mn: ",", // Mongolian
  no: ",", // Norwegian
  pl: ",", // Polish
  pt: ",", // Portugese
  ru: ",", // Russian
  sr: ",", // Serbian
  sk: ",", // Slovak
  sl: ",", // Slovenian
  es: ",", // Spanish
  sv: ",", // Swedish
  tr: ",", // Turkish
  tk: ",", // Turkmen
  uk: ",", // Ukrainian
  // Kurmanji and Latin are missing

  // A few other languages
  jp: ".", // Japanese
  ko: ".", // Korean
  zh: ".", // Chinese
)

// Get the decimal separator based on the text language
//
// This function can only be called in a known context!
// 
// All languages from https://typst.app/tools/hyphenate/ except for Kurmanji and Latin
// are currently supported. In addition Japanese, Korean and Chinese are available.
// If a language is not supported, the separator will default to ".". 
#let get-decimal-separator() = {
  language-decimal-separator.at(text.lang, default: ".")
}


// Config for the output format of numbers and units
// 
// The following options are available:
//  - decimal-separator (auto | str | content): Defaults to `auto`
//  - uncertainty-mode (str): Defaults to "plus-minus". Can also be "parentheses" or "conserve"
//  - unit-separator (content): Default to `h(0.2em)`
//  - per-mode (str): Defaults to "power". Can also be "fraction" or "slash"
//  - quantity-separator (content): Defaults to `h(0.2em)`
#let state-config = state("fancy-units-config", (
  "decimal-separator": auto,
  "uncertainty-mode": "plus-minus",
  "unit-separator": h(0.2em),
  "per-mode": "power",
  "quantity-separator": h(0.2em),
))

// Change the configuration of the package
// 
// - args (any): Named arguments to update the config
// 
// The `args` are used to update the current config state. Only the keys
// that appear in the `args` are actually changed in the state. It is not
// possible to delete keys from the state.
#let fancy-units-configure(..args) = {
  context { state-config.update(state-config.get() + args.named()) }
}


#let num(
  decimal-separator: auto,
  uncertainty-mode: auto,
  body
) = {
  let (number, tree) = interpret-number(body)

  context {
    let config = state-config.get()
    if decimal-separator != auto { config.decimal-separator = decimal-separator }
    if config.decimal-separator == auto { config.decimal-separator = get-decimal-separator() }
    if uncertainty-mode != auto { config.uncertainty-mode = uncertainty-mode }
    format-number(number, tree, config)
  }
}

#let unit(
  decimal-separator: auto,
  unit-separator: auto,
  per-mode: auto,
  body
) = {
  let bare-tree = unwrap-content(body)
  // wrap the "text" child to use the functions find-brackets() and group-brackets-children()
  if "text" in bare-tree.keys() { bare-tree = (children: (bare-tree,), layers: ()) }
  let tree = interpret-unit(bare-tree)

  context {
    let config = state-config.get()
    if decimal-separator != auto { config.decimal-separator = decimal-separator }
    if config.decimal-separator == auto { config.decimal-separator = get-decimal-separator() }
    if unit-separator != auto { config.unit-separator = unit-separator }
    let per-mode = if per-mode != auto { per-mode } else { config.per-mode }
    if per-mode == "power" { format-unit-power(tree, config) }
    else if per-mode == "fraction" { format-unit-fraction(tree, config) }
    else if per-mode == "slash" { format-unit-slash(tree, config) }
    else { panic("Unknown per-mode '" + per-mode + "'") }
  }
}

#let qty(
  decimal-separator: auto,
  uncertainty-mode: auto,
  unit-separator: auto,
  per-mode: auto,
  quantity-separator: auto,
  body-number,
  body-unit,
) = {
  num(
    decimal-separator: decimal-separator,
    uncertainty-mode: uncertainty-mode,
    body-number
  )

  context {
    if quantity-separator != auto { quantity-separator } else { state-config.get().quantity-separator }
  }

  unit(
    decimal-separator: decimal-separator,
    unit-separator: unit-separator,
    per-mode: per-mode,
    body-unit
  )
}