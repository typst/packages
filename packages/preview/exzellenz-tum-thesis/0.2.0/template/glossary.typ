// this is an example. Check https://typst.app/universe/package/glossarium

#let glossary = (
  (
    key: "tum",
    short: "TUM",
    long: "Technical University Munich",
  ),
  (
    key: "lmu",
    short: "LMU",
    long: "Ludwig-Maximilians-Universität München",
  ),
  (
    key: "ieee",
    short: "IEEE",
    long: "Institute of Electrical and Electronics Engineers",
  ),
  // Add a PLURAL form
  (
    key: "potato",
    short: "potato",
    // "plural" will be used when "short" should be pluralized
    plural: "potatoes",
  ),
  // Add a LONGPLURAL form
  (
    key: "dm",
    short: "DM",
    long: "diagonal matrix",
    // "longplural" will be used when "long" should be pluralized
    longplural: "diagonal matrices",
    description: "Probably some math stuff idk",
  ),
  // Add a CUSTOM entry
  (
    key: "c",
    short: $c$,
    description: "Speed of light in vacuum",
    // The custom key will be ignored by the default print-glossary function
    custom: (unit: $op("m s")^(-1)$),
  ),
)