// src/kinsoku/kinsoku-builtin.typ
#import "kinsoku-utils.typ": *

// Built-in resolve function
// Implements the priority-based resolution from the kinsoku spec:
//   1. Unbreakable sequences     → push-previous
//   2. Forbidden-start (Gyoto):
//      a. Hanging (burasagari)   → burasagari
//      b. Compressible (oikomi)  → oikomi(amount)
//      c. Otherwise              → push-previous
//   3. Forbidden-end (Gyomatsu)  → push-previous
//   4. Default                   → oidashi
// ---------------------------------------------------------------------------

#let builtin-resolve(col, token, h, config, cur-h, max-h) = {
  let k = config.kinsoku
  let last = if col.len() > 0 { col.last() } else { none }

  // Priority 0: Unbreakable pairs (Buntetsu Kinsoku)
  if (
    k.at("buntetsu-kinsoku", default: true)
      and is-unbreakable-pair(last, token, k.unbreakable-chars)
  ) {
    return (action: "push-previous")
  }

  // Priority 1–3: Forbidden-start (Gyoto Kinsoku)
  if is-forbidden-start(token, k.forbidden-start) {
    let next-token = k.at("next-token", default: none)

    // Priority 1: Burasagari — hanging punctuation
    if is-hanging(token, k.hanging) and k.mode == "burasagari" {
      if is-forbidden-start(next-token, k.forbidden-start) {
        return (action: "push-previous")
      }
      return (action: "burasagari")
    }

    // Priority 2: Oikomi — spacing compression
    let shrinkable = calculate-shrinkable-space(col, config)
    let overflow = (cur-h + h) - max-h

    if k.mode == "oikomi" and shrinkable >= overflow {
      if is-forbidden-start(next-token, k.forbidden-start) {
        return (action: "push-previous")
      }
      return (action: "oikomi", compression-amount: overflow)
    }

    // Priority 3: Oidashi cascading into push-previous
    return (action: "push-previous")
  }

  // Check Gyomatsu Kinsoku (Forbidden End)
  if is-forbidden-end(last, k.forbidden-end) {
    return (action: "push-previous")
  }

  // Default: break normally
  (action: "oidashi")
}

// ---------------------------------------------------------------------------
