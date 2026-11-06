#import "../touying.typ": *
#import "../utils.typ" as ambrosia-utils
#import "render.typ": touying-slide
#import "watermark.typ": with-watermark
#import "../components/branding.typ": primary-logos, render-primary-logos
#import "../components/image-caption.typ": render-image-caption

/// Counted section divider; also usable as new-section-slide-fn.
#let section-slide(title: auto, subtitle: none, logo: true, watermark: auto, config: (:), ..bodies) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(self, config-store(navigation: none, section-progress: false), config-page(header: none, margin: (top: 1em, bottom: 1.4em, x: 2.5em)), config)
  self.store.title = none
  self.store.subtitle = none
  self = with-watermark(self, "section", enabled: watermark)
  let title = if title != auto { title } else {
    ambrosia-utils.display-current-heading(level: 1, depth: 1, selector-filter: ambrosia-utils.appendix-filter)
  }
  touying-slide(self: self, setting: body => {
    set std.align(center + horizon)
    if logo and primary-logos(self).len() > 0 {
      let logo-self = self
      logo-self.store.logo-background = self.page.fill
      context render-primary-logos(logo-self, 1.8em, page.width * 60%, alignment: center, kind: "section")
      v(0.75em)
    }
    text(size: 1.8em, weight: "bold", fill: self.colors.primary, title)
    if subtitle != none {
      v(0.5em)
      text(size: 1em, fill: self.colors.foreground, subtitle)
    }
    if body != none and body != [] {
      parbreak()
      v(0.5em)
      body
    }
  }, ..bodies)
})

/// Full-page image. Native alignments place a band or an inset caption card.
/// Forward image arguments unchanged to retain caller-relative paths and alt text.
/// -> content
#let image-slide(
  /// Caption content; omit it for a credit-only overlay.
  /// -> content | none
  caption: none,
  /// Image credit, optionally containing a native link.
  /// -> content | none
  credit: none,
  /// Native placement, such as `top` or `bottom + right`. Unspecified axes use left/bottom.
  /// -> alignment
  caption-position: bottom,
  /// Width relative to the region remaining after the outer margin.
  /// -> length | ratio | relative
  caption-width: 100%,
  /// Outer inset: a length/percentage or native inset dictionary.
  /// -> length | ratio | relative | dictionary
  caption-margin: 0em,
  /// Panel fill. Auto uses translucent chrome; none removes the panel.
  /// -> auto | color | gradient | none
  caption-fill: auto,
  /// Text and link fill. Auto follows chrome, or contrasts with an explicit solid panel.
  /// -> auto | color | gradient
  caption-text-fill: auto,
  /// Native image fit; use "contain" to retain the complete image.
  /// -> str
  fit: "cover",
  /// Per-slide Touying configuration.
  /// -> dictionary
  config: (:),
  /// Native image arguments, including its source, alt text and scaling controls.
  /// -> arguments
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(self, config-store(navigation: none, section-progress: false, navigation-buttons: false), config-page(margin: 0em, header: none, footer: none), config)
  touying-slide(self: self, block(width: 100%, height: 100%, breakable: false, clip: true,
    layout(bounds => context {
      [#metadata((width: bounds.width.pt(), height: bounds.height.pt()))<ambrosia-image-region>]
      place(top + left, image(..args, width: 100%, height: 100%, fit: fit))
      if caption != none or credit != none {
        render-image-caption(self, caption, credit, position: caption-position,
          width: caption-width, margin: caption-margin, fill: caption-fill, text-fill: caption-text-fill)
      }
    })))
})
