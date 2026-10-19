#import "context.typ": component-wrapper
#import "markers.typ": apply-marker-style
#import "alerts.typ": apply-alert-style
#import "text.typ": apply-tone-style
#import "block-styles.typ": get-block-style, block-style-names
#import "../palettes.typ": contrast, on-color
#import "../vendor/shadowed.typ": frame, shadow
#import "watermark.typ": watermark-mark

#let block-kinds = ("accent", "info", "success", "warning", "danger", "neutral")

// Bodies remain positional so Touying can inspect nested pauses and modifiers.
#let render-ambrosia-block(self: none, title: none, style: auto, kind: "accent", fill: auto,
  background: auto, text-fill: auto, title-fill: auto, shadowed: auto,
  radius: 0.3em, inset: 0.5em, stroke: auto, width: 100%, gap: 0.45em, it,
  watermark: false,
) = layout(size => context {
  let style = if style == auto { self.store.at("block-style", default: "plain") } else { style }
  let definition = get-block-style(style)
  // A vertical stripe meets the panel edge squarely, including its shadow.
  let radius = if style == "stripe" {
    if type(radius) == dictionary { radius + (top-left: 0em, bottom-left: 0em) }
    else { (left: 0em, right: radius) }
  } else { radius }
  let watermark = if watermark == true { "body" } else { watermark }
  assert(watermark in (false, "body", "title"), message: "Block watermark must be false, true, body, or title.")
  assert(kind in block-kinds, message: "Unknown block kind: " + str(kind) + ". Choose: " + block-kinds.join(", ") + ".")
  let accent = if fill != auto { fill } else if kind == "accent" { self.colors.primary-dark } else { self.colors.at(kind) }
  let background = if background != auto { background } else {
    if definition.background == "none" { none }
    else if definition.background == "alternate" { self.colors.surface-alt }
    else if definition.background == "tinted" and not self.store.dark { accent.lighten(90%) }
    else { self.colors.surface }
  }
  let foreground = if text-fill != auto { text-fill }
    else if type(background) == color and contrast(self.colors.foreground, background) < 4.5 { on-color(background) }
    else { self.colors.foreground }
  let title-color = if title-fill != auto { title-fill }
    else if definition.header in ("joined", "detached", "tabbed") { on-color(accent) }
    else if definition.header == "ruled" { foreground }
    else { accent }
  let stroke = if stroke != auto { stroke } else {
    if definition.border == "none" { none }
    else if definition.border == "accent" { 0.07em + accent }
    else if definition.border == "stripe" { (left: 0.18em + accent, rest: none) }
    else { 0.04em + self.colors.border }
  }
  let shadowed = if shadowed != auto { shadowed } else if definition.shadow != auto { definition.shadow }
    else { self.store.at("block-shadow", default: true) }

  set text(fill: foreground)
  show: apply-marker-style.with(color: accent)
  show: apply-alert-style.with(color: accent)

  let header() = {
    show heading: set text(fill: title-color)
    text(fill: title-color, weight: "bold", title)
  }
  let border-thickness(value) = {
    if value == none { 0pt }
    else if type(value) == dictionary { calc.max(0pt, ..value.values().map(border-thickness)) }
    else if type(value) == length { value }
    else if type(value) == std.stroke { if value.thickness == auto { 1pt } else { value.thickness } }
    else { 1pt }
  }
  let cast-shadow(body, fill: background, radius: radius, stroke: stroke, enabled: shadowed) = {
    if not enabled { return body }
    let hollow = if fill == none { border-thickness(stroke) } else { none }
    // A completely transparent, borderless region has no silhouette to shadow.
    if hollow == 0pt { return body }
    shadow(body, blur: 0.4em, dx: 0.15em, dy: 0.15em,
      fill: self.colors.chrome.transparentize(60%), radius: radius, hollow: hollow)
  }
  let panel(body, fill: background, radius: radius, stroke: stroke, region: "body", inset: inset, shaded: shadowed) = {
    // Resolve text emphasis against this panel rather than the slide's page.
    let body = {
      show: apply-tone-style.with(muted: self.colors.muted,
        background: if fill == none { page.fill } else { fill })
      body
    }
    let content = if watermark != region or self.store.at("watermark-logo", default: none) == none {
      block(width: 100%, breakable: false, fill: fill, radius: radius, inset: inset, stroke: stroke, body)
    } else {
      let mark = watermark-mark(self, if fill == none { self.page.fill } else { fill },
        if region == "title" { 1.8em } else { 4em }, opacity: 7%)
      let dimensions = measure(mark)
      block(width: 100%, breakable: false, fill: fill, radius: radius, stroke: stroke, inset: inset, clip: true, {
        place(bottom + right, dx: dimensions.width * 25%, dy: dimensions.height * 20%, mark)
        body
      })
    }
    cast-shadow(content, fill: fill, radius: radius, stroke: stroke, enabled: shaded)
  }
  let title-panel(radius, stroke: stroke, shaded: shadowed) = {
    panel(header(), fill: accent, radius: radius, stroke: stroke, region: "title",
      inset: (x: inset, y: 0.35em), shaded: shaded)
  }
  let content = if title == none {
    panel(it)
  } else if definition.header == "joined" {
    let joined = grid(columns: 1, row-gutter: 0em,
      title-panel((top: radius), stroke: none, shaded: background == none and shadowed),
      rect(width: 100%, height: 0.2em, stroke: none,
        fill: if type(background) == color { gradient.linear(accent, background, angle: 90deg) } else { background }),
      panel(it, radius: (bottom: radius), stroke: none, shaded: false),
    )
    cast-shadow(frame(joined, radius: radius, stroke: stroke))
  } else if definition.header == "detached" {
    grid(columns: 1, row-gutter: gap,
      title-panel(radius),
      panel(it),
    )
  } else if definition.header == "tabbed" {
    // Reserve half the tab above the panel, and the other half inside it.
    // Measuring only its heading avoids replaying the live block body.
    layout(bounds => {
      let tab = box(fill: accent, radius: radius, stroke: 0.04em + accent,
        inset: (x: 0.8em, y: 0.3em), clip: true, {
          if watermark == "title" and self.store.at("watermark-logo", default: none) != none {
            place(bottom + right, watermark-mark(self, accent, 1.8em, opacity: 7%))
          }
          header()
        })
      let dimensions = measure(tab, width: calc.max((1em).to-absolute(), bounds.width - (2 * inset).to-absolute()))
      block(width: 100%, breakable: false, {
        [#metadata((width: dimensions.width.pt(), height: dimensions.height.pt(), available: bounds.width.pt()))<ambrosia-block-tab>]
        pad(top: dimensions.height / 2, panel({
          v(dimensions.height / 2 + gap)
          it
        }))
        place(top + center, cast-shadow(
          box(width: dimensions.width, height: dimensions.height, tab),
          fill: accent, stroke: 0.04em + accent))
      })
    })
  } else {
    panel(grid(columns: 1, row-gutter: gap,
      if watermark == "title" {
        // A quiet header has no separate fill; stamp it on its actual body surface.
        panel(header(), fill: none, radius: 0em, stroke: none, region: "title", inset: 0em)
      } else { header() },
      ..if definition.header == "ruled" { (line(length: 100%, stroke: 0.06em + accent),) } else { () },
      it,
    ))
  }
  block(width: width, breakable: false, content)
})

/// A nonbreaking content container. Style selects geometry; kind selects meaning.
/// Positional content keeps nested Touying pauses visible to the slide parser.
/// -> content
#let ambrosia-block(
  /// Optional heading; omitted titles reclaim their region.
  /// -> content | none
  title: none,
  /// Theme default, or plain, framed, poster, outlined, stripe, or tabbed.
  /// -> auto | str
  style: auto,
  /// Accent, info, success, warning, danger, or neutral.
  /// -> str
  kind: "accent",
  /// Accent override for borders and title regions.
  /// -> auto | color
  fill: auto,
  /// Body surface override; none makes it transparent.
  /// -> auto | color | gradient | none
  background: auto,
  /// Body ink; auto chooses contrast on solid surfaces.
  /// -> auto | color | gradient
  text-fill: auto,
  /// Heading ink; auto follows the selected style.
  /// -> auto | color | gradient
  title-fill: auto,
  /// Follow the style/theme, or explicitly enable/disable its shadow.
  /// -> auto | bool
  shadowed: auto,
  /// Corner radius; stripe keeps its left corners square.
  /// -> length
  radius: 0.3em,
  /// Internal padding.
  /// -> length
  inset: 0.5em,
  /// Native border override, including a side dictionary.
  /// -> auto | stroke | color | length | dictionary | none
  stroke: auto,
  /// Width relative to the available region.
  /// -> length | ratio | relative
  width: 100%,
  /// Space between the title and body regions.
  /// -> length
  gap: 0.45em,
  /// Positional block body, including nested content and pauses.
  /// -> content
  it,
  /// False hides it; true/body or title chooses the watermark region.
  /// -> bool | str
  watermark: false,
) = {
  if style != auto { let _ = get-block-style(style) }
  assert(kind in block-kinds, message: "Unknown block kind: " + str(kind) + ".")
  component-wrapper(render-ambrosia-block.with(title: title, style: style, kind: kind, fill: fill,
    background: background, text-fill: text-fill, title-fill: title-fill, shadowed: shadowed,
    radius: radius, inset: inset, stroke: stroke, width: width, gap: gap,
    watermark: watermark,
  ), it)
}
