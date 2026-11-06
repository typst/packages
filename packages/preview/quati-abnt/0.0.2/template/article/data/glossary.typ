// # Glossary. Glossário.

#let abbreviations_entries = ()

#let glossary_entries = (
  (
    key: "abnt",
    short: "ABNT",
    long: "Associação Brasileira de Normas Técnicas",
    group: "Normatização",
  ),
  (
    key: "nbr",
    short: "NBR",
    plural: "NBRs",
    long: "Norma Brasileira",
    longplural: "Normas Brasileiras",
    group: "Normatização",
  ),
)

#let symbols_entries = ()


#let glossary_entries = (
  ..abbreviations_entries,
  ..glossary_entries,
  ..symbols_entries,
)
