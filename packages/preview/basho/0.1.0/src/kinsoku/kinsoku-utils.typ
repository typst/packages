// src/kinsoku.typ
// Japanese line-breaking rules (禁則処理)
//
// Exports:
//   - default-resolver(..)  — factory that returns a resolver dict with
//     all character sets + built-in resolve function
//   - Standalone helpers for custom resolvers

// ---------------------------------------------------------------------------
// Character-check helpers (reusable by custom resolvers)
// ---------------------------------------------------------------------------

/// Checks whether a token is a forbidden-start character (Gyoto / 行頭禁則).
/// Such characters must NOT appear at the start of a column.
#let is-forbidden-start(token, chars) = {
  if token == none { return false }
  if token.type != "char" { return false }
  chars.contains(token.text)
}

/// Checks whether a token is a forbidden-end character (Gyomatsu / 行末禁則).
/// Such characters must NOT appear at the end of a column.
#let is-forbidden-end(token, chars) = {
  if token == none { return false }
  if token.type != "char" { return false }
  chars.contains(token.text)
}

/// Checks whether a token is hanging-punctuation (burasagari / ぶら下がり).
/// Such characters can visually overflow into the gutter.
#let is-hanging(token, chars) = {
  if token == none { return false }
  if token.type != "char" { return false }
  chars.contains(token.text)
}

/// Checks whether two adjacent tokens form an unsplittable sequence
/// (Buntetsu Kinsoku / 分割禁則), e.g. consecutive dashes or ellipses: —— ……
#let is-unbreakable-pair(prev, current, chars) = {
  if prev == none or current == none { return false }
  if prev.type != "char" or current.type != "char" { return false }
  chars.contains(prev.text) and prev.text == current.text
}

/// Checks whether a token is eligible for spacing compression (Oikomi / 追い込み).
/// Yakumono (約物 / punctuation) typically has 0.5em of compressible space.
#let is-compressible-punctuation(token, chars) = {
  if token == none { return false }
  if token.type != "char" { return false }
  chars.contains(token.text)
}

// ---------------------------------------------------------------------------
// Computation helpers (reusable by custom resolvers)
// ---------------------------------------------------------------------------

/// Calculates the total amount of shrinkable space in a column.
/// Two-stage compression: first counts available internal-aki, then space-after.
#let calculate-shrinkable-space(col, config) = {
  let cb = config.char-box-abs
  let total = 0pt
  for token in col {
    let internal = token.at("internal-aki", default: 0.0) * cb
    let applied = token.at("compression-applied", default: 0pt)
    let available-internal = calc.max(0pt, internal - applied)
    total += available-internal + token.at("space-after", default: 0pt)
  }
  total
}

/// Distributes compression across tokens in the column in two stages:
/// 1. Compress internal-aki.
/// 2. If space is still needed, compress space-after.
#let apply-spacing-compression(col, amount, config) = {
  let cb = config.char-box-abs
  let remaining = amount
  let result = ()

  // Stage 1: Compress internal-aki
  let stage1 = ()
  for token in col {
    if remaining > 0pt {
      let internal = token.at("internal-aki", default: 0.0) * cb
      let applied = token.at("compression-applied", default: 0pt)
      let available = calc.max(0pt, internal - applied)
      if available > 0pt {
        let reduction = calc.min(available, remaining)
        token.insert("compression-applied", applied + reduction)
        remaining -= reduction
      }
    }
    stage1.push(token)
  }

  // Stage 2: Compress space-after
  for token in stage1 {
    if remaining > 0pt {
      let space = token.at("space-after", default: 0pt)
      if space > 0pt {
        let reduction = calc.min(space, remaining)
        token.insert("space-after", space - reduction)
        remaining -= reduction
      }
    }
    result.push(token)
  }

  result
}

/// Returns the compressible amount for a single token.
#let get-compressible-amount(token, config) = {
  if token == none { return 0pt }
  let cb = config.char-box-abs
  let internal = token.at("internal-aki", default: 0.0) * cb
  let applied = token.at("compression-applied", default: 0pt)
  let available = calc.max(0pt, internal - applied)
  available + token.at("space-after", default: 0pt)
}

/// Returns the number of justification points in the column.
#let count-justification-points(col) = {
  let count = 0
  for token in col {
    if token.at("justification-point", default: false) {
      count += 1
    }
  }
  count
}

/// Distributes available space across justification points.
#let justify-line(col, available-space, config) = {
  let count = count-justification-points(col)
  if count > 0 and available-space > 0pt {
    let add = available-space / count
    let max-stretch = config.kinsoku.at("max-stretch", default: none)
    if max-stretch != none {
      add = calc.min(add, max-stretch * config.at("char-box-abs", default: 1em))
    }
    let result = ()
    for token in col {
      if token.at("justification-point", default: false) {
        token.insert("space-after", token.at("space-after", default: 0pt) + add)
      }
      result.push(token)
    }
    return result
  }
  col
}

/// Checks whether a token is valid at the end of a column.
/// Returns false for null tokens and forbidden-end characters.
#let is-valid-line-end(token, forbidden-end-chars) = {
  if token == none { return false }
  if token.type != "char" { return true }
  not forbidden-end-chars.contains(token.text)
}

// ---------------------------------------------------------------------------
