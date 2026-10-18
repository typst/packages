#import "@preview/rubby:0.10.2": get-ruby
#import "utils.typ": segment-content

// ── default styles ────────────────────────────────────────────────────────────

/// Default ruby styles for pīnyīn annotation.
/// Pass a modified copy as `ruby-styles` to override individual keys.
/// `pos` must be `top` or `bottom` (without quotes, rubby constraint).
#let _default-pinyin-ruby-styles = (
  size:         0.7em,
  dy:           0pt,
  pos:          top,
  alignment:    "center",
  delimiter:    "|",
  auto-spacing: true,
)

// ── segment renderer ──────────────────────────────────────────────────────────

/// Render one segment dict `{word, pinyin}` as pīnyīn-annotated content.
/// Delegates to `rubby`'s `get-ruby` for top/bottom placement.
#let _render-segment-pinyin(seg, ruby-styles: (:)) = {
  if seg.pinyin == none {
    if seg.word == "\n" { linebreak() }
    else { seg.word }
  } else {
    ruby-styles    = _default-pinyin-ruby-styles + ruby-styles
    let ruby-fn    = get-ruby(..ruby-styles)
    let annotation = seg.pinyin.join(ruby-styles.delimiter)
    let base       = seg.word.clusters().join(ruby-styles.delimiter)
    ruby-fn(annotation, base)
  }
}

/// Render an array of segment dicts with pīnyīn annotations.
///
/// Parameters:
/// - `segs`        — array from `segment()` or `segment-content()`
/// - `ruby-styles` — style dict (see `_default-pinyin-ruby-styles`)
/// - `word-sep`    — horizontal gap between consecutive Chinese words
///                   (default: 0.25em). Pass `0em` to disable.
#let render-segments-pinyin(segs, ruby-styles: _default-pinyin-ruby-styles, word-sep: 0.25em) = {
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
    _render-segment-pinyin(seg, ruby-styles: ruby-styles)
    i += 1
  }
}

/// High-level function: annotate Chinese text with pīnyīn ruby.
///
/// Parameters:
/// - `it`          — string or content block
/// - `style`       — `"marks"` (default) or `"numbers"`
/// - `ruby-styles` — style dict (see `_default-pinyin-ruby-styles`)
/// - `word-sep`    — gap between consecutive Chinese words (default: 0.25em)
///
/// Example:
/// ```typst
/// #pinyin-ruby[北京歡迎你！]
/// #pinyin-ruby(style: "numbers")[北京]
/// #pinyin-ruby(ruby-styles: (size: 0.5em, dy: 0pt, pos: top,
///                             alignment: "center", auto-spacing: true))[北京]
/// ```
#let pinyin-ruby(
  it,
  style:       "marks",
  ruby-styles: _default-pinyin-ruby-styles,
  word-sep:    0.25em,
) = {
  render-segments-pinyin(
    segment-content(it, style: style),
    ruby-styles: ruby-styles,
    word-sep:    word-sep,
  )
}
