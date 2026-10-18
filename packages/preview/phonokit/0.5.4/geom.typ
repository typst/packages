// Feature-Geometry Module
// Draws hierarchical feature-geometry trees (consonants and vocoids).

#import "@preview/cetz:0.4.2"
#import "features.typ": feat
#import "ipa.typ": ipa-to-unicode
#import "_config.typ": phonokit-font

// ── Layout constants ────────────────────────────────────────────────────────
// Two gap sizes: tight for all-leaf sibling groups (e.g. spread/constricted),
// normal for mixed groups that contain internal nodes (e.g. voice/C-place).
#let _leaf-h-gap = 0.45  // gap between siblings when every sibling is a leaf
#let _h-gap = 0.18  // gap between siblings in mixed groups
#let _root-h-gap = 0.60  // gap between root's direct children (laryngeal / nasal / oral cavity)
#let _leaf-w = 0.55  // minimum width of a leaf node (canvas units)
#let _v-gap = 0.90  // vertical gap between levels (internal nodes)
#let _mixed-leaf-vg = 0.65  // vertical gap for leaf children that have non-leaf siblings
#let _mixed-nonleaf-vg = 1.25  // vertical gap for non-leaf in a mixed group (e.g. C-place under oral cavity)
#let _stagger-dy = 0.38  // extra downward step per sibling in an all-leaf group
#let _ml-stagger-dy = 0.70  // step for 2nd+ leading leaves before a non-leaf (e.g. [cont] before C-place)
#let _nonleaf-stagger-dy = 0.38  // extra downward step per sibling in an all-non-leaf group
// ── Label abbreviations ──────────────────────────────────────────────────────
// Maps bare argument names → short display/anchor forms.
#let _abbrev = (
  "constricted": "constr",
  "continuant": "cont",
  "distributed": "distr",
  "dorsal": "dor",
  "coronal": "cor",
  "labial": "lab",
  "anterior": "ant",
  "radical": "rad",
  "high": "hi",
)
#let _short(lbl) = _abbrev.at(lbl, default: lbl)

// Split a label into (sign, bare-base).  "+anterior" → ("+", "anterior").
// "−" is U+2212 (3 UTF-8 bytes); check with starts-with, slice by byte length.
#let _sign-base(lbl) = {
  if lbl.starts-with("+") { ("+", lbl.slice(1)) } else if lbl.starts-with("−") { ("−", lbl.slice("−".len())) } else {
    ("", lbl)
  }
}

// Display form: preserve sign, abbreviate bare base.
// "+anterior" → "+ant",  "−voice" → "−voice",  "coronal" → "cor"
#let _display(lbl) = {
  let (sign, base) = _sign-base(lbl)
  sign + _short(base)
}

// Normalize a place-feature string from an array argument.
// Converts ASCII "-" prefix → "−" (U+2212) to match the sign convention.
// e.g. "-back" → "−back", "+high" → "+high", "round" → "round"
#let _norm-feat(f) = if f.starts-with("-") { "−" + f.slice(1) } else { f }

// ── Node constructors ───────────────────────────────────────────────────────
#let _n(lbl, kind, ch) = (label: lbl, kind: kind, children: ch)
#let _feat(lbl, ch: ()) = _n(lbl, "feature", ch)
#let _class(lbl, ch) = _n(lbl, "class", ch)

// ── All-leaf predicate ──────────────────────────────────────────────────────
// True when every child of `node` is a terminal leaf (no grandchildren).
// These groups use _leaf-h-gap for tighter packing.
#let _all-leaves(node) = {
  node.children.len() > 0 and node.children.all(c => c.children.len() == 0)
}

// ── All-non-leaf predicate ──────────────────────────────────────────────────
// True when every child of `node` is an internal node (has its own children).
// e.g. vocalic → [V-place, aperture]. These groups stagger vertically to
// avoid horizontal label collisions between wide class-node names.
#let _all-nonleaves(node) = {
  node.children.len() > 0 and node.children.all(c => c.children.len() > 0)
}

// ── Recursive subtree width ─────────────────────────────────────────────────
#let _tree-w(node) = {
  if node.children.len() == 0 { return _leaf-w }
  let gap = if _all-leaves(node) { _leaf-h-gap } else if node.kind == "root" { _root-h-gap } else { _h-gap }
  let cw = node.children.map(c => _tree-w(c))
  calc.max(cw.sum() + (node.children.len() - 1) * gap, _leaf-w)
}

// ── Recursive layout → flat list of positioned entries ──────────────────────
// Returns array of (label, kind, feats, x, y, par) dictionaries.
#let _layout(node, x0, y, par) = {
  let w = _tree-w(node)
  let my-x = x0 + w / 2
  let me = ((label: node.label, kind: node.kind, feats: node.at("features", default: ()), x: my-x, y: y, par: par),)
  let gap = if _all-leaves(node) { _leaf-h-gap } else if node.kind == "root" { _root-h-gap } else { _h-gap }
  // Count consecutive leading leaves (leaves before the first non-leaf child).
  let n-leading = {
    let count = 0
    for c in node.children {
      if c.children.len() == 0 { count = count + 1 } else { break }
    }
    count
  }
  let cx = x0
  let out = me
  for (i, child) in node.children.enumerate() {
    let cw = _tree-w(child)
    let all-prev-leaves = node.children.slice(0, i).all(c => c.children.len() == 0)
    // Leaf children are staggered vertically by their rank among leaf siblings.
    // Non-leaf children (e.g. C-place) always stay at the standard level.
    let child-y = if child.children.len() == 0 {
      let leaf-rank = node.children.slice(0, i).filter(c => c.children.len() == 0).len()
      // "Leading" leaves: all siblings before this one are also leaves.
      //   • n-leading == 1: single leaf before a non-leaf (e.g. [nasal] before oral
      //     cavity) — use _mixed-leaf-vg for vertical position.
      //   • n-leading >= 2: multiple leaves (e.g. voice/continuant before C-place) —
      //     use _mixed-leaf-vg so the stagger distributes them around the non-leaf level.
      // "Sandwiched" leaves: a non-leaf precedes this leaf → push below non-leaf level.
      let base = if _all-leaves(node) { _v-gap } else if all-prev-leaves { _mixed-leaf-vg } else {
        _v-gap + _stagger-dy * 0.3
      }
      let step = if all-prev-leaves and not _all-leaves(node) { _ml-stagger-dy } else { _stagger-dy }
      y - base - leaf-rank * step
    } else {
      // Non-leaf child: stagger vertically when all siblings are also non-leaves
      // AND the parent is not the root node.  Root's direct children (laryngeal,
      // oral cavity) must stay at the same tier by convention.  Deeper all-non-leaf
      // groups (e.g. V-place + aperture under vocalic) do get staggered.
      if _all-nonleaves(node) and node.kind != "root" {
        y - _v-gap - i * _nonleaf-stagger-dy
      } else if not _all-leaves(node) and not _all-nonleaves(node) {
        y - _mixed-nonleaf-vg // mixed group: non-leaf drops further (e.g. C-place)
      } else {
        y - _v-gap
      }
    }
    // Single leading leaf: shift further left so the line from the parent is
    // more diagonal rather than nearly vertical next to the root label.
    let cx-adj = if (
      child.children.len() == 0 and all-prev-leaves and not _all-leaves(node) and n-leading == 1
    ) { -0.40 } else { 0 }
    out = out + _layout(child, cx + cx-adj, child-y, (my-x, y))
    cx = cx + cw + gap
  }
  out
}

// ── Segment presets (Clements & Hume 1995) ──────────────────────────────────
// Pre-built spec dicts for common segments. Used by the `ph` parameter in
// geom() and as a `ph` key in geom-group spec dicts, e.g. (ph: "a").
// Height is encoded by aperture (no features = high), front/back by V-place.
#let _presets = (
  // NOTE: The most common vowels:
  "i": (
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    coronal: true,
    aperture: ("-", "-", "-"),
    segment: "i",
  ),
  "e": (
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    coronal: true,
    aperture: ("-", "+", "-"),
    segment: "e",
  ),
  "E": (
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    coronal: true,
    aperture: ("-", "+", "+"),
    segment: "E",
  ),
  "a": (root: ("+son", "+approx", "+vocoid"), vocalic: true, aperture: ("+", "+", "+"), segment: "a"),
  "o": (
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    labial: true,
    dorsal: true,
    aperture: ("-", "+", "-"),
    segment: "o",
  ),
  "O": (
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    labial: true,
    dorsal: true,
    aperture: ("-", "+", "+"),
    segment: "O",
  ),
  "u": (
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    labial: true,
    dorsal: true,
    aperture: ("-", "-", "-"),
    segment: "u",
  ),
  "I": (
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    coronal: true,
    tense: "-",
    aperture: ("-", "-", "-"),
    segment: "I",
  ),
  "U": (
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    labial: true,
    dorsal: true,
    tense: "-",
    aperture: ("-", "-", "-"),
    segment: "U",
  ),
  // Additional vowels — high confidence:
  "y": (
    // ø̈ close front rounded
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    coronal: true,
    labial: true,
    aperture: ("-", "-", "-"),
    segment: "y",
  ),
  "W": (
    // ɯ close back unrounded
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    dorsal: true,
    aperture: ("-", "-", "-"),
    segment: "W",
  ),
  "7": (
    // ɤ close-mid back unrounded
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    tense: "+",
    dorsal: true,
    aperture: ("-", "+", "-"),
    segment: "7",
  ),
  "\\o": (
    // ø close-mid front rounded
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    tense: "+",
    coronal: true,
    labial: true,
    aperture: ("-", "+", "-"),
    segment: "\\o",
  ),
  "\\oe": (
    // œ open-mid front rounded
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    tense: "-",
    coronal: true,
    labial: true,
    aperture: ("-", "+", "+"),
    segment: "\\oe",
  ),
  "2": (
    // ʌ open-mid back unrounded
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    tense: "-",
    dorsal: true,
    aperture: ("-", "+", "+"),
    segment: "2",
  ),
  "A": (
    // ɑ open back unrounded
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    dorsal: true,
    aperture: ("+", "+", "+"),
    segment: "A",
  ),
  "6": (
    // ɒ open back rounded
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    labial: true,
    dorsal: true,
    aperture: ("+", "+", "+"),
    segment: "6",
  ),
  // Flagged vowels — central/near-open: place analysis is theory-dependent.
  "@": (
    // ə mid central — placeless in CH (no V-place node), aperture ("-","+","-")
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    aperture: ("-", "+", "-"),
    segment: "@",
  ),
  "1": (
    // ɨ close central unrounded — placeless in CH
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    aperture: ("-", "-", "-"),
    segment: "1",
  ),
  "0": (
    // ʉ close central rounded — labial only, no dorsal/coronal V-place
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    labial: true,
    aperture: ("-", "-", "-"),
    segment: "0",
  ),
  "\\ae": (
    // æ near-open front — aperture approximated as open-mid ("-","+","+"); same as /ɛ/ in CH
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    coronal: true,
    aperture: ("-", "+", "+"),
    segment: "\\ae",
  ),
  // NOTE: Some consonants:
  "p": (
    root: ("-son", "-approx", "-vocoid"),
    vocalic: false,
    labial: true,
    voice: "-",
    segment: "p",
    continuant: "-",
  ),
  "b": (
    root: ("-son", "-approx", "-vocoid"),
    vocalic: false,
    labial: true,
    voice: "+",
    segment: "b",
    continuant: "-",
  ),
  "t": (root: ("-son", "-approx", "-vocoid"), coronal: true, anterior: "+", voice: "-", continuant: "-", segment: "t"),
  "d": (root: ("-son", "-approx", "-vocoid"), coronal: true, anterior: "+", voice: "+", continuant: "-", segment: "d"),
  "k": (
    root: ("-son", "-approx", "-vocoid"),
    vocalic: false,
    dorsal: true,
    voice: "-",
    segment: "k",
    continuant: "-",
  ),
  "g": (
    root: ("-son", "-approx", "-vocoid"),
    vocalic: false,
    dorsal: true,
    voice: "+",
    segment: "g",
    continuant: "-",
  ),
  "f": (
    root: ("-son", "-approx", "-vocoid"),
    vocalic: false,
    labial: true,
    voice: "-",
    segment: "f",
    continuant: "+",
  ),
  "v": (
    root: ("-son", "-approx", "-vocoid"),
    vocalic: false,
    labial: true,
    voice: "+",
    segment: "v",
    continuant: "+",
  ),
  "s": (root: ("-son", "-approx", "-vocoid"), coronal: true, anterior: "+", voice: "-", continuant: "+", segment: "s"),
  "z": (root: ("-son", "-approx", "-vocoid"), coronal: true, anterior: "+", voice: "+", continuant: "+", segment: "z"),
  // ʃ/ʒ: coronal [-anterior], NOT dorsal
  "S": (root: ("-son", "-approx", "-vocoid"), coronal: true, anterior: "-", voice: "-", continuant: "+", segment: "S"),
  "Z": (root: ("-son", "-approx", "-vocoid"), coronal: true, anterior: "-", voice: "+", continuant: "+", segment: "Z"),
  // Affricates — [-continuant] following standard SPE/Kenstowicz analysis
  "ts": (
    root: ("-son", "-approx", "-vocoid"),
    coronal: true,
    anterior: "+",
    voice: "-",
    continuant: ("-", "+"),
    segment: "ts",
  ),
  "dz": (
    root: ("-son", "-approx", "-vocoid"),
    coronal: true,
    anterior: "+",
    voice: "+",
    continuant: ("-", "+"),
    segment: "dz",
  ),
  "tS": (
    root: ("-son", "-approx", "-vocoid"),
    coronal: true,
    anterior: "-",
    voice: "-",
    continuant: ("-", "+"),
    segment: "tS",
  ),
  "dZ": (
    root: ("-son", "-approx", "-vocoid"),
    coronal: true,
    anterior: "-",
    voice: "+",
    continuant: ("-", "+"),
    segment: "dZ",
  ),
  "n": (
    root: ("+son", "-approx", "-vocoid"),
    vocalic: false,
    nasal: true,
    coronal: true,
    voice: "+",
    segment: "n",
    continuant: "-",
  ),
  "m": (
    root: ("+son", "-approx", "-vocoid"),
    vocalic: false,
    nasal: true,
    labial: true,
    voice: "+",
    segment: "m",
    continuant: "-",
  ),
  "N": (
    root: ("+son", "-approx", "-vocoid"),
    vocalic: false,
    nasal: true,
    dorsal: true,
    voice: "+",
    segment: "N",
    continuant: "-",
  ),
  // ɲ: palatal nasal = coronal [-anterior]
  "\\N": (root: ("+son", "-approx", "-vocoid"), coronal: true, anterior: "-", nasal: "+", segment: "\\N"),
  // Additional consonants — high confidence:
  "j": (root: ("+son", "+approx", "-vocoid"), dorsal: true, continuant: "+", segment: "j"), // j palatal approximant
  "h": (root: ("-son", "-approx", "-vocoid"), spread: true, continuant: "+", segment: "h"), // h glottal fricative
  "?": (root: ("-son", "-approx", "-vocoid"), constricted: true, continuant: "-", segment: "?"), // ʔ glottal stop
  "T": (
    root: ("-son", "-approx", "-vocoid"),
    coronal: true,
    anterior: "+",
    distributed: true,
    voice: "-",
    continuant: "+",
    segment: "T",
  ), // θ voiceless dental fricative
  "D": (
    root: ("-son", "-approx", "-vocoid"),
    coronal: true,
    anterior: "+",
    distributed: true,
    voice: "+",
    continuant: "+",
    segment: "D",
  ), // ð voiced dental fricative
  "x": (root: ("-son", "-approx", "-vocoid"), dorsal: true, voice: "-", continuant: "+", segment: "x"), // x voiceless velar fricative
  "G": (root: ("-son", "-approx", "-vocoid"), dorsal: true, voice: "+", continuant: "+", segment: "G"), // ɣ voiced velar fricative
  "F": (root: ("-son", "-approx", "-vocoid"), labial: true, voice: "-", continuant: "+", segment: "F"), // ɸ voiceless bilabial fricative
  "B": (root: ("-son", "-approx", "-vocoid"), labial: true, voice: "+", continuant: "+", segment: "B"), // β voiced bilabial fricative
  "V": (root: ("+son", "+approx", "-vocoid"), labial: true, continuant: "+", segment: "V"), // ʋ labiodental approximant
  "M": (root: ("+son", "-approx", "-vocoid"), labial: true, nasal: true, voice: "+", continuant: "-", segment: "M"), // ɱ labiodental nasal
  "\\:t": (
    root: ("-son", "-approx", "-vocoid"),
    coronal: true,
    anterior: "-",
    distributed: true,
    voice: "-",
    continuant: "-",
    segment: "\\:t",
  ), // ʈ retroflex stop (vl)
  "\\:d": (
    root: ("-son", "-approx", "-vocoid"),
    coronal: true,
    anterior: "-",
    distributed: true,
    voice: "+",
    continuant: "-",
    segment: "\\:d",
  ), // ɖ retroflex stop (vd)
  "\\:s": (
    root: ("-son", "-approx", "-vocoid"),
    coronal: true,
    anterior: "-",
    distributed: true,
    voice: "-",
    continuant: "+",
    segment: "\\:s",
  ), // ʂ retroflex fricative (vl)
  "\\:z": (
    root: ("-son", "-approx", "-vocoid"),
    coronal: true,
    anterior: "-",
    distributed: true,
    voice: "+",
    continuant: "+",
    segment: "\\:z",
  ), // ʐ retroflex fricative (vd)
  "\\:n": (
    root: ("+son", "-approx", "-vocoid"),
    coronal: true,
    anterior: "-",
    distributed: true,
    nasal: "+",
    voice: "+",
    continuant: "-",
    segment: "\\:n",
  ), // ɳ retroflex nasal
  // Flagged consonants — place analysis is theory-dependent:
  "r": (root: ("+son", "-approx", "-vocoid"), coronal: true, anterior: "+", voice: "+", continuant: "-", segment: "r"), // r alveolar trill — [-cont] following Kenstowicz (1994)
  "l": (root: ("+son", "+approx", "-vocoid"), coronal: true, anterior: "+", voice: "+", continuant: "+", segment: "l"), // l alveolar lateral — NOTE: lateral feature not modelled
  "J": (root: ("-son", "-approx", "-vocoid"), dorsal: true, voice: "+", continuant: "+", segment: "J"), // ʝ voiced palatal fricative — NOTE: coronal vs. dorsal analysis contested; dorsal used here
  "C": (root: ("-son", "-approx", "-vocoid"), coronal: true, anterior: "-", voice: "-", continuant: "+", segment: "C"), // ç voiceless palatal fricative — NOTE: strident not modelled (cf. /ʃ/)
  // archiphoneme /T/: any stop — no place, no voice specified
  "\\T": (root: ("-son", "-approx", "-vocoid"), continuant: "-", segment: "\\T"),
  "\\C": (root: ("±son", "±approx", "-vocoid"), segment: "\\C"),
  "\\V": (root: ("+son", "+approx", "+vocoid"), segment: "\\V"),
)

// ── Segment presets (Sagey 1986) ─────────────────────────────────────────────
// Vowels only — consonant presets are identical in both models.
// Height/backness encoded as dorsal sub-features; roundness as labial: ("round",).
// No aperture node. Note: [e]/[ɛ] and [o]/[ɔ] share the same basic features
// in Sagey (ATR/tense distinguishes them, which is not modelled here).
#let _presets-sagey = (
  "i": (
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    dorsal: ("+high", "-back"),
    segment: "i",
  ),
  "e": (
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    tense: "+",
    dorsal: ("-high", "-back"),
    segment: "e",
  ),
  "E": (
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    tense: "-",
    dorsal: ("-high", "-back"),
    segment: "E",
  ),
  "a": (
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    dorsal: ("-high", "+lo"),
    segment: "a",
  ),
  "o": (
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    tense: "+",
    labial: ("round",),
    dorsal: ("-high", "+back"),
    segment: "o",
  ),
  "O": (
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    tense: "-",
    labial: ("round",),
    dorsal: ("-high", "+back"),
    segment: "O",
  ),
  "u": (
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    labial: ("round",),
    dorsal: ("+high", "+back"),
    segment: "u",
  ),
  "I": (
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    tense: "-",
    dorsal: ("+high", "-back"),
    segment: "I",
  ),
  "U": (
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    tense: "-",
    labial: ("round",),
    dorsal: ("+high", "+back"),
    segment: "U",
  ),
  // Additional vowels — high confidence:
  "y": (
    // y close front rounded
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    labial: ("round",),
    dorsal: ("+high", "-back"),
    segment: "y",
  ),
  "W": (
    // ɯ close back unrounded
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    dorsal: ("+high", "+back"),
    segment: "W",
  ),
  "7": (
    // ɤ close-mid back unrounded
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    tense: "+",
    dorsal: ("-high", "+back"),
    segment: "7",
  ),
  "\\o": (
    // ø close-mid front rounded
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    tense: "+",
    labial: ("round",),
    dorsal: ("-high", "-back"),
    segment: "\\o",
  ),
  "\\oe": (
    // œ open-mid front rounded
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    tense: "-",
    labial: ("round",),
    dorsal: ("-high", "-back"),
    segment: "\\oe",
  ),
  "2": (
    // ʌ open-mid back unrounded
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    tense: "-",
    dorsal: ("-high", "+back"),
    segment: "2",
  ),
  "A": (
    // ɑ open back unrounded
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    dorsal: ("-high", "+lo", "+back"),
    segment: "A",
  ),
  "6": (
    // ɒ open back rounded
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    labial: ("round",),
    dorsal: ("-high", "+lo", "+back"),
    segment: "6",
  ),
  // Flagged vowels — central/near-open: place analysis is theory-dependent.
  "@": (
    // ə mid central — dorsal [-hi] only; back unspecified
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    dorsal: ("-high",),
    segment: "@",
  ),
  "1": (
    // ɨ close central unrounded — dorsal [+hi], no back value
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    dorsal: ("+high",),
    segment: "1",
  ),
  "0": (
    // ʉ close central rounded — [+hi] + labial, no back value
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    labial: ("round",),
    dorsal: ("+high",),
    segment: "0",
  ),
  "\\ae": (
    // æ near-open front — [-hi, +lo, -back]; +lo distinguishes from /ɛ/ (-hi, -back)
    root: ("+son", "+approx", "+vocoid"),
    vocalic: true,
    vplace: true,
    dorsal: ("-high", "+lo", "-back"),
    segment: "\\ae",
  ),
)

// ── Build tree from spec dict ────────────────────────────────────────────────
// Accepts a dict with the same keys as geom() (all optional, same defaults).
// Returns (tree: root-node-dict, is-vocoid: bool).
#let _build-tree(spec) = {
  let root = spec.at("root", default: ())
  let laryngeal = spec.at("laryngeal", default: false)
  let nasal = spec.at("nasal", default: false)
  let spread = spec.at("spread", default: false)
  let constricted = spec.at("constricted", default: false)
  let voice = spec.at("voice", default: false)
  let continuant = spec.at("continuant", default: false)
  let labial = spec.at("labial", default: false)
  let coronal = spec.at("coronal", default: false)
  let anterior = spec.at("anterior", default: false)
  let distributed = spec.at("distributed", default: false)
  let dorsal = spec.at("dorsal", default: false)
  let vocalic = spec.at("vocalic", default: false)
  let vplace = spec.at("vplace", default: false)
  let aperture = spec.at("aperture", default: false)

  // Normalize root to array
  let root-feats = if type(root) == str { (root,) } else { root }

  // Auto-inference: show parent when any child is active
  let radical = spec.at("radical", default: false)

  let laryngeal = laryngeal or spread or constricted or voice != false
  // coronal may be bool or array; treat array as "active"
  let coronal = if type(coronal) == array { coronal } else if coronal or (anterior != false) or distributed {
    true
  } else { false }
  let tense = spec.at("tense", default: false)

  // aperture is active when: true, or a non-empty array with at least one active element
  let aperture-active = if type(aperture) == array {
    aperture.any(v => v != false)
  } else { aperture != false }
  let vocalic = vocalic or vplace or aperture-active or (tense != false)
  // If already in vocoid mode and place features are supplied, vplace is implied.
  // labial/coronal/dorsal/radical may now be arrays (truthy) — != false covers all.
  let place-active = (labial != false) or (coronal != false) or (dorsal != false) or (radical != false)
  let vplace = vplace or (vocalic and place-active)
  let vocalic = vocalic or vplace or aperture-active
  let show-cplace = place-active or vocalic

  // [nasal] label
  let nasal-lbl = if nasal == true { "nasal" } else if nasal == "+" { "+nasal" } else if nasal == "-" {
    "−nasal"
  } else { none }

  // [continuant] labels — accepts a single value or an array of up to 2 (affricates).
  let _cont-lbl(v) = if v == true { "continuant" } else if v == "+" { "+continuant" } else if v == "-" {
    "−continuant"
  } else { none }
  let continuant-lbls = if type(continuant) == array {
    continuant.slice(0, calc.min(continuant.len(), 2)).map(_cont-lbl).filter(l => l != none)
  } else {
    let l = _cont-lbl(continuant)
    if l != none { (l,) } else { () }
  }

  // [voice] label
  let voice-lbl = if voice == true { "voice" } else if voice == "+" { "+voice" } else if voice == "-" {
    "−voice"
  } else { none }

  // [anterior] label
  let ant-lbl = if anterior == true { "anterior" } else if anterior == "+" { "+anterior" } else if anterior == "-" {
    "−anterior"
  } else { none }

  // [coronal] subtree — used when coronal is bool (existing anterior/distributed params)
  let cor-ch-default = ()
  if ant-lbl != none { cor-ch-default = cor-ch-default + (_feat(ant-lbl),) }
  if distributed { cor-ch-default = cor-ch-default + (_feat("distributed"),) }

  // Place features (shared by consonant and vocoid branches).
  // Each of labial/coronal/dorsal/radical may be:
  //   false   → node absent
  //   true    → node shown, no sub-features (bool mode)
  //   array   → node shown with sub-feature children from the array
  //             (e.g. dorsal: ("+high", "-back"), labial: ("round",))
  //             Array mode for coronal replaces the anterior/distributed params.
  let place-ch = ()
  if labial != false {
    let ch = if type(labial) == array { labial.map(f => _feat(_norm-feat(f))) } else { () }
    place-ch = place-ch + (_feat("labial", ch: ch),)
  }
  if coronal != false {
    let ch = if type(coronal) == array { coronal.map(f => _feat(_norm-feat(f))) } else { cor-ch-default }
    place-ch = place-ch + (_feat("coronal", ch: ch),)
  }
  if radical != false { place-ch = place-ch + (_feat("radical"),) }
  if dorsal != false {
    let ch = if type(dorsal) == array { dorsal.map(f => _feat(_norm-feat(f))) } else { () }
    place-ch = place-ch + (_feat("dorsal", ch: ch),)
  }

  // [tense] label
  let tense-lbl = if tense == true { "tense" } else if tense == "+" { "+tense" } else if tense == "-" {
    "−tense"
  } else { none }

  // Vocoid branch
  let voc-ch = ()
  if tense-lbl != none { voc-ch = voc-ch + (_feat(tense-lbl),) }
  if vplace {
    voc-ch = voc-ch + (_class("V-place", place-ch),)
  }
  if aperture-active {
    let ap-ch = if type(aperture) == array {
      let names = ("open1", "open2", "open3")
      let result = ()
      for (i, v) in aperture.slice(0, calc.min(aperture.len(), 3)).enumerate() {
        let lbl = if v == true { names.at(i) } else if v == "+" { "+" + names.at(i) } else if v == "-" {
          "−" + names.at(i)
        } else { none }
        if lbl != none { result = result + (_feat(lbl),) }
      }
      result
    } else { () }
    voc-ch = voc-ch + (_class("aperture", ap-ch),)
  }

  // C-place children
  let cplace-ch = if vocalic { (_class("vocalic", voc-ch),) } else { place-ch }

  // Auto-inference: != false covers true, "+", "-"
  let show-oc = continuant-lbls.len() > 0 or show-cplace

  // Oral cavity children
  let oc-ch = continuant-lbls.map(_feat)
  if show-cplace { oc-ch = oc-ch + (_class("C-place", cplace-ch),) }

  // Laryngeal children — [voice] is under laryngeal (Clements & Hume 1995)
  let laryng-ch = ()
  if voice-lbl != none { laryng-ch = laryng-ch + (_feat(voice-lbl),) }
  if spread { laryng-ch = laryng-ch + (_feat("spread"),) }
  if constricted { laryng-ch = laryng-ch + (_feat("constricted"),) }

  // Root children
  let root-ch = ()
  if laryngeal { root-ch = root-ch + (_class("laryngeal", laryng-ch),) }
  if nasal-lbl != none { root-ch = root-ch + (_feat(nasal-lbl),) }
  if show-oc { root-ch = root-ch + (_class("oral cavity", oc-ch),) }

  (
    tree: (label: "root", kind: "root", features: root-feats, children: root-ch),
    is-vocoid: vocalic,
  )
}

// ── Vocoid positional nudge ──────────────────────────────────────────────────
// Vocoid trees are naturally skewed: the deep vocalic subtree inflates the
// oral-cavity subtree's width, pushing it far right and laryngeal far left.
// Corrections:
//   1. Shift oral-cavity subtree left  (oc-shift)
//   2. Shift laryngeal subtree right   (lar-shift)
//   3. Individual nudges for [cont], [lab], [dor], [nasal]
//
// Subtrees identified via a single forward pass (pre-order). par coords are
// exact copies of the parent's (x,y), so array.contains() is exact.
#let _apply-vocoid-nudge(nodes, is-vocoid) = {
  if not is-vocoid { return nodes }

  let oc-shift = -2.00 // move oral-cavity subtree left
  let lar-shift = +1.10 // move laryngeal subtree right

  // Build a subtree membership set from a named root label.
  let _build-sub(root-label) = {
    let sub = ()
    let rn = nodes.find(e => e.label == root-label)
    if rn != none {
      sub = sub + ((rn.x, rn.y),)
      for n in nodes {
        if n.par != none and sub.contains(n.par) {
          let pos = (n.x, n.y)
          if not sub.contains(pos) { sub = sub + (pos,) }
        }
      }
    }
    sub
  }

  let vp-extra = -0.35 // push V-place subtree left  (more gap from aperture)
  let ap-extra = +0.35 // push aperture subtree right (more gap from V-place)
  // Only spread V-place/aperture when BOTH are present under vocalic;
  // if only one is present it is the sole child and should stay centred.

  let oc-sub = _build-sub("oral cavity")
  let lar-sub = _build-sub("laryngeal")
  let vplace-sub = _build-sub("V-place")
  let apt-sub = _build-sub("aperture")

  // Only apply root-level shifts when the root has multiple children.
  let has-laryngeal = nodes.any(e => e.label == "laryngeal")
  let has-nasal = nodes.any(e => e.label == "nasal" or e.label.ends-with("nasal"))
  let has-open3 = nodes.any(e => e.label.ends-with("open3"))
  let has-lab = nodes.any(e => e.label == "labial")
  let has-cor = nodes.any(e => e.label == "coronal")
  let has-dor = nodes.any(e => e.label == "dorsal")
  // Full vocoid tree (laryngeal + nasal + OC): OC moves right to spread out.
  // Partial tree (only laryngeal or only nasal): OC moves left as before.
  let effective-oc-shift = if has-laryngeal and has-nasal { +0.10 } else if has-laryngeal or has-nasal {
    oc-shift
  } else { 0 }
  let effective-lar-shift = if oc-sub.len() > 0 { lar-shift + (if has-open3 { 0.60 } else { 0 }) } else { 0 }
  let effective-vp-extra = if vplace-sub.len() > 0 and apt-sub.len() > 0 { vp-extra } else { 0 }
  let effective-ap-extra = if vplace-sub.len() > 0 and apt-sub.len() > 0 { ap-extra } else { 0 }

  // Total x displacement for a given (x,y) position — sum of all applicable shifts.
  let _dx-for(pos) = {
    let d = 0.0
    if oc-sub.contains(pos) { d = d + effective-oc-shift }
    if vplace-sub.contains(pos) { d = d + effective-vp-extra }
    if apt-sub.contains(pos) { d = d + effective-ap-extra }
    if lar-sub.contains(pos) { d = d + effective-lar-shift }
    d
  }

  nodes.map(e => {
    let base-x = e.x + _dx-for((e.x, e.y))
    let new-par = if e.par == none { none } else {
      let pd = _dx-for(e.par)
      if pd != 0 { (e.par.at(0) + pd, e.par.at(1)) } else { e.par }
    }

    if e.label.ends-with("continuant") {
      let cont-nudge = if not has-lab and has-cor and has-dor { -0.40 } else { 0 }
      (..e, x: base-x + 2.80 + cont-nudge, par: new-par)
    } else if e.label == "labial" {
      // Only nudge toward [cor] when [cor] is actually present.
      // Amount increases when [dor] is also there (three-way spread needs more room).
      let lab-nudge = if has-cor { (if has-dor { 0.40 } else { 0.10 }) } else { 0 }
      (..e, x: base-x + lab-nudge, par: new-par)
    } else if e.label == "dorsal" {
      if has-cor {
        // [cor] is in the middle: pull [dor] left toward it and lift above open1.
        (..e, x: base-x - 0.15, y: e.y + _stagger-dy, par: new-par)
      } else {
        // No [cor]: stay at natural position (sole feature, or alongside [lab] only).
        (..e, x: base-x, par: new-par)
      }
    } else if e.label == "nasal" or e.label.ends-with("nasal") {
      // Full vocoid tree only (has laryngeal): nudge nasal right.
      let nx = if has-laryngeal { e.x + 0.90 + (if has-open3 { 0.60 } else { 0 }) } else { e.x }
      (..e, x: nx, y: e.y - 0.30)
    } else {
      (..e, x: base-x, par: new-par)
    }
  })
}

// ── Node name for CeTZ anchor ────────────────────────────────────────────────
// Based on the argument name: sign stripped, spaces→hyphens, NO abbreviation.
// "+anterior" → "anterior1",  "oral cavity" → "oral-cavity2",  "−voice" → "voice1"
#let _node-name(label, tidx) = {
  let (_, base) = _sign-base(lower(label))
  base.replace(" ", "-") + str(tidx)
}

// ── Manual position adjustments ──────────────────────────────────────────────
// `position` is an array of (key, dx, dy) triples. `key` is:
//   - geom():       bare argument name,          e.g. "continuant", "oral-cavity"
//   - geom-group(): argument name + tree index,  e.g. "continuant1", "oral-cavity2"
// `use-tidx`: when true, match key against _node-name(label, tidx);
//             when false, match against bare base label (spaces→hyphens, no index).
// Moving a node also patches every node whose stored parent coords match the
// original position, so tree lines stay connected.
#let _apply-positions(nodes, position, use-tidx) = {
  // Auto-wrap a single flat (key, dx, dy) triple
  let position = if position.len() > 0 and type(position.at(0)) == str {
    (position,)
  } else { position }
  if position.len() == 0 { return nodes }

  // Build adjustment dict: key → (dx, dy)
  let adj = (:)
  for entry in position {
    adj.insert(entry.at(0), (entry.at(1), entry.at(2)))
  }

  // Resolve key for a node entry
  let node-key(e) = if use-tidx {
    _node-name(e.label, e.tidx)
  } else {
    let (_, base) = _sign-base(lower(e.label))
    base.replace(" ", "-")
  }

  // First pass: build "orig-x,orig-y" → new-(x,y) for all nodes that move,
  // so we can patch children's stored parent coordinates in the second pass.
  let moved = (:)
  for e in nodes {
    let key = node-key(e)
    if key in adj {
      let (dx, dy) = adj.at(key)
      moved.insert(str(e.x) + "," + str(e.y), (e.x + dx, e.y + dy))
    }
  }

  // Second pass: update node positions and parent references
  nodes.map(e => {
    let key = node-key(e)
    let (nx, ny) = if key in adj {
      let (dx, dy) = adj.at(key)
      (e.x + dx, e.y + dy)
    } else { (e.x, e.y) }

    let new-par = if e.par != none {
      let pk = str(e.par.at(0)) + "," + str(e.par.at(1))
      if pk in moved { moved.at(pk) } else { e.par }
    } else { none }

    (..e, x: nx, y: ny, par: new-par)
  })
}

// ── Segment label normalisation ──────────────────────────────────────────────
// Strings are passed through ipa-to-unicode (TIPA conventions); content is used as-is.
// Strip phonemic/phonetic delimiters from a ph key so it can be looked up in _presets.
// "/a/" → "a",  "[a]" → "a",  "a" → "a"
#let _ph-bare(s) = if type(s) != str { s } else if s.starts-with("/") and s.ends-with("/") and s.len() > 2 {
  s.slice(1, -1)
} else if s.starts-with("[") and s.ends-with("]") and s.len() > 2 { s.slice(1, -1) } else { s }

// Render a segment label string.  The user controls brackets by the string itself:
//   "/a/"  → /ipa("a")/   (phonemic)
//   "[a]"  → [ipa("a")]   (phonetic)
//   "a"    → ipa("a")     (bare)
//   content → passed through unchanged
#let _seg(s) = if type(s) != str { s } else if s.starts-with("/") and s.ends-with("/") and s.len() > 2 {
  [/#(ipa-to-unicode(s.slice(1, -1)))/]
} else if s.starts-with("[") and s.ends-with("]") and s.len() > 2 {
  [\[#(ipa-to-unicode(s.slice(1, -1)))\]]
} else { ipa-to-unicode(s) }

// ── Delink mark drawing ───────────────────────────────────────────────────────
// Draws two parallel bars perpendicular to the parent→child line at its midpoint,
// matching the same symbol used in autoseg() / multi-tier().
// (fx,fy) = parent bottom endpoint; (tx,ty) = child top endpoint.
#let _draw-delink(fx, fy, tx, ty, sw) = {
  let dx = tx - fx
  let dy = ty - fy
  let len = calc.sqrt(dx * dx + dy * dy)
  if len == 0 { return }
  let dir-x = dx / len
  let dir-y = dy / len
  let perp-x = -dir-y
  let perp-y = dir-x
  let mid-x = (fx + tx) / 2
  let mid-y = (fy + ty) / 2
  let bar = 0.15 // half-length of each bar (canvas units)
  let gap = 0.03 // half-gap between the two bars
  for sign in (-1, 1) {
    let cx = mid-x + sign * gap * dir-x
    let cy = mid-y + sign * gap * dir-y
    cetz.draw.line(
      (cx - bar * perp-x, cy - bar * perp-y),
      (cx + bar * perp-x, cy + bar * perp-y),
      stroke: sw,
    )
  }
}

// ── General post-layout nudge (all tree types) ───────────────────────────────
// When [voice] and [continuant] coexist they end up at nearly the same vertical
// level and close in x, causing overlap. Push [voice] down unconditionally.
#let _apply-general-nudge(nodes) = {
  let has-cont = nodes.any(e => e.label.ends-with("continuant"))
  let has-dor = nodes.any(e => e.label == "dorsal")

  // Full consonant tree: root has laryngeal + nasal + oral cavity all present.
  // Shift the oral-cavity subtree slightly left so it doesn't crowd the tree.
  // Gated on all three being present — leaves other consonant trees unchanged.
  let has-lar = nodes.any(e => e.label == "laryngeal")
  let has-nas = nodes.any(e => e.label == "nasal" or e.label.ends-with("nasal"))
  let has-oc = nodes.any(e => e.label == "oral cavity")
  let oc-shift = if has-lar and has-nas and has-oc { -0.50 } else { 0.0 }

  // Build oral-cavity subtree membership (pre-order, using original positions).
  let oc-sub = if oc-shift != 0.0 {
    let sub = ()
    let rn = nodes.find(e => e.label == "oral cavity")
    if rn != none {
      sub = sub + ((rn.x, rn.y),)
      for n in nodes {
        if n.par != none and sub.contains(n.par) {
          let pos = (n.x, n.y)
          if not sub.contains(pos) { sub = sub + (pos,) }
        }
      }
    }
    sub
  } else { () }

  // Fix 2 — OC not centered under root when nasal+OC present but no laryngeal.
  // Compute how far the root is displaced from the OC's current center.
  let oc-center-shift = if not has-lar and has-nas and has-oc {
    let rn = nodes.find(e => e.kind == "root")
    let on = nodes.find(e => e.label == "oral cavity")
    if rn != none and on != none { rn.x - on.x } else { 0.0 }
  } else { 0.0 }

  // Build OC subtree membership for the center-shift (different gate from oc-sub).
  let oc-center-sub = if oc-center-shift != 0.0 {
    let sub = ()
    let on = nodes.find(e => e.label == "oral cavity")
    if on != none {
      sub = sub + ((on.x, on.y),)
      for n in nodes {
        if n.par != none and sub.contains(n.par) {
          let pos = (n.x, n.y)
          if not sub.contains(pos) { sub = sub + (pos,) }
        }
      }
    }
    sub
  } else { () }

  // Fix 3 — [cor] and [rad] overlap when lab+cor+rad+dor all present.
  // Pre-account for the rad nudge (-0.30 when dor present) and shift [cor]
  // subtree to the midpoint between [lab].x and post-nudge [rad].x.
  let rad-entry = nodes.find(e => e.label == "radical")
  let lab-entry = nodes.find(e => e.label == "labial")
  let cor-entry = nodes.find(e => e.label == "coronal")
  let has-rad = rad-entry != none

  let cor-shift = if has-rad and cor-entry != none and lab-entry != none {
    let rad-x = rad-entry.x + (if has-dor { -0.30 } else { 0.0 })
    (lab-entry.x + rad-x) / 2.0 - cor-entry.x
  } else { 0.0 }

  let cor-sub = if cor-shift != 0.0 {
    let sub = ()
    if cor-entry != none {
      sub = sub + ((cor-entry.x, cor-entry.y),)
      for n in nodes {
        if n.par != none and sub.contains(n.par) {
          let pos = (n.x, n.y)
          if not sub.contains(pos) { sub = sub + (pos,) }
        }
      }
    }
    sub
  } else { () }

  // Fix 4 — second [−cont] overlaps C-place in affricates (two continuant nodes).
  let cont-nodes = nodes.filter(e => e.label.ends-with("continuant"))
  let cont-count = cont-nodes.len()
  let cont-right-x = if cont-count == 2 {
    calc.max(..cont-nodes.map(e => e.x))
  } else { none }

  nodes.map(e => {
    // [voice] drops down when [continuant] is also present (avoids overlap).
    let e2 = if has-cont and (e.label == "voice" or e.label.ends-with("voice")) {
      (..e, y: e.y - 0.80)
    } else { e }
    // Full tree: nudge [nasal] left and up so it sits naturally between laryngeal and oral cavity.
    let e2 = if oc-shift != 0.0 and (e2.label == "nasal" or e2.label.ends-with("nasal")) {
      (..e2, x: e2.x + 0.10, y: e2.y + 0.20)
    } else { e2 }
    // [rad] nudge left when [dor] is also present, to close the gap between them.
    let e2 = if has-dor and e2.label == "radical" {
      (..e2, x: e2.x - 0.30)
    } else { e2 }
    // Fix 3: shift [cor] subtree to midpoint between [lab] and post-nudge [rad].
    let e2 = if cor-sub.contains((e.x, e.y)) {
      let new-par = if e2.par == none { none } else if cor-sub.contains(e2.par) {
        (e2.par.at(0) + cor-shift, e2.par.at(1))
      } else { e2.par }
      (..e2, x: e2.x + cor-shift, par: new-par)
    } else { e2 }
    // Fix 4: nudge the rightmost continuant node left+down when two are present.
    let e2 = if cont-count == 2 and e2.label.ends-with("continuant") and e2.x == cont-right-x {
      (..e2, x: e2.x - 0.25, y: e2.y - 0.20)
    } else { e2 }
    // Shift oral-cavity subtree left in full consonant trees (has-lar+has-nas+has-oc).
    let e2 = if oc-sub.contains((e.x, e.y)) {
      let new-par = if e2.par == none { none } else if oc-sub.contains(e2.par) {
        (e2.par.at(0) + oc-shift, e2.par.at(1))
      } else { e2.par }
      (..e2, x: e2.x + oc-shift, par: new-par)
    } else { e2 }
    // Fix 2: center OC subtree under root when nasal+OC present but no laryngeal.
    if oc-center-sub.contains((e.x, e.y)) {
      let new-par = if e2.par == none { none } else if oc-center-sub.contains(e2.par) {
        (e2.par.at(0) + oc-center-shift, e2.par.at(1))
      } else { e2.par }
      (..e2, x: e2.x + oc-center-shift, par: new-par)
    } else { e2 }
  })
}

/// Draw a feature-geometry tree for a consonant or vocoid.
///
/// Arguments control which nodes are present. By default all nodes are absent.
/// Parent nodes are inferred automatically from their children (e.g. specifying
/// `spread: true` automatically shows "laryngeal").
///
/// - root (array): Feature strings for the root matrix, e.g. `("+son", "-vocoid")`.
///   Accepts the same formats as `feat()`.
/// - laryngeal (bool): Show "laryngeal" class node.
/// - nasal (bool, str): Show `[nasal]`. Pass `true` → `[nasal]`,
///   `"+"` → `[+nasal]`, `"-"` → `[−nasal]`.
/// - spread (bool): Show `[spread]` under laryngeal.
/// - constricted (bool): Show `[constricted]` under laryngeal.
/// - voice (bool, str): Show `[voice]` under laryngeal (Clements & Hume 1995). Pass
///   `true` → `[voice]`, `"+"` → `[+voice]`, `"-"` → `[−voice]`.
/// - continuant (bool, str): Show `[continuant]` under oral cavity. Pass `true` → `[cont]`,
///   `"+"` → `[+cont]`, `"-"` → `[−cont]`.
/// - labial (bool): Show `[labial]` (under C-place or V-place).
/// - coronal (bool): Show `[coronal]` (under C-place or V-place).
/// - anterior (bool, str): Show `[anterior]`. Pass `true` → `[anterior]`,
///   `"+"` → `[+anterior]`, `"-"` → `[−anterior]`.
/// - distributed (bool): Show `[distributed]` under `[coronal]`.
/// - radical (bool): Show `[rad]` (radical/pharyngeal) under C-place or V-place.
/// - dorsal (bool, array): Show `[dorsal]` (under C-place or V-place).
///   Pass an array of feature strings to add sub-features (Sagey-style):
///   `dorsal: ("+high", "-back")` → `[dor]` with `[+hi]` and `[−back]` children.
/// - labial (bool, array): Show `[labial]`. Array adds sub-features:
///   `labial: ("round",)` → `[lab]` with `[round]` child.
/// - coronal (bool, array): Show `[coronal]`. Array provides children directly,
///   replacing the separate `anterior`/`distributed` params:
///   `coronal: ("+ant", "-distr")` → `[cor]` with `[+ant]` and `[−distr]`.
/// - tense (bool, str): Show `[tense]` under the vocalic node. Pass `true` → `[tense]`,
///   `"+"` → `[+tense]`, `"-"` → `[−tense]`. Automatically infers `vocalic: true`.
///   Used in Sagey-style representations to distinguish [e]/[ɛ] and [o]/[ɔ].
/// - vocalic (bool): Show "vocalic" class node under C-place (vocoid branch).
/// - vplace (bool): Show "V-place" under vocalic. When true, `labial`/`coronal`/`dorsal`
///   attach here instead of directly under C-place. Inferred automatically when
///   `vocalic` is active and any place feature is supplied.
/// - aperture (bool, array): Show "aperture" class node under vocalic.
///   Pass `true` → node only; pass an array of up to 3 values to show
///   `[open1]`/`[open2]`/`[open3]` as children. Each element may be
///   `true` → `[openN]`, `"+"` → `[+openN]`, `"-"` → `[−openN]`,
///   or `false` → omit that degree. E.g. `aperture: ("+", false, "-")`.
///   (Replaces the former `open` parameter.)
/// - scale (number): Uniform scale factor (default: 1).
/// - position (array): Manual position tweaks. Each entry: `(key, dx, dy)` where
///   `key` is the bare argument name (`"continuant"`, `"oral-cavity"`) and `dx`/`dy`
///   are canvas-unit offsets (positive x = right, positive y = up).
///   Example: `position: (("continuant", -0.2, 0.3),)`
/// - delinks (array): Node keys whose line *to their parent* is replaced with a
///   delink mark (two perpendicular bars). Keys follow the same convention as
///   `position`: bare argument name for `geom()`, e.g. `delinks: ("c-place",)`.
/// - prefix (str): String prepended to the segment label. `"-"` is automatically converted to `"–"`. E.g. `prefix: "-"` → `–/a/`.
/// - suffix (str): String appended to the segment label. `"-"` is automatically converted to `"–"`.
/// - segment (content): Optional label centred above the root node, e.g. `"s"` or `$s$`.
/// - ph (str): Pre-built segment preset. Supports `"a"`, `"e"`, `"i"`, `"o"`, `"u"`,
///   `"E"` (ɛ), `"O"` (ɔ). The segment label defaults to the `ph` value unless overridden
///   by `segment`. Any other explicitly-provided argument overrides the corresponding preset
///   value: `#geom(ph: "O", root: ("+son", "+approx"))` replaces its root features.
///   Example: `#geom(ph: "i", scale: 1.5)`.
/// - model (str): Feature-geometry model for preset vowels. `"ch"` (default) uses
///   Clements & Hume 1995 (aperture nodes for height). `"sagey"` uses Sagey 1986
///   (dorsal sub-features for height/backness, labial `[round]` for rounding, no aperture).
///   Consonant presets are identical in both models.
/// -> content
#let geom(
  ph: none,
  model: "ch",
  root: (),
  laryngeal: false,
  nasal: false,
  spread: false,
  constricted: false,
  voice: false,
  continuant: false,
  labial: false,
  coronal: false,
  anterior: false,
  distributed: false,
  dorsal: false,
  radical: false,
  vocalic: false,
  vplace: false,
  aperture: false,
  tense: false,
  scale: 1.0,
  position: (),
  delinks: (),
  segment: none,
  prefix: "",
  suffix: "",
  highlight: (),
  timing: auto,
) = {
  // Auto-detect length from ph: "iː" or "i:" → long (two timing slots)
  // Strip the length mark so the preset lookup finds "i", not "iː"
  // Keep the original for use as the segment label fallback.
  let _is-long = ph != none and type(ph) == str and (ph.contains("ː") or ph.contains(":"))
  let _ph-orig = ph
  let ph = if ph != none and type(ph) == str { ph.replace("ː", "").replace(":", "") } else { ph }

  // Resolve timing:
  //   auto  → one × normally, two × when ph contains a length mark
  //   false → no timing tier
  //   string/symbol/array → explicit (normalized below)
  let timing = if timing == false {
    ()
  } else if timing == auto {
    if _is-long { ($times$, $times$) } else { ($times$,) }
  } else {
    // Coerce bare string/symbol to array, then normalize "mora"/"mu" → μ, "x"/"X" → ×
    let t = if type(timing) == str or type(timing) == symbol { (timing,) } else { timing }
    t.map(t => if type(t) == str {
      let tl = lower(t)
      if tl == "mora" or tl == "mu" { sym.mu } else if tl == "x" { $times$ } else { t }
    } else { t })
  }
  let prefix = prefix.replace("-", "–")
  let suffix = suffix.replace("-", "–")
  let scale-factor = scale

  // When ph is set, load the preset, then apply any explicitly-provided
  // non-default arguments on top. This lets callers override individual keys:
  //   #geom(ph: "O", root: ("+son", "+approx"))  ← root replaces preset's root
  // Sagey model uses _presets-sagey for vowels; consonants fall back to _presets.
  let ph-key = if ph != none { _ph-bare(ph) } else { none }
  let spec = if ph-key != none and ph-key in _presets {
    let preset-dict = if model == "sagey" and ph-key in _presets-sagey {
      _presets-sagey
    } else { _presets }
    // Use segment label exactly as provided by the user; fall back to the preset's own segment field.
    let seg = if segment != none { prefix + segment + suffix } else { prefix + _ph-orig + suffix }
    let overrides = (:)
    if root != () { overrides.insert("root", root) }
    if laryngeal != false { overrides.insert("laryngeal", laryngeal) }
    if nasal != false { overrides.insert("nasal", nasal) }
    if spread != false { overrides.insert("spread", spread) }
    if constricted != false { overrides.insert("constricted", constricted) }
    if voice != false { overrides.insert("voice", voice) }
    if continuant != false { overrides.insert("continuant", continuant) }
    if labial != false { overrides.insert("labial", labial) }
    if coronal != false { overrides.insert("coronal", coronal) }
    if anterior != false { overrides.insert("anterior", anterior) }
    if distributed != false { overrides.insert("distributed", distributed) }
    if dorsal != false { overrides.insert("dorsal", dorsal) }
    if radical != false { overrides.insert("radical", radical) }
    if vocalic != false { overrides.insert("vocalic", vocalic) }
    if vplace != false { overrides.insert("vplace", vplace) }
    if aperture != false { overrides.insert("aperture", aperture) }
    if tense != false { overrides.insert("tense", tense) }
    (..(preset-dict.at(ph-key)), segment: seg, ..overrides)
  } else {
    (
      root: root,
      laryngeal: laryngeal,
      nasal: nasal,
      spread: spread,
      constricted: constricted,
      voice: voice,
      continuant: continuant,
      labial: labial,
      coronal: coronal,
      anterior: anterior,
      distributed: distributed,
      dorsal: dorsal,
      radical: radical,
      vocalic: vocalic,
      vplace: vplace,
      aperture: aperture,
      tense: tense,
      segment: if segment != none { prefix + segment + suffix } else if prefix != "" or suffix != "" {
        prefix + suffix
      } else { none },
    )
  }
  let result = _build-tree(spec)
  let tree = result.tree
  let is-vocoid = result.is-vocoid

  let nodes = _layout(tree, 0.0, 0.0, none)
  let nodes = _apply-vocoid-nudge(nodes, is-vocoid)
  let nodes = _apply-general-nudge(nodes)
  // Tag with tree index 1 (single tree)
  let nodes = nodes.map(e => (..e, tidx: 1))
  let nodes = _apply-positions(nodes, position, false)

  // ── Render ────────────────────────────────────────────────────────────
  let _loff = 0.20
  let _dim = luma(65%)
  let _norm = luma(15%)
  // Per-node color: dim everything not in the highlight set (when set is non-empty).
  let _nc = nname => if highlight.len() == 0 or nname in highlight { _norm } else { _dim }

  // Dynamic baseline: anchor root node (canvas y=0) at the text baseline.
  let y-min = nodes.fold(0.0, (acc, e) => calc.min(acc, e.y))

  context {
    let em-in-cu = text.size / (scale-factor * 1cm)
    let _timing-gap = 0.65 // vertical gap from root to timing tier
    let _timing-y = 0.55 + _timing-gap // y-coordinate of timing nodes (root at 0)
    let _t-spacing = 0.55 // horizontal gap between timing nodes
    let seg-present = spec.at("segment", default: none) != none
    let y-top = if timing.len() > 0 {
      // timing nodes sit at _timing-y; segment label (if any) floats above them
      let label-top = if seg-present {
        _timing-y + 0.45 + text.size * 0.84 / (scale-factor * 1cm)
      } else {
        _timing-y + text.size * 0.35 / (scale-factor * 1cm)
      }
      label-top
    } else if seg-present {
      0.55 + text.size * 0.84 / (scale-factor * 1cm)
    } else {
      text.size * 0.35 / (scale-factor * 1cm)
    }
    let bl = (em-in-cu + (-y-min)) / (2 * em-in-cu + y-top - y-min)
    let fsz = text.size * 0.70 * scale-factor
    let font = phonokit-font.get()

    box(inset: 1em * scale-factor, baseline: bl * 100%, {
      cetz.canvas(length: scale-factor * 1cm, {
        import cetz.draw: *

        for entry in nodes {
          let nname = _node-name(entry.label, entry.tidx)
          let is-delinked = nname.slice(0, -1) in delinks
          let nc = _nc(nname)

          if entry.par != none {
            let (px, py) = entry.par
            let (fx, fy) = (px, py - _loff)
            let (tx, ty) = (entry.x, entry.y + _loff)
            let par-entry = nodes.find(e => e.x == px and e.y == py)
            let par-nname = if par-entry != none { _node-name(par-entry.label, par-entry.tidx) } else { none }
            let both-highlighted = (
              highlight.len() > 0 and nname in highlight and par-nname != none and par-nname in highlight
            )
            let line-paint = if highlight.len() == 0 or both-highlighted { _norm } else { _dim }
            let sw = (paint: line-paint, thickness: 0.016)
            line((fx, fy), (tx, ty), stroke: sw)
            if is-delinked { _draw-delink(fx, fy, tx, ty, sw) }
          }

          if entry.kind == "root" {
            content(
              (entry.x, entry.y),
              text(font: font, size: fsz, fill: nc, [root]),
              name: nname,
            )
            if entry.feats.len() > 0 {
              let mat-x = entry.x + 0.25
              let items = entry.feats.map(f => {
                let norm = f.replace("-", "−")
                let (sign, base) = if norm.starts-with("±") { ("±", norm.slice("±".len())) } else if norm.starts-with(
                  "+",
                ) { ("+", norm.slice(1)) } else if norm.starts-with("−") { ("−", norm.slice("−".len())) } else {
                  ("", norm)
                }
                text(font: font, fill: nc, if sign != "" { box(width: 0.65em, align(center, sign)) + base } else {
                  norm
                })
              })
              content(
                (mat-x, entry.y),
                {
                  set text(font: font, size: fsz, fill: nc)
                  box(baseline: 50%, math.vec(
                    align: left,
                    delim: "[",
                    gap: 0pt,
                    ..items,
                  ))
                },
                anchor: "west",
              )
            }
          } else {
            let inner = if entry.kind == "feature" {
              [\[#(_display(entry.label))\]]
            } else {
              [#(_display(entry.label))]
            }
            content(
              (entry.x, entry.y),
              text(font: font, size: fsz, fill: nc, inner),
              name: nname,
            )
          }
        }

        // Segment label — always full colour (never dimmed by highlight)
        let seg-label = spec.at("segment", default: none)
        if seg-label != none {
          let root-entry = nodes.find(e => e.kind == "root")
          if root-entry != none {
            let label-y = if timing.len() > 0 {
              root-entry.y + _timing-y + 0.45
            } else {
              root-entry.y + 0.55
            }
            content(
              (root-entry.x, label-y),
              text(font: font, size: fsz * 1.2, fill: _norm, _seg(seg-label)),
              anchor: "south",
            )
          }
        }

        // Timing tier (X-slots, morae, etc.)
        if timing.len() > 0 {
          let root-entry = nodes.find(e => e.kind == "root")
          if root-entry != none {
            let rx = root-entry.x
            let ry = root-entry.y
            let t-y = ry + _timing-y
            let n = timing.len()
            let t-paint = if highlight.len() == 0 { _norm } else { _dim }
            for (i, t) in timing.enumerate() {
              let tx = if n == 1 { rx } else { rx + (i - (n - 1) / 2.0) * _t-spacing }
              line(
                (rx, ry + _loff),
                (tx, t-y - _loff),
                stroke: (paint: t-paint, thickness: 0.016),
              )
              content((tx, t-y), text(font: font, size: fsz, fill: t-paint, t))
            }
          }
        }
      })
    })
  } // context
}

/// Draw two or more feature-geometry trees side by side in a single canvas,
/// with optional dashed arrows connecting nodes across trees.
///
/// Each tree is specified as a dict with the same keys as `geom()` (all
/// optional, same defaults). Trees cannot be passed as rendered `#geom()`
/// content — pass spec dicts or `#let` variables instead:
///
/// ```typst
/// #let consonant = (root: ("-son",), labial: true)
/// #let vowel     = (root: ("+son",), vocalic: true, dorsal: true)
/// #geom-group(consonant, vowel,
///   arrows: (("labial1", "dorsal2"),))
/// ```
///
/// Node names are formed by stripping `+`/`−` prefixes, replacing spaces with
/// hyphens, and appending the 1-based tree index:
/// `"anterior1"`, `"oral-cavity2"`, `"c-place1"`, `"root2"`, etc.
///
/// Each arrow entry is either a simple array `(from, to)` or a dict with
/// named keys for full control:
/// ```typst
/// arrows: (
///   ("labial1", "labial2"),                             // simple
///   (from: "cor1", to: "cor2", color: blue),            // coloured
///   (from: "dor1", to: "dor2", ctrl: (1.0, -0.5)),      // custom S-curve
/// )
/// ```
///
/// - ..trees (arguments): Positional spec dicts, one per tree.
/// - arrows (array): Cross-tree arrows. Each entry: `(from, to)` array or
///   `(from: str, to: str, color: color, ctrl: array)` dict (all keys except
///   `from`/`to` optional).
/// - gap (number): Canvas-unit gap between trees (default: 1.5).
/// - scale (number): Uniform scale factor (default: 1).
/// - model (str): Feature-geometry model for preset vowels. `"ch"` (default) or `"sagey"`.
///   Applies to all trees in the group. See `geom()` for details.
/// - position (array): Manual position tweaks after layout. Each entry: `(key, dx, dy)`
///   where `key` is the node anchor name with tree index (`"continuant1"`, `"oral-cavity2"`)
///   and `dx`/`dy` are canvas-unit offsets. Arrows automatically use the adjusted positions.
///   Example: `position: (("continuant1", -0.2, 0.3),)`
/// - delinks (array): Node anchor names (with tree index) whose line to their parent is
///   replaced with a delink mark. E.g. `delinks: ("c-place1",)`.
/// - curved (bool): When `true`, arrows are drawn as quadratic bézier curves with
///   automatic obstacle avoidance — they route around intervening nodes rather than
///   crossing them. Uses the same algorithm as `#vowels()`. (default: `false`)
/// -> content
#let geom-group(
  ..args,
  arrows: (),
  gap: 1.5,
  scale: 1.0,
  model: "ch",
  position: (),
  delinks: (),
  curved: false,
  highlight: (),
) = {
  let specs = args.pos()
  let scale-factor = scale

  // Auto-wrap a flat ("from", "to") pair so both forms are valid:
  //   arrows: ("labial1", "c-place3")          ← single arrow, flat
  //   arrows: (("labial1", "c-place3"), ...)   ← multiple arrows, nested
  let arrows = if arrows.len() > 0 and type(arrows.at(0)) == str {
    (arrows,)
  } else { arrows }

  // ── Build and layout each tree, offset x by cumulative width + gap ────
  // Each spec may carry a `scale` key (default 1.0) that scales that tree's
  // coordinates and font size relative to the group scale.
  let all-nodes = ()
  let x-cursor = 0.0
  let seg-labels = () // (x, y, ts, text, root-nname, has-timing)
  let timing-data = () // (root-x, ts, resolved-timing-array)
  for (idx, spec) in specs.enumerate() {
    // Auto-detect length mark in ph; strip it so preset lookup works.
    let ph-raw = spec.at("ph", default: none)
    let _is-long = ph-raw != none and type(ph-raw) == str and (ph-raw.contains("ː") or ph-raw.contains(":"))
    let spec = if _is-long {
      (..spec, ph: ph-raw.replace("ː", "").replace(":", ""))
    } else { spec }

    // Resolve preset if ph key is present; explicit spec keys override the preset.
    // Sagey model uses _presets-sagey for vowels; consonants fall back to _presets.
    let spec = if "ph" in spec and _ph-bare(spec.at("ph")) in _presets {
      let ph-val = spec.at("ph")
      let ph-key = _ph-bare(ph-val)
      let preset-dict = if model == "sagey" and ph-key in _presets-sagey {
        _presets-sagey
      } else { _presets }
      let base = preset-dict.at(ph-key)
      let px = spec.at("prefix", default: "").replace("-", "–")
      let sx = spec.at("suffix", default: "").replace("-", "–")
      // Use original ph (with length mark) as segment label fallback
      let seg-ph = if ph-raw != none { ph-raw } else { ph-val }
      let seg = if "segment" in spec { px + spec.at("segment") + sx } else { px + seg-ph + sx }
      let overrides = (:)
      for pair in spec.pairs() {
        if pair.at(0) not in ("ph", "prefix", "suffix") { overrides.insert(pair.at(0), pair.at(1)) }
      }
      (..base, segment: seg, ..overrides)
    } else { spec }

    // Resolve timing for this tree (same logic as geom())
    let timing-raw = spec.at("timing", default: auto)
    let tree-timing = if timing-raw == false {
      ()
    } else if timing-raw == auto {
      if _is-long { ($times$, $times$) } else { ($times$,) }
    } else {
      let t = if type(timing-raw) == str or type(timing-raw) == symbol { (timing-raw,) } else { timing-raw }
      t.map(t => if type(t) == str {
        let tl = lower(t)
        if tl == "mora" or tl == "mu" { sym.mu } else if tl == "x" { $times$ } else { t }
      } else { t })
    }

    let result = _build-tree(spec)
    let tree = result.tree
    let is-vocoid = result.is-vocoid
    let ts = spec.at("scale", default: 1.0) // per-tree relative scale
    let px = spec.at("prefix", default: "").replace("-", "–")
    let sx = spec.at("suffix", default: "").replace("-", "–")
    let seg = if spec.at("segment", default: none) != none { px + spec.at("segment") + sx } else { none }
    let nodes = _layout(tree, 0.0, 0.0, none)
    let nodes = _apply-vocoid-nudge(nodes, is-vocoid)
    let nodes = _apply-general-nudge(nodes)
    let tidx = idx + 1
    // Scale coordinates and offset into the shared canvas.
    all-nodes = (
      all-nodes
        + nodes.map(e => (
          ..e,
          x: e.x * ts + x-cursor,
          y: e.y * ts,
          par: if e.par == none { none } else {
            (e.par.at(0) * ts + x-cursor, e.par.at(1) * ts)
          },
          tidx: tidx,
          tscale: ts,
        ))
    )
    let root-w = _tree-w(tree)
    let root-x = x-cursor + root-w / 2 * ts
    let root-nname = _node-name("root", tidx)
    // Record segment label position
    if seg != none {
      seg-labels = seg-labels + ((root-x, 0.0, ts, seg, root-nname, tree-timing.len() > 0),)
    }
    // Record timing tier data
    if tree-timing.len() > 0 {
      timing-data = timing-data + ((root-x, ts, tree-timing),)
    }
    x-cursor = x-cursor + _tree-w(tree) * ts + gap
  }
  let all-nodes = _apply-positions(all-nodes, position, true)

  // ── Render ────────────────────────────────────────────────────────────
  let _loff = 0.20
  let _dim = luma(65%)
  let _norm = luma(15%)
  let _nc = nname => if highlight.len() == 0 or nname in highlight { _norm } else { _dim }

  let y-min-g = all-nodes.fold(0.0, (acc, e) => calc.min(acc, e.y))

  // Build name → (x, y, loff) lookup OUTSIDE the canvas block.
  // dict.insert() inside CeTZ's canvas block may not behave correctly
  // because CeTZ processes drawing commands in a special context.
  let name-to-pos = (:)
  for e in all-nodes {
    name-to-pos.insert(_node-name(e.label, e.tidx), (e.x, e.y, _loff * e.tscale))
  }

  context {
    let em-in-cu-g = text.size / (scale-factor * 1cm)
    let _timing-gap = 0.65
    let _timing-y = 0.55 + _timing-gap
    let _t-spacing = 0.55
    // y-top-g: highest point across all trees (timing + segment labels)
    let y-top-g = {
      let timing-tops = timing-data.map(td => {
        let (rx, ts, tt) = td
        let has-seg = seg-labels.any(sl => calc.abs(sl.at(0) - rx) < 0.001)
        if has-seg {
          (_timing-y + 0.45 + text.size * 0.84 / (scale-factor * 1cm)) * ts
        } else {
          (_timing-y + text.size * 0.35 / (scale-factor * 1cm)) * ts
        }
      })
      let seg-tops = seg-labels
        .filter(sl => not sl.at(5))
        .map(sl => 0.55 * sl.at(2) + text.size * 0.84 / (scale-factor * 1cm))
      let all-tops = timing-tops + seg-tops
      if all-tops.len() > 0 {
        all-tops.fold(text.size * 0.35 / (scale-factor * 1cm), calc.max)
      } else {
        text.size * 0.35 / (scale-factor * 1cm)
      }
    }
    let bl-g = (em-in-cu-g + (-y-min-g)) / (2 * em-in-cu-g + y-top-g - y-min-g)
    let fsz = text.size * 0.70 * scale-factor
    let font = phonokit-font.get()

    box(inset: 1em * scale-factor, baseline: bl-g * 100%, {
      cetz.canvas(length: scale-factor * 1cm, {
        import cetz.draw: *

        // Draw all tree nodes
        for entry in all-nodes {
          let nname = _node-name(entry.label, entry.tidx)
          let ts = entry.tscale
          let efsz = fsz * ts
          let eloff = _loff * ts
          let nc = _nc(nname)

          if entry.par != none {
            let (px, py) = entry.par
            let (fx, fy) = (px, py - eloff)
            let (tx, ty) = (entry.x, entry.y + eloff)
            let par-entry = all-nodes.find(e => e.x == px and e.y == py)
            let par-nname = if par-entry != none { _node-name(par-entry.label, par-entry.tidx) } else { none }
            let both-highlighted = (
              highlight.len() > 0 and nname in highlight and par-nname != none and par-nname in highlight
            )
            let line-paint = if highlight.len() == 0 or both-highlighted { _norm } else { _dim }
            let sw = (paint: line-paint, thickness: 0.016)
            line((fx, fy), (tx, ty), stroke: sw)
            if nname in delinks { _draw-delink(fx, fy, tx, ty, sw) }
          }

          if entry.kind == "root" {
            content(
              (entry.x, entry.y),
              text(font: font, size: efsz, fill: nc, [root]),
              name: nname,
            )
            if entry.feats.len() > 0 {
              let mat-x = entry.x + 0.25 * ts
              let items = entry.feats.map(f => {
                let norm = f.replace("-", "−")
                let (sign, base) = if norm.starts-with("±") { ("±", norm.slice("±".len())) } else if norm.starts-with(
                  "+",
                ) { ("+", norm.slice(1)) } else if norm.starts-with("−") { ("−", norm.slice("−".len())) } else {
                  ("", norm)
                }
                text(font: font, fill: nc, if sign != "" { box(width: 0.65em, align(center, sign)) + base } else {
                  norm
                })
              })
              content(
                (mat-x, entry.y),
                {
                  set text(font: font, size: efsz, fill: nc)
                  box(baseline: 50%, math.vec(
                    align: left,
                    delim: "[",
                    gap: 0pt,
                    ..items,
                  ))
                },
                anchor: "west",
              )
            }
          } else {
            let inner = if entry.kind == "feature" {
              [\[#(_display(entry.label))\]]
            } else {
              [#(_display(entry.label))]
            }
            content(
              (entry.x, entry.y),
              text(font: font, size: efsz, fill: nc, inner),
              name: nname,
            )
          }
        }

        // Segment labels — always full colour (never dimmed by highlight)
        for (sx, sy, ts, seg, root-nname, has-timing) in seg-labels {
          let label-y = sy + (if has-timing { (_timing-y + 0.45) * ts } else { 0.55 * ts })
          let seg-body = _seg(seg)
          content(
            (sx, label-y),
            text(font: font, size: fsz * ts * 1.2, fill: _norm, seg-body),
            anchor: "south",
          )
        }

        // Timing tiers
        let t-paint = if highlight.len() == 0 { _norm } else { _dim }
        for (rx, ts, tt) in timing-data {
          let ry = 0.0
          let t-y = ry + _timing-y * ts
          let n = tt.len()
          let loff = 0.20 * ts
          for (i, t) in tt.enumerate() {
            let tx = if n == 1 { rx } else { rx + (i - (n - 1) / 2.0) * _t-spacing * ts }
            line(
              (rx, ry + loff),
              (tx, t-y - loff),
              stroke: (paint: t-paint, thickness: 0.016),
            )
            content((tx, t-y), text(font: font, size: fsz * ts, fill: t-paint, t))
          }
        }

        // Draw cross-tree arrows.
        // Shaft is dashed; head is a separate solid segment so the arrowhead
        // contour is never dashed (same technique as #vowels).
        // When curved: quadratic bézier with obstacle avoidance (same algorithm as vowels.typ).
        let head-back = 0.12 // canvas units of solid segment before the tip
        let clearance = 0.45 // obstacle avoidance radius (canvas units)
        let sample-ts = (0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9)
        let obs-pts = all-nodes.map(e => (e.x, e.y)) // all node centres

        for arrow in arrows {
          // Accept both positional arrays ("from", "to") / ("from", "to", color)
          // and dicts (from: "...", to: "...", color: ..., ctrl: ...).
          let is-dict = type(arrow) == dictionary
          let from-name = if is-dict { arrow.at("from") } else { arrow.at(0) }
          let to-name = if is-dict { arrow.at("to") } else { arrow.at(1) }
          let paint = if is-dict { arrow.at("color", default: luma(15%)) } else if arrow.len() >= 3 {
            arrow.at(2)
          } else { luma(15%) }
          // ctrl: two-element array (lift1, lift2) — Y-offsets from each endpoint.
          // When set, bypasses curved entirely.
          let ctrl-val = if is-dict { arrow.at("ctrl", default: none) } else { none }

          if from-name in name-to-pos and to-name in name-to-pos {
            let (fx, fy, f-loff) = name-to-pos.at(from-name)
            let (tx, ty, t-loff) = name-to-pos.at(to-name)
            // Dim arrow if neither endpoint is highlighted (when highlight is active).
            let arrow-lit = highlight.len() == 0 or from-name in highlight or to-name in highlight
            let paint = if arrow-lit { paint } else { _dim }
            // Arrows connect to the TOP of each node (where parent lines terminate),
            // EXCEPT for root nodes which have no parent — they connect at the BOTTOM
            // (facing their children) to avoid landing near the segment label above.
            let fy = if from-name.starts-with("root") { fy - f-loff } else { fy + f-loff }
            let ty = ty - t-loff
            let dx = tx - fx
            let dy = ty - fy
            let len = calc.sqrt(dx * dx + dy * dy)

            // ── Control points ─────────────────────────────────────────────
            // Priority: ctrl > curved.
            // ctrl: explicit Y-offsets from each endpoint → cubic Bézier, any shape.
            // curved: auto S-curve scaled by distance.
            let (ctrl1, ctrl2) = if ctrl-val != none {
              // ctrl: (lift1, lift2) — Y-offsets from each endpoint.
              (
                (fx + dx * 0.30, fy + ctrl-val.at(0)),
                (tx - dx * 0.30, ty + ctrl-val.at(1)),
              )
            } else {
              if curved and len > 0 {
                let v-reach = calc.abs(dy)
                let h-reach = calc.abs(dx)
                // ctrl1: departs with upward bias, scaling with whichever reach dominates.
                let lift1 = calc.max(v-reach * 0.50, h-reach * 0.20, 0.50)
                // ctrl2: arrives from below target — dip scales with vertical distance.
                let dip2 = calc.max(v-reach * 0.25, 0.40)
                (
                  (fx + dx * 0.30, fy + lift1),
                  (tx - dx * 0.10, ty - dip2),
                )
              } else { (none, none) }
            }

            // ── Tangent at tip & pullback ───────────────────────────────────
            let (tang-x, tang-y) = if ctrl2 != none {
              let ex = tx - ctrl2.at(0)
              let ey = ty - ctrl2.at(1)
              let ed = calc.sqrt(ex * ex + ey * ey)
              if ed > 0 { (ex / ed, ey / ed) } else { (dx / len, dy / len) }
            } else {
              (dx / len, dy / len)
            }
            let hb = calc.min(head-back, len * 0.4)
            let hax = tx - tang-x * hb
            let hay = ty - tang-y * hb

            let shaft-stroke = (paint: paint, thickness: 0.018, dash: "dashed")
            let head-stroke = (paint: paint, thickness: 0.018)
            let mark-style = (end: ">", fill: paint, scale: 0.5)

            // Dashed shaft
            if ctrl1 != none {
              bezier((fx, fy), (hax, hay), ctrl1, ctrl2, stroke: shaft-stroke)
            } else {
              line((fx, fy), (hax, hay), stroke: shaft-stroke)
            }
            // Solid arrowhead
            let tiny = 0.01
            line(
              (hax - tang-x * tiny, hay - tang-y * tiny),
              (tx, ty),
              stroke: head-stroke,
              mark: mark-style,
            )
          }
        }
      })
    })
  } // context
}
