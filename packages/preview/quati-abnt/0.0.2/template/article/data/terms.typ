// # Terms. Termos.

#import "../packages.typ": quati-abnt.common.util.foreign_text, quati-abnt.common.util.get_term as quati_abnt_get_term

#let terms_entries = (
  (
    key: "link",
    short: foreign_text[link],
    plural: foreign_text[links],
  ),
  (
    key: "script",
    short: foreign_text[script],
    plural: foreign_text[scripts],
  ),
  (
    key: "software",
    short: foreign_text[software],
  ),
  (
    key: "web",
    short: foreign_text[web],
  ),
)

#let get_term = (
  capitalize: false,
  field: "short",
  plural: false,
  term_key,
) => {
  quati_abnt_get_term(
    capitalize: capitalize,
    field: field,
    plural: plural,
    terms_entries: terms_entries,
    term_key,
  )
}
