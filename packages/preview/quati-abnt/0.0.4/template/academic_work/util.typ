// # Util. Utilitários

#import "data/terms.typ": terms_entries
#import "./packages.typ": (
  quati-abnt.common.style, quati-abnt.common.util.foreign_text, quati-abnt.common.util.get_term as quati_abnt_get_term,
)

#let get_term = (
  capitalize: false,
  field: "short",
  plural: false,
  term_key,
) => {
  quati_abnt_get_term(
    capitalize: false,
    field: "short",
    plural: false,
    terms_entries: terms_entries,
    term_key,
  )
}
