#import "_config.typ": phonokit-font

/// Place a ToBI label above the current inline text position
///
/// Designed to be placed inline immediately after the syllable or word being annotated.
/// The label floats above the text at the insertion point, optionally connected by
/// a vertical stem.
///
/// Always pass labels as *strings* (e.g. `"H*"`), not bare content (`[H*]`), since
/// characters like `*` and `_` have special meaning in Typst markup. Use ASCII
/// hyphens for phrase accents (e.g. `"L-"`, `"L-H%"`); en/em dashes are
/// automatically normalized to hyphens. Double hyphens are converted to superscript "-".
///
/// Arguments:
/// - label (string): ToBI label
/// - line (boolean): draw a vertical stem connecting label to text (default: true)
/// - height (length): distance from text baseline to the bottom of the label (default: 1.8em)
/// - lift (length): gap between text baseline and stem bottom (default: 0.6em)
/// - gap (length): gap between stem top and label bottom (default: 0.15em)
/// - en-dash (boolean): render phrase-accent hyphens as en dashes (default: false)
///
/// Example:
/// ```
/// #import "@preview/phonokit:0.5.4": *
/// You're a were#int("*L")wolf?#h(1em)#int("H%", line: false)

/// ```
#let int(
  label,
  line: true,
  height: 2em,
  lift: 0.8em,
  gap: 0.22em,
  en-dash: true,
) = context {
  // Normalize all dash variants to ASCII hyphen, then output in the desired
  // form. U+2011 (non-breaking hyphen, class GL) never breaks. For en-dash
  // rendering, U+2060 (word joiner, class WJ) prepended to U+2013 suppresses
  // any break opportunity around the en dash.
  let single-dash = s => if en-dash { s.replace("-", "\u{2060}\u{2013}\u{2060}") } else { s.replace("-", "\u{2011}") }
  let normalize-str = s => single-dash(
    s.replace("\u{2011}", "-").replace("\u{2013}", "-").replace("\u{2014}", "-"),
  )
  // "--" becomes a superscript en-dash (Zsiga-style phrase accent).
  // Normalize other dashes first, then split on "--" before the
  // single-dash replacement so the two hyphens aren't individually
  // converted. Use a for loop to build content instead of .join()
  // to avoid content-separator ambiguity.
  let lbl-text = if type(label) == str {
    let base = label.replace("\u{2011}", "-").replace("\u{2013}", "-").replace("\u{2014}", "-")
    if base.contains("--") {
      let parts = base.split("--").map(single-dash)
      text(font: phonokit-font.get(), size: 0.8em, {
        parts.at(0)
        for i in range(1, parts.len()) {
          super(size: 0.90em, [–])
          parts.at(i)
        }
      })
    } else {
      text(font: phonokit-font.get(), size: 0.8em, normalize-str(label))
    }
  } else {
    text(font: phonokit-font.get(), size: 0.8em, label)
  }
  let lbl-w = measure(lbl-text).width
  let lbl-h = measure(lbl-text).height
  let lbl = box(width: lbl-w, lbl-text)
  // baseline: 0pt places the box bottom at the text baseline,
  // so the box extends upward to reserve space for the annotation.
  // place() positions elements absolutely so surrounding alignment cannot shift them.
  let stem-h = height - lift - gap
  box(width: 0pt, height: height + lbl-h, baseline: 0pt, {
    // Stem (anchored at bottom-left, offset upward by lift)
    if line {
      place(bottom + left, dy: -lift, rect(width: 0.05em, height: stem-h, fill: black, stroke: none))
    }
    // Label (anchored at top, centered horizontally via dx)
    place(top + left, dx: -lbl-w / 2, lbl)
  })
}
