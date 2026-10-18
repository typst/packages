// helper/abbreviations.typ
// Smart abbreviation tracking with first-use expansion.
// IMPL-01: Uses state + query pattern from ptb-typst-template (verzeichnisse.typ)
//
// Two usage modes (api-design §3):
//   Mode 1 — Central dict in hwr(): abbreviations: ("KI": "Künstliche Intelligenz", ...)
//             Registered via setup-abbreviations(); use #abk("KI") in text.
//   Mode 2 — Inline definition: #abk("API", "Application Programming Interface")
//             Defines and tracks in one call; no central dict entry needed.
//
// First use  → "Künstliche Intelligenz (KI)"  (clickable link to Abkürzungsverzeichnis)
// Later uses → "KI"                            (clickable link)

// Global state: stores inline-defined abbreviations (Mode 2)
// Central-dict abbreviations are passed directly to abkuerzungsverzeichnis via render-indices.
#let _abk-dict = state("_abk-dict", (:))

/// Initialize central abbreviation dictionary.
/// Call once in hwr() with the abbreviations: parameter.
#let setup-abbreviations(dict) = {
  _abk-dict.update(old => old + dict)
}

/// Smart abbreviation reference.
///
/// - key: str — the abbreviation (e.g. "KI")
/// - long: str | none — full form for inline definition (Mode 2); omit if key is in central dict
///
/// First call expands: "Künstliche Intelligenz (KI)"
/// Subsequent calls: "KI"
/// Always creates a clickable link to the entry in Abkürzungsverzeichnis.
#let abk(key, long: none) = context {
  // If a long form is provided inline, register it in the state
  if long != none {
    _abk-dict.update(d => {
      if key not in d { d.insert(key, long) }
      d
    })
  }

  let d = _abk-dict.get()
  let full = if long != none { long } else { d.at(key, default: none) }

  // Fail early with a clear message when the key is not defined anywhere.
  // (A missing key causes a cryptic label-not-found error at link time otherwise.)
  if full == none {
    panic("abk(\"" + key + "\"): abbreviation not defined. " +
          "Either add it to the abbreviations: dict in hwr() or use " +
          "abk(\"" + key + "\", long: \"...\") on first use.")
  }

  // Check prior uses of this key before the current position
  let past-uses = query(selector(<abk>).before(here())).filter(n => n.value == key)
  let is-first = past-uses.len() == 0

  let display = if is-first {
    full + " (" + key + ")"
  } else {
    key
  }

  // Emit invisible metadata label for query + tracking
  [#metadata(key) <abk>]
  // Clickable link to abbreviation list entry
  link(label("abk-list-" + key))[#display]
}
