#import "@preview/rubby:0.10.2": get-ruby
#import "utils.typ": segment-content, pinyin-to-zhuyin

// ── default styles ────────────────────────────────────────────────────────────

/// Default ruby styles for zhùyīn (bopomofo) annotation.
/// Pass a modified copy as `ruby-styles` to override individual keys.
///
/// `pos` may be:
///   top | bottom — rendered via `rubby`
///   left | right — rendered manually with `box` + `stack`
///                      (traditional Taiwanese textbook right-side placement)
#let _default-zhuyin-ruby-styles = (
  size:         0.33em,
  dy:           0pt,
  pos:          right,
  alignment:    "center",
  delimiter:    "|",
  auto-spacing: true,
)

// ── manual left/right renderer ────────────────────────────────────────────────

/// Render a single (base-char, zhuyin-str) pair with the annotation placed
/// to the left or right of the character using `box` + `stack`.
///
/// The zhuyin string (e.g. "ㄆㄧㄣˉ") is split into grapheme clusters and
/// stacked top-to-bottom to form a vertical annotation column, matching the
/// traditional right-side bopomofo display in Taiwanese textbooks.
/// For neutral tone (e.g. "·ㄇㄚ") the dot is the first cluster and is
/// rendered above the bopomofo body, also scaled up for legibility.
#let _zhuyin-manual-pair(char, zhuyin-str, ruby-styles) = {
  set text(top-edge: "ascender", bottom-edge: "descender")
  let clusters = zhuyin-str.clusters()
  let rb-size  = ruby-styles.size

  // Detect neutral tone: dot is a prefix (first cluster is "·")
  let is-neutral = clusters.first() == "·"

  let (glyphs, tone) = if is-neutral {
    (clusters.slice(1),   "·")   // body after dot; dot rendered first (top)
  } else {
    (clusters.slice(0,-1), clusters.last())  // body; suffix tone mark at bottom
  }

  let tone-box = scale(
    text(size: rb-size, tone, top-edge: "bounds", bottom-edge: "bounds"),
    200%,
    reflow: true,
  )
  let body-text = text(size: rb-size, stack(dir: ttb, ..glyphs))

  let ann-col = box(
    width: rb-size * 2,
    align(center,
      box(
        align(bottom,
          // Neutral: dot on top, then body. Tones 1–4: body, then mark below.
          if is-neutral {
            stack(tone-box, body-text, dir: ttb)
          } else {
            stack(body-text, tone-box, dir: ltr)
          }
        ),
      )
    ),
  )
  let base-col = text(char)
  let items    = if ruby-styles.pos == "left" {
    (ann-col, base-col)
  } else {
    (base-col, ann-col)
  }
  box(baseline: 0.12em, align(horizon, stack(dir: ltr, ..items)))
}

// ── segment renderer ──────────────────────────────────────────────────────────

/// Render one segment dict `{word, pinyin}` as zhùyīn-annotated content.
///
/// - `ruby-styles` is a dictionary of style keys (see `_default-zhuyin-ruby-styles`).
/// - For `pos: top` / `bottom`, the full zhuyin string per character is
///   passed to `rubby`'s `get-ruby` (annotation stays as a horizontal string).
/// - For `pos: left` / `right`, each character is rendered individually
///   via the manual `box + stack` layout.
#let _render-segment-zhuyin(seg, ruby-styles: (:)) = {
  if seg.pinyin == none {
    if seg.word == "\n" { linebreak() }
    else { seg.word }
  } else {
    let chars   = seg.word.clusters()
    let zy-arr  = seg.pinyin.map(pinyin-to-zhuyin)  // one zhuyin str per char
    ruby-styles = _default-zhuyin-ruby-styles + ruby-styles
    let pos     = ruby-styles.pos

    if pos == top or pos == bottom {
      let ruby-fn = get-ruby(
        size:         ruby-styles.size,
        dy:           ruby-styles.dy,
        pos:          pos,
        alignment:    ruby-styles.alignment,
        delimiter:    ruby-styles.delimiter,
        auto-spacing: ruby-styles.auto-spacing,
      )
      ruby-fn(zy-arr.join("|"), chars.join("|"))
    } else {
      // left/right: render each (char, zhuyin) pair individually
      for (char, zy) in chars.zip(zy-arr) {
        _zhuyin-manual-pair(char, zy, ruby-styles)
      }
    }
  }
}

/// Render an array of segment dicts with zhùyīn annotations.
///
/// Parameters:
/// - `segs`        — array from `segment()` or `segment-content()`
/// - `ruby-styles` — style dict (see `_default-zhuyin-ruby-styles`)
/// - `word-sep`    — horizontal gap between consecutive Chinese words
///                   (default: 0.25em). Pass `0em` to disable.
#let render-segments-zhuyin(segs, ruby-styles: _default-zhuyin-ruby-styles, word-sep: 0.25em) = {
  let n = segs.len()
  let i = 0
  while i < n {
    let seg  = segs.at(i)
    let next = if i + 1 < n { segs.at(i + 1) } else { none }
    // Two consecutive \n → paragraph break.
    if seg.word == "\n" and next != none and next.word == "\n" {
      parbreak(); i += 2; continue
    }
    // Gap between consecutive Chinese words.
    if word-sep != 0em and i > 0 {
      let prev = segs.at(i - 1)
      if seg.pinyin != none and prev.pinyin != none { h(word-sep) }
    }
    _render-segment-zhuyin(seg, ruby-styles: ruby-styles)
    i += 1
  }
}

/// High-level function: annotate Chinese text with zhùyīn (bopomofo) ruby.
///
/// Parameters:
/// - `it`          — string or content block
/// - `ruby-styles` — style dict (see `_default-zhuyin-ruby-styles`)
/// - `word-sep`    — gap between consecutive Chinese words (default: 0.25em)
///
/// Example:
/// ```typst
/// #zhuyin-ruby[北京歡迎你！]   // right-side by default
///
/// // Top placement:
/// #zhuyin-ruby(ruby-styles: (size: 0.5em, dy: 0pt, pos: top,
///                             alignment: "center", auto-spacing: true))[北京]
/// ```
#let zhuyin-ruby(
  it,
  ruby-styles: _default-zhuyin-ruby-styles,
  word-sep:    0.25em,
) = {
  render-segments-zhuyin(
    segment-content(it, style: "numbers"),
    ruby-styles: ruby-styles,
    word-sep:    word-sep,
  )
}
