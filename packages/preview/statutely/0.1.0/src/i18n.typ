// Language strings. Add a language by adding a key with the same fields.
#let strings = (
  da: (statutes-of: "Vedtægter for", last-updated: "Senest opdateret", stk: "Stk. {n}."),
  en: (statutes-of: "Statutes of", last-updated: "Last updated", stk: "({n})"),
)

// Raw lookup; call only inside `context`. Falls back to English.
#let lookup(key) = strings.at(if text.lang in strings { text.lang } else { "en" }).at(key)
#let tr(key) = context lookup(key)
