// citrus - Punctuation Collapsing
//
// Implements CSL punctuation collapsing rules based on citeproc-js LtoR_MAP.

/// Apply CSL punctuation collapsing to content
///
/// Based on citeproc-js LtoR_MAP logic. The map defines what happens when
/// two punctuation marks are adjacent (left + right → result).
///
/// Absorption rules (from citeproc-js):
/// - "!" absorbs "." and ":"    → !. → !,  !: → !
/// - "?" absorbs "." and ":"    → ?. → ?,  ?: → ?
/// - ":" absorbs "."            → :. → :
/// - ":" absorbed by "!" "?"    → :! → !,  :? → ?
/// - ";" absorbs "." and ":"    → ;. → ;,  ;: → ;
/// - ";" absorbed by "!" "?"    → ;! → !,  ;? → ?
/// - "," absorbs "."            → ,. → ,
///
/// All other combinations keep both characters.
///
/// This wrapper limits the show rules to CSL output only.
#let collapse-punctuation(content) = {
  // Rule 1: Duplicate punctuation collapses (keeps first character)
  show regex("[.。]{2,}"): it => it.text.first()
  show regex("[,，、]{2,}"): it => it.text.first()
  show regex("[;；]{2,}"): it => it.text.first()
  show regex("[:：]{2,}"): it => it.text.first()
  show regex("[!！]{2,}"): it => it.text.first()
  show regex("[?？]{2,}"): it => it.text.first()

  // Rule 2: Absorption rules from citeproc-js LtoR_MAP
  // Helper to get the "stronger" punctuation
  let get-absorbed(text, absorbers) = {
    let chars = text.clusters()
    chars.find(c => c in absorbers)
  }

  // "!" absorbs "." and ":"
  show regex("[!！][.。]"): it => it.text.first()
  show regex("[!！][:：]"): it => it.text.first()

  // "?" absorbs "." and ":"
  show regex("[?？][.。]"): it => it.text.first()
  show regex("[?？][:：]"): it => it.text.first()

  // ":" absorbs "." only
  show regex("[:：][.。]"): it => it.text.first()

  // ":" is absorbed by "!" and "?"
  show regex("[:：][!！]"): it => it.text.clusters().last()
  show regex("[:：][?？]"): it => it.text.clusters().last()

  // ";" absorbs "." and ":"
  show regex("[;；][.。]"): it => it.text.first()
  show regex("[;；][:：]"): it => it.text.first()

  // ";" is absorbed by "!" and "?"
  show regex("[;；][!！]"): it => it.text.clusters().last()
  show regex("[;；][?？]"): it => it.text.clusters().last()

  // "," absorbs "."
  show regex("[,，、][.。]"): it => it.text.first()

  content
}
