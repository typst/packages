// ilkman — covers (docs) and title slides share this layout engine.
#import "../core.typ": *
#import "art.typ": *

#let cover-styles = ("waveform", "pcm", "packet", "bits", "gitgraph", "minimap", "neural", "solid", "topo", "halftone")

#let _is-dark(col) = {
  let (r, g, b, ..) = col.rgb().components()
  0.2126 * r / 100% + 0.7152 * g / 100% + 0.0722 * b / 100% < 0.5
}

// Default background per style: "primary" = palette primary, else white.
#let _default-bg = (solid: "primary", neural: "primary")

#let _resolve-bg(pal, style, bg, page-bg: white) = {
  let b = if bg == auto { _default-bg.at(style, default: "white") } else { bg }
  if b == "white" or b == none { return page-bg }
  if type(b) == color { return b }
  if b in ("primary", "accent", "ink", "tint", "wash") { return pal.at(b) }
  hue-tones(pal, b).strong
}

/// Draw the art for `style` into w × h.
#let draw-art(style, w, h, pal, seed, opts, c, info, dark) = {
  let o = opts.at(style, default: (:))
  if style == "waveform" { art-waveform(w, h, pal, seed, o, dark: dark) }
  else if style == "pcm" { art-pcm(w, h, pal, seed, o, dark: dark) }
  else if style == "topo" { art-topo(w, h, pal, seed, o, dark: dark) }
  else if style == "halftone" { art-halftone(w, h, pal, seed, o, dark: dark) }
  else if style == "neural" { art-neural(w, h, pal, seed, o, dark: dark) }
  else if style == "minimap" { art-minimap(w, h, pal, seed, o, dark: dark) }
  else if style == "gitgraph" { art-gitgraph(w, h, pal, seed, o, dark: dark) }
  else if style == "bits" { art-bits(w, h, pal, seed, o, title: plain(info.title), fonts: c.fonts, dark: dark) }
  else { none }
}

/// Shared cover renderer. `wide` = slide (16:9) layout.
#let render-cover(c, info, opts, page-w, page-h, wide: false) = {
  let style = opts.style
  assert(style in cover-styles, message: "ilkman: unknown cover style \"" + style + "\". Available: " + cover-styles.join(", "))
  // art and text colors always come from the light (original) palette
  let pal = light-pal(c)
  if opts.art-color != auto {
    let a = strong-color(pal, opts.art-color)
    pal.insert("primary", a)
    pal.insert("accent", a.lighten(25%))
    pal.insert("tint", a.lighten(65%))
    pal.insert("wash", a.lighten(88%))
  }
  let bg = _resolve-bg(c.pal, style, opts.bg, page-bg: c.at("page-bg", default: white))
  let dark = _is-dark(bg)
  let fg = if dark { white } else { pal.ink }
  let soft = if dark { pal.tint } else { pal.ink.lighten(35%) }
  let acc = if dark { pal.tint } else { pal.primary }
  let seed = if opts.seed == auto { seed-of(plain(info.title)) } else { seed-of(str(opts.seed)) }

  let margin = if wide { page-h * 0.09 } else { page-w * 0.1 }
  let title-size = if opts.title-size != auto { opts.title-size } else if wide { page-h * 0.075 } else { page-w * 0.062 }

  let meta = (info.author, info.date, info.version).filter(x => x != none and x != "")
  let vol = if opts.volume != none { tr(c, "volume") + " " + str(opts.volume) }
  let kicker = (opts.series, vol).filter(x => x != none)

  let text-block(show-title: true) = {
    set par(first-line-indent: 0pt, justify: false, leading: 0.45em, spacing: 0.6em)
    if kicker.len() > 0 {
      text(size: title-size * 0.36, fill: acc, weight: "bold", kicker.join(" · "))
      v(title-size * 0.15)
    }
    if show-title {
      block(text(..font-args(c.fonts, "heading"), weight: c.fonts.heading.weight, size: title-size, fill: fg, info.title))
    }
    if info.subtitle != none {
      v(title-size * 0.05)
      block(text(size: title-size * 0.48, fill: soft, info.subtitle))
    }
    if meta.len() > 0 {
      v(title-size * 0.35)
      text(size: title-size * 0.34, fill: soft, meta.map(m => if type(m) == datetime { m.display() } else { m }).join("  ·  "))
    }
  }

  let logo = if opts.logo != none {
    place(bottom + right, dx: -margin, dy: -margin * 0.6, box(height: if wide { page-h * 0.08 } else { page-w * 0.07 }, opts.logo))
  }

  let art-frac = if opts.art-height != auto { opts.art-height } else if style == "solid" { 0% } else if style == "packet" { 0% } else { 58% }
  let content = if wide {
    // slide: art on the right, text on the left
    let art-w = if style in ("solid",) { 0pt } else { page-w * 0.5 }
    let text-w = page-w - art-w - 2 * margin
    {
      if art-w > 0pt and style != "packet" {
        place(top + right, draw-art(style, art-w, page-h, pal, seed, opts, c, info, dark))
      }
      if style == "packet" {
        place(horizon + right, dx: -margin, box(width: page-w * 0.48, art-packet(page-w * 0.48, page-h * 0.6, pal, opts.at("packet", default: (:)), c, title: info.title, author: info.author, date: info.date, dark: dark)))
      }
      place(horizon + left, dx: margin, box(width: text-w * 0.95, text-block(show-title: style != "packet")))
    }
  } else {
    let art-h = page-h * art-frac
    let top-text = opts.text-pos == "top"
    {
      if style == "packet" {
        place(top + left, dx: margin, dy: margin * 1.4, art-packet(page-w - 2 * margin, page-h * 0.5, pal, opts.at("packet", default: (:)), c, title: info.title, author: info.author, date: info.date, dark: dark))
        place(bottom + left, dx: margin, dy: -margin, box(width: page-w - 2 * margin, text-block(show-title: false)))
      } else if style == "solid" {
        let rule = opts.at("solid", default: (:)).at("rule", default: false)
        place(if top-text { top + left } else { bottom + left }, dx: margin, dy: if top-text { margin * 1.5 } else { -margin * 1.2 }, box(width: page-w - 2 * margin, {
          if rule { line(length: 18%, stroke: 2pt + pal.accent); v(title-size * 0.4) }
          text-block()
        }))
      } else {
        let art-y = if top-text { page-h - art-h } else { 0pt }
        let pad = if style in ("bits", "minimap", "gitgraph", "pcm", "waveform") { margin * 0.6 } else { 0pt }
        place(top + left, dx: pad, dy: art-y + pad, draw-art(style, page-w - 2 * pad, art-h - pad * (if top-text { 1 } else { 1.4 }), pal, seed, opts, c, info, dark))
        place(if top-text { top + left } else { bottom + left }, dx: margin, dy: if top-text { margin * 1.2 } else { -margin }, box(width: page-w - 2 * margin, text-block()))
      }
    }
  }
  (bg: bg, body: { content; logo })
}

#let _cover-defaults = (
  style: "waveform", seed: auto, art-height: auto, text-pos: "bottom",
  title-size: auto, bg: auto, art-color: auto,
  series: none, volume: none, logo: none,
)

/// Merge user arguments into cover options + info.
#let cover-options(c, args) = {
  let named = args.named()
  let opts = _cover-defaults
  let info = c.info
  for (k, v) in named {
    if k in ("title", "subtitle", "author", "date", "version") {
      if v != auto { info.insert(k, v) }
    } else { opts.insert(k, v) }
  }
  if args.pos().len() > 0 { opts.insert("style", args.pos().first()) }
  (opts: opts, info: info)
}

/// Book cover (full page, no margins).
///
/// ```typst
/// #im-cover(style: "neural", subtitle: [Protokolden üretime],
///   neural: (layers: (8, 12, 12, 4)))
/// ```
///
/// Styles: waveform, pcm, packet, bits, gitgraph, minimap, neural, solid, topo, halftone.
/// Common options: seed, art-height, text-pos ("bottom"/"top"), title-size,
/// bg, art-color, series, volume, logo, title, subtitle, author, date, version.
/// Style options go in a dictionary named after the style, e.g. `waveform: (bars: 60)`.
#let im-cover(..args) = context {
  let c = ctx()
  let r = cover-options(c, args)
  let pw = page.width
  let ph = page.height
  let out = render-cover(c, r.info, r.opts, pw, ph)
  page(margin: 0pt, header: none, footer: none, fill: out.bg, numbering: none, out.body)
}
