// Plot decoration: title / subtitle / caption / tag blocks, plot-background
// padding, chrome extent reservation, and final stack composition.

#import "../utils/margin.typ": resolve-margin-side-rel-cm
#import "../theme/theme.typ": _rect-style, _text-args, _text-style
#import "../utils/typst-markup.typ": resolve-prose
#import "extents.typ": _text-margin-cm

// Resolve a `margin(...)` record into a four-side dict of absolute Typst
// cm lengths. Per-side `%` / `relative` values are resolved against the
// canvas dims (`ref-w` for horizontal sides, `ref-h` for vertical), so
// plot-background's `pad()` / `block(inset:)` agree with the cetz rect
// surfaces on what `100%` means (the plot canvas, not the surrounding
// Typst block).
#let _margin-lengths(rec, ref-w, ref-h, size-pt) = (
  top: resolve-margin-side-rel-cm(rec.top, ref-h, size-pt: size-pt) * 1cm,
  right: resolve-margin-side-rel-cm(rec.right, ref-w, size-pt: size-pt) * 1cm,
  bottom: resolve-margin-side-rel-cm(rec.bottom, ref-h, size-pt: size-pt) * 1cm,
  left: resolve-margin-side-rel-cm(rec.left, ref-w, size-pt: size-pt) * 1cm,
)

// Build the decoration blocks (title / subtitle / caption), the plot-background
// `pad()` / `block(inset:)` padding, and the inter-block gaps once, against the
// *requested* image dims (`ref-w` / `ref-h`). The same dict feeds both
// `_decorate-extents` (reserve chrome before sizing the canvas) and
// `_render-decorate` (compose the final stack), so measured and composed agree.
//
// Chrome text is boxed to the inner content width (requested width minus left
// and right padding) so long titles wrap rather than widening the image past
// the requested `width`.
#let _decorate-parts(labs, theme, ref-w, ref-h) = {
  let plot-bg = _rect-style(
    theme,
    "plot-background",
    inset-ref-w: ref-w,
    inset-ref-h: ref-h,
    outset-ref-w: ref-w,
    outset-ref-h: ref-h,
  )
  // `inset` grows the fill past the content via Typst `block(inset: ...)`
  // (inner padding); `outset` reserves whitespace around the block by
  // wrapping it in an outer `pad(...)` (outer margin).
  let _size-pt = if (
    type(theme.at("text", default: none)) == dictionary
      and theme.text.at("size", default: none) != none
  ) { theme.text.size / 1pt } else { 9 }
  let outer-pad = _margin-lengths(plot-bg.outset, ref-w, ref-h, _size-pt)
  let inner-inset = _margin-lengths(plot-bg.inset, ref-w, ref-h, _size-pt)
  // Inner content width the chrome (and canvas) occupy after padding both sides.
  let inner-w = (
    ref-w * 1cm
      - outer-pad.left
      - inner-inset.left
      - outer-pad.right
      - inner-inset.right
  )
  let tag = _text-style(theme, "plot-tag")
  let title = _text-style(theme, "plot-title")
  let subtitle = _text-style(theme, "plot-subtitle")
  let caption = _text-style(theme, "plot-caption")
  // Box each chrome label to the inner width so it wraps; the caller's
  // `..text-args` carries per-label `weight` / `style` overrides and wins over
  // the resolved base args from `_text-args`. `align(...)` inside the
  // definite-width box makes each label's horizontal alignment explicit, so it
  // no longer inherits the host document's ambient `set align(...)`.
  // `default-align` is the per-surface default used when the theme
  // element leaves `align` unset.
  let _chrome-block(value, style, default-align, ..text-args) = if (
    value != none and value != auto and style.size > 0pt
  ) {
    let a = if style.align != none { style.align } else { default-align }
    let args = _text-args(style)
    for (k, v) in text-args.named() { args.insert(k, v) }
    let body = text(..args)[#resolve-prose(value, eval-strings: style.typst)]
    if style.angle != none { body = rotate(style.angle, reflow: true, body) }
    box(width: inner-w, align(a, body))
  } else { none }
  let tag-block = if labs != none {
    _chrome-block(labs.tag, tag, left, weight: tag.weight)
  } else { none }
  let title-block = if labs != none {
    _chrome-block(labs.title, title, left, weight: title.weight)
  } else { none }
  let subtitle-block = if labs != none {
    _chrome-block(labs.subtitle, subtitle, left)
  } else { none }
  let caption-block = if labs != none {
    _chrome-block(labs.caption, caption, right, style: "italic")
  } else { none }

  // Multiplied by 1cm so the resolved em is baked in against the upstream
  // text style, not re-resolved against the surrounding document font size.
  let _gap-length(style, side) = {
    _text-margin-cm(style, side, 0.6em) * 1cm
  }

  // Bottom margin of the lowest header block sets the gap above the canvas.
  let above-canvas = if subtitle-block != none {
    subtitle
  } else if title-block != none {
    title
  } else if tag-block != none { tag } else { none }

  (
    plot-bg: plot-bg,
    outer-pad: outer-pad,
    inner-inset: inner-inset,
    tag-block: tag-block,
    title-block: title-block,
    subtitle-block: subtitle-block,
    caption-block: caption-block,
    tag-gap: _gap-length(tag, "bottom"),
    inter-title-gap: _gap-length(title, "bottom"),
    above-gap: if above-canvas != none {
      _gap-length(above-canvas, "bottom")
    } else { 0pt },
    caption-gap: _gap-length(caption, "top"),
  )
}

// Chrome reservation in cm for each side, measured from the `_decorate-parts`
// blocks. Subtracted from the requested dims before the canvas is sized so the
// composed stack totals back to the requested `width` x `height`.
#let _decorate-extents(parts) = {
  let _h(b) = if b == none { 0cm } else { measure(b).height }
  let top = parts.outer-pad.top + parts.inner-inset.top
  let headers = 0
  if parts.tag-block != none {
    top += _h(parts.tag-block)
    headers += 1
  }
  if parts.title-block != none {
    if headers > 0 { top += parts.tag-gap }
    top += _h(parts.title-block)
    headers += 1
  }
  if parts.subtitle-block != none {
    if headers > 0 {
      top += if parts.title-block != none { parts.inter-title-gap } else {
        parts.tag-gap
      }
    }
    top += _h(parts.subtitle-block)
    headers += 1
  }
  if headers > 0 { top += parts.above-gap }
  let bottom = parts.outer-pad.bottom + parts.inner-inset.bottom
  if parts.caption-block != none {
    bottom += parts.caption-gap + _h(parts.caption-block)
  }
  (
    top: top / 1cm,
    bottom: bottom / 1cm,
    left: (parts.outer-pad.left + parts.inner-inset.left) / 1cm,
    right: (parts.outer-pad.right + parts.inner-inset.right) / 1cm,
  )
}

#let _render-decorate(canvas, parts) = {
  let plot-bg = parts.plot-bg
  let outer-pad = parts.outer-pad
  let inner-inset = parts.inner-inset
  let _nonzero(d) = (
    d.top != 0pt or d.right != 0pt or d.bottom != 0pt or d.left != 0pt
  )
  let _wrap(content) = if (
    plot-bg.fill != none
      or plot-bg.stroke != none
      or _nonzero(inner-inset)
      or _nonzero(outer-pad)
  ) {
    pad(
      top: outer-pad.top,
      right: outer-pad.right,
      bottom: outer-pad.bottom,
      left: outer-pad.left,
      block(
        fill: plot-bg.fill,
        stroke: plot-bg.stroke,
        breakable: false,
        inset: inner-inset,
        content,
      ),
    )
  } else { content }
  let tag-block = parts.tag-block
  let title-block = parts.title-block
  let subtitle-block = parts.subtitle-block
  let caption-block = parts.caption-block

  let items = ()
  if tag-block != none { items.push(tag-block) }
  if title-block != none {
    if items.len() > 0 { items.push(v(parts.tag-gap)) }
    items.push(title-block)
  }
  if subtitle-block != none {
    if items.len() > 0 {
      items.push(v(if title-block != none { parts.inter-title-gap } else {
        parts.tag-gap
      }))
    }
    items.push(subtitle-block)
  }
  if items.len() > 0 { items.push(v(parts.above-gap)) }
  items.push(canvas)
  if caption-block != none {
    items.push(v(parts.caption-gap))
    items.push(caption-block)
  }
  if items.len() == 1 { return _wrap(canvas) }
  _wrap(block(stack(dir: ttb, spacing: 0pt, ..items)))
}
