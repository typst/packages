// src/kinsoku/kinsoku.typ
#import "kinsoku-utils.typ": *
#import "kinsoku-builtin.typ": builtin-resolve

// Default resolver factory
// Returns a complete kinsoku configuration dictionary.
// Users override any field by passing named arguments.
// The `resolve` function is the built-in algorithm; set `resolve` to replace
// it entirely while keeping helper access via imports.
// ---------------------------------------------------------------------------

#let default-resolver(
  forbidden-start: "）〕］｝〉》」』】)]}〞\u{201d}\u{2019}。、，．・：；ー～ぁぃぅぇぉっゃゅょゎァィゥェォッャュョヮヵヶ！？",
  forbidden-end: "（〔［｛〈《「『【([{〝\u{201c}\u{2018}",
  hanging: "、。，．",
  unbreakable-chars: "—―…‥",
  buntetsu-kinsoku: true,
  compressible-punctuation: "、。，．",
  mode: "burasagari",
  compression-per-punct: 0.5,
  consecutive-compression: 0.25,
  max-stretch: 0.5,
  resolve-fn: none,
) = {
  let rfn = if resolve-fn != none { resolve-fn } else { builtin-resolve }
  (
    forbidden-start: forbidden-start,
    forbidden-end: forbidden-end,
    hanging: hanging,
    unbreakable-chars: unbreakable-chars,
    buntetsu-kinsoku: buntetsu-kinsoku,
    compressible-punctuation: compressible-punctuation,
    mode: mode,
    compression-per-punct: compression-per-punct,
    consecutive-compression: consecutive-compression,
    max-stretch: max-stretch,
    resolve: rfn,
  )
}
