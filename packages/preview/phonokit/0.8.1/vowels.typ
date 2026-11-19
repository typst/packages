#import "@preview/cetz:0.5.3": canvas, draw
#import "ipa.typ": as-typed, ipa-to-unicode, unknown-commands
#import "_config.typ": phonokit-font

// Vowel data with relative positions (0-1 scale)
// frontness: 0 = front, 0.5 = central, 1 = back
// height: 1 = close, 0.67 = close-mid, 0.33 = open-mid, 0 = open
// rounded: affects horizontal positioning within minimal pairs
#let vowel-data = (
  "i": (frontness: 0.05, height: 1.00, rounded: false),
  "y": (frontness: 0.05, height: 1.00, rounded: true),
  "ɨ": (frontness: 0.50, height: 1.00, rounded: false),
  "ʉ": (frontness: 0.50, height: 1.00, rounded: true),
  "ɯ": (frontness: 0.95, height: 1.00, rounded: false),
  "u": (frontness: 0.95, height: 1.00, rounded: true),
  "ɪ": (frontness: 0.15, height: 0.85, rounded: false),
  "ʏ": (frontness: 0.25, height: 0.85, rounded: true),
  "ʊ": (frontness: 0.85, height: 0.85, rounded: true),
  "e": (frontness: 0.05, height: 0.67, rounded: false),
  "ø": (frontness: 0.05, height: 0.67, rounded: true),
  "ɘ": (frontness: 0.50, height: 0.67, rounded: false),
  "ɵ": (frontness: 0.50, height: 0.67, rounded: true),
  "ɤ": (frontness: 0.95, height: 0.67, rounded: false),
  "o": (frontness: 0.95, height: 0.67, rounded: true),
  "ə": (frontness: 0.585, height: 0.51, rounded: false),
  "ɛ": (frontness: 0.05, height: 0.34, rounded: false),
  "œ": (frontness: 0.05, height: 0.34, rounded: true),
  "ɜ": (frontness: 0.50, height: 0.34, rounded: false),
  "ɞ": (frontness: 0.50, height: 0.34, rounded: true),
  "ʌ": (frontness: 0.95, height: 0.34, rounded: false),
  "ɔ": (frontness: 0.95, height: 0.34, rounded: true),
  "æ": (frontness: 0.05, height: 0.15, rounded: false),
  "ɐ": (frontness: 0.585, height: 0.18, rounded: false),
  "a": (frontness: 0.05, height: 0.00, rounded: false),
  "ɶ": (frontness: 0.05, height: 0.00, rounded: true),
  "ɑ": (frontness: 0.95, height: 0.00, rounded: false),
  "ɒ": (frontness: 0.95, height: 0.00, rounded: true),
)

// Calculate actual position from relative coordinates
#let get-vowel-position(vowel-info, trapezoid, width, height, offset) = {
  let front = vowel-info.frontness
  let h = vowel-info.height

  // Calculate y coordinate
  let y = -height / 2 + (h * height)

  // Interpolate x based on trapezoid shape at this height
  let t = 1 - h // interpolation factor (0 at top, 1 at bottom)
  let left-x = trapezoid.at(0).at(0) * (1 - t) + trapezoid.at(3).at(0) * t
  let right-x = trapezoid.at(1).at(0) * (1 - t) + trapezoid.at(2).at(0) * t

  let x = 0

  // Front vowels (frontness < 0.4)
  if front < 0.4 {
    // Extreme front (< 0.15): tense vowels like i, e
    if front < 0.15 {
      if vowel-info.rounded {
        // Front rounded: inside (right of left edge)
        x = left-x + offset
      } else {
        // Front unrounded: outside (left of left edge)
        x = left-x - offset
      }
    } // Near-front (0.15-0.4): lax vowels like ɪ, ʏ
    // Always positioned inside the trapezoid
    else {
      x = left-x + (front * (right-x - left-x))
    }
  } // Back vowels (frontness > 0.6)
  else if front > 0.6 {
    // Extreme back (> 0.85): tense vowels like u, o
    if front > 0.85 {
      if vowel-info.rounded {
        // Back rounded: outside (right of right edge)
        x = right-x + offset
      } else {
        // Back unrounded: inside (left of right edge)
        x = right-x - offset
      }
    } // Near-back (0.6-0.85): lax vowels like ʊ
    // Always positioned inside the trapezoid
    else {
      x = left-x + (front * (right-x - left-x))
    }
  } // Central vowels
  else {
    // Calculate base central position
    let center-x = left-x + (front * (right-x - left-x))

    // Apply full offset for rounded/unrounded pairs (same as front/back)
    if vowel-info.rounded {
      x = center-x + offset // Rounded to the right
    } else {
      x = center-x - offset // Unrounded to the left
    }
  }

  (x, y)
}

// Language vowel inventories
#let language-vowels = (
  "spanish": "aeoiu",
  "portuguese": "iɔeaouɛ",
  "italian": "iɔeaouɛ",
  "english": "iɪaeɛæɑɔoʊuʌə",
  "french": "iœɑɔøeaouɛyə",
  "german": "iyʊuɪʏeøoɔɐaɛœə",
  "japanese": "ieaou",
  "russian": "iɨueoa",
  "arabic": "aiu",
  "all": "iyɨʉɯuɪʏʊeøɘɵɤoəɛœɜɞʌɔæɐaɶɑɒ",
  // Add more languages here or adjust existing inventories
)

#let language-nasal-vowels = (
  "french": ("ɛ", "œ", "ɔ", "ɑ"),
)

#let _strip-nasal(vowel) = vowel.normalize(form: "nfd").replace("̃", "")

// Length marks: long (ː) and half-long (ˑ). They are separate grapheme
// clusters, so they attach to whichever vowel cluster precedes them.
#let _length-marks = ("ː", "ˑ")
#let _strip-length(s) = _length-marks.fold(s, (acc, m) => acc.replace(m, ""))

// Ordered variant keys of one vowel quality: the plain vowel first if it
// occurs, then each length-marked variant in the order seen ("i", "iː").
#let _variant-keys(prefix, short, marks) = {
  (if short { (prefix,) } else { () }) + marks.map(m => prefix + m)
}

#let _collect-custom-vowels(input) = {
  let converted = ipa-to-unicode(input.replace(regex("\\s+"), " "))
  let oral = ""
  let nasals = ()
  let rejected = ()
  // One token per vowel occurrence: (base, nasal, mark). A length mark is a
  // separate cluster and attaches to the vowel cluster right before it.
  let tokens = ()
  let prev-is-vowel = false
  // Length marks with no vowel right before them (": a", "i::")
  let orphans = ()
  let prev-is-rejected = false

  for cluster in converted.clusters() {
    let decomposed = cluster.normalize(form: "nfd")
    let base = _strip-nasal(decomposed)
    if cluster in _length-marks and prev-is-vowel {
      let last = tokens.pop()
      last.mark = cluster
      tokens.push(last)
      prev-is-vowel = false
    } else if cluster in _length-marks {
      // A mark after an unknown symbol ("p:") is reported through that symbol
      if not prev-is-rejected and cluster not in orphans {
        orphans.push(cluster)
      }
      prev-is-vowel = false
    } else if base in vowel-data {
      prev-is-rejected = false
      if base not in oral {
        oral += base
      }
      let nasal = "̃" in decomposed
      if nasal and base not in nasals {
        nasals.push(base)
      }
      tokens.push((base: base, nasal: nasal, mark: none))
      prev-is-vowel = true
    } else {
      if cluster not in rejected {
        rejected.push(cluster)
      }
      prev-is-vowel = false
      prev-is-rejected = true
    }
  }

  // Oral and nasal occurrences are tracked apart: "ã:" makes the nasal copy
  // long, not the oral vowel.
  let variants = (:)
  let nasal-variants = (:)
  for base in oral.clusters() {
    for nasal in (false, true) {
      let own = tokens.filter(t => t.base == base and t.nasal == nasal)
      if own.len() == 0 { continue }
      let short = own.any(t => t.mark == none)
      let marks = own.filter(t => t.mark != none).map(t => t.mark).dedup()
      if nasal {
        nasal-variants.insert(base, _variant-keys(base + "\u{0303}", short, marks))
      } else {
        variants.insert(base, _variant-keys(base, short, marks))
      }
    }
    // A vowel given only nasalized still plots its plain oral glyph
    if base not in variants { variants.insert(base, (base,)) }
  }

  (oral: oral, nasals: nasals, rejected: rejected, orphans: orphans, variants: variants, nasal-variants: nasal-variants)
}

// Resolve a target (already converted to Unicode) to the variant of a plotted
// vowel it names: (base, index) into `variants.at(base)`, or none. Variants
// are independent characters: only an exact key matches, so "i:" picks "iː"
// and "i" picks the short "i", never the other.
#let _resolve-variant(variants, target) = {
  let base = _strip-length(target)
  if base not in variants { return none }
  let idx = variants.at(base).position(k => k == target)
  if idx != none { (base, idx) } else { none }
}

// Main vowels function
#let vowels(
  ..args, // Optional positional vowel-string (read below) — allows `lang`-only calls
  lang: none,
  width: 8,
  height: 6,
  rows: 3, // Only 2 internal horizontal lines
  cols: 2, // Only 1 vertical line inside trapezoid
  scale: 0.7, // Scale factor for entire chart
  nasals: auto, // Draw nasalized copies; auto = on when a custom string has a nasal vowel
  arrows: (), // List of (from-tipa-str, to-tipa-str) tuples
  arrow-color: black, // Color for arrow lines and heads
  arrow-style: "solid", // "solid" or "dashed"
  arrow-head: "curved-stealth", // "curved-stealth", "stealth", "triangle", "barbed" or "straight"
  curved: auto, // auto: straight, but side-by-side labels get a U-shaped arc; true: all arcs; false: all straight
  shift: (), // List of (tipa-str, x-offset, y-offset) tuples
  shift-color: gray, // Color for shifted vowel symbols
  shift-size: none, // Font size for shifted vowels; none = same as regular
  highlight: (), // List of tipa strings whose background circle is highlighted
  highlight-color: luma(220), // Circle color for highlighted vowels (default: light gray)
  circle-size: 1, // Multiplier for the radius of highlight circles
  highlight-style: "gradient", // "gradient" (soft edge) or "solid" (hard edge)
  phoneme-colors: (:), // Dictionary of phoneme-specific text colors
) = {
  // Read the optional positional argument: vowel symbols, a language name, or
  // tipa-style IPA. It is optional (via the `..args` sink) so that `lang`-only
  // calls like `vowels(lang: "spanish")` work — a parameter with a default value
  // would be named-only in Typst and could not be passed positionally.
  assert(args.pos().len() <= 1,
    message: "vowels: expected at most one positional argument (the vowel string)")
  assert(args.named().len() == 0,
    message: "vowels: unexpected named argument(s): " + args.named().keys().join(", "))
  // Arrowhead shapes (CeTZ marks) and their size: stealth heads are drawn a
  // little smaller, so they read lighter than the solid triangle
  let arrow-heads = ("curved-stealth": 0.8, "stealth": 0.8, "triangle": 1, "barbed": 1, "straight": 1)
  assert(arrow-head in arrow-heads,
    message: "vowels: arrow-head must be one of " + arrow-heads.keys().map(repr).join(", ") + ", got " + repr(arrow-head))
  assert(curved == auto or type(curved) == bool,
    message: "vowels: curved must be true, false or auto, got " + repr(curved))
  assert(nasals == auto or type(nasals) == bool,
    message: "vowels: nasals must be true, false or auto, got " + repr(nasals))
  assert(highlight-style in ("gradient", "solid"),
    message: "vowels: highlight-style must be \"gradient\" or \"solid\", got " + repr(highlight-style))
  let vowel-string = args.pos().at(0, default: none)
  // An unfinished inventory should stay quiet while the user is typing.
  if lang == none and (vowel-string == none or vowel-string.trim() == "") {
    return none
  }

  // Determine which vowels to plot
  let vowels-to-plot = ""
  let nasal-target-vowels = ()
  let parsed-variants = none
  let parsed-nasal-variants = (:)
  let error-msg = none
  let presets = [
    Available presets: #(language-vowels.keys().map(raw).join(", ")).
    Use a listed preset or provide only vowel symbols.
  ]
  let inventory-error = [*Error:* #presets]

  // Check if vowel-string is actually a language name
  if vowel-string != none and vowel-string in language-vowels {
    // It's a language name - use language vowels
    vowels-to-plot = language-vowels.at(vowel-string)
  } else if lang != none {
    // Explicit lang parameter provided
    if lang in language-vowels {
      vowels-to-plot = language-vowels.at(lang)
    } else {
      return [*Error:* Unknown language #raw(as-typed(lang)). \ #presets]
    }
  } else if vowel-string != none and vowel-string != "" {
    // Use as manual vowel specification - keep oral bases for plotting and
    // remember which vowels were explicitly nasalized in the input.
    let unknown = unknown-commands(vowel-string)
    if unknown.len() > 0 {
      return [*Error:* Unknown command(s): #unknown.map(c => raw(as-typed(c))).join(", "). \ #presets]
    }
    let parsed = _collect-custom-vowels(vowel-string)
    if parsed.rejected.len() > 0 {
      return [*Error:* Unknown symbol(s): #parsed.rejected.map(r => raw(as-typed(r))).join(", "). \ #presets]
    }
    if parsed.orphans.len() > 0 {
      // Shown in the IPA font and named: ˑ is nearly invisible in raw text
      let names = ("ː": "long", "ˑ": "half-long")
      let (subject, verb, obj) = if parsed.orphans.len() == 1 { ("Length mark", "has", "it") } else { ("Length marks", "have", "them") }
      return context {
        let marks = parsed.orphans.map(m => [#text(font: phonokit-font.get(), m) (#names.at(m))]).join(", ")
        [*Error:* #subject #marks #verb no vowel before #obj. Write each mark right after a vowel, as in #raw("a:").]
      }
    }
    if parsed.oral == "" {
      return inventory-error
    }
    vowels-to-plot = parsed.oral
    nasal-target-vowels = parsed.nasals
    parsed-variants = parsed.variants
    parsed-nasal-variants = parsed.nasal-variants
  } else {
    // Nothing specified
    error-msg = inventory-error
  }

  // If there's an error, display it and return
  if error-msg != none {
    return error-msg
  }

  // Calculate scaled dimensions
  let scaled-width = width * scale
  let scaled-height = height * scale
  let scaled-offset = 0.55 * scale
  // White mask circles: fixed size, only cut gaps in the grid lines behind vowels
  let scaled-circle-radius = 0.35 * scale
  // Colored highlight circles: drawn above the masks, resizable via circle-size.
  // "gradient": solid up to 60% of the radius (just past the mask, so letters
  // stay clean), then fading out, so the edge is diffuse. A fading edge looks
  // smaller than a hard one, hence the larger radius than "solid".
  // A user-supplied gradient or tiling can't fade out: it is drawn solid.
  let soft = highlight-style == "gradient" and type(highlight-color) == color
  let scaled-highlight-radius = (if highlight-style == "gradient" { 0.6 } else { 0.45 }) * circle-size * scale
  let highlight-fill = if soft {
    gradient.radial(
      (highlight-color, 0%),
      (highlight-color, 60%),
      (highlight-color.transparentize(100%), 100%),
    )
  } else { highlight-color }
  // Arrows stop where a highlight visibly ends: mid-fade, or the hard edge
  let scaled-highlight-edge = (if soft { 0.8 } else { 1 }) * scaled-highlight-radius
  let scaled-bullet-radius = 0.09 * scale
  let scaled-font-size = 22 * scale
  let scaled-line-thickness = 0.85 * scale
  let scaled-arrow-mark = 1.5 * scale
  let scaled-nasal-dy = 0.44 * scale
  let scaled-nasal-font-size = scaled-font-size * 0.9 * 1pt
  let nasal-color = gray.darken(10%)
  let resolved-shift-size = if shift-size != none { shift-size * scale } else { scaled-font-size * 1pt }
  // Variant keys of each plotted vowel ("i" -> ("i", "iː")); presets have no length
  let plotted = vowels-to-plot.clusters().filter(v => v in vowel-data)
  let variants = if parsed-variants != none { parsed-variants } else {
    plotted.fold((:), (acc, v) => { acc.insert(v, (v,)); acc })
  }
  // Split highlight into regular-vowel highlights (strings) and shifted-vowel
  // highlights (arrays in the same (tipa-str, x, y) format as shift:).
  // Regular highlights name one variant: "i:" never highlights a short "i".
  let highlight-variants = highlight.filter(h => type(h) == str)
    .map(h => _resolve-variant(variants, ipa-to-unicode(h)))
    .filter(r => r != none)
  let highlight-shifts = highlight.filter(h => type(h) != str)
    .map(h => (ipa-to-unicode(h.at(0)), h.at(1), h.at(2)))
  let resolved-phoneme-colors = (:)
  for (phoneme, color) in phoneme-colors {
    resolved-phoneme-colors.insert(ipa-to-unicode(phoneme).normalize(form: "nfd"), color)
  }
  // Exact keys only: "a" and "a:" are independent characters. Keys compare
  // decomposed, so a precomposed "ã" matches the drawn a + combining tilde.
  let color-of(key) = resolved-phoneme-colors.at(key.normalize(form: "nfd"), default: none)
  let styled-text(size, key, fill: auto) = {
    let c = if fill != auto { fill } else { color-of(key) }
    if c != none {
      text(size: size, font: phonokit-font.get(), fill: c, top-edge: "x-height", bottom-edge: "baseline", key)
    } else {
      text(size: size, font: phonokit-font.get(), top-edge: "x-height", bottom-edge: "baseline", key)
    }
  }
  let vowel-text = (size, phoneme) => styled-text(size, phoneme)
  let shifted-vowel-text = (size, phoneme) => styled-text(size, phoneme,
    fill: { let c = color-of(phoneme); if c != none { c } else { shift-color } })

  // Context: length-marked variants are measured to lay them out side by side
  context canvas({
    import draw: *

    // Define the trapezoidal quadrilateral using scaled dimensions
    let trapezoid = (
      (-scaled-width / 2, scaled-height / 2.),
      (scaled-width / 2., scaled-height / 2),
      (scaled-width / 2., -scaled-height / 2),
      (-scaled-width / 10, -scaled-height / 2),
    )

    // Draw horizontal grid lines
    for i in range(1, rows) {
      let t = i / rows
      let left-x = trapezoid.at(0).at(0) * (1 - t) + trapezoid.at(3).at(0) * t
      let right-x = trapezoid.at(1).at(0) * (1 - t) + trapezoid.at(2).at(0) * t
      let y = scaled-height / 2 - (scaled-height * t)

      line((left-x, y), (right-x, y), stroke: (paint: gray.lighten(30%), thickness: scaled-line-thickness * 1pt))
    }

    // Draw vertical grid lines
    for i in range(1, cols) {
      let t = i / cols
      let top-x = trapezoid.at(0).at(0) * (1 - t) + trapezoid.at(1).at(0) * t
      let bottom-x = trapezoid.at(3).at(0) * (1 - t) + trapezoid.at(2).at(0) * t

      line((top-x, scaled-height / 2), (bottom-x, -scaled-height / 2), stroke: (
        paint: gray.lighten(30%),
        thickness: scaled-line-thickness * 1pt,
      ))
    }

    // Draw the outline
    line(..trapezoid, close: true, stroke: (paint: gray.lighten(30%), thickness: scaled-line-thickness * 1pt))

    // Lay out the variants of one vowel side by side ("i iː"), relative to
    // the vowel's position. The first variant's base glyph stays centered on
    // the position; the rest follow after a narrow space. Returns the
    // segments (key, dx: center offset) and `extra`, how far the label
    // reaches past the right edge of the base glyph.
    let width-of(size, body) = measure(text(size: size, font: phonokit-font.get(), body)).width / 1cm
    let layout(keys, glyph, size) = {
      let glyph-w = width-of(size, glyph)
      let gap = width-of(size, "\u{202F}")
      let left = -glyph-w / 2
      let segments = ()
      for (i, key) in keys.enumerate() {
        let w = width-of(size, key)
        segments.push((key: key, dx: if i == 0 { 0 } else { left + w / 2 }))
        left += w + gap
      }
      (segments: segments, extra: left - gap - glyph-w / 2)
    }
    let layouts = (:)
    for v in plotted {
      layouts.insert(v, layout(variants.at(v), v, scaled-font-size * 1pt))
    }

    // Label placement, in two steps.
    //
    // 1. Minimal pairs straddle a grid point, and the bullet sits on it.
    //    Each pair is laid out symmetrically around that point from the
    //    measured label widths: the left label ends, and the right label
    //    starts, half the usual gap away from it. Wide glyphs (ɯ, œ, ɶ) thus
    //    don't crowd their side of the bullet, and a length-marked left
    //    label grows leftwards ("i iː • y") instead of pushing its partner.
    // 2. Labels can still run into the next vowel in the row (ɪː ʏ, œː ɜ).
    //    Walk each row left to right and push a label right when the label
    //    before it comes closer than in the same chart without length marks:
    //    a pair partner keeps exactly that distance, any other neighbour
    //    keeps it or `min-gap`, whichever is smaller.
    let label-size = scaled-font-size * 1pt
    let min-gap = width-of(label-size, "\u{2002}")
    let is-pair(a, b) = (a.frontness == b.frontness and a.height == b.height
      and a.rounded != b.rounded)
    let row-items = plotted
      .map(v => (
        v: v,
        info: vowel-data.at(v),
        p: get-vowel-position(vowel-data.at(v), trapezoid, scaled-width, scaled-height, scaled-offset),
        half: width-of(label-size, v) / 2,
        extra: layouts.at(v).extra,
      ))
      .sorted(key: it => it.p.at(0))
    let same-row(a, b) = calc.abs(a.p.at(1) - b.p.at(1)) <= 0.001
    // Step 1: offsets from the canonical position, with length marks
    // (`with-length`) and as if there were none (`plain`, the reference
    // spacing for step 2)
    let pair-offset = (with-length: (:), plain: (:))
    for (j, b) in row-items.enumerate() {
      for a in row-items.slice(0, j) {
        if not (same-row(a, b) and is-pair(a.info, b.info)) { continue }
        let mid = (a.p.at(0) + b.p.at(0)) / 2
        let half-gap = (b.p.at(0) - a.p.at(0) - a.half - b.half) / 2
        pair-offset.plain.insert(a.v, mid - half-gap - a.half - a.p.at(0))
        pair-offset.with-length.insert(a.v, mid - half-gap - a.extra - a.half - a.p.at(0))
        let b-off = mid + half-gap + b.half - b.p.at(0)
        pair-offset.plain.insert(b.v, b-off)
        pair-offset.with-length.insert(b.v, b-off)
      }
    }
    let x-of(it, kind) = it.p.at(0) + pair-offset.at(kind).at(it.v, default: 0)
    // Step 2
    let label-shift = (:)
    for (j, b) in row-items.enumerate() {
      let b-left = x-of(b, "with-length") - b.half
      let b-left-plain = x-of(b, "plain") - b.half
      let need = 0
      for a in row-items.slice(0, j) {
        if not same-row(a, b) { continue }
        let a-right = x-of(a, "with-length") + a.half + a.extra + label-shift.at(a.v, default: 0)
        let usual = b-left-plain - (x-of(a, "plain") + a.half)
        let keep = if is-pair(a.info, b.info) { usual } else { calc.min(usual, min-gap) }
        need = calc.max(need, a-right + keep - b-left)
      }
      if need > 0.001 { label-shift.insert(b.v, need) }
    }
    let vowel-pos(v) = {
      let p = get-vowel-position(vowel-data.at(v), trapezoid, scaled-width, scaled-height, scaled-offset)
      (p.at(0) + pair-offset.with-length.at(v, default: 0) + label-shift.at(v, default: 0), p.at(1))
    }
    // Position of one variant of a plotted vowel
    let variant-pos(base, idx) = {
      let p = vowel-pos(base)
      (p.at(0) + layouts.at(base).segments.at(idx).dx, p.at(1))
    }
    // Where a shifted copy of `key` starts: the spot `key` itself occupies in
    // the chart. A plotted variant starts from its own slot ("iː" in "i iː"
    // starts right of i); anything else starts from its base vowel. `whole`
    // says how the copy is drawn there, matching the plotted label: centered
    // as a whole (later variants) or on its base glyph, with the length mark
    // overflowing to the right. So a shift of (0, 0) lands on the original,
    // and "i" and "iː" shifted by the same x keep their i's aligned.
    let shift-origin(key) = {
      let r = _resolve-variant(variants, key)
      if r != none { (pos: variant-pos(..r), whole: r.at(1) > 0) }
      else { (pos: vowel-pos(_strip-length(key)), whole: false) }
    }
    let shift-pos(key, dx, dy) = {
      let o = shift-origin(key).pos
      (o.at(0) + dx, o.at(1) + dy)
    }
    // Highlights and arrows aim at the centre of the whole label ("iː", not
    // its i). A label anchored on its base glyph has its centre this far to
    // the right of the anchor; zero for a plain vowel.
    let mark-offset(key, size) = (width-of(size, key) - width-of(size, _strip-length(key))) / 2
    let variant-centre(base, idx) = {
      let p = variant-pos(base, idx)
      let dx = if idx == 0 { mark-offset(variants.at(base).at(0), label-size) } else { 0 }
      (p.at(0) + dx, p.at(1))
    }
    let shift-centre(key, dx, dy) = {
      let p = shift-pos(key, dx, dy)
      let extra = if shift-origin(key).whole { 0 } else { mark-offset(key, resolved-shift-size) }
      (p.at(0) + extra, p.at(1))
    }

    // Collect vowel positions
    let vowel-positions = ()
    for vowel in vowels-to-plot.clusters() {
      if vowel in vowel-data {
        let vowel-info = vowel-data.at(vowel)
        vowel-positions.push((vowel: vowel, info: vowel-info, pos: vowel-pos(vowel)))
      }
    }

    // Build the global obstacle list for curved-arrow avoidance:
    // all plotted vowels plus all shifted copies, pre-computed once.
    let shifted-obs = shift
      .filter(s => _strip-length(ipa-to-unicode(s.at(0))) in vowel-data)
      .map(s => shift-centre(ipa-to-unicode(s.at(0)), s.at(1), s.at(2)))
    let preset-name = if vowel-string != none and vowel-string in language-vowels {
      vowel-string
    } else {
      lang
    }
    let nasal-bases = if preset-name != none and preset-name in language-nasal-vowels {
      language-nasal-vowels.at(preset-name)
    } else {
      nasal-target-vowels
    }
    // How far up a nasal copy must sit for its ink to just touch the oral
    // glyph below: the oral glyph's ink above its center plus the nasal
    // glyph's ink below its center. Labels are centered on the band between
    // baseline and x-height, so ascending ink (the dot of i, the slash of ø)
    // and descending ink (ỹ) both count.
    let ink(s, size, top, bottom) = measure(text(size: size, font: phonokit-font.get(),
      top-edge: top, bottom-edge: bottom, s)).height / 1cm
    let half-x(size) = ink("x", size, "x-height", "baseline") / 2
    let nasal-touch(v) = (
      ink(v, label-size, "bounds", "baseline") - half-x(label-size)
      + ink(v + "̃", scaled-nasal-font-size, "baseline", "bounds") + half-x(scaled-nasal-font-size)
    )
    // The default offset leaves x-height vowels (a, e, o...) this much room;
    // a row whose oral glyphs reach higher (i, ɨ, y, ø) lifts all its nasal
    // copies together to keep that room, so copies in a row stay level
    let nasal-room = scaled-nasal-dy - nasal-touch("a")
    let nasal-dy-at(y) = calc.max(scaled-nasal-dy, ..vowel-positions
      .filter(vp => vp.vowel in nasal-bases and calc.abs(vp.pos.at(1) - y) <= 0.001)
      .map(vp => nasal-touch(vp.vowel) + nasal-room))
    // auto: a custom string that writes a nasal vowel ("aã", "ã:") wants it
    // drawn; presets stay oral unless asked
    let show-nasals = if nasals == auto { nasal-target-vowels.len() > 0 } else { nasals }
    let nasal-positions = if show-nasals {
      vowel-positions
        .filter(vp => vp.vowel in nasal-bases)
        .map(vp => {
          let glyph = vp.vowel + "̃"
          let keys = parsed-nasal-variants.at(vp.vowel, default: (glyph,))
          (
            vowel: vp.vowel,
            pos: (vp.pos.at(0), vp.pos.at(1) + nasal-dy-at(vp.pos.at(1))),
            glyph: glyph,
            layout: layout(keys, glyph, scaled-nasal-font-size),
          )
        })
    } else {
      ()
    }
    // Nasal copies as targets: "ã" and "ã:" name a drawn nasal variant, by
    // exact key like oral ones. Returns (copy index, variant index) or none.
    let nasal-slot(key) = {
      let k = key.normalize(form: "nfd")
      for (j, np) in nasal-positions.enumerate() {
        let i = np.layout.segments.position(sg => sg.key == k)
        if i != none { return (j, i) }
      }
      none
    }
    // Centre of a nasal variant's whole label, as for oral variants
    let nasal-centre(j, i) = {
      let np = nasal-positions.at(j)
      let sg = np.layout.segments.at(i)
      let dx = sg.dx + if i == 0 { mark-offset(sg.key, scaled-nasal-font-size) } else { 0 }
      (np.pos.at(0) + dx, np.pos.at(1))
    }
    let nasal-highlights = highlight.filter(h => type(h) == str)
      .map(h => nasal-slot(ipa-to-unicode(h)))
      .filter(n => n != none)

    // Resolve an arrow endpoint to a canvas position.
    // endpoint is either a tipa string (a plotted variant, a drawn nasal copy,
    // or the canonical vowel position) or a
    // (tipa-str, x-offset, y-offset) array (shifted position, same format as shift:).
    // Returns (found, position) where found is false if the vowel is unknown.
    let pos-of(endpoint) = {
      let is-str = type(endpoint) == str
      let key = ipa-to-unicode(if is-str { endpoint } else { endpoint.at(0) })
      let v = _strip-length(key)
      let x-off = if is-str { 0 } else { endpoint.at(1) }
      let y-off = if is-str { 0 } else { endpoint.at(2) }
      // A plain endpoint on a plotted vowel targets that variant; shifted
      // endpoints and vowels not plotted use the canonical position
      let r = if is-str { _resolve-variant(variants, key) } else { none }
      let n = if is-str { nasal-slot(key) } else { none }
      if r != none {
        (true, variant-centre(..r))
      } else if n != none {
        (true, nasal-centre(..n))
      } else if not is-str and v in vowel-data {
        (true, shift-centre(key, x-off, y-off))
      } else if v in vowel-data and v not in variants {
        let base = vowel-pos(v)
        (true, (base.at(0) + x-off, base.at(1) + y-off))
      } else {
        (false, (0, 0))
      }
    }

    // Radius at which an arrow pointing at `endpoint` should stop: the edge of
    // the highlight circle if that vowel is highlighted, else the mask edge.
    let end-radius(endpoint) = {
      let highlighted = if type(endpoint) == str {
        let key = ipa-to-unicode(endpoint)
        _resolve-variant(variants, key) in highlight-variants or nasal-slot(key) in nasal-highlights
      } else {
        let v = ipa-to-unicode(endpoint.at(0))
        highlight-shifts.any(h => h.at(0) == v and h.at(1) == endpoint.at(1) and h.at(2) == endpoint.at(2))
      }
      if highlighted { calc.max(scaled-circle-radius, scaled-highlight-edge) } else { scaled-circle-radius }
    }

    // How far from `endpoint`'s centre an arrow ends (or starts) when it
    // leaves the label in direction (vx, vy). Highlights and lone labels use
    // their circle. A variant with a sibling ("uː" in "u uː") uses its own
    // label box instead: the circle would reach into the sibling, so the
    // head would sit on "u" while aiming at "uː".
    let edge-dist(endpoint, vx, vy) = {
      let r = end-radius(endpoint)
      if r > scaled-circle-radius or type(endpoint) != str { return r }
      let key = ipa-to-unicode(endpoint)
      let o = _resolve-variant(variants, key)
      let n = if o == none { nasal-slot(key) } else { none }
      let (label, size, siblings) = if o != none {
        (variants.at(o.at(0)).at(o.at(1)), label-size, variants.at(o.at(0)).len())
      } else if n != none {
        let segs = nasal-positions.at(n.at(0)).layout.segments
        (segs.at(n.at(1)).key, scaled-nasal-font-size, segs.len())
      } else { (none, none, 1) }
      if siblings < 2 { return r }
      let pad = scaled-circle-radius * 0.3
      let hw = width-of(size, label) / 2 + pad
      let hh = if vy > 0 {
        ink(label, size, "bounds", "baseline") - half-x(size) + pad
      } else {
        ink(label, size, "baseline", "bounds") + half-x(size) + pad
      }
      let ax = calc.abs(vx)
      let ay = calc.abs(vy)
      calc.min(if ax > 0.001 { hw / ax } else { r * 10 }, if ay > 0.001 { hh / ay } else { r * 10 })
    }

    let all-obstacle-positions = (
      vowel-positions.map(vp => layouts.at(vp.vowel).segments.map(sg => (vp.pos.at(0) + sg.dx, vp.pos.at(1)))).flatten().chunks(2)
      + shifted-obs
      + nasal-positions.map(np => np.layout.segments.map(sg => (np.pos.at(0) + sg.dx, np.pos.at(1)))).flatten().chunks(2)
    )

    // True if p is either at/near endpoint ep, or is its minimal-pair partner.
    // Minimal-pair partners share height (dy ≈ 0) and lie exactly 2×scaled-offset
    // apart in x (one rounded, one unrounded). They are geometrically inseparable
    // from their partner, so arrows approaching ep will inevitably pass near the
    // partner and should not try to avoid it. The ±40% relative tolerance on the
    // distance keeps the check scale-independent while excluding near-front lax
    // pairs like ɪ/ʏ (whose inter-vowel distance is only ~68% of 2×scaled-offset).
    let near-or-pair(p, ep) = {
      let dx = p.at(0) - ep.at(0)
      let dy = p.at(1) - ep.at(1)
      let d  = calc.sqrt(dx*dx + dy*dy)
      let at-endpoint   = d < scaled-circle-radius * 0.5
      let is-pair = calc.abs(dy) < scaled-offset * 0.1 and calc.abs(d - 2*scaled-offset) < scaled-offset * 0.4
      at-endpoint or is-pair
    }

    // Draw arrows in three phases so that arrowhead clustering can be applied
    // after all control points and tangents are known.

    // ── Phase 1: compute drawing parameters for every valid arrow ────────────
    // A straight arrow is drawn only if its head fits between the circle it
    // leaves and the one it reaches. With plain circles that is 0.7 × scale
    // plus the head (0.24 × scale for the default curved-stealth, 0.3 for
    // the triangle): æ→a and ɜ→ə fit. Side-by-side labels get a U or a loop
    // instead (below), so this never applies to them.
    let arrow-head-length = 0.2 * scaled-arrow-mark * arrow-heads.at(arrow-head)
    // The two bases an arrow links, if they are a minimal pair ("i" → "y")
    let pair-of(arrow) = {
      if type(arrow.at(0)) != str or type(arrow.at(1)) != str { return none }
      let r1 = _resolve-variant(variants, ipa-to-unicode(arrow.at(0)))
      let r2 = _resolve-variant(variants, ipa-to-unicode(arrow.at(1)))
      if r1 == none or r2 == none or r1.at(0) == r2.at(0) { return none }
      if is-pair(vowel-data.at(r1.at(0)), vowel-data.at(r2.at(0))) { (r1.at(0), r2.at(0)) } else { none }
    }
    // Vowels a minimal-pair U already runs under
    let pair-bases = arrows.map(pair-of).filter(p => p != none).flatten()
    let arrows-data = ()
    for arrow in arrows {
      let is-pair-arrow = pair-of(arrow) != none
      let arc-all = curved == true
      let fr = pos-of(arrow.at(0))
      let tr = pos-of(arrow.at(1))
      let dist = if fr.at(0) and tr.at(0) {
        let ddx = tr.at(1).at(0) - fr.at(1).at(0)
        let ddy = tr.at(1).at(1) - fr.at(1).at(1)
        calc.sqrt(ddx * ddx + ddy * ddy)
      } else { 0 }
      let ux = if dist > 0 { (tr.at(1).at(0) - fr.at(1).at(0)) / dist } else { 0 }
      let uy = if dist > 0 { (tr.at(1).at(1) - fr.at(1).at(1)) / dist } else { 0 }
      // Side-by-side labels (a minimal pair, or "i" and "iː"): a straight
      // arrow would run into the bullet or the sibling, so unless
      // `curved: false`, the arrow leaves downwards, runs under them and
      // comes up into the target. It has room for its head, so the minimum
      // distance doesn't apply.
      let rr = if type(arrow.at(0)) == str and type(arrow.at(1)) == str {
        (_resolve-variant(variants, ipa-to-unicode(arrow.at(0))), _resolve-variant(variants, ipa-to-unicode(arrow.at(1))))
      } else { (none, none) }
      let sibling-arrow = rr.at(0) != none and rr.at(1) != none and rr.at(0).at(0) == rr.at(1).at(0) and rr.at(0).at(1) != rr.at(1).at(1)
      if curved != false and (is-pair-arrow or sibling-arrow) and fr.at(0) and tr.at(0) {
        let from-pos = fr.at(1)
        let to-pos = tr.at(1)
        // A loop goes over the labels when a minimal-pair U already runs
        // under that vowel
        let up = sibling-arrow and rr.at(0).at(0) in pair-bases
        let side = if up { 1 } else { -1 }
        let start-r = edge-dist(arrow.at(0), 0, side)
        let end-r = edge-dist(arrow.at(1), 0, side)
        let af = (from-pos.at(0), from-pos.at(1) + side * start-r)
        let at = (to-pos.at(0), to-pos.at(1) + side * end-r)
        // A minimal pair gets a U. A vowel and its own long form are too
        // close for one, so their arrow loops wider than the two labels,
        // like a circular "reset" arrow: control points pushed outwards
        let dir = if at.at(0) >= af.at(0) { 1 } else { -1 }
        let (depth, spread) = if sibling-arrow {
          (scaled-circle-radius * 2.6, scaled-circle-radius * 1.6)
        } else {
          (calc.max(calc.abs(to-pos.at(0) - from-pos.at(0)) * 0.6, scaled-circle-radius * 1.2), 0)
        }
        let low = if up { calc.max(af.at(1), at.at(1)) + depth } else { calc.min(af.at(1), at.at(1)) - depth }
        let c1 = (af.at(0) - dir * spread, low)
        let c2 = (at.at(0) + dir * spread, low)
        let tx = at.at(0) - c2.at(0)
        let ty = at.at(1) - c2.at(1)
        let tn = calc.sqrt(tx * tx + ty * ty)
        arrows-data.push((
          id: arrows-data.len(),
          target: arrow.at(1),
          from-pos: from-pos,
          adjusted-from: af,
          to-pos: to-pos,
          ctrl: c1,
          ctrl2: c2,
          tangent: (tx / tn, ty / tn),
          adjusted-to: at,
          end-r: end-r,
          curved: true,
        ))
        continue
      }
      if dist > 0 and dist >= edge-dist(arrow.at(0), ux, uy) + edge-dist(arrow.at(1), -ux, -uy) + arrow-head-length {
        let from-pos = fr.at(1)
        let to-pos = tr.at(1)
        let dx = to-pos.at(0) - from-pos.at(0)
        let dy = to-pos.at(1) - from-pos.at(1)
        let mid-x = (from-pos.at(0) + to-pos.at(0)) / 2
        let mid-y = (from-pos.at(1) + to-pos.at(1)) / 2

        // Control point selection for curved arrows.
        // Two obstacle lists are used in priority order:
        //   strict – excludes only the exact endpoints; pair partners are live
        //            obstacles so the algorithm avoids departing through them
        //            (e.g. ɔ→ɪ must not start by crossing through ʌ).
        //   loose  – also excludes pair partners; used as a fallback only when
        //            no strict-safe path exists.
        // Sampling at t = 0.1 and 0.9 (in addition to interior midpoints) catches
        // obstacles very close to the source or destination vowel.
        let ctrl = if arc-all {
          let px = -dy / dist  // CCW perpendicular unit vector
          let py =  dx / dist
          let ccw-sm = (mid-x + px * dist * 0.30, mid-y + py * dist * 0.30)
          let cw-sm  = (mid-x - px * dist * 0.30, mid-y - py * dist * 0.30)
          let ccw-lg = (mid-x + px * dist * 0.55, mid-y + py * dist * 0.55)
          let cw-lg  = (mid-x - px * dist * 0.55, mid-y - py * dist * 0.55)
          let local-obs-strict = all-obstacle-positions.filter(p => {
            let dfx = p.at(0) - from-pos.at(0)
            let dfy = p.at(1) - from-pos.at(1)
            let dtx = p.at(0) - to-pos.at(0)
            let dty = p.at(1) - to-pos.at(1)
            let far-from = calc.sqrt(dfx*dfx + dfy*dfy) > scaled-circle-radius * 0.5
            let far-to   = calc.sqrt(dtx*dtx + dty*dty) > scaled-circle-radius * 0.5
            far-from and far-to
          })
          let local-obs-loose = all-obstacle-positions.filter(p =>
            not near-or-pair(p, from-pos) and not near-or-pair(p, to-pos)
          )
          let clearance(t) = scaled-circle-radius * 1.3
          let sample-ts = (0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9)
          let hits(obs, c) = obs.any(ob =>
            sample-ts.any(t => {
              let bx = (1-t)*(1-t)*from-pos.at(0) + 2*t*(1-t)*c.at(0) + t*t*to-pos.at(0)
              let by = (1-t)*(1-t)*from-pos.at(1) + 2*t*(1-t)*c.at(1) + t*t*to-pos.at(1)
              let ex = ob.at(0) - bx
              let ey = ob.at(1) - by
              calc.sqrt(ex*ex + ey*ey) < clearance(t)
            })
          )
          // Where the head lands for control point c: it must stay off every
          // other label, including a sibling variant ("u" when aiming at "uː")
          let head-hits(c) = {
            let ex = to-pos.at(0) - c.at(0)
            let ey = to-pos.at(1) - c.at(1)
            let ed = calc.sqrt(ex * ex + ey * ey)
            let end-r = edge-dist(arrow.at(1), -ex / ed, -ey / ed)
            let tip = (to-pos.at(0) - ex / ed * end-r, to-pos.at(1) - ey / ed * end-r)
            let back = (tip.at(0) - ex / ed * arrow-head-length, tip.at(1) - ey / ed * arrow-head-length)
            local-obs-strict.any(ob => (tip, back).any(q => {
              let qx = ob.at(0) - q.at(0)
              let qy = ob.at(1) - q.at(1)
              calc.sqrt(qx * qx + qy * qy) < scaled-circle-radius * 0.7
            }))
          }
          // Flatter and wider arcs give a crowded target a clean way in
          let ccw-xs = (mid-x + px * dist * 0.15, mid-y + py * dist * 0.15)
          let cw-xs  = (mid-x - px * dist * 0.15, mid-y - py * dist * 0.15)
          let ccw-xl = (mid-x + px * dist * 0.80, mid-y + py * dist * 0.80)
          let cw-xl  = (mid-x - px * dist * 0.80, mid-y - py * dist * 0.80)
          let ctrl-candidates = (ccw-sm, cw-sm, ccw-lg, cw-lg, ccw-xs, cw-xs, ccw-xl, cw-xl)
          let chosen = ctrl-candidates.find(c => not hits(local-obs-strict, c) and not head-hits(c))
          let chosen = if chosen != none { chosen } else {
            ctrl-candidates.slice(0, 4).find(c => not hits(local-obs-strict, c))
          }
          let chosen = if chosen != none { chosen } else {
            ctrl-candidates.slice(0, 4).find(c => not hits(local-obs-loose, c))
          }
          if chosen != none { chosen } else { ccw-sm }
        } else {
          (mid-x + (-dy / dist) * dist * 0.3, mid-y + (dx / dist) * dist * 0.3)
        }

        // Tangent at destination: ctrl→to-pos for curves, chord for straight lines.
        let tangent = if arc-all {
          let ex = to-pos.at(0) - ctrl.at(0)
          let ey = to-pos.at(1) - ctrl.at(1)
          let ed = calc.sqrt(ex * ex + ey * ey)
          (ex / ed, ey / ed)
        } else {
          (dx / dist, dy / dist)
        }

        // Pull endpoint back to the target's edge along the arrival tangent
        let end-r = edge-dist(arrow.at(1), -tangent.at(0), -tangent.at(1))
        let adjusted-to = (
          to-pos.at(0) - tangent.at(0) * end-r,
          to-pos.at(1) - tangent.at(1) * end-r,
        )

        // Start at the source circle's edge along the departure tangent:
        // arrows are drawn above masks and highlights, so nothing hides
        // a line that starts at the centre
        let start-tangent = if arc-all {
          let sx = ctrl.at(0) - from-pos.at(0)
          let sy = ctrl.at(1) - from-pos.at(1)
          let sd = calc.sqrt(sx * sx + sy * sy)
          (sx / sd, sy / sd)
        } else {
          (dx / dist, dy / dist)
        }
        let start-r = edge-dist(arrow.at(0), start-tangent.at(0), start-tangent.at(1))
        let adjusted-from = (
          from-pos.at(0) + start-tangent.at(0) * start-r,
          from-pos.at(1) + start-tangent.at(1) * start-r,
        )

        arrows-data.push((
          id: arrows-data.len(),
          target: arrow.at(1),
          from-pos: from-pos,
          adjusted-from: adjusted-from,
          to-pos: to-pos,
          ctrl: ctrl,
          tangent: tangent,
          adjusted-to: adjusted-to,
          end-r: end-r,
          curved: arc-all,
          ctrl2: none,
          // A straight arrow across a minimal pair replaces its bullet
          straight-pair: if arc-all { none } else { pair-of(arrow) },
        ))
      }
    }

    // ── Phase 2: arrowheads converging at the same vowel ──────────────────
    // Arrows whose tips land close together at one target would draw heads on
    // top of each other. Instead every arrow keeps its head, and the tips are
    // spread around the target's edge, a head width apart, in the order the
    // arrows arrive, so the lines don't cross at the end.
    let head-width = 0.15 * scaled-arrow-mark * arrow-heads.at(arrow-head)
    let cluster-radius = scaled-circle-radius
    let arrows-data = arrows-data.map(a => {
      let cluster = arrows-data.filter(b => {
        let dtx = b.to-pos.at(0) - a.to-pos.at(0)
        let dty = b.to-pos.at(1) - a.to-pos.at(1)
        let same-target = calc.sqrt(dtx*dtx + dty*dty) < 0.01
        let dax = b.adjusted-to.at(0) - a.adjusted-to.at(0)
        let day = b.adjusted-to.at(1) - a.adjusted-to.at(1)
        same-target and calc.sqrt(dax*dax + day*day) < cluster-radius
      })
      if cluster.len() < 2 { return a }
      let n = cluster.len()
      let tx = cluster.map(b => b.tangent.at(0)).sum() / n
      let ty = cluster.map(b => b.tangent.at(1)).sum() / n
      let tn = calc.sqrt(tx*tx + ty*ty)
      let avg = if tn > 0.001 { (tx/tn, ty/tn) } else { a.tangent }
      // Outward direction from the target towards the arrivals
      let out = (-avg.at(0), -avg.at(1))
      // Rank arrivals by angle around the average direction
      let rel(b) = {
        let d = (-b.tangent.at(0), -b.tangent.at(1))
        calc.atan2(d.at(0) * out.at(0) + d.at(1) * out.at(1), out.at(0) * d.at(1) - out.at(1) * d.at(0))
      }
      let order = cluster.sorted(key: b => rel(b).rad()).map(b => b.id)
      let k = order.position(x => x == a.id)
      let e0 = edge-dist(a.target, out.at(0), out.at(1))
      let step = 1.3 * head-width / e0
      let theta = calc.atan2(out.at(0), out.at(1)) + (k - (n - 1) / 2) * step * 1rad
      let d = (calc.cos(theta), calc.sin(theta))
      let e = edge-dist(a.target, d.at(0), d.at(1))
      let tip = (a.to-pos.at(0) + d.at(0) * e, a.to-pos.at(1) + d.at(1) * e)
      let back = if a.curved { if a.ctrl2 != none { a.ctrl2 } else { a.ctrl } } else { a.adjusted-from }
      let vx = tip.at(0) - back.at(0)
      let vy = tip.at(1) - back.at(1)
      let vn = calc.sqrt(vx * vx + vy * vy)
      a + (tangent: (vx / vn, vy / vn), adjusted-to: tip)
    })

    // Shifted vowels: (vowel, position, highlighted)
    let shift-positions = ()
    for s in shift {
      // The shifted copy keeps its length mark and starts from its own spot
      let vowel = ipa-to-unicode(s.at(0))
      let x-off = s.at(1)
      let y-off = s.at(2)
      if _strip-length(vowel) in vowel-data {
        shift-positions.push((
          vowel: vowel,
          pos: shift-pos(vowel, x-off, y-off),
          centre: shift-centre(vowel, x-off, y-off),
          whole: shift-origin(vowel).whole,
          highlighted: highlight-shifts.any(h => h.at(0) == vowel and h.at(1) == x-off and h.at(2) == y-off),
        ))
      }
    }

    // ── Phase 3: render ──────────────────────────────────────────────────────
    // Shafts go under the masks, so a line passes under every label it
    // crosses (as on main); heads go on top of masks and highlights, so a
    // head is never covered at its target.
    let shaft-stroke = (paint: arrow-color, thickness: scaled-line-thickness * 1.5pt,
      dash: if arrow-style == "dashed" { "dashed" } else { none })
    let head-stroke = (paint: arrow-color, thickness: scaled-line-thickness * 1.5pt)
    let mark-style = (end: arrow-head, fill: arrow-color,
      stroke: (paint: arrow-color, thickness: scaled-line-thickness * 1.5pt),
      scale: scaled-arrow-mark * arrow-heads.at(arrow-head))
    // Each arrow is cut where it reaches the back of its head: the shaft runs
    // up to that point, and the head points from it to the tip. On a tight
    // curve the tip tangent and the line under the head differ, so a head
    // aligned with the tip tangent would look kinked against the shaft.
    let lerp(p, q, t) = (p.at(0) + (q.at(0) - p.at(0)) * t, p.at(1) + (q.at(1) - p.at(1)) * t)
    // Point at t, and the control points of the part from 0 to t
    // (de Casteljau), for a line, a quadratic or a cubic curve
    let split(a, t) = {
      let p0 = a.adjusted-from
      let p3 = a.adjusted-to
      if not a.curved { (point: lerp(p0, p3, t), ctrls: ()) }
      else if a.ctrl2 == none {
        let q0 = lerp(p0, a.ctrl, t)
        let q1 = lerp(a.ctrl, p3, t)
        (point: lerp(q0, q1, t), ctrls: (q0,))
      } else {
        let q0 = lerp(p0, a.ctrl, t)
        let q1 = lerp(a.ctrl, a.ctrl2, t)
        let q2 = lerp(a.ctrl2, p3, t)
        let r0 = lerp(q0, q1, t)
        let r1 = lerp(q1, q2, t)
        (point: lerp(r0, r1, t), ctrls: (q0, r0))
      }
    }
    let dist2(p, q) = calc.sqrt(calc.pow(p.at(0) - q.at(0), 2) + calc.pow(p.at(1) - q.at(1), 2))
    // Parameter where the curve is one head length from the tip (bisection)
    let head-cut(a) = {
      let (lo, hi) = (0.0, 1.0)
      for _ in range(24) {
        let mid = (lo + hi) / 2
        if dist2(split(a, mid).point, a.adjusted-to) > arrow-head-length { lo = mid } else { hi = mid }
      }
      lo
    }
    let arrows-data = arrows-data.map(a => {
      let t = head-cut(a)
      let part = split(a, t)
      a + (head-back: part.point, shaft-ctrls: part.ctrls)
    })
    for a in arrows-data {
      if a.shaft-ctrls.len() > 0 {
        bezier(a.adjusted-from, a.head-back, ..a.shaft-ctrls, stroke: shaft-stroke)
      } else {
        line(a.adjusted-from, a.head-back, stroke: shaft-stroke)
      }
    }

    // White mask circles: cut a gap in the grid lines behind every vowel, shifted ones included.
    // All masks go before any highlight, so a mask never covers a neighbouring highlight circle.
    for vp in vowel-positions + shift-positions {
      circle(vp.pos, radius: scaled-circle-radius, fill: white, stroke: none)
    }
    // Length-marked variants extend to the right: mask under them too, so
    // grid lines don't cross "iː"
    for vp in vowel-positions {
      let extra = layouts.at(vp.vowel).extra
      if extra <= 0.001 { continue }
      let left = vp.pos.at(0) + width-of(scaled-font-size * 1pt, vp.vowel) / 2
      rect((left, vp.pos.at(1) - scaled-circle-radius * 0.8), (left + extra, vp.pos.at(1) + scaled-circle-radius * 0.8), fill: white, stroke: none)
    }

    // Highlight circles: above the masks and arrow shafts, below arrowheads,
    // minimal-pair bullets and symbols. Each one sits on the highlighted variant.
    for r in highlight-variants.dedup() {
      circle(variant-centre(..r), radius: scaled-highlight-radius, fill: highlight-fill, stroke: none)
    }
    for n in nasal-highlights.dedup() {
      circle(nasal-centre(..n), radius: scaled-highlight-radius, fill: highlight-fill, stroke: none)
    }
    for sp in shift-positions.filter(sp => sp.highlighted) {
      circle(sp.centre, radius: scaled-highlight-radius, fill: highlight-fill, stroke: none)
    }

    // Arrowheads: from the cut to the tip, so the shaft meets the middle of
    // the head's back
    for a in arrows-data {
      line(a.head-back, a.adjusted-to, stroke: head-stroke, mark: mark-style)
    }

    // Draw bullets between minimal pairs (same frontness/height, different rounding)
    for i in range(vowel-positions.len()) {
      for j in range(i + 1, vowel-positions.len()) {
        let v1 = vowel-positions.at(i)
        let v2 = vowel-positions.at(j)

        // Check if they form a minimal pair
        let same-front = v1.info.frontness == v2.info.frontness
        let same-height = v1.info.height == v2.info.height
        let diff-round = v1.info.rounded != v2.info.rounded

        // A straight arrow drawn between the pair already links them and
        // would run into the bullet, so the bullet is left out
        let linked = arrows-data.any(a => a.at("straight-pair", default: none) != none
          and a.straight-pair.contains(v1.vowel) and a.straight-pair.contains(v2.vowel))
        if same-front and same-height and diff-round and not linked {
          // Center the bullet in the gap between the two labels, not between
          // the vowel positions: a wide glyph (ɯ, œ, ɶ) would otherwise
          // crowd its side. A length-marked left label counts from its end.
          let (left, right) = if v1.pos.at(0) <= v2.pos.at(0) { (v1, v2) } else { (v2, v1) }
          let left-end = left.pos.at(0) + width-of(label-size, left.vowel) / 2 + layouts.at(left.vowel).extra
          let right-start = right.pos.at(0) - width-of(label-size, right.vowel) / 2
          let mid-x = (left-end + right-start) / 2
          let mid-y = (v1.pos.at(1) + v2.pos.at(1)) / 2
          circle((mid-x, mid-y), radius: scaled-bullet-radius, fill: black)
        }
      }
    }

    // Plot vowel symbols
    // Labels are boxed from baseline to x-height, so the canvas bounds miss
    // ink above and below that band (the dot of i, nasal tildes, descenders).
    // An invisible vertical line through each label spans its full ink, so
    // the chart's box contains every glyph and tight page margins don't clip.
    let ink-guard(pos, s, size) = line(
      (pos.at(0), pos.at(1) - ink(s, size, "baseline", "bounds") - half-x(size)),
      (pos.at(0), pos.at(1) + ink(s, size, "bounds", "baseline") - half-x(size)),
      stroke: none)
    // Draw the variants of one vowel. The first sits in an overflowing box
    // as wide as the base glyph, so that glyph stays centered on the position
    // even when a length mark follows it; the others are centered on their
    // own slots.
    // `fallback` is the fill for keys without a colour in phoneme-colors
    // (grey for nasal copies); none keeps the regular text colour.
    let draw-variants(pos, glyph, lay, size, fallback: none) = {
      for (i, sg) in lay.segments.enumerate() {
        ink-guard((pos.at(0) + sg.dx, pos.at(1)), sg.key, size)
        let fill = if fallback == none { auto } else {
          let c = color-of(sg.key)
          if c != none { c } else { fallback }
        }
        let body = styled-text(size, sg.key, fill: fill)
        if i == 0 {
          content(pos, context box(width: measure(styled-text(size, glyph, fill: fill)).width, body))
        } else {
          content((pos.at(0) + sg.dx, pos.at(1)), body)
        }
      }
    }
    for vp in vowel-positions {
      draw-variants(vp.pos, vp.vowel, layouts.at(vp.vowel), scaled-font-size * 1pt)
    }

    // Draw schematic nasalized copies slightly offset from the oral vowels.
    for np in nasal-positions {
      draw-variants(np.pos, np.glyph, np.layout, scaled-nasal-font-size, fallback: nasal-color)
    }

    // Draw shifted vowel symbols (on top of regular vowels)
    for sp in shift-positions {
      ink-guard(sp.pos, sp.vowel, resolved-shift-size)
      let body = shifted-vowel-text(resolved-shift-size, sp.vowel)
      content(sp.pos, if sp.whole { body } else {
        box(width: measure(shifted-vowel-text(resolved-shift-size, _strip-length(sp.vowel))).width, body)
      })
    }
  })
}
